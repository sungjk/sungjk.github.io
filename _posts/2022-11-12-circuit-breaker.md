---
layout: entry
title: Circuit Breaker
author: 김성중
author-email: ajax0615@gmail.com
description: 서비스간 장애 전파를 방지하기 위한 패턴인 Circuit Breaker에 대해서 알아봅니다.
keywords: Circuit Breaker
publish: true
---

네트워크를 통해서 다른 시스템에서 실행 중인 소프트웨어를 원격으로 호출하는건 일반적인 패턴이다. 메모리 내에서 하는 호출과 원격 호출의 가장 큰 차이점 중 하나는, 원격 호출은 실패하거나 정해진 타임아웃 시간에 도달할 때까지 응답 없이 중단될 수 있다는 것이다. 더 최악인건, 응답이 없는 공급자(Supplier)에 많은 호출자가 있는 경우, 중요한 리소스가 부족해서 여러 시스템에 걸쳐 연속적인 에러가 발생할 수 있다는 것이다. Michael Nygard는 [Release It](https://www.amazon.com/gp/product/0978739213/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0978739213&linkCode=as2&tag=martinfowlerc-20)에서 이런 종류의 치명적인 Cascade를 방지하기 위해 Circuit Breaker 패턴을 대중화했다.

Circuit Breaker의 기본 아이디어는 매우 간단하다. 에러를 모니터링하는 circuit breaker 객체에서 호출할 대상(Supplier)으로의 함수 호출을 랩핑한다. 실패 횟수가 특정 임계치에 도달하면 circuit breaker가 작동하고, circuit breaker에 대한 클라이언트(Client)의 모든 호출은 공급자(Supplier)로 이어지지 않고 에러와 함께 반환된다. 일반적으로 circuit breaker가 트립되면 모니터링 Alert도 필요하다.

![circuit-breaker](/images/2022/11/12/circuit-breaker.png "circuit-breaker"){: .center-image }

다음은 타임아웃으로부터 보호하는 Ruby 예시이다. 보호된 호출인 블록(Lambda)으로 Circuit Breaker를 설정합니다.

```ruby
cb = CircuitBreaker.new {|arg| @supplier.func arg}
```

Circuit Breaker는 블록을 저장하고 다양한 매개변수(임계값, 타임아웃 및 모니터링용)를 초기화하고 Circuit Breaker를 닫힌(closed) 상태로 재설정한다.

```ruby
class CircuitBreaker...
  attr_accessor :invocation_timeout, :failure_threshold, :monitor
  def initialize &block
    @circuit = block
    @invocation_timeout = 0.01
    @failure_threshold = 5
    @monitor = acquire_monitor
    reset
  end
```

Circuit Breaker를 호출했을때 회로가 닫혀 있으면 기본 블록을 호출하고 열려 있으면 에러를 리턴한다.

```ruby
# client code
    aCircuitBreaker.call(5)

class CircuitBreaker...
  def call args
    case state
    when :closed
      begin
        do_call args
      rescue Timeout::Error
        record_failure
        raise $!
      end
    when :open then raise CircuitBreaker::Open
    else raise "Unreachable Code"
    end
  end
  def do_call args
    result = Timeout::timeout(@invocation_timeout) do
      @circuit.call args
    end
    reset
    return result
  end
```

타임아웃이 발생하면 실패 카운터를 증가시키고, 호출에 성공하면 다시 0으로 재설정한다.

```ruby
class CircuitBreaker...
  def record_failure
    @failure_count += 1
    @monitor.alert(:open_circuit) if :open == state
  end
  def reset
    @failure_count = 0
    @monitor.alert :reset_circuit
  end
```

실패한 횟수와 임계값(threshold)을 비교해서 Circuit Breaker의 상태를 확인한다.

```ruby
class CircuitBreaker...
  def state
     (@failure_count >= @failure_threshold) ? :open : :closed
  end
```

이 간단한 Circuit Breaker는 회로가 열려 있을 때 함수 호출이 생기는걸 막아주지만, 상황이 다시 좋아졌을때 설정을 다시 초기화하려면 외부 개입이 필요하다. 이건 건물의 전기 회로 차단기(electrical circuit breakers)에 대한 접근 방식이고, 소프트웨어 회로 차단기(software circuit breakers)의 경우 기본 호출이 다시 작동하는지 차단기 자체에서 감지하도록 할 수 있다. 적당한 간격을 두고 함수 호출을 다시 해서 성공하면 설정을 업데이트해서 자체 리셋(self-resetting)을 구현할 수 있다.

![circuit-breaker-state](/images/2022/11/12/circuit-breaker-state.png "circuit-breaker-state"){: .center-image }

이런 종류의 Circuit Breaker를 생성한다는건 재설정을 시도하기 위해 임계값을 추가하고 마지막 에러 시간을 유지하도록 변수를 설정하는 것을 의미한다. 

```ruby
class ResetCircuitBreaker...
  def initialize &block
    @circuit = block
    @invocation_timeout = 0.01
    @failure_threshold = 5
    @monitor = BreakerMonitor.new
    @reset_timeout = 0.1
    reset
  end
  def reset
    @failure_count = 0
    @last_failure_time = nil
    @monitor.alert :reset_circuit
  end
```

그리고 열림(Open), 닫힘(Closed)을 제외한 반쯤 열린 상태(Half Open)가 있다. 이건 Circuit Breaker에 문제가 수정되었는지 확인하기 위해 실제 호출을 할 준비가 되었음을 나타낸다.

```ruby
class ResetCircuitBreaker...
  def state
    case
    when (@failure_count >= @failure_threshold) && 
        (Time.now - @last_failure_time) > @reset_timeout
      :half_open
    when (@failure_count >= @failure_threshold)
      :open
    else
      :closed
    end
  end

```

반개방 상태(Half Open)에서 함수 호출 시도를 요청해서 성공하면 Circuit Breaker를 재설정하고, 그렇지 않으면 타임아웃을 다시 시작한다.

```ruby
class ResetCircuitBreaker...
  def call args
    case state
    when :closed, :half_open
      begin
        do_call args
      rescue Timeout::Error
        record_failure
        raise $!
      end
    when :open
      raise CircuitBreaker::Open
    else
      raise "Unreachable"
    end
  end
  def record_failure
    @failure_count += 1
    @last_failure_time = Time.now
    @monitor.alert(:open_circuit) if :open == state
  end
```

이 예시는 간단한 설명이다. 실제로 Circuit Breaker는 더 많은 기능과 매개변수화를 제공한다. 종종 네트워크 연결 실패와 같이 함수 호출을 막아줘야 할 다양한 에러로부터 보호해주는 역할을 한다. 모든 에러가 Circuit Breaker를 작동시켜야 하는 것은 아니며, 일부 에러는 정상적인 에러를 반영하고 일반적인 로직으로 처리될 수도 있다.

트래픽이 많으면 초기 타임아웃을 기다리는 많은 호출에 문제가 발생할 수 있다. 원격 호출(Remote Call)은 종종 느리기 때문에 각 호출을 다른 스레드에 두거나, [Future나 Promise](https://en.wikipedia.org/wiki/Futures_and_promises)를 이용해서 응답이 돌아왔을 때 결과를 처리하는 것도 좋은 방법이다. 스레드풀에서 이런 스레드를 가져와서, 스레드풀이 소진될 때 Circuit Breaker가 중단되도록 할 수도 있다.

호출을 성공했을때 카운트를 리셋하는건 Circuit Breaker를 다루는 간단한 방법이다. 보다 정교한 방법은 에러 빈도를 살펴보고, 실패율이 50%에 도달하면 Circuit Breaker를 작동시키는 것이다. 타임아웃의 임계값은 10이지만, 연결 실패의 임계값은 3으로 설정하는 것처럼 에러마다 다른 임계값을 설정할 수도 있다.

이 예시는 동기식 호출(synchronous)을 위한 Circuit Breaker인데, Circuit Breaker는 비동기 통신(asynchronous)에도 유용하다. 일반적인 방법은 모든 요청을 공급자(Supplier)가 빠른 속도로 소비하는 대기열에 추가하는 것이다. 이는 서버 과부하를 방지하기 위한 기술이기도 하다. 이 경우 대기열이 가득차면 Circuit Breaker가 중단된다.

Circuit Breaker는 실패할 가능성이 있는 작업에 묶여 있는 리소스를 줄이는 데에도 도움이 된다. 클라이언트에 대한 타임아웃 대기를 피하고 서킷이 끊어지면 문제가 있는 서버에 부하가 걸리는 것을 방지할 수도 있다. 여기서는 Circuit Breaker의 일반적인 케이스인 원격 호출(Remote Call)에 대해서 이야기했지만, 시스템의 일부를 다른 부분의 에러로부터 보호하려는 모든 상황에서 사용할 수 있다.

Circuit Breaker는 모니터링에도 가치가 있다. 서킷의 상태 변경 사항은 모두 기록되어야 하며, Circuit Breaker는 모니터링을 위한 상태 세부 정보도 공개해야 한다. 종종 발생할 수 있는 문제에 대한 경고 메시지로 사용할 수도 있고, 운영자는 Circuit Breaker를 작동시키거나 재설정할 수도 있어야 한다.

Circuit Breaker 자체는 가치가 있지만 Circuit Breaker를 사용하는 클라이언트는 Circuit Breaker 에러에 대응해야 한다. 모든 원격 호출과 마찬가지로, 실패시 수행할 작업을 고려해야 한다. 수행중인 작업을 실패처리 하면 되나? 아니면 수행할 수 있는 다른 해결 방법이 있나? 신용 카드 승인은 나중에 처리하기 위해 대기열에 추가할 수도 있다. 일부 데이터를 가져오는데 실패하면 표시하기에 충분한 오래된 데이터를 표시해서 완화할 수도 있다.

---

# Resilience4j - CircuitBreaker
JVM 애플리케이션에서 fault tolerance library로 많이 사용되는 Resilience4j도 CircuitBreaker 기능을 지원한다. Resilience4j의 CircuitBreaker는 CLOSED, OPEN 및 HALF_OPEN의 세 가지 정상 상태와 DISABLED 및 FORCED_OPEN 두 가지 특수한 상태가 있는 유한 상태 머신(finite state machine)으로 구현되었다.

![resilience4j-circuit-breaker-state](/images/2022/11/12/resilience4j-circuit-breaker-state.png "resilience4j-circuit-breaker-state"){: .center-image }

기능을 사용하기 위해 관련된 설정들을 찾다보면 서로 사용하는 방식이 많이 다른데다가, 실제로 적용할 백엔드 서비스의 유형에 따라 설정에 포함시켜야 할 속성이나 값이 크게 달라질 수 있다. 어떤 설정이 있나 찾아보니 현재 대부분 Sliding Window(Count-based, Time-based) 방식을 사용하나, 과거에는 Ring Buffer 방식으로도 사용한 점이 보여서 좀 더 알아보았다.

### Sliding Window
[Sliding Window](https://www.geeksforgeeks.org/window-sliding-technique/)은 네트워크에서 패킷을 전송하는 방식 중 하나인데 그냥 알고리즘 중 하나다. CircuitBreaker는 Sliding Window를 사용해서 호출 결과를 저장하고 집계하는데, 호출수를 기반으로한 방식(count-based sliding window)과 시간 기반으로 하는 방식(time-based sliding window) 중에 선택할 수 있다. 카운트 기반으로한 방식은 마지막 N개의 호출 결과를 집계하고, 시간 기반으로 한 방식은 마지막 N초의 호출 결과를 집계한다.

**Count-based sliding window**<br/>
카운트 기반 방식은 내부적으로 N개의 호출을 기록할 수 있도록 원형 배열을 사용한다. window size가 10이면 원형 배열에는 항상 10개의 측정값이 있다. sliding window는 총 집계를 점진적으로 업데이트한다. 새 호출 결과가 기록되면 총 집계가 업데이트된다. 가장 오래된 내용이 제거되면 총 집계에서 차감되고 버킷이 리셋된다(Subtract-on-Evict). 스냅샷을 검색하는 시간은 상수값인 O(1)인데, 스냅샷을 조회하는 시점에 이미 계산되어 있고 window size와 상관없기 때문이다. 이 구현은 메모리 소비면에서도 O(n)이어야 한다.

**Time-based sliding window**<br/>
시간 기반으로 한 방식은 N 부분 집계(버킷)의 원형 배열로 구현된다. window size가 10초인 경우 원형 배열에는 항상 10개의 버킷이 있다. 각 버킷은 특정 시간(epoch second)에 발생한 모든 호출 결과를 집계한다(Partial aggregation). 원형 배열의 헤드 버킷은 현재 시간(current epoch second)에 발생한 호출 결과를 저장한다. 다른 버킷은 이전 초의 호출 결과를 저장한다. 총 집계는 새로운 호출 결과가 기록될 때 점진적으로 업데이트된다. 가장 오래된 버킷이 제거되면 해당 버킷의 부분 총 집계(Partial total aggregation)가 전체 집계에서 차감되고 버킷이 리셋된다(Subtract-on-Evict). 부분 집계(Partial aggragation)는 실패한 호출 수, 느린 호출 수, 총 호출 수를 계산하기 위한 3개의 Integer 값과 모든 호출의 기간(duration)을 저장하는 long 값으로 구성된다.

### Ring Buffer(~v0.17.0)
CLOSED 상태에서 Ring Bit Buffer를 사용해서 함수 호출의 성공과 실패 상태를 저장한다. 성공한 건 0 bit로 저장되고 실패한 건 1 bit로 저장된다. 그리고 고정된 사이즈의 Buffer 크기를 설정할 수 있다. 내부적으로 BitSet과 유사한 자료 구조를 사용해서 Boolean Array에 비해 메모리도 적게 사용된다. BitSet은 Long[] Array를 사용해서 비트를 저장한다. 이 말은 즉, BitSet은 1024 호출의 상태를 저장하기 위해 16개의 긴(64bit) 값 배열만 있으면 된다는 뜻이다.

다음은 버퍼 사이즈가 12인 Ring Buffer 다이어그램이다.

![ring-buffer](/images/2022/11/12/ring-buffer.png "ring-buffer"){: .center-image }

Ring Bit Buffer가 가득 차있어야 실패율을 계산할 수 있다. 예를 들어, Ring Buffer 사이즈가 10이면 실패율을 계산하기 전에 최소 10개의 호출이 있어야 한다. 9개의 호출만 있는 경우, 9개의 호출이 모두 실패하더라도 CircuitBreaker는 열리지 않는다.

실패율이 설정해 둔 임계치를 초과하면 CircuitBreaker의 상태가 CLOSED에서 OPEN으로 전환된다. 이 다음부터는 일정 시간동안 호출되는 요청이 차단되는데, 이 때 차단된 요청에 대해 CallNotPermittedException을 발생시킨다.

일정 시간이 경과한 후 CircuitBreaker 상태는 OPEN에서 HALF_OPEN으로 전환되는데, 이 때 미리 설정해놓은 수만큼의 호출을 허용해서 백엔드를 여전히 사용할 수 없는지 또는 다시 사용할 수 있게 되었는지 확인한다. 그리고 다른 Ring Bit Buffer를 사용하여 HALF_OPEN 상태에서 실패율을 평가한다. 실패율이 설정해놓은 임계치를 초과하면 상태가 OPEN으로 다시 변경된다. 실패율이 임계치 이하면 상태가 다시 CLOSED로 전환된다.

---

### 참고
- [Circuit Breaker](https://martinfowler.com/bliki/CircuitBreaker.html)
- [DependencyCommand](https://netflixtechblog.com/fault-tolerance-in-a-high-volume-distributed-system-91ab4faae74a)
- [Resilience4j(v2.0.0)](https://resilience4j.readme.io/docs/circuitbreaker#create-and-configure-a-circuitbreaker)
- [Resilience4j(v0.17.0)](https://resilience4j.readme.io/v0.17.0/docs/circuitbreaker)
