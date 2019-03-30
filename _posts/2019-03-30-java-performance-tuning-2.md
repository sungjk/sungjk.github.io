---
layout: entry
post-category: java
title: 자바 성능 튜닝 이야기 - 2
author: 김성중
author-email: ajax0615@gmail.com
description: 이상민님의 '자바 성능 튜닝 이야기'를 읽고 정리한 글입니다.
keywords: Java, 자바
publish: false
---

![java_performance_tuning](/images/2019/03/28/java_performance_tuning.jpeg "java_performance_tuning"){: .center-image }

# 6. static 제대로 한번 써 보자
100개의 클래스의 인스턴스를 생성하더라도, static으로 선언된 변수나 메서드들은 동일한 주소의 값을 참조한다.

static의 특징은 다른 JVM에서는 static으로 선언해도 다른 주소나 다른 값을 참조하지만, 하나의 JVM이나 WAS 인스턴스에서는 같은 주소에 존재하는 값을 참조한다. 그리고 GC의 대상도 되지 않는다.

### static 잘 활용하기
- 자주 사용하고 절대 변하지 않는 변수는 final static으로 선언하자.
- 설정 파일 정보도 static으로 관리하자.
- 코드성 데이터는 DB에서 한 번만 읽자.

### static과 메모리 릭
static으로 선언한 부분은 GC가 되지 않는다. 만약 어떤 클래스에 데이터를 Vector나 ArrayList에 담을 때 해당 Collection 객체를 static으로 선언하면 어떻게 될까? 지속적으로 해당 객체에 데이터가 쌓인다면, 더 이상 GC가 되지 않으면서 시스템은 OutOfMemoryError를 발생시킨다.

---

# 7. 클래스 정보, 어떻게 알아낼 수 있나?
자바 API 중 reflection 패키지에 있는 클래스들을 사용하면 JVM에 로딩되어 있는 클래스와 메서드 정보들을 읽어 올 수 있다.

### Class 클래스
Class 클래스는 클래스에 대한 정보를 얻을 때 사용하기 좋고, 생성자는 따로 없다. ClassLoader 클래스의 defineClass() 메서드를 이용해서 클래스 객체를 만들 수도 있지만, 좋은 방법은 아니다. 그보다는 Object 클래스에 있는 getClass() 메서드를 이용하는 것이 일반적이다.

- String getName(): 클래스의 이름을 리턴한다.
- Package getPackage(): 클래스의 패키지 정보를 패키지 클래스 타입으로 리턴한다.
- Field[] getFields(): public으로 선언된 변수 목록을 Field 클래스 배열 타입으로 리턴한다.
- Field getField(String name): public으로 선언된 변수를 Field 클래스 타입으로 리턴한다.
- Field[] getDeclaredFields(): 해당 클래스에서 정의된 변수 목록을 Field 클래스 배열 타입으로 리턴한다.
- Field getDeclaredField(String name): 해당 클래스에서 정의된 변수 목록을 Field 클래스 배열 타입으로 리턴한다.
- Method[] getDeclaredField(String name): name과 동일한 이름으로 정의된 변수를 Field 클래스 타입으로 리턴한다.
- Method[] getMethods(): public으로 선언된 모든 메서드 목록을 Method 클래스 배열 타입으로 리턴한다. 해당 클래스에서 사용 가능한 상속받은 메서드도 포함된다.
- Method getMethod(String name, Class... parameterTypes): 지정된 이름과 매개변수 타입을 갖는 메서드를 Method 클래스 타입으로 리턴한다.
- Method[] getDeclaredMethods(): 해당 클래스에서 선언된 모든 메서드 정보를 리턴한다.
- Method getDeclaredMethod(String name, Class... parameterTypes): 지정된 이름과 매개변수 타입을 갖는 해당 클래스에서 선언된 메서드를 Method 클래스 타입으로 리턴한다.
- Constructor[] getConstructors(): 해당 클래스에 선언된 모든 public 생성자의 정보를 Constructor 배열 타입으로 리턴한다.
- Constructor[] getDeclaredConstructors(): 해당 클래스에서 선언된 모든 생성자의 정보를 Constructor 배열 타입으로 리턴한다.
- int getModifiers(): 해당 클래스의 접근자(modifier) 정보를 int 타입으로 리턴한다.
- String toString(): 해당 클래스 객체를 문자열로 리턴한다.

현재 클래스의 이름을 알고 싶으면 다음과 같이 사용하면 된다.

```java
String currentClassName = this.getClass().getName();
```

여기서 getName() 메서드는 패키지 정보까지 리턴해 준다. 클래스 이름만 필요한 경우에는 getSimpleName() 메서드를 사용하면 된다.

### Method 클래스
Method 클래스를 이용하여 메서드에 대한 정보를 얻을 수 있다. 하지만 Method 클래스에는 생성자가 없으므로 Class 클래스의 getMethods() 메서드를 사용하거나 getDeclaredMethods() 메서드를 써야 한다.

### Field 클래스
Field 클래스는 클래스에 있는 변수들의 정보를 제공하기 위해서 사용한다. Method 클래스와 마찬가지로 생성자가 없으므로 Class 클래스의 getFields()나 getDeclaredFields() 메서드를 써야 한다.

### reflection 클래스를 잘못 사용한 사례

```java
public String checkClass(Object src) {
  if (src.getClass().getName().equals("java.math.BigDecimal")) {
    // 데이터 처리
  }
  ...
}
```

이렇게 사용할 경우 응답 속도에 그리 많은 영향을 주지는 않지만, 많이 사용하면 필요 없는 시간을 낭비하게 된다. 기본으로 돌아가서 다음과 같이 사용하면 좋다.

```java
public String checkClass(Object src) {
  if (src instanceof java.math.BigDecimal) {
    // 데이터 처리
  }
  ...
}
```

| 대상 | 응답 시간(마이크로초) |
| :---: | :---: |
| instanceof 사용 | 0.167 |
| Reflection 사용 | 1.022 |

instanceof를 사용했을 때와 .getClass().getName()을 사용했을 때를 비교하면 약 6배의 성능 차이가 발생한다. 어떻게 보면 시간으로 보았을 때 큰 차이는 발생하지 않지만, 작은 것부터 생각하면서 코딩하는 습관을 가지는 것이 좋다.

---

# 8. synchronized는 제대로 알고 써야 한다
### 프로세스와 스레드
클래스를 하나 수행시키거나 WAS를 기동하면, 서버에서 자바 프로세스가 하나 생성된다. 하나의 프로세스에는 여러 개의 스레드가 생성된다. 단일 스레드가 생성되어 종료될 수도 있고, 여러 개의 스레드가 생성되어 수행될 수도 있다. 그러므로 프로세스와 스레드의 관계는 1:N 관계라고 보면 된다.

### Thread 클래스 상속과 Runnable 인터페이스 구현
스레드의 구현은 Thread 클래스를 상속받는 방법과 Runnable 인터페이스를 구현하는 방법 두 가지가 있다. 기본적으로 Thread 클래스는 Runnable 인터페이스를 구현한 것이기 때문에 어느 것을 사용해도 거의 차이가 없다. 대신 Runnable 인터페이스를 구현하면 원하는 기능을 추가할 수 있다. 이는 장점이 될 수도 있지만, 해당 클래스를 수행할 때 별도의 스레드 객체를 생성해야 한다는 단점이 될 수도 있다. 또한 자바는 다중 상속을 인정하지 않는다. 따라서 스레드를 사용해야 할 때 이미 상속받은 클래스가 존재한다면 Runnable 인터페이스를 구현해야 한다.

```java
public class RunnableImpl implements Runnable {
  public void run() {
    System.out.println("This is RunnableImpl.");
  }
}

public class ThreadExtends extends Thread {
  public void run() {
    System.out.println("This is ThreadExtends.");
  }
}
```

그럼 이 클래스들을 어떻게 실행해야 할까? Thread 클래스를 상속받은 경우에는 start() 메서드를 호출하면 된다. 하지만 Runnable 인터페이스를 매개변수로 받는 생성자를 사용해서 Thread 클래스를 만든 후 start() 메서드를 호출해야 한다. 그렇게 하지 않고 그냥 run() 메서드를 호출하면 새로운 스레드가 생성되지 않는다.

```java
public class RunThreads {
  public static void main(String[] args) {
    RunnableImpl ri = new RunnableImpl();
    ThreadExtends te = new ThreadExtends();
    new Thread(ri).start();
    te.start();
  }
}
```

### sleep(), wait(), join() 메서드
sleep() 메서드는 명시된 시간만큼 해당 스레드를 대기시킨다. wait() 메서드도 명시된 시간만큼 해당 스레드를 대기시킨다. sleep() 메서드와 다른 점은 매개변수인데, 만약 아무런 매개변수를 지정하지 않으면 notify() 메서드 혹은 notifyAll() 메서드가 호출될 때까지 대기한다. wait() 메서드가 대기하는 시간을 설정하는 방법은 sleep() 메서드와 동일하다.

join() 메서드는 명시된 시간만큼 해당 스레드가 죽기를 기다린다. 만약 아무런 매개변수를 지정하지 않으면 죽을 때까지 계속 대기한다.

### interrupt(), notify(), notifyAll() 메서드
앞서 명시한 세 개의 메서드를 '모두' 멈출 수 있는 유일한 메서드는 interrupt 메서드다. interrupt() 메서드가 호출되면 중지된 스레드에는 InterruptedException이 발생한다. notify() 메서드와 notifyAll() 메서드는 모두 wait() 메서드를 멈추기 위한 메서드다. 이 두 메서드는 Object 클래스에 정의되어 있는데, wait() 메서드가 호출된 후 대기 상태로 바뀐 스레드를 깨운다. notify() 메서드는 객체의 모니터와 관련있는 단일 스레드를 깨우며, notifyAll() 메서드는 객체의 모니터와 관련있는 모든 스레드를 깨운다.

### Synchronized를 이해하자
메서드를 동기화하려면 메서드 선언부에 사용하면 된다. 특정 부분을 동기화하려면 해당 블록에만 선언을 해서 사용하면 된다.

```
public synchronized void foo(){
  ...
}

public void foo2() {
  synchronized(obj) {
    ...
  }
}
```

그리고 다음과 같은 상황에 동기화를 사용한다.

- 하나의 객체를 여러 스레드에서 동시에 사용할 경우
- static으로 선언한 객체를 여러 스레드에서 동시에 사용할 경우

### 동기화를 위해서 자바에서 제공하는 것들
JDK 5.0부터 추가된 java.util.concurrent 패키지에 대해서 간단히 알아보자. 이 패키지에는 주요 개념 네 가지가 포함되어 있다.

- Lock: 실행 중인 메서드를 간단한 방법으로 정지시켰다가 실행시킨다. 상호 참조로 인해 발생하는 데드락을 피할 수 있다.
- Executors: 스레드를 더 효율적으로 관리할 수 있는 클래스들을 제공한다. 스레드 풀도 제공하므로, 필요에 따라 유용하게 사용할 수 있다.
- Concurrent 컬랙션
- Atomic 변수: 동기화가 되어 있는 변수를 제공한다. 이 변수를 사용하면, synchronized 식별자를 메서드에 지정할 필요 없이 사용할 수 있다.

### JVM 내에서는 synchronized은 어떻게 동작할까?
자바의 HotSpot VM은 \'자바 모니터(monitor)\'를 제공함으로써 스레드들이 \'상호 배제 프로토콜(mutual exclusion protocol)\'에 참여할 수 있도록 돕는다. 자바 모니터는 잠긴 상태(lock)나 풀림(unlocked) 중 하나이며, 동일한 모니터에 진입한 여러 스레드들 중에서 한 시점에는 단 하나의 스레드만 모니터를 가질 수 있다. 즉, 모니터를 가진 스레드만 모니터에 의해서 보호되는 영역(synchronized 블록)에 들어가서 작업을 할 수 있다. 모니터를 보유한 스레드가 보호 영역에서의 작업을 마치면, 모니터는 다른 대기중인 스레드에게 넘어간다.

JDK 5부터는 `-XX:+UseBiasedLocking`라는 옵션을 통해서 biased locking 이라는 기능을 제공한다. 그 전까지는 대부분의 객체들이 하나의 스레드에 의해서 잠기게 되었지만, 이 옵션을 켜면 스레드가 자기 자신을 향하여 bias된다. 즉, 이 상태가 되면 스레드는 많은 비용이 드는 인스트럭션 재배열 작업을 통해서 잠김과 풀림 작업을 수행할 수 있게 된다. 이 작업들은 진보된 적응 스피닝(adaptive spinning) 기술을 사용하여 처리량을 개선시킬 수 있다고 한다. 결과적으로 동기화 성능은 보다 빨라졌다.

HotSpot VM에서 대부분의 동기화 작업은 fast-path 코드 작업을 통해서 진행한다. 만약 여러 스레드가 경합을 일으키는 상황이 발생하면 이 fast-path 코드는 slow-path 코드 상태로 변환된다. 참고로 slow-path 구현은 C++ 코드로 되어 있으며, fast-path 코드는 JIT compiler에서 제공하는 장비에 의존적인 코드로 작성되어 있다.

---


---

# References
- [개발자가 반드시 알아야 할 자바 성능 튜닝 이야기](http://www.yes24.com/Product/Goods/11261731)
- [Core J2EE Patterns](http://www.corej2eepatterns.com/)
