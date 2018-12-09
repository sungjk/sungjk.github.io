---
layout: entry
post-category: java
title: Effective Java(9)
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java의 10장(병행성)을 정리한 글입니다.
publish: true
---

# 규칙 66. 변경 가능 공유 데이터에 대한 접근은 동기화하라
객체는 일관된(consistent) 상태를 갖도록 생성되며(규칙 15), 해당 객체를 접근하는 메서드는 그 객체에 락(lock)을 건다. 동기화 없이는 한 스레드가 만든 변화를 다른 스레드가 확인할 수 없다. 동기화는 스레드가 일관성이 깨진 객체를 관측할 수 없도록 할 뿐 아니라, 동기화 메서드나 동기화 블록에 진입한 스레드가 동일한 락의 보호 아래 이루어진 모든 변경(modification)의 영향을 관측할 수 있도록 보장한다.

**상호 배제성뿐 아니라 스레드 간의 안정적 통신을 위해서도 동기화는 반드시 필요하다.**

**Thread.stop은 절대로 이용하지 마라.** false로 초기화되는 boolean 필드를 이용하는 것이 바람직하다.

```java
// 적절히 동기화한 스레드 종료 예제
public class StopThread {
  private static boolean stopRequested;
  private static synchronized void requestStop() {
    stopRequested = true;
  }
  private static synchronized boolean stopRequested() {
    return stopRequested;
  }

  public static void main(String[] args) throws InterruptedException {
    Thread backgroundThread = new Thread(new Runnable() {
      public void run() {
        int i = 0;
        while (!stopRequested())
          i++;
      }
    });
    backgroundThread.start();

    TimeUnit.SECONDS.sleep(1);
    requestStop();
  }
}
```

**읽기 연산과 쓰기 연산에 전부 적용하지 않으면 동기화는 아무런 효과도 없다.** StopThread의 동기화 메서드가 하는 일은 동기화가 없이도 원자적이다. 다시 말해서, 상호 배제성을 달성하기 위해서가 아니라, 스레드 간 통신 문제를 해결하기 위해 동기화를 한 것이다. volatile이 상호 배제성을 실현하진 않지만, 어떤 스레드건 가장 최근에 기록된 값을 읽도록 보장하기 때문에 굳이 락을 쓰지 않아도 된다.

```java
// volatile 필드를 사용해 스레드를 종료시키는 예제
public class StopThread {
  private static volatile boolean stopRequested;

  public static void main(String[] args) throws InterruptedException {
    Thread backgroundThread = new Thread(new Runnable() {
      public void run() {
        int i = 0;
        while (!stopRequested)
          i++;
      }
    });
    backgroundThread.start();

    TimeUnit.SECONDS.sleep(1);
    stopRequested = true;
  }
}
```

volatile을 사용할 때는 주의해야 한다.

```java
private static volatile int nextSerialNumber = 0;

public static int generateSerialNumber() {
  return nextSerialNumber++;
}
```

여기서 증가 연산자 ++는 원자적이지 않다. 첫 번째 스레드가 필드의 값을 읽은 후 새 값을 미처 기록하기 전에 두 번째 스레드가 필드에서 같은 값을 읽으면, 두 스레드는 같은 일련번호를 얻게 된다. 이것은 *안전 오류*(safety failure)다. 이는 메서드를 synchronized로 선언해서 해결하면 된다. 여러 스레드가 동시에 호출하더라도 서로 겹쳐 실행되지 않는 메서드가 되고, 각각의 메서드 호출은 그전에 행해진 모든 호출의 영향을 관측할 수 있게 된다. 더 좋은 방법은 AtomicLong 클래스를 쓰는 것이다.

```java
private static final AtomicLong nextSerialNum = new AtomicLong();

public static long generateSerialNumber() {
  return nextSerialNum.getAndIncrement();
}
```

이번 절에서 설명한 문제를 피하는 가장 좋은 방법은 변경 가능 데이터를 공유하지 않는 것이다. 굳이 공유를 해야겠다면 변경 불가능 데이터를 공유하거나(규칙 15), 아예 공유하지 마라. **변경 가능 데이터는 한 스레드만 이용하도록 하라는 것이다.**

특정한 스레드만이 데이터 객체를 변경할 수 있도록 하고, 변경이 끝난 뒤에야 다른 스레드와 공유하도록 할 떄는 객체 참조를 공유하는 부분에만 동기화를 적용하면 된다. 객체 참조를 안전하게 발행하는 방법은 많다. 클래스가 초기화될 때 같이 초기화되는 static 필드에 저장해도 된다. volatile 필드나 final 필드에 저장해도 되고, 락을 걸어야 접근 가능한 필드에 저장해 둘 수도 있다. 아니면 concurrent 컬렉션에 보관해도 된다(규칙 69).

### 요약
**변경 가능한 데이터를 공유할 때는 해당 데이터를 읽거나 쓰는 모든 스레드는 동기화를 수행해야 한다는 것이다.**

---

# 규칙 67. 과도한 동기화는 피하라
**생존 오류나 안전 오류를 피하고 싶으면, 동기화 메서드나 블록 안에서 클라이언트에게 프로그램 제어 흐름(control)을 넘기지 마라.** 다시 말해서, 동기화가 적용된 영역 안에서는 재정의(override) 가능 메서드나 클라이언트가 제공한 함수 객체 메서드(규칙 21)를 호출하지 말라는 것이다.

아래 클래스는 구독 가능한(observable) wrapper 클래스다. 집합에 새로운 원소가 추가되었을 때 발생하는 notification을 구독(subsbribe)할 수 있도록 한다. 구독자(Observer) 패턴이다.

```java
// 동기화 블록 안에서 불가해 메서드를 호출하는 잘못된 사례
public class ObservableSet<E> extends ForwardingSet<E> {
  public ObservableSet(Set<E> set) { super(set); }

  private final List<SetObserver<E>> observers =
    new ArrayList<SetObserver<E>>();

  public void addObserver(SetObserver<E> observer) {
    synchronized(observers) {
      observers.add(observer);
    }
  }

  public boolean removeObserver(SetObserver<E> observer) {
    synchronized(observers) {
      return observers.remove(observer);
    }
  }

  private void notifyElementAdded(E element) {
    synchronized(observers) {
      for (SetObserver<E> observer : observers)
        observer.add(this. element);
    }
  }

  @Override
  public boolean add(E element) {
    boolean added = super.add(element);
    if (added)
      notifyElementAdded(element);
    return added;
  }

  @Override
  public boolean addAll(Collection<? extends E> c) {
    boolean result = false;
    for (E element : c)
      result |= add(element); // notifyElementAdded 호출
    return result;
  }
}
```

구독자는 addObserver 메서드를 호출해서 자신을 notification 구독자로 등록하고, removeObserver 메서드를 호출해서 notification 구독을 해제한다. 두 메서드의 인자로 전달되는 객체는 아래의 callback 인터페이스 자료형의 객체다.

```java
public interface SetObserver<E> {
  // 구독자 집합에 새 원소가 추가되었을 때 호출됨
  void added(ObservableSet<E> set, E element);
}
```

0부터 99까지의 수를 찍는 코드를 만들어보자. 집합에 추가된 Integer 값을 출력하되 그 값이 23일 때는 자기 자신을 구독자 리스트에서 삭제하는 구독자 객체가 전달되도록 해 보자.

```java
public static void main(String[] args) {
  ObservableSet<Integer> set =
    new ObservableSet<Integer>(new HashSet<Integer>());

  set.addObserver(new SetObserver<Integer>() {
    public void added(ObservableSet<Integer> s, Integer e) {
      System.out.println(e);
      if (e == 23) s.removeObserver(this);
    }
  });

  for (int i = 0; i < 100; i++)
    set.add(i);
}
```

이 프로그램을 돌려보면 예상과 다르게, 0부터 23까지 출력된 다음에 ConcurrentModificationException이 발생한다. 구독자의 added 메서드가 호출된 순간, notifyElementAdded 메서드가 observers 리스트를 순회하고 있었기 떄문이다. 방금 살펴본 added 메서드는 구독자 집합에 정의된 removeObserver 메서드를 호출하는데, 이 메서드는 다시 observers.remove를 호출한다. 문제는 리스트 순회가 이루어지고 있는 도중에 리스트에서 원소를 삭제하려 한 것이다(illegal).

다음으로 구독 해제를 시도하는 구독자를 만들되, removeObserver를 직접 호출하는 대신 그 일을 해줄 다른 스레드의 서비스를 이용하는 것이다. 이 구독자는 실행자 서비스(executor service)를 사용한다(규칙 68).

```java
// 괜히 후면 스레드를 이용하는 구독자
set.addObserver(new SetObserver<Integer>() {
  public void added(final ObservableSet<Integer> s, Integer e) {
    System.out.println(e);
    if (e == 23) {
      ExecutorService executor = Executors.newSingleThreadExecutor();
      final SetObserver<Integer> observer = this;
      try {
        executor.submit(new Runnable() {
          public void run() {
            s.removeObserver(observer);
          }
        }).get();
      } catch (ExecutionException ex) {
        throw new AssertionError(ex.getCause());
      } catch (InterruptedException ex) {
        throw new AssertionException(ex);
      } finally {
        executor.shutdown();
      }
    }
  }
})
```

이번에는 예외가 발생하지 않는 반면 교착상태가 생긴다. 후면 스레드는 s.removeObserver를 호출하는데, 이 메서드는 observers에 락을 걸려 한다. 하지만 락을 걸 수는 없다. 왜냐하면 주 스레드가 이미 락을 걸고 있기 때문이다. 주 스레드는 후면 스레드가 구독 해제를 끝내기를 기다리면서 락을 계속 들고 있는데, 그래서 교착상태가 생기는 것이다.

앞서 살펴본 두 예제(예외와 데드락)은 운이 좋은 편이다. 불가해 메서드 added가 호출될 시점에, 동기화 영역이 보호하는 자원 observers의 상태는 일관되게 유지되고 있었으니까. 그런데 동기화 영역이 보호하는 불변식(invariant)이 일시적으로 위반된 순간에, 동기화 영역에서 불가해 메서드를 호출했다고 해보자. 자바가 제공하는 락은 *재진입 가능*하므로(reentrant), 그런 호출은 교착상태로 이어지지 않을 것이다. 예외를 발생시켰던 첫 번째 예제를 예로 들면, 불가해 메서드를 호출하는 스레드는 이미 락을 들고 있는 상태였으므로, 다시 락을 획득하려고 해도 성공한다. 락이 보호하는 데이터에 대해 개념적으로는 관련성 없는 작업이 진행 중인데도 말이다. 이것 때문에 실로 참혹한 결과가 빚어지게 될 수도 있다. 본질적으로 말해서, 락이 제 구실을 못하게 된 것이다. 재진입 가능 락(reentrant lock)은 객체 지향 다중 스레드 프로그램을 쉽게 구현할 수 있도록 하지만, 생존 오류를 안전 오류로 변모시킬 수도 있는 것이다.

다행히도 이런 문제는 불가해 메서드를 호출하는 부분을 동기화 영역 밖으로 옮기면 쉽게 해결할 수 있다. notifyElementAdded 메서드의 경우, observers 리스트의 복사본을 만들어서 락 없이도 안전하게 리스트를 순회할 수 있도록 바꾸는 것이다. 이렇게 바꾸면 앞서 보았던 두 예제에서는 더 이상 예외나 교착 상태가 일어나지 않는다.

```java
// 불가해 메서드를 호출하는 코드를 동기화 영역 밖으로 옮겼다 (open call)
private void notifyElementAdded(E element) {
  List<SetObserver<E>> snapshot = null;
  synchronized(observers) {
    snapshot = new ArrayList<SetObserver<E>>(observers);
  }
  for (SetObserver<E> observer : snapshot)
    observer.added(this, element);
}
```

불가해 메서드 호출 코드를 동기화 영역 밖으로 옮기는 문제라면 더 좋은 해결책이 있다. 자바 1.5부터 CopyOnWriteArrayList라는 *병행성 컬렉션*(concurrent collection, 규칙69)이 추가되었는데, 이럴 때 써먹으려고 고안된 것이다. 이 리스트는 ArrayList의 변종으로, 내부 배열을 통째로 복사하는 방식으로 쓰기(write) 연산을 지원한다. 내부 배열을 절대 수정하지 않으므로 순회 연산만큼은 락을 걸 필요가 없어져서 대단히 빠르다. 이 리스트의 성능은 대체로 끔찍하지만 구독자 리스트에는 딱이다.

```java
// 다중 스레드에 안전한 구독자 집합: CopyOnWriteArrayList
private final List<SetObserver<E>> observers =
  new CopyOnWriteArrayList<SetObserver<E>>();

public void addObserver(SetObserver<E> observer) {
  observers.add(observer);
}

public boolean removeObserver(SetObserver<E> observer) {
  return observers.remove(observer);
}

private void notifyElementAdded(E element) {
  for (SetObserver<E> observer : observers)
    observer.added(this, element);
}
```

동기화 영역 바깥에서 불가해 메서드를 호출하는 것을 *열린 호출*(open call)이라고 한다. 오류를 방지할 뿐 아니라, 병행성을 대단히 높여주는 기법이다. **명심해야 할 것은, 동기화 영역 안에서 수행되는 작ㅇ버의 양을 가능한 한 줄여야 한다는 것이다.** 락을 걸고, 공유 데이터를 검사하고, 필요하다면 변환하고, 락을 해제하라.

변경 가능(mutable) 클래스의 경우, 병렬적으로 이용될 클래스이거나, 내부적인 동기화를 통해 외부에서 전체 객체에 락을 걸 때보다 높은 병행성(concurrency)을 달성할 수 있을 때만 스레드 안전성(thread safety)을 갖도록 구현해야 한다(규칙 70). 그렇지 않다면 내부적인 동기화는 하지 마라. 필요할 때, 클라이언트가 객체 외붖거으로 동기화를 하도록 두라.

클래스 내부적으로 동기화 메커니즘을 적용해야 한다면, 락 분할(lock splitting), 락 스트라이핑(striping), 비봉쇄형 병행성 제어(nonblocking concurrency control)처럼 높은 병행성을 달성하도록 돕는 다양한 기법을 활용할 수 있다.

static 필드를 변경하는 메서드가 있을 때는 해당 필드에 대한 접근을 반드시 동기화해야 한다.

### 요약
- 데드락과 데이터 훼손 문제를 피하려면 동기화 영역 안에서 불가해 메서드는 호출하지 말라.
- 동기화 영역 안에서 하는 작업의 양을 제한하라.
- 변경 가능 클래스를 설계할 때는, 내부적으로 동기화를 처리해야 하는지 살펴보자.

---

# 규칙 68. 스레드보다는 실행자와 태스크를 이용하라
자바 1.5부터 추가된 java.util.concurrent 안에 *Executor Framework* 라는 것이 들어 있는데, 유연성이 높은 인터페이스 기반 태스크(task) 실행 프레임워크다. 작업 큐를 한 줄의 코드로 생성할 수 있다.

```java
ExecutorService executor = Executors.newSingleThreadExecutor();

// 실행자에 Runnable을 넘겨 실행시키기
executor.execute(runnable);

// 종료하기
executor.shutdown();
```

큐의 작업을 처리하는 스레드를 여러 개 만들고 싶을 때는 thread pool 이라 부르는 ExecutorService를 생성하는 정적 팩터리 메서드를 이용하면 된다. Thread pool에 담기는 스레드의 숫자는 고정시켜 놓을 수도 있고, 가변적으로 변하도록 설정할 수도 있다.

작은 프로그램이거나 부하가 크지 않은 서버를 만들 때는 보통 Executors.newCachedThreadPool이 좋다. 설정이 필요 없고, 보통 많은 일을 잘 처리하기 때문이다. 하지만 부하가 심한 곳에 팔릴 서버를 만드는 데는 적합하지 않다. 캐시 기반 스레드 풀의 경우, 작업은 큐에 들어가는 것이 아니라 실행을 담당하는 스레드에 바로 넘겨진다. 가용한 스레드가 없는 경우에는 새 스레드가 만들어진다. 서버 부하가 너무 심해서 모든 CPU가 100%에 가깝게 이용되고 있는 상황에서 새 태스크가 들어오면 더 많은 스레드가 만들어질 것이고, 상황은 더 나빠질 것이다. 따라서 부하가 심한 환경에 들어갈 서버를 만들 때는 Executors.newFixedThreadPool을 이용해서 스레드 개수가 고정된 풀을 만들거나, 최대한 많은 부분을 직접 제어하기 위해 ThreadPoolExecutor 클래스를 사용하는 것이 좋다.

이제 Thread는 더 이상 중요하지 않다. 작업과 실행 메커니즘이 분리된 것이다. 중요한 것은 작업의 단위이며, 태스크(task)라 부른다. 태스크에는 두 가지 종류가 있다. Runnable과 Callable이다(Callable은 Runnable과 비슷하지만 값을 반환하는 차이가 있다). 태스크 실행하는 일반 메커니즘은 Executor service다. 태스크와 Executor service를 분리해서 생각하게 되면 실행 정책(execution policy)을 더욱 유연하게 정할 수 있게 된다. 핵심은, 컬렉션 프레임워크(Collection Framework)가 데이터를 모으는 일(aggregation)을 처리하는 것과 마찬가지로, Executor service는 태스크를 실행하는 부분을 담당하는 것이다.

---

# 규칙 69. wait나 notify 대신 병행성 유틸리티를 이용하라
**wait와 notify를 정확하게 사용하는 것이 어렵기 때문에, 이 고수준 유틸리티들을 반드시 이용해야 한다.

병행 컬렉션은 List, Queue, Map 등의 표준 컬렉션 인터페이스에 대한 고성능 병행 컬렉션 구현을 제공한다. 이 컬렉션들은 병행성을 높이기 위해 동기화를 내부적으로 처리한다(규칙 67). 따라서 **컬렉션 외부에서 병행성을 처리하는 것은 불가능하다. 락을 걸어봐야 아무 효과가 없을 뿐 아니라** 프로그램만 느려진다.

ConcurrentHashMap은 get 같은 읽기 연산에 최적화되어 있다. 따라서 처음에 get을 호출한 다음 그 결과를 보고 필요하다 여겨질 때만 putIfAbsent를 호출하도록 하면 바람직하다.

```java
// ConcurrentHashMap으로 구현한 병행 정규화 맵
public static String intern(String s) {
  String result = map.get(s);
  if (result == null) {
    result = map.putIfAbsent(s, s);
    if (result == null)
      result = s;
  }
  return result;
}
```

확실한 이유가 없다면 **Collections.synchronizedMap이나 Hashtable 대신 ConcurrentHashMap을 사용하도록 하자.**

카운트다운 래치(countdown latch)는 일회성 배리어(barrier)로서 하나 이상의 스레드가 작업을 마칠 때까지 다른 여러 스레드가 대기할 수 있도록 한다. CountDownLatch에 정의된 유일한 생성자는 래치의 countdown 메서드가 호출될 수 있는 횟수를 나타내는 int 값을 인자로 받는다. 대기 중인 스레드가 진행할 수 있으려면 그 횟수만큼 countdown 메서드가 호출되어야 한다.

**특정 구간의 실행시간을 잴 때는 System.currentTimeMillis 대신 System.nanoTime을 사용해야 한다.** 그래야 더 정밀하게 잴 수 있을 뿐더러, 시스템의 실시간 클락(real-time clock) 변동에도 영향을 받지 않게 된다.

```java
// wait 메서드를 사용하는 표준적 숙어
synchronized (obj) {
  while (<이 조건이 만족되지 않을 경우에 순환문 실행>)
    obj.wait(); // (락 해제. 깨어나면 다시 락 획득)

  ... // 조건이 만족되면 그에 맞는 작업 실행
}
```

**wait 메서드를 호출할 때는 반드시 이 대기 순환문(wait loop) 숙어대로 하자.** wait 호출 전에 조건을 검사하고, 조건이 만족되었을 때는 wait를 호출하지 않도록 하는 것은 생존 오류를 피하려면 필요한 부분이다. 조건이 만족되고 notify나 notifyAll이 이미 호출된 다음에 wait를 호출하면, 스레드는 깨어나지 못할 수도 있다.

### 요약
wait나 notify를 사용해 프로그램을 짜는 것은 \"병행성 어셈블리 언어\"를 사용해 코딩하는 것과 같다. **새로 만드는 프로그램에 wait나 notify를 사용할 이유는 거의 없다.**

---

# 규칙 70. 스레드 안전성에 대해 문서로 남겨라
**병렬적으로 사용해도 안전한 클래스가 되려면, 어떤 수준의 스레드 안전성을 제공하는 클래스인지 문서에 명확하게 남겨야 한다.** 아래에 스레드 안전성을 그 수준별로 요약하였다.

- **변경 불가능**(immutable) - 이 클래스로 만든 객체들은 상수다. 따라서 외부적인 동기화 메커니즘 없이도 병렬적 이용이 가능하다. String, Long, BigInteger 등이 그 예다(규칙 15).
- **무조건적 스레드 안전성**(unconditionally thread-safe) - 이 클래스의 객체들은 변경이 가능하지만 적절한 내부 동기화 메커니즘을 갖추고 있어서 외부적으로 동기화 메커니즘을 적용하지 않아도 병렬적으로 사용할 수 있다. Random, ConcurrentHashMap 같은 클래스가 그 예다.
- **조건부 스레드 안전성**(conditionally thread-safe) - 무조건적 스레드 안전성과 거의 같은 수준이나 몇몇 스레드는 외부적 동기화가 없이는 병렬적으로 사용할 수 없다. Collections.synchronized 계열 메서드가 반환하는 포장 객체(wrapper)가 그 사례다. 이런 객체의 반복자(iterator)는 외부적 동기화 없이는 병렬적으로 이용할 수 없다.
- **스레드 안전성 없음** - 이 클래스의 객체들은 변경 가능하다. 해당 객체들을 병렬적으로 사용하려면 클라이언트는 메서드를 호출하는 부분을 클라이언트가 선택한 외부적 동기화 수단으로 감싸야 한다. ArrayList나 HashMap 같은 일반 용도의 컬렉션 구현체들이 그 예다.
- **다중 스레드에 적대적**(thread-hostile) - 이런 클래스의 객체는 메서드를 호출하는 모든 부분을 외부적 동기화 수단으로 감싸더라도 안전하지 않다. 이런 클래스가 되는 것은 보통, 동기화 없이 정적 데이터(static data)를 변경하기 때문이다.

lock 필드를 final로 선언하면 실수로 lock 필드의 내용을 변경하는 일을 막을 수 있다. 실수로 변경하게 되면, 끔찍하게도 객체의 내용에 동기화 없이 접근할 수 있게 된다(규칙 56).

---

# 규칙 71. 초기화 지연은 신중하게 하라
*초기화 지연*(lazy initialization)은 필드 초기화를 실제로 그 값이 쓰일 때까지 미루는 것이다. 값을 사용하는 곳이 없다면 필드는 결코 초기화되지 않을 것이다. 이 기법은 static 필드와 객체 필드에 모두 적용 가능하다. 초기화 지연 기법은 기본적으로 최적화 기법이지만, 클래스나 객체 초기화 과정에서 발생하는 해로운 순환성(circularity)을 해소하기 위해서도 사용한다.

다중 스레드 환경에서 초기화 지연 기법을 구현하는 것은 까다롭다. 두 개 이상의 스레드가 그런 필드를 공유할 때는 반드시 적절한 동기화를 해 주어야 하며, 그렇지 않으면 심각한 버그가 생길 수 있다(규칙 66). **대부분의 경우, 지연된 초기화를 하느니 일반 초기화를 하는 편이 낫다.**

```java
// 객체 필드를 초기화하는 일반적인 방법
private final FieldType field = computeFieldValue();
```

**초기화 순환성(initialization circularity) 문제를 해소하기 위해서 초기화를 지연시키는 경우에는 동기화된 접근자(synchronized accessor)를 사용하라.** 가장 간단하고 명확한 방법이다.

```java
// 동기화된 접근자를 사용한 객체 필드 초기화 지연 방법
private FieldType field;

synchronized FieldType getField() {
  if (field == null)
    field = computeFieldValue();
  return field;
}
```

이 두 숙어(*일반 초기화 숙어* 와 *동기화된 접근자를 통한 초기화 지연 숙어*)는 정적 필드에도 똑같이 적용 가능하다. 차이라고는 필드나 접근자 선언부에 static이 붙는다는 것뿐이다.

**성능 문제 때문에 정적 필드 초기화를 지연시키고 싶을 때는 초기화 지연 담당 클래스(lazy initialization holder class) 숙어를 적용하라**

```
// 정적 필드에 대한 초기화 지연 담당 클래스 숙어
private static class FieldHolder {
  static final FieldType field = computeFieldValue();
}
static FieldType getField() { return FieldHolder.field; }
```

**성능 문제 때문에 객체 필드 초기화를 지연시키고 싶다면 이중 검사(double-check) 숙어를 사용하라.** 이 숙어를 사용하면 초기화가 끝난 필드를 이용하기 위해 락을 걸어야 하는 비용을 없앨 수 있다(규칙 67). 이 숙어 뒤에 숨은 아이디어는 필드의 값을 두 번 검사한다는 것이다. 한 번은 락 없이 검사하고, 초기화가 되지 않은 것 같으면 락을 걸어서 검사한다. 두 번째 검사로 초기화가 됮 ㅣ않았다고 판정되면 필드를 초기화한다.

```java
// 이중 검사 패턴을 통해 객체 필드 초기화를 지연시키는 숙어
private volatile FieldType field;

FieldType getField() {
  FieldType result = field;
  if (result == null) { // 첫 번째 검사(락 없음)
    synchronized(this) {
      result = field;
      if (result == null) // 두 번쨰 검사(락)
        field = result = computeFieldValue();
    }
  }
  return result;
}
```

### 요약
- 대부분의 필드 초기화는 지연시키지 않아야 한다.
- 객체 필드에는 이중 검사 숙어를 적용하고, 정적 필드에는 초기화 지연 담당 클래스 숙어를 적용하라.

---

# 규칙 72. 스레드 스케줄러에 의존하지 마라
실행할 스레드가 많을 때, 어떤 스레드를 얼마나 오랫동안 실행할지 결정하는 것은 스레드 스케줄러(thread scheduler)다. **정확성을 보장하거나 성능을 높이기 위해 스레드 스케줄러에 의존하는 프로그램은 이식성이 떨어진다(non-portable).**

안정적이고, 즉각 반응하며(responsive) 이식성이 좋은 프로그램을 만드는 가장 좋은 방법은, *실행 가능한* 스레드의 평균적 수가 프로세서 수보다 너무 많아지지 않도록 하는 것이다.

실행 가능 스레드의 수를 일정 수준으로 낮추는 기법의 핵심은 각 스레드가 필요한 일을 하고 나서 다음에 할 일을 기다리게 만드는 것이다. **스레드는 필요한 일을 하고 있지 않을 때는 실행 중이어서는 안 된다.**

다른 스레드에 비해 충분한 CPU 시간을 받지 못하는 스레드가 있는 탓에 겨우겨우 동작하는 프로그램을 만나더라도, **Thread.yield를 호출해서 문제를 해결하려고는 하지 마라.** 어떤 JVM에서는 성능이 좋아질 수 있어도, 다른 JVM에서는 성능이 떨어지거나 아무 효과가 없을 수도 있다. **Thread.yield에는 테스트 가능한 의미(semantic)가 없다.** 바람직한 해결책ㅇ,ㄴ 프로그램 구조를 바꿔서 병렬적으로 실행 가능한(runnable) 스레드의 수를 줄이는 것이다.

이와 관련된 기법으로 스레드 우선순위(priority)를 변경하는 것이 있는데, 비슷한 문제가 있다. **스레드 우선순위는 자바 플랫폼에서 가장 이식성이 낮은 부분 가운데 하나다.**

### 요약
- 프로그램의 정확성을 스레드 스케줄러에 의존하지 마라.
- Thread.yield나 스레드 우선순위에 의존하지도 마라.

---

# 규칙 73. 스레드 그룹은 피하라
스레드 시스템이 제공하는 기본적인 추상화 단위(abstraction) 가운데는 스레드, 락, 모니터(monitor) 이외에도 *스레드 그룹*(thread group)이라는 것이 있다.

**스레드 그룹은 이제 폐기된 추상화 단위다.** 스레드를 논리적인 그룹으로 나누는 클래스를 만들어야 한다면, 스레드 풀 실행자(thread pool executor)를 이용하라(규칙 68).

---

# Reference
- [Effective Java 2/E](http://www.insightbook.co.kr/%EB%8F%84%EC%84%9C-%EB%AA%A9%EB%A1%9D/programming-insight/%EC%9D%B4%ED%8E%99%ED%8B%B0%EB%B8%8C-%EC%9E%90%EB%B0%94effective-java-2e)
