---
layout: entry
post-category: java
title: 자바 성능 튜닝 이야기 - 2
author: 김성중
author-email: ajax0615@gmail.com
description: 이상민님의 '자바 성능 튜닝 이야기'를 읽고 정리한 글입니다.
keywords: Java, 자바
publish: true
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

```java
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

# 9. IO에서 발생하는 병목 현상
웹 애플리케이션에서 IO 처리를 하는 부분은 시스템의 응답 속도에 많은 영향을 준다.

### 기본적인 IO는 이렇게 처리한다
자바에서 입력과 출력은 스트림(stream)을 통해서 이루어진다. 파일을 포함해 디바이스를 통해 이뤄지는 작업을 모두 IO라고 한다. 네트워크를 통해서 다른 서버로 데이터를 전송하거나, 다른 서버로부터 데이터를 전송 받는 것도 IO에 포함된다.

```java
System.out.println("Jeremy");
```

여기서 out은 PrintStream을 System 클래스에 static으로 정의해 놓은 변수이다(이 또한 역시 IO). IO에서 발생하는 시간은 CPU를 사용하는 시간과 대기 시간 중 대기 시간에 속하기 때문에 성능에 영향을 가장 많이 미친다.

자바에서 파일을 읽고 처리하는 방법은 굉장히 많다. 스트림을 읽는 데 관련된 주요 클래스는 다음과 같다. 여기에 명시된 모든 입력과 관련된 스트림들은 java.io.InputStream 클래스로부터 상속받았다.

- ByteArrayInputStream: 바이트로 구성된 배열을 읽어서 입력 스트림을 만든다.
- FileInputStream: 이미지와 같은 바이너리 기반의 파일의 스트림을 만든다.
- FilterInputStream: 여러 종류의 유용한 입력 스트림의 추상 클래스이다.
- ObjectInputStream: ObjectOutputStream을 통해서 저장해 놓은 객체를 읽기 위한 스트림을 만든다.
- PipedInputStream: PipedOutputStream을 통해서 출력된 스트림을 읽어서 처리하기 위한 스트림을 만든다.
- SequenceInputStream: 별개인 두 개의 스트림을 하나의 스트림으로 만든다.

문자열 기반의 스트림을 읽기 위해서 사용하는 클래스는 java.io.Reader 클래스의 하위 클래스들이다.

- BufferedReader: 문자열 입력 스트림을 버퍼에 담아서 처리한다. 일반적으로 문자열 기반의 파일을 읽을 때 가장 많이 사용된다.
- CharArrayReader: char의 배열로 된 문자 배열을 처리한다.
- FilterReader: 문자열 기반의 스트림을 처리하기 위한 추상 클래스이다.
- FileReader: 문자열 기반의 파일을 읽기 위한 클래스이다.
- InputStreamReader: 바이트 기반의 스트림을 문자열 기반의 스트림으로 연결하는 역할을 수행한다.
- PipedReader: 파이프 스트림을 읽는다.
- StringReader: 문자열 기반의 소스를 읽는다.

BufferedReader 클래스는 다른 FileReader 클래스와 마찬가지로 문자열 단위나 문자열 배열 단위로 읽을 수 있는 기능을 제공하지만, 추가로 라인 단위로 읽을 수 있는 readLine() 메서드를 제공한다. 실제 응답 속도도 약 350ms로, 약간 빨라진다. 이 속도는 파일의 크기와 비례한다.

|  | 버퍼 없이 FileReader | 버퍼 포함한 FileReader | BufferedReader 사용시 |
| :---: | :---: | :---: | :---: |
| 응답 속도 | 2,480ms | 400ms | 350ms |

### NIO의 원리
JDK 1.4부터 새롭게 추가된 NIO가 어떤 것인지 알아보자. 자바를 사용하여 하드 디스크에 있는 데이터를 읽는다면 어떤 프로세스로 진행될까?

1. 파일을 읽으라는 메서드를 자바에 전달한다.
2. 파일명을 전달받은 메서드가 운영체제의 커널에게 파일을 읽어 달라고 요청한다.
3. 커널이 하드 디스크로부터 파일을 읽어서 자신의 커널에 있는 버퍼에 복사하는 작업을 수행한다. DMA에서 이 작업을 하게 된다.
4. 자바에서는 마음대로 커널의 버퍼를 사용하지 못하므로, JVM으로 그 데이터를 전달한다.
5. JVM에서는 메서드에 있는 스트림 관리 클래스를 사용하여 데이터를 처리한다.

자바에서는 3번 복사 작업과 4번 전달 작업을 수행할 때 대기하는 시간이 발생할 수 밖에 없다. 이러한 단점을 보완하기 위해 NIO가 탄생했다. NIO를 사용한다고 IO에서 발생하는 모든 병목 현상이 해결되는 것은 아니지만, IO를 위한 여러 가지 새로운 개념이 도입되었다.

- 버퍼의 도입
- 채널의 도입
- 문자열의 인코더와 디코어 제공
- Perl 스타일의 정규 표현식에 기초한 패턴 매칭 방법 제공
- 파일을 잠그거나 메모리 매핑이 가능한 파일 인터페이스 제공
- 서버를 위한 복합적인 Non-blocking IO 제공

### DirectByteBuffer를 잘못 사용하여 문제가 발생한 사례
NIO를 사용할 때 ByteBuffer를 사용하는 경우가 있다. ByteBuffer는 네트워크나 파일에 있는 데이터를 읽어 들일때 사용한다. ByteBuffer 객체를 생성하는 메서드에는 wrap(), allocate(), allocateDirect()가 있다. 이 중에서 allocateDirect 메서드는 데이터를 JVM에 올려서 사용하는 것이 아니라, OS 메모리에 할당된 메모리를 Native한 JNI로 처리하는 DirectByteBuffer 객체를 생성한다. 그런데 이 DirectByteBuffer 객체는 필요할 때 계속 생성해서는 안 된다.

```java
...
psvm() {
  DirectByteBuffer check = new DirectByteBufferCheck();
  for (int loop = 1; loop < 1024000; loop++) {
    check.getDirectByteBuffer();
    if (loop % 100 == 0) {
      System.out.println(loop);
    }
  }
}

public ByteBuffer getDirectByteBuffer() {
  ByteBuffer buffer = ByteBuffer.allocateDirect(65536);
  return buffer;
}
...
```

getDirectByteBuffer 메서드를 지속적으로 호출하는 간단한 코드다. getDirectByteBuffer 메서드에서는 ByteBuffer 클래스의 allocateDirect 메서드를 호출함으로써 DirectByteBuffer 객체를 생성한 후 리턴해준다.

이 예제를 실행하고 나서 GC 상황을 모니터링하기 위해 jstat 명령을 사용하여 확인해보면 거의 5~10초에 한 번씩 Full GC가 발생하는 것을 볼 수 있다. 그런데 Old 영역의 메모리는 증가하지 않는다. 왜 이러한 문제가 발생했을까?

그 이유는 DirectByteBuffer의 생성자 때문이다. 이 생성자는 java.nio 에 아무런 접근 제어자가 없이 선언된(package private) Bits라는 클래스의 reserveMemory() 메서드를 호출한다. 이 reserveMemory 메서드에서는 JVM에 할당되어 있는 메모리보다 더 많으 메모리를 요구할 경우 System.gc() 메서드를 호출하도록 되어 있다.

JVM에 있는 코드에 System.gc() 메서드가 있기 때문에 해당 생성자가 무차별적으로 생성될 경우 GC가 자주 발생하고 성능에 영향을 줄 수 밖에 없다. 따라서, 이 DirectByteBuffer 객체를 생성할 때는 매우 신중하게 접근해야만 하며, 가능하다면 singleton 패턴을 사용하여 해당 JVM에는 하나의 객체만 생성하도록 하는 것을 권장한다.

---

# 10. 로그는 반드시 필요한 내용만 찍자

### System.out.println()의 문제점
파일이나 콘솔에 로그를 남길 경우 애플리케이션에서는 대기 시간이 발생한다. 이 대기 시간은 시스템의 속도에 의존적이다. 만약 디스크에 로그를 남긴다면, 서버 디스크의 RPM이 높을수록 로그의 처리 속도는 빨라질 것이다.

> 개션율이란 튜닝 전과 후의 차이를 수치로 나타낸 것이다. 다음의 공식으로 구한다<br/>
> (튜닝 전 응답 속도 - 튜닝 후 응답 속도) * 100 / 튜닝 후 응답 속도 = 개선율(%)

의미 없는 디버그용 로그를 프린트하기 위해서 아까운 서버의 리소스와 디스크가 낭비될 수 있다. 별다른 튜닝도 필요 없는 로그 제거 작업이 성능을 얼마나 많이 향상 시킬 수 있을지 다시 한 번 생각해 보고, 운영 서버의 소스에 있는 모든 시스템 로그를 제거하기 바란다.

### System.out.format() 메서드
format() 메서드는 JDK 5.0의 System 클래스에서 사용하는 out 객체 클래스인 PrintStream에 새로 추가되었다. 문자열을 사용할 경우에는 %s, int나 long과 같은 정수형을 나타낼 경우에는 %d, float이나 double을 나타낼 경우에는 %f를 사용하면 된다.

```java

String str1;
for (int i = 0; i < repeats; i++) {
  str1 = "aaa" + " " + "bbb" + " " + "ccc" + " " + 1L;
}

String str2;
for (int i = 0; i < repeats; i++) {
  str2 = String.format("%s %s %s %d", "aaa", "bbb", "ccc", 1L);
}
```

이 코드를 컴파일한 클래스를 역 컴파일 해보면 String을 더하는 문장(str1)은 다음과 같이 변환된다.

```java
(new StringBuilder(String.valueOf("aaa"))).append(" ")
  .append("bbb").append(" ")
  .append("ccc").append(" ")
  .append(1L).append(" ").toString();
```

그리고 format() 메서드를 사용하는 문장은 다음과 같이 변환된다.

```java
str2 = String.format("%s %s %s %d", new Object[] {
  "aaa", "bbb", "ccc", Long.valueOf(1)
}});
```

컴파일시 변환된 부분을 보면 새로운 Object 배열을 생성하여 그 값을 배열에 포함 시키도록 되어 있다. 게다가 long 값을 Object 형태로 나타내기 위해서 Long 클래스의 valueOf() 메서드를 사용하고 있다.

실제 String.format() 메서드의 소스를 보면, 그 내부에서 java.util 패키지에 있는 Formatter 클래스를 호출한다. Formatter 클래스에서는 %가 들어가 있는 format 문자열을 항상 파싱(parsing)하기 때문에 문자열을 그냥 더하는 것보다 성능이 좋을 수 없다.

만약 디버그용으로 사용한다면, 필자는 format 메서드를 사용하기를 권장한다. 더 편리하고 소스의 가독성도 높아지기 때문이다. 다만 운영 시에는 디버그용 로그를 제거할 경우를 가정하고 권하는 것임을 꼭 명심하기 바란다.

### 로그를 더 간결하게 처리하는 방법
모든 소스를 찾아 다니면서 printFlag를 변경하는 것보다 간단한 flag 정보를 갖는 클래스를 만들어 관리하면 약간 더 편하다.

```java
public class LogFlag {
  public static final boolean printFlag = false;
}

...
if (LogFlag.printFlag) {
  System.out.format("LogRemoveSample.getList() : size = %d\n", retList.size());
}
...
```

매번 if 문장으로 막는 것보다 간단하게 사용하기 위해서는 좀 더 보완을 해서 다음과 같이 클래스를 만들면 된다.

```java
public class SampleLogger {
  private static final boolean printFlag = false;
  public static void log(String message) {
    if (printFlag) {
      System.out.println(message);
    }
  }
}
```

SimpleLogger.log("...") 같은 방식으로 소스를 작성하면 되고, printFlag에 따라서 로그를 남길지, 남기지 않을지를 결정 할 수 있다. 이 소스의 단점은 printFlag를 수정하기 위해서 다시 컴파일해야 한다는 점과 어차피 log() 메서드 요청을 하기 위해서 메시지 문자열을 생성해야 한다는 것이다.

### 로거 사용 시의 문제점
운영 시 로그 레벨을 올려 놓는다고 해도, 디버그용 로그 메시지는 간단한 문자든 간단한 쿼리든 상관 없이 하나 이상의 객체가 필요하다. 그러면 그 객체를 생성하는 데 메모리와 시간이 소요된다. 또한 메모리에서 제거하기 위해서는 GC를 수행해야 하고, GC 수행 시간이 또 소요된다.

가장 좋은 방법은 디버그용 로그를 제거하는 것이다. 하지만 그렇지 못한 것이 현실이다. 그래서 이 경우에는 시스템 로그의 경우처럼 로그 처리 여부를 처리하는 것이 좋다.

```java
if (logger.isLoggable(Level.INFO)) {
  // 로그 처리
}
```

이렇게 if 문장으로 처리하면 로그를 위한 불필요한 메모리 사용을 줄일 수 있어, 더 효율적으로 메시지를 처리할 수 있다.

### 로그를 깔끔하게 처리해주는 slf4j와 LogBack

> Simple Logging Facade for Java(SLF4J)

```java
...
logger.debug("Temperature set to {}. Old temperature was {}.", newT, oldT);
...
logger.debug("Temperature has risen above 50 degrees.");
...
```

기존 로거들은 앞 절에서 이야기한 대로 출력을 위해서 문자열을 더해 전달해 줘야만 했다. 하지만, slf4j는 format 문자열에 중괄호를 넣고, 그 순서대로 출력하고자 하는 데이터들을 콤마로 구분하여 전달해준다. 이렇게 전달해 주면 로그를 출력하지 않을 경우 필요 없는 문자열 더하기 연산이 발생하지 않는다.

추가로 LogBack이라는 로거는 예외의 스택 정보를 출력할 때 해당 클래스가 어떤 라이브러리를 참고하고 있는지도 포함하여 제공하기 때문에 쉽게 관련된 클래스를 확인할 수 있다.

### 예외 처리는 이렇게
여러 스레드에서 콘솔에 로그를 프린트하면 데이터가 섞인다. 자바의 예외 스택 정보는 로그를 최대 100개까지 프린트하기 때문에 서버의 성능에도 많은 부하를 준다. 스택 정보를 가져오는 부분에서는 거의 90% 이상이 CPU를 사용하는 시간이고, 나머지 프린트하는 부분에서는 대기 시간이 소요된다.

예외를 메시지로 처리하면 실제 사용자들은 한 줄의 오류 메시지나 오류 코드만을 보게되기 때문에 장애를 처리하기 쉽지 않다. 스택 정보를 보고 싶을 경우에는 다음과 같이 처리하는 방법도 있다.

```java
try {
  ...
} catch (Exception e) {
  StackTraceElement[] ste = e.getStackTrace();
  String className = ste[0].getClassName();
  String methodName = ste[0].getMethodName();
  int lineNumber = ste[0].getLineNumber();
  String fileName = ste[0].getFileName();
  logger.severe("Exception : " + e.getMessage());
  logger.severe(className + "." + methodName + " " + fileName + " " + lineNumber + "line");
}
```

마지막 라인의 문자열 더하는 구문들은 어차피 StringBuilder로 변환되므로 큰 성능 저하를 발생시키지 않는다.

참고로 StackTraceElement 배열의 0번째에는 예외가 발생한 클래스 정보가 있으며, 마지막에는 최초 호출된 클래스의 정보가 있다.

---

# References
- [개발자가 반드시 알아야 할 자바 성능 튜닝 이야기](http://www.yes24.com/Product/Goods/11261731)
- [Core J2EE Patterns](http://www.corej2eepatterns.com/)
