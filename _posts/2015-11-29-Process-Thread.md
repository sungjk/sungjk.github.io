---
layout: entry
title: Process & Thread
author: 김성중
author-email: ajax0615@gmail.com
description: 프로세스와 쓰레드에 대한 설명입니다.
keywords: 프로세스, 쓰레드, 스레드, process, thread
publish: true
---

![Process_Thread](/images/2015/11/29/Process_Thread.gif "Process_Thread")

이 그림은 Process와 Thread를 잘 나타내는데 네모 박스는 하나의 프로세스를 나타내고 실은 쓰레드를 나타낸다. 하나의 프로세스에 여러 개의 쓰레드가 있을 수 있지만, 하나의 쓰레드에 여러 개가 있을 수는 없다. 쓰레드는 독립적으로 실행될 수 없고, 하나의 프로세스에 종속되기 때문이다.

프로세스와 스레드는 서로 관련은 있지만 기본적으로 다르다.

프로세스는 실행되고 있는 프로그램의 인스턴스라고 생각할 수 있다. 프로세스는 CPU 시간이나 메모리 등의 시스템 자원이 할당되는 독립적인 개체이다. 각 프로세스는 별도의 주소 공간에서 실행되며, 한 프로세스는 다른 프로세스의 변수나 자료구조에 접근할 수 없다. 한 프로세스가 다른 프로세스의 자원에 접근하려면 프로세스 간 통신(inter-process communication)을 사용해야 한다. 프로세스 간 통신 방법으로는 파이프, 파일, 소켓 등을 이용한 방법이 있다.

**하나의 프로세스는 운영체제의 가상 메모리 공간에 독립적인 할당 공간에서 로딩이 된다. 쓰레드는 프로세스에 종속되기 때문에 마찬가지로 할당된 메모리 공간에서 움직인다. 그러므로 Main procedure에서 선언된 변수나 함수는 그 프로세스에서 일을 하는 모든 쓰레드가 접근할 수 있게 된다.**

프로세스와 쓰레드를 설명할 수 있는 쉬운 예는 곰플레이어와 같은 프로그램이다. AVI 파일을 클릭하면 이 프로그램은 자막이 있으면 자막을 보여주고, 사운드를 들려주고,영상을 보여주며 전체화면으로 바꾸면 끊기지 않고 전체화면으로 바꿔준다. 이것은 단일 프로세스의 단일 쓰레드로는 구현이 불가능하다(불가능하다기 보다 대단히 어려운 과정을 거쳐야함...). 사운드를 들려주는 쓰레드, 영상을 보여주는 쓰레드, 프레임을 조정하는 쓰레드, 자막을 관리하는 쓰레드가 각자 자기 할일을 하고 있으며, 각각의 쓰레드가 CPU의 자원을 독점적으로 쓰지 않고 적절히 양보하면서 쓰기 때문에 가능하다.

![Threads](/images/2015/11/29/threads.jpg "Threads")

스레드는 프로세스 안에 존재하며 프로세스의 자원(Code, Data, Heap, 열린 파일이나 시그널 같은 운영체제 자원 등)을 공유한다. 같은 프로세스 안에 있는 여러 프로세스들은 같은 힘 공간을 공유한다. 반면에 프로세스는 다른 프로세스의 메모리에 직접 접근할 수 없다. 각각의 스레드는 별도의 레지스터와 스택을 갖고 있지만, 힙 메모리는 서로 읽고 쓸 수 있다.

---

### 문제 1
다음과 같은 코드가 있다고 하자.

```java
public class Foo {
    public Foo() { ... }
    public void first() { ... }
    public void second() { ... }
    public void third() { ... }
}
```

Foo 인스턴스 하나를 서로 다른 세 스레드에 전달한다. threadA는 first를 호출할 것이고, threadB는 second를 호출할 것이며, threadC는 third를 호출할 것이다. first가 second보다 먼저 호출되고, second가 third보다 먼저 호출되도록 보장하는 메커니즘을 설계하라.

### 해결 1
second()를 실행하기 전에 first()가 끝났는지 확인한다. third()를 호출하기 전에 second()가 끝났는지 확인한다. 스레드 안전성(thread safety)에 대해 각별히 유의해야 하는데, 단순히 불린(boolean) 타입의 플래그 변수만으로는 스레드 안전성을 확보할 수 없다.

lock을 써서 다음과 같은 코드를 만든다면 어떨까?

```java
public class FooBad {
    public int pauseTime = 1000;
    public ReentrantLock lock1, lock2;

    public FooBad() {
        try {
            lock1 = new ReentrantLock();
            lock2 = new ReentrantLock();
            lock1.lock();
            lock2.lock();
        } catch (...) { ... }
    }

    public void first() {
        try {
            ...
            lock1.unlock(); // first()가 끝났다고 표시
        } catch (...) { ... }
    }

    public void second() {
        try {
            lock1.lock();   // first()가 끝날 때까지 대기
            lock1.unlock();
            ...
            lock2.unlock(); // second()가 끝났다고 표시
        } catch (...) { ... }
    }

    public void third() {
        try {
            lock2.lock();   // third()가 끝날 때까지 대기
            lock2.unlock();
            ...
        } catch (...) { ... }
    }
}
```

그런데 이 코드는 락 소유권(lock ownership) 문제 때문에 정상적으로 동작하지 않는다. 한 스레드가 락을 수행했지만(FooBad의 생성자), 다른 스레드가 해당 락을 풀려고 시도하고 있다. 그렇게 하려고 하면 예외(exception)가 발생한다. 자바에서 락은 락을 건 스레드가 소유한다.

대신, 세마포어(semaphores)를 사용하면 이 문제를 해결할 수 있다. 논리는 동일하다.

```java
public class Foo {
    public Semaphore sem1, sem2;

    public Foo() {
        try {
            sem1 = new Semaphore(1);
            sem2 = new Semaphore(1);

            sem1.acquire();
            sem2.acquire();
        } catch (...) { ... }
    }

    public void first() {
        try {
            ...
            sem1.release();
        } catch (...) { ... }
    }

    public void second() {
        try {
            sem1.acquire();
            sem1.release();
            ...
            sem2.release();
        } catch (...) { ... }
    }

    public void thrid() {
        try {
            sem2.acquire();
            sem2.release();
            ...
        } catch (...) { ... }
    }
}
```

---

### 문제 2
동기화된 메서드 A와 일반 메서드 B가 구현된 클래스가 있다. 같은 프로그램에서 실행되는 스레드가 두 개 존재할 때 A를 동시에 실행할 수 있는가? A와 B는 동시에 실행될 수 있는가?

### 해결 2
메서드에 synchronized를 적용하면 두 스레드가 동일한 객체의 메서드를 동시에 실행하지 못하도록 할 수 있다.

따라서 첫 질문에 대한 답은 '상황에 따라 다르다'이다. 두 스레드가 같은 객체를 갖고 있다면 답은 NO이다. 메서드 A를 동시에 실행할 수 없다. 하지만 다른 객체라면 YES이다. 동시에 실행할 수 있다.

개념적으로 보면 락(lock)과 같다. synchronized 메서드를 호출하면, 동일한 객체에 정의된 모든 synchronized 메서드에 락이 걸리는 것고 같다. 따라서 해당 객체의 synchronized 메서드를 실행하려는 다른 스레드는 모두 블록된다.

두 번째 질문에서, thread2가 synchronized로 선언되지 않은 메서드 B를 실행하는 동안, thread1은 synchronized로 선언된 메서드 A를 실행할 수 있나? B가 synchronized로 선언되지 않았으므로, thread1이 A를 실행하지 못할 이유가 없다. 따라서 thread1과 thread2가 같은 객체를 가리킨다고 하더라도 실행할 수 있다.

여기서 기억해 두어야 할 가장 핵심적인 개념은, 객체별로 실행 가능한 synchronized 메서드는 하나뿐이라는 것이다. 다른 스레드는 해당 객체의 비-synchronized 메서드 혹은 다른 객체의 메서드는 실행할 수 있다.

---

# 요약

### Process
* 멀티 프로세스 시스템 내에서 실행된 프로그램의 인스턴스
* 프로세스는 각 프로세스 별로 독립된 메모리 공간을 갖는다. 그렇기 때문에 어떤 프로세스가 다른 프로세스의 메모리에 직접 접근할 수 없다. 이는 IPC(Inter-Process-Communication)를 통해 프로세스 간 통신이 가능하다.
* 컨텍스트-스위칭(Context-switch) 시 보존해 두어야 할 정보가 상대적으로 많아 컨텍스트 스위치하는 시간이 길다.

### Thread
* 하나의 프로세스는 기본적으로 메인 쓰레드를 가지고 실행된다. 멀티-쓰레드가 지원되는 시스템 내에서는 하나의 프로세스가 여러 개의 쓰레드를 실행할 수 있다.
* 쓰레드는 메모리를 공유한다. 하나의 쓰레드가 메모리에 쓰고, 다른 쓰레드가 메모리를 읽는 것이 가능하다. 따라서 쓰레드 간의 통신은 상대적으로 쉽고 간단하게 구현할 수 있다. 대신 메모리를 공유하기 때문에 동기화(Synchronization), 데드락(Deadlock) 등의 문제가 발생할 수 있어, 설게 및 제어를 잘 해야 한다. 또한 멀티-쓰레드 프로그래밍의 경우, 미묘한 시간 차이 등에 의한 문제가 발생하기에 상대적으로 디버깅이 어렵다.
* 컨텍스트-스위칭(Contxt-switch) 시 보존해 두어야 할 정보가 상대적으로 적어 컨텍스트 스위치하는 시간이 짧다. 따라서 연달아 쉬고 있는 복수의 작업을 행하는 경우에는 프로세스보다 쓰레드가 좋은 경우가 많다.

### Multi-Process / Multi-Thread
* 각 프로세스간의 메모리 구분이 필요하거나 독립된 주소 공간을 가져야 할 경우, 멀티 프로세스를 사용
* 따라서, 독립적이고 안정적인걸 원하면 멀티 프로세스를 사용
* 컨텍스트-스위칭이 자주 일어나서 주소 공간의 공유가 빈번한 모델일 경우, 멀티 스레드를 사용
* 따라서, 데이터 공유가 빈번하면 멀티 스레드.
