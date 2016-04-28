---
layout: post
title: Process와 Thread
categories: [general, setup, demo]
tags: [demo, dbyll, dbtek, setup]
fullview: true
comments: true
---


# Process와 Thread

![Process_Thread](/img/2015/11/29/Process_Thread.gif "Process_Thread")

이 그림은 Process와 Thread를 잘 나타내는데 네모 박스는 하나의 프로세스를 나타내고 실은 쓰레드를 나타낸다. 하나의 프로세스에 여러 개의 쓰레드가 있을 수 있지만, 하나의 쓰레드에 여러 개가 있을 수는 없다. 쓰레드는 독립적으로 실행될 수 없고, 하나의 프로세스에 종속되기 때문이다.

**하나의 프로세스는 운영체제의 가상 메모리 공간에 독립적인 할당 공간에서 로딩이 된다. 쓰레드는 프로세스에 종속되기 때문에 마찬가지로 할당된 메모리 공간에서 움직인다. 그러므로 Main procedure에서 선언된 변수나 함수는 그 프로세스에서 일을 하는 모든 쓰레드가 접근할 수 있게 된다.** 그러나 쓰레드가 동작하는 순서는 프로그래머가 동기화할 수 없는 경우가 많다.(쓰레드의 많은 예제 중에 여러 개의 쓰레드에서 전역 변수 값을 1씩 올리며 출력하는데 순서대로 올라가지 않는  예제)

프로세스와 쓰레드를 설명할 수 있는 쉬운 예는 곰플레이어와 같은 프로그램이다. AVI 파일을 클릭하면 이 프로그램은 자막이 있으면 자막을 보여주고, 사운드를 들려주고,영상을 보여주며 전체화면으로 바꾸면 끊기지 않고 전체화면으로 바꿔준다. 이것은 단일 프로세스의 단일 쓰레드로는 구현이 불가능하다(불가능하다기 보다 대단히 어려운 과정을 거쳐야함...). 사운드를 들려주는 쓰레드, 영상을 보여주는 쓰레드, 프레임을 조정하는 쓰레드, 자막을 관리하는 쓰레드가 각자 자기 할일을 하고 있으며, 각각의 쓰레드가 CPU의 자원을 독점적으로 쓰지 않고 적절히 양보하면서 쓰기 때문에 가능하다.

<br>

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