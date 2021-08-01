---
layout: entry
title: 코루틴(Coroutine)
author: 김성중
author-email: ajax0615@gmail.com
description: 코루틴 알아보기
keywords: 코루틴, coroutine
publish: true
---

비동기(Asynchronous), 논블로킹(Non-blocking) 프로그래밍은 자원을 효율적으로 활용하기 위해 중요하게 고려해야 할 부분이다. 그리고 코틀린은 언어 수준에서 코루틴(Coroutine)을 제공함으로써 이 문제를 유연하게 해결하고 있다. 단순히 코틀린에서 제공하는 코루틴의 개념과 사용법만을 소개하기보다는 컴퓨터 프로그램의 요소로서의 코루틴, 즉 흐름 제어(control flow)를 위한 기초적인 부분부터 알아봐야겠다는 생각에 이 글을 정리하게 되었다.

---

# 코루틴(Coroutine)

![coroutine](/images/2021/08/01/coroutine.png "coroutine"){: .center-image }

[위키피디아]([https://en.wikipedia.org/wiki/Coroutine](https://en.wikipedia.org/wiki/Coroutine))에 코루틴은 아래과 같이 정의되어 있다.

> 1 Coroutines are computer program components that generalize subroutines for non-preemptive multitasking, by allowing execution to be suspended and resumed.<br/>
> 2 Coroutines are well-suited for implementing familiar program components such as cooperative tasks, exceptions, event loops, iterators, infinite lists and pipes.

- 첫째. **코루틴은 실행을 일시중단(suspend)하고 재개(resume)할 수 있도록 하여 비선점형 멀티태스킹(non-preemptive multitasking)을 위한 서브루틴을 일반화하는 컴퓨터 프로그램 구성 요소이다.**
- 둘째. 코루틴은 협력 작업(Cooperative task), 예외, 이벤트 루프, 반복자, 무한 목록 및 파이프와 같은 프로그램 구성 요소를 구현하는데 적합하다.

프로그램 구성 요소를 만들기 위해 적합하다는 두 번째 정의는 뭐 대충이라도 이해가 간다. 그런데 첫 번째 설명이 핵심인 것 같은데, "일시 중단하고 재개한다. 비선점형 멀티태스킹을 위한 서브루틴을 일반화한다." 는 말이 이해가 잘 안 됐다. 정확히는 일시 중단하고 재개하는 것이 어떻게 구현되어 있는지 동작 원리가 궁금했고, 서브루틴을 일반화한다 말이 이해가 안 됐다. 이 문장들이 의미하는 바를 분석해보면서 코루틴이 뭔지 알아보겠다.

### 서브루틴(Subroutine)
[위키피디아]([https://en.wikipedia.org/wiki/Subroutine](https://en.wikipedia.org/wiki/Subroutine))에 있는 설명에 따르면 서브루틴은 함수, 메서드 또는 프로시저 등을 의미하는 일반적이고 포괄적인 용어이다. 함수, 메서드 또는 프로시저 각각이 의미하는 바와 정의는 모두 다르지만, 이들을 하나로 표현할 수 있는 용어 정도로 생각하면 된다. 그래서 서브루틴은 우리가 흔히 아는 함수의 특징인, 일반적으로 함수는 하나의 진입점(input)을 통해 실행되고 하나의 종료 지점(return)을 통해 끝난다.

### 비선점형 멀티태스킹(Non-preemtive multitasking)
하나의 프로세스 안에서 여러 스레드가 실행되면 이 스레드들은 CPU와 메모리라는 한정적인 자원을 서로 사용하려고 경쟁하게 된다. 운영체제는 하나의 스레드가 자원을 무한정 점유하는 문제를 막기 위해 스케쥴링을 하는데, 이 스케쥴링 방식에 선점형(Preemptive)과 비선점형(Non-preemptive) 방식 2가지가 존재한다. 선점형은 강제로 실행권을 빼앗기는 것이고, 비선점형은 실행 주체가 자신의 실행권을 자발적으로 내려 놓는것을 의미한다.

### 일시 중단과 재개(suspend & resume)
위에서 이야기한 비선점형 멀티태스킹이 자신의 실행권을 자발적으로 내려놓는다는 것을 의미한다는 관점에서 생각해보면 실행을 일시중단하고 재개하는 것이 어떤 의미인지 처음보다는 조금 더 다가온다. 실행권을 내려놓겠다는 신호를 줘야 하는데, 대개 많은 언어에서 async/await, yield, suspend 같은 키워드를 사용하고 있다. yield와 같은 키워드를 만나면 실행권을 내려놓으면서 그 위치를 기억하고, 다음 호출 때 그곳부터 다음을 실행할 수 있도록 하는 것이다. Python 이나 Javascript 에 있는 Generator 에 대해서 이해하고 있다면 더 이해하기 쉬울 것이다.

![FunctionsVersusCoroutines](/images/2021/08/01/FunctionsVersusCoroutines.png "FunctionsVersusCoroutines"){: .center-image }
<center>c++ 20에 추가된 coroutine</center>

### 그래서 코루틴이란,
우리가 코드를 작성할 때 **프로그램의 흐름을 제어하기 위해 사용하는 조건문(if-else), 반복문(for, while), 예외처리문(try-catch-finally), 함수 등과 같은 control flow 요소 중 하나**이다. 함수 호출과 종료를 call과 return으로 표현하는 것처럼, 코루틴의 일시중단과 재개에 suspend와 resume을 표현하는 것 뿐이다. 여러 개의 코루틴을 동작시키고 각각 다른 곳에서 일시중단 된다면 여러 스레드가 동시에 동작하는 것과 같은 효과를 가지게 된다.

---

# 스레드와의 차이점
> Coroutines can be thought of as light-weight threads.

[코틀린 공식 문서](https://kotlinlang.org/docs/coroutines-basics.html)에 보면 코루틴에 대해서 light-weight thread 라고 설명하고 있다. 동시에 여러 코드 블록을 실행한다는 개념적인 관점에서 보면 스레드와 매우 유사해 보인다. 그러나 코루틴은 협력적으로 멀티태스팅(Cooperative multitasking)되는 반면에, 일반적으로 스레드는 선점형으로 멀티태스킹(Preemptively multitasking)된다. 여기서 협력적이라는 말은 위에서 살펴본 비선점형 멀티태스킹(Non-preemptive multitasking)과 같은 의미다.

일반적으로 멀티스레드 환경에서 CPU가 Task 여러 개를 바꿔가며 실행하려면 Context Switching이 필요한데, 현재 PCB 정보를 저장하고 다음 PCB 정보를 읽어서 Register에 적재하는 등 비용이 발생한다. 하지만 코루틴은 코루틴 간 전환을 위해 Context Switching을 포함한 시스템 호출이나 blocking 호출이 필요하지 않다. 마찬가지로 멀티스레드 환경에서 동기화를 위해 사용하는 mutex, semaphore 도 필요 없다.


### Stackful vs. Stackless

각 언어별로 코루틴을 구현할 때 코루틴 내에 자체 스택 프레임을 포함한 경우도 있고, 그렇지 않은 경우도 있다.

Lua와 같은 언어에서는 코루틴에서 다른 함수를 호출하여 그 함수에서 코루틴의 실행을 중단할 수 있다. 당연한 이야기 같지만, 이게 가능해지려면 코루틴 안에 자체적으로 스택 프레임을 가지고 있어야 한다.

하지만 C++, C#, Javascript, Python, Kotlin 과 같은 언어에서는 불가능한 일이다.

```javascript
function* createGenerator() {
    console.log(yield "Coroutine");
    [1, 2, 3].forEach(it => {
        console.log(yield it); // error
    });
}
```

코루틴 내에 스택을 가지고 있지 않아서 코루틴에서 하위 서브루틴의 실행을 중단시킬 수 없다. 코루틴 컨텍스트는 코루틴 중첩 호출을 통해서만 전달할 수 있기 때문에 위의 forEach 같은 함수들이 코루틴 용도로 재정의되어야 문제없이 사용할 수 있다.

이런 단점도 있는 반면에, Stackless의 경우 코루틴 내에 스택을 할당할 필요가 없기 때문에 훨씬 더 적은 메모리만으로도 사용이 가능하다.

---

# 동시성 관점에서의 코루틴

동시성(Concurrency)이란 운영체제의 시분할(time-share)에 의해서 달성된다. 스레드는 CPU 코어에서 할당된 시간 프레임 안에서 일을 처리하는데, OS에 의해 선점(preempted)될 수도 있고 제어권을 양도할 수도 있다. 반면에, 코루틴은 OS가 아닌 스레드 내에서 다른 코루틴에 제어를 건네준다. 따라서 스레드 내의 모든 코루틴은 OS에서 관리하는 다른 스레드에 CPU 코어를 양보하지 않고 해당 스레드의 시간 프레임을 계속 이용할 수 있다. 즉, 코루틴은 OS가 아닌 사용자에 의해 시분할을 달성한다고 생각하면 된다. 코루틴은 해당 코루틴을 실행하는 스레드에 할당된 동일한 코어에서 실행된다.

> 위에서 설명한 코루틴의 동시성 처리는 시분할과 마찬가지로 병렬(parallel)로 실행되는 것처럼 느껴지지만, 실제로는 실행이 겹치지 않고 상호 배치되는(interleaved) 형태라고 한다.

다양한 플랫폼에서 동시성 처리를 위해 멀티쓰레딩을 지원하고 있다. 효율적인 자원 활용을 위한 멀티스레드는 장점도 많지만, 공유 변수 관리, deadlock, race condition 등 신경써야 할 부분이 많다. 이처럼 처리가 복잡할 수 있는 멀티스레드 대신 코루틴을 이용하면 좀 더 쉽게 멀티태스킹을 구현할 수 있고, Context Switching과 같은 비용도 발생하지 않아 성능 면에서도 우수하다고 생각한다.

---

# 코틀린의 코루틴
[코틀린 버전 1.3](https://kotlinlang.org/docs/whatsnew13.html)에는 정말 많은 업데이트가 있었는데, 그중 가장 눈에 띄는 건 단연 Coroutine 이다. 코틀린은 언어 차원에서 표준 라이브러리에 최소한의 저수준 API만 제공하고, 다양한 다른 라이브러리에서 코루틴을 활용할 수 있도록 가이드했다. 그리고 JetBrains에서 개발한 `kotlinx.coroutines`에는 코루틴을 위한 많은 라이브러리가 있다. 여기에 `launch`, `async` 등을 포함한 고수준의 코루틴 요소들이 포함되어 있다.

### 코루틴 빌더
- 새 코루틴을 생성하기 위해 빌더 함수 runBlocking, launch, async 중 하나를 사용할 수 있다. runBlocking은 최상위 함수인 반면, launch와 async는 CoroutineScope의 확장 함수다.
- GlobalScope에 정의된 launch와 async의 문제점은 시작하는 코루틴이 특정 코루틴 잡(job)에도 할당되지 않고 영구적으로 취소되지 않으면 애플리케이션의 전체 수명주기에 걸쳐 실행된다.   ~따라서 반드시 사용해야 할 이유가 없다면 사용하지 말자.~

### runBlocking 빌더
- 현재 스레드를 블록하고 모든 내부 코루틴이 종료될 때까지 블록한다.
- [runBlocking](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/run-blocking.html) 참고

```kotlin
fun <T> runBlocking(
    context: CoroutineContext = EmptyCoroutineContext,
    block: suspend CoroutineScope.() -> T
): T
```

- runBlocking 은 suspend 함수가 아니므로 보통 함수에서 호출할 수 있다. 인자로는 CoroutineScope에 확장 함수로 추가될 suspend 함수를 받고, 이 인자로 받은 함수를 실행하고, 실행한 함수가 리턴하는 값을 리턴한다.

```kotlin
fun main() {
    println("Before runBlocking")
    runBlocking {
        print("Hello, ")
        delay(200L)
        println("Coroutine!")
    }
    println("After runBlocking")
}

// Before runBlocking
// Hello, Coroutine!
// After runBlocking
```

### launch 빌더
- 독립된 프로세스를 실행하는 코루틴을 시작하고, 해당 코루틴에서 리턴값을 받을 필요가 없는 경우 사용.
- CoroutineScope의 확장 함수이기 때문에 CoroutineScope이 사용 가능한 경우에만 사용할 수 있다.
- launch 함수는 코루틴 취소가 필요하면 사용할 수 있는 [Job](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-job/index.html) 인스턴스(코루틴 자체를 의미)를 리턴한다.
- [launch](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/launch.html) 참고

```kotlin
fun CoroutineScope.launch(
    context: CoroutineContext = EmptyCoroutineContext,
    start: CoroutineStart = CoroutineStart.DEFAULT,
    block: suspend CoroutineScope.() -> Unit
): Job
```

- CoroutineContext는 다른 코루틴과 상태를 공유하기 위해 사용한다. CoroutineStart 파라미터는 DEFAULT, LAZY, ATOMIC 또는 UNDISPATCHED 값만이 될 수 있는 Enum class이다.
- 마지막 파라미터로 제공되는 람다는 반드시 인자가 없는 일시 중단 함수이고, 아무것도 리턴하지 않아야 한다.

```kotlin
fun main() {
    println("Before runBlocking")
    runBlocking {
        println("Before launch")
        launch {
            print("Hello, ")
            delay(200L)
            println("Coroutine!")
        }
        println("After launch")
    }
    println("After runBlocking")
}

// Before runBlocking
// Before launch
// After launch
// Hello, Coroutine!
// After runBlocking
```

### async 빌더
- 값을 리턴해야 하는 경우에는 일반적으로 async 빌더를 사용한다.
- async 빌더도 CoroutineScope의 확장 함수이다.
- [async](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/async.html) 참고

```kotlin
fun <T> CoroutineScope.async(
    context: CoroutineContext = EmptyCoroutineContext,
    start: CoroutineStart = CoroutineStart.DEFAULT,
    block: suspend CoroutineScope.() -> T
): Deferred<T>
```

- 파라미터로 제공한 일시 중단 함수는 값을 리턴하면 async 함수가 지연된([Deferred](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-deferred/index.html)) 인스턴스로 해당 값을 감싼다. 지연된 인스턴스는 자바스크립트의 Promise 또는 자바의 Future와 비슷한 느낌을 준다. 공식문서에 따르면 non-blocking cancellable future 라고 표현하고 있다.
- Deferred에서 알아야 할 중요한 함수가 생산된 값을 리턴하기 전에 코루틴이 완료될 때까지 기다리는 await이다.
- delay: 코루틴을 실행하고 있는 스레드를 블록하지 않고 코루틴을 대기 상태로 만드는 일시 중단 함수

```kotlin
suspend fun add(x: Int, y: Int): Int {
    delay(ThreadLocalRandom.current().nextLong(1000L))
    return x + y
}

suspend fun main() = coroutineScope {
    val firstSum = async {
        println(Thread.currentThread().name)
        add(2, 2)
    }
    val secondSum = async {
        println(Thread.currentThread().name)
        add(3, 4)
    }
    println("Awaiting concurrent sum...")
    val total = firstSum.await() + secondSum.await()
    println("Total is $total")
}

// DefaultDispatcher-worker-1
// Awaiting concurrent sum...
// DefaultDispatcher-worker-2
// Total is 11
```

### coroutineScope 빌더
- 종료 전에 포함된 모든 코루틴이 완료될 때까지 기다리는 일시 중단 함수
- runBlocking 과는 다르게 메인 스레드를 블록하지 않는 것이 장점이지만 반드시 일시 중단 함수의 일부로서 호출돼야 한다.
- coroutineScope 의 이점은 코루틴 완료 여부를 확인하기 위해 코루틴을 조사해야 할 필요가 없다는 것이다. 자동으로 모든 sub coroutine이 완료될 때까지 기다린다.
- [CoroutineScope](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-coroutine-scope/index.html) 참고

```kotlin
suspend fun <R> coroutineScope(block: suspend CoroutineScope.() -> R): R
```

- 인자가 없고 제네릭 값을 리턴하는 람다를 받는다.
- coroutineScope 함수는 일시 중단 함수이기 때문에 반드시 일시 중단 함수 또는 다른 코루틴에서 호출돼야 한다.

```kotlin
suspend fun main() = coroutineScope {
    for (i in 0 until 10) {
        launch {
            delay(1000L - i * 10)
            println("A$i ")
        }
    }
}

// A9 A8 A7 A6 A5 A4 A3 A2 A1 A0
```

- 10개의 코루틴을 시작하고 각 코루틴은 자신 이전에 실행된 코루틴보다 10밀리초 적게 지연된다. 즉 화면에 출력된 결과에는 A가 포함돼 있고 숫자는 내림차순이다.
- coroutineScope로 시작해서 코루틴이 모두 포함된 영역을 설정하고 결과 블록 안에서 개별 작ㅇ버을 다루기 위해 launch 또는 async를 사용할 수 있다. 이후에 이 영역은 프로그램 종료 전에 모든 코루틴이 완료될 때까지 기다리고, 만약 코루틴이 하나라도 실패하면 나머지 코루틴을 취소한다. 이 방식은 루틴의 완료 여부를 조사하지 않고도 균형 있는 제어와 에러 처리를 달성하고 루틴이 실패하는 경우를 처리하지 않는 것을 방지한다.

### CoroutineContext & Dispatcher
코루틴은 항상 Kotlin 표준 라이브러이에 정의된 [CoroutineContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/) 타입의 값으로 표현되는 Context 내에서 실행된다. 코루틴 컨텍스트는 다양한 요소의 집합인데, 그중에서도 주의 깊게 볼만한 건 Job와 Dispatcher이다.

코루틴 컨텍스트에는 해당 코루틴이 실행에 사용하는 스레드를 결정하는 코루틴 디스패처([CoroutineDispatcher](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-coroutine-dispatcher/index.html))가 포함된다. 코루틴 디스패처는 코루틴 실행을 특정 스레드로 제한하거나 스레드 풀에 디스패치하거나, 제한 없이 실행되도록 할 수 있다.

> launch, async와 같은 모든 코루틴 빌더는 새 코루틴 및 기타 컨텍스트 요소에 대한 디스패처를 명시적으로 지정할 수 있도록 CoroutineContext 파라미터를 허용한다. 매개변수를 허용합니다.

[CoroutineContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/)
- fold: 초기값을 시작으로 각 Context 요소들을 왼쪽에서 오른쪽으로(foldLeft) operation을 적용해서 값을 누적해서 만든다.
- get: 주어진 key에 해당하는 Context 요소를 반환하거나 없으면 null 반환
- plus: 현재 Context와 파라미터로 주어진 다른 Context가 갖는 요소들을 모두 포함하는 Context를 반환
- minusKey: 현재 Context에서 주어진 키를 갖는 요소들을 제외한 새로운 Context를 반환

[EmptyCoroutineContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-empty-coroutine-context/)
- 특별히 Context가 명시되지 않을 경우 이 singleton 객체가 생성됨.

---

# 함께 보면 좋은 글
- [WIKIPEDIA - Coroutine](https://en.wikipedia.org/wiki/Coroutine)
- [Kotlin Coroutines proposals](https://github.com/Kotlin/KEEP/blob/master/proposals/coroutines.md)
- [Kotlin Coroutines guide](https://kotlinlang.org/docs/coroutines-guide.html)
- [kotlinx-coroutines-core](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/index.html)
- [What is a coroutine?](https://stackoverflow.com/q/553704)
- [Difference between thread and coroutine in Kotlin](https://stackoverflow.com/questions/43021816/difference-between-thread-and-coroutine-in-kotlin)
- [Introduction to kotlin coroutines](https://www.slideshare.net/NaverEngineering/introduction-to-kotlin-coroutines-180513000)
