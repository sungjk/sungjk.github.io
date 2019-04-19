---
layout: entry
post-category: java
title: 자바 성능 튜닝 이야기 - 4
author: 김성중
author-email: ajax0615@gmail.com
description: 이상민님의 '자바 성능 튜닝 이야기'를 읽고 정리한 글입니다.
keywords: Java, 자바
publish: true
---

![java_performance_tuning](/images/2019/03/28/java_performance_tuning.jpeg "java_performance_tuning"){: .center-image }

# 16. JVM은 도대체 어떻게 구동될까?
자바를 만든 Sun에서는 자바의 성능을 개선하기 위해서 Just In Time(JIT) 컴파일러를 만들었고, 이름을 HotSpot으로 지었다. 여기서 JIT 컴파일러는 프로그램의 성능에 영향을 주는 지점에 대해서 지속적으로 분석한다. 분석된 지점은 부하를 최소화하고, 높은 성능을 내기 위한 최적화의 대상이 된다. 이 HotSpot은 자바 1.3 버전부터 기본 VM으로 사용되어 왔기 때문에, 지금 운영되고 있는 대부분의 시스템들은 모두 HotSpot 기반의 VM이라고 생각하면 된다. HotSpot VM은 세 가지 주요 컴포넌트로 되어 있다.

- VM(Virtual Machine) 런타임
- JIT(Just In Time) 컴파일러
- 메모리 관리자

![hotspot-vm](/images/2019/04/06/hotspot-vm.png "hotspot-vm"){: .center-image }

\'HotSpot VM Runtime\'에 \'GC\'와 \'JIT 컴파일러\'를 끼워 맞춰 사용할 수 있다. 이를 위해서 \'VM 런타임\'은 JIT 컴파일러용 API와 가비지 컬렉터용 API를 제공한다. 그리고, JVM을 시작하는 런처와 스레드 관리, JNI 등도 VM 런타임에서 제공한다.

### JIT Optimizer라는게 도대체 뭘까?
모든 코드는 초기에 인터프리터에 의해서 컴파일되고, 해당 코드가 충분히 많이 사용될 경우에 JIT가 컴파일할 대상이 된다. HotSpot VM에서 이 작업은 각 메서드에 있는 카운터를 통해서 통제되며, 메서드에는 두 개의 카운터가 존재한다.

- 수행 카운터(Invocation counter): 메서드를 시작할 때마다 증가
- 백에지 카운터(backedge counter): 높은 바이트 코드 인덱스에서 낮은 인덱스로 컨트롤 흐름이 변경될 때마다 증가

backedge counter는 메서드가 루프가 존재하는지를 확인할 때 사용되며, Invocation counter 보다 컴파일 우선순위가 높다.

이 카운터들이 인터프리터에 의해서 증가될 때마다 그 값들이 한계치에 도달했는지를 확인하고, 도달했을 경우 인터프리터는 컴파일을 요청한다. Invocation counter에서 사용하는 한계치는 CompileThreashold이며, backedge counter에서 사용하는 한계치는 다음의 공식을 계산한다.

CompileThreashold * OnStackReplacePercentage / 100

> 이 두 개의 값들은 JVM이 시작할 때 지정 가능하며 다음과 같이 시작 옵션에 지정할 수 있다.<br/>
> -XX:CompileThreashold=35000<br/>
> -XX:OnStackReplacePercentage=80<br/>
> 이렇게 지정하면 메서드가 35000번 호출되었을 때 JIT에서 컴파일을 하며, backedge counter가 35000 * 80 / 100 = 28000이 되었을때 컴파일된다.

컴파일이 요청되면 컴파일 대상 목록의 큐에 쌓이고, 하나 이상의 컴파일러 스레드가 이 큐를 모니터링한다. 만약 컴파일 스레드가 바쁘지 않을 때는 큐에서 대상을 빼내서 컴파일을 시작한다. 보통 인터프리터는 컴파일이 종료되기를 기다리지 않고 Invocation counter를 리셋하고 인터프리터에서 메서드 수행을 계속한다. 컴파일이 종료되면 컴파일된 코드와 메서드가 연결되어 그 이후부터는 메서드가 호출되면 컴파일된 코드를 사용하게 된다. 만약 인터프리터에서 컴파일이 종료될 때까지 기다리도록 하려면 JVM 시작시 -Xbatch나 -XX:-BackgroundCompilation 옵션을 지정하여 컴파일을 기다리도록 할 수도 있다.

HotSpot VM은 OSR(On Stack Replacement)이라는 특별한 컴파일도 수행한다. 이 OSR은 인터프리터에서 수행한 코드 중 오랫동안 루프가 지속되는 경우에 사용된다. 만약 해당 코드의 컴파일이 완료된 상태에서 최적화되지 않은 코드가 수행되고 있는 것을 발견한 경우에 인터프리터에 계속 머무르지 않고 컴파일된 코드로 변경한다. 이 작업은 인터프리터에서 시작된 오랫동안 지속되는 루프가 다시는 불리지 않을 경우엔 도움이 되지 않지만, 루프가 끝나지 않고 지속적으로 수행되고 있을 경우에는 큰 도움이 된다.

> Java 5 HotSpot VM이 발표되면서 새로운 기능이 추가되었다. 이 기능은 JVM이 시작될 떄 플랫폼과 시스템 설정을 평가하여 자동으로 garbage collector를 선정하고, 자바 힙 사이즈와 JIT 컴파일러를 선택하는 것이다. 이 기능을 통해서 애플리케이션의 활동과 객체 할당 비율에 따라서 garbage collector가 동적으로 자바 힙 사이즈를 조절하며, New의 Eden과 Survivor, Old 영역의 비율을 자동적으로 조절하는 것을 의미한다. 이 기능은 -XX:+UseParallelGC와 -XX:+UseParallelOldGC에서만 적용되며, 이 기능을 제거하려면 -XX:-UseAdaptiveSizePolicy라는 옵션을 적용하여 끌 수가 있다.

### JRockit의 JIT 컴파일 및 최적화 절차
![jrockit-1](/images/2019/04/06/jrockit-1.gif "jrockit-1"){: .center-image }

JVM은 각 OS에서 작동할 수 있도록 자바 코드를 입력 값(정확하게는 바이트코드)으로 받아 각종 변환을 거친 후 해당 칩의 아키텍처에서 잘 돌아가는 기계어 코드로 변환되어 수행되는 구조로 되어 있다.

![jrockit-2](/images/2019/04/06/jrockit-2.gif "jrockit-2"){: .center-image }

JRockit은 이와 같이 최적화 단계를 거치도록 되어 있으며, 각각의 단계는 다음의 작업을 수행한다.

- **JRockit runs JIT compilation**<br/>
자바 애플리케이션을 실행하면 기본적으로는 1번 단계인 JIT 컴파일을 거친 후 실행이 된다. 이 단계를 거친 후 메서드가 수행되면, 그 다음부터는 컴파일된 코드를 호출하기 때문에 처리 성능이 빨라진다.<br/>
애플리케이션이 시작하는 동안 몇천 개의 새로운 메서드가 수행되며 이로 인해 다른 JVM보다 JRockit JVM이 더 느릴 수 있다. 그리고 이 작업으로 인해 JIT가 메서드를 수행하고 컴파일하는 작업은 오버헤드가 되지만, JIT가 없으면 JVM은 계속 느린 상태로 지속될 것이다. 다시 말해서 JIT를 사용하면 시작할 때의 성능은 느리겠지만, 지속적으로 수행할 때는 더 빠른 처리가 가능하다. 따라서 모든 메서드를 컴파일하고 최적화하는 작업은 JVM 시작 시간을 느리게 만들기 때문에 시작할 때는 모든 메서드를 최적화하지는 않는다.

- **JRockit monitors threads**<br/>
JRockit에는 \'sampler thread\'라는 스레드가 존재하며 주기적으로 애플리케이션의 스레드를 점검한다. 이 스레드는 어떤 스레드가 동작 중인지 여부와 수행 내역을 관리한다. 이 정보들을 통해서 어떤 메서드가 많이 사용되는지를 확인하여 최적화 대상을 찾는다.

- **JRockit JVM performs optimization**<br/>
\'sampler thread\'가 식별한 대상을 최적화한다. 이 작업은 백그라운드에서 진행되며 수행중인 애플리케이션에 영향을 주지는 않는다.

### JVM이 시작할 때의 절차는 이렇다
1. java 명령어 줄에 있는 옵션 파싱:<br/>
일부 명령은 자바 실행 프로그램에서 적절한 JIT 컴파일러를 선택하는 등의 작업을 하기 위해서 사용하고 다른 명령들은 HotSpot VM에 전달된다.
2. 자바 힙 사이즈 할당 및 JIT 컴파일러 타입 지정:<br/>
메모리 크기나 JIT 컴파일러 종류가 명시적으로 지정되지 않은 경우에 자바 실행 프로그램이 시스템의 상황에 맞게 선정한다. 이 과정은 좀 복잡한 단계(HotSpot VM Adaptive Tuning)을 거치니 일단 넘어가자.
3. CLASSPATH와 LD_LIBRARY_PATH 같은 환경 변수를 지정한다.
4. 자바의 Main 클래스가 지정되지 않았으면, Jar 파일의 manifest 파일에서 Main 클래스를 확인한다.
5. JNI의 표준 API인 JNI_CreateJavaVM를 사용하여 새로 생성한 non-primordial이라는 스레드에서 HotSpot VM을 생성한다.
6. HotSpot VM이 생성되고 초기화되면, Main 클래스가 로딩된 런처에서는 main() 메서드의 속성 정보를 읽는다.
7. CallStaticVoidMethod는 네이티브 인터페이스를 불러 HotSpot VM에 있는 main() 메서드가 수행된다. 이때 자바 실행 시 Main 클래스 뒤에 있는 값들이 전달된다.

추가로 5.에 있는 자바의 가상 머신(JVM)을 생성하는 JNI_CreateJavaVM 단계에 대해서 더 알아보자. 이 단계에서는 다음의 절차를 거친다.

1. JNI_CreateJavaVM는 동시에 두개의 스레드에서 호출할 수 없고, 오직 하나의 HotSpot VM 인스턴스가 프로세스 내에서 생성될 수 있도록 보장한다. HotSpot VM이 정적인 데이터 구조를 생성하기 때문에 다시 초기화는 불가능해서 오직 하나의 HotSpot VM이 프로세스에서 생성될 수 있다.
2. JNI 버전이 호환성 있는지 점검하고, GC 로깅을 위한 준비도 완료한다.
3. OS 모듈들이 초기화된다. 예를 들면 랜덤 번호 생성기, PID 할당 등이 여기에 속한다.
4. 커맨드 라인 변수와 속성들이 JNI_CreateJavaVM 변수에 전달되고, 나중에 사용하기 위해서 파싱한 후 보관한다.
5. 표준 자바 시스템 속성(properties)이 초기화된다.
6. 동기화, 메모리, safepoint 페이지와 같은 모듈들이 초기화된다.
7. libzip, libhpi, libjava, libthread와 같은 라이브러리들이 로드된다.
8. 시그널 처리기가 초기화 및 설정된다.
9. 스레드 라이브러리가 초기화된다.
10. 출력(output) 스트림 로거가 초기화된다.
11. JVM을 모니터링하기 위한 에이전트 라이브러리가 설정되어 있으면 초기화 및 시작된다.
12. 스레드 처리를 위해서 필요한 스레드 상태와 스레드 로컬 저장소가 초기화된다.
13. HotSpot VM의 \'글로벌 데이터\'들이 초기화된다. 글로벌 데이터에는 이벤트 로그(event log), OS 동기화, 성능 통계 메모리(perfMemory), 메모리 할당자(chunkPool)들이 있다.
14. HotSpot VM에서 스레드를 생성할 수 있는 상태가 된다. main 스레드가 생성되고, 현재 OS 스레드에 붙는다. 그러나 아직 스레드 목록에 추가되지는 않는다.
15. 자바 레벨의 동기화가 초기화 및 활성화된다.
16. 부트 클래스로더, 코드 캐시, 인터프리터, JIT 컴파일러, JNI, 시스템 dictionary, \'글로벌 데이터\' 구조의 집합인 universe 등이 초기화된다.
17. 스레드 목록에 자바 main 스레드가 추가되고 universe의 상태를 점검한다. HotSpot VM의 중요한 기능을 하는 HotSpot VM Thread가 생성된다. 이 시점에 HotSpot VM의 현재 상태를 JVMTI에 전달한다.
18. java.lang 패키지에 있는 String, System, Thread, ThreadGroup, Class 클래스와 java.lang의 하위 패키지에 있는 Method, Finalizer 클래스 등이 로딩되고 초기화된다.
19. HotSpot VM의 시그널 핸들러 스레드가 시작되고 JIT 컴파일러가 초기화되며 HotSpot의 컴파일 브로커 스레드가 시작된다. 그리고 HotSpot VM과 관련된 각종 스레드들이 시작한다. 이때부터 HotSpot VM의 전체 기능이 동작한다.
20. JNIEnv가 시작되며 HotSpot VM을 시작한 호출자에게 새로운 JNI 요청을 처리할 상황이 되었다고 전달해 준다.

이렇게 복잡한 JNI_CreateJavaVM 시작 단계를 거치고 나머지 단계들을 거치면 JVM이 시작된다.

### JVM이 종료될 때의 절차는 이렇다
HotSpot VM의 종료는 다음의 DestroyJavaVM 메서드의 종료 절차를 따른다.

1. HotSpot VM이 작동중인 상황에서는 단 하나의 데몬이 아닌 스레드(nondaemon thread)가 수행될 때까지 대기한다.
2. java.lang 패키지에 있는 Shutdown 클래스의 shutdown() 메서드가 수행된다. 이 메서드가 수행되면 자바 레벨의 shutdown hook이 수행되고, finalization-on-exit이라는 값이 true일 경우에 자바 객체 finalizer를 수행한다.
3. HotSpot VM 레벨의 shutdown hook을 수행함으로써 HotSpot VM의 종료를 준비한다. 이 작업은 JVM_OnExit() 메서드를 통해서 지정된다. 그리고 HotSpot VM의 profiler, stat sampler, watcher, garbage collector 스레드를 종료시킨다. 이 작업들이 종료되면 JVMTI를 비활성화하며 Signal 스레드를 종료시킨다.
4. HotSpot의 JavaThread::exit() 메서드를 호출하여 JNI 처리 블록을 해제한다. 그리고 guard pages 스레드 목록에 있는 스레드들을 삭제한다. 이 순간부터는 HotSpot VM에서 자바 코드를 실행하지 못한다.
5. HotSpot VM 스레드를 종료한다. 이 작업을 수행하면 HotSpot VM에 남아 있는 HotSpot VM 스레드들을 safepoint로 옮기고 JIT 컴파일러 스레드들을 중지시킨다.
6. JNI, HotSpot VM, JVMTI barrier에 있는 추적(tracing) 기능을 종료시킨다.
7. 네이티브 스레드에서 수행하고 있는 스레드들을 위해서 HotSpot의 \"vm exited\" 값을 설정한다.
8. 현재 스레드를 삭제한다.
9. 입출력 스트림을 삭제하고 PrefMemory 리소스 연결을 해제한다.
10. JVM 종료를 호출한 호출자로 복귀한다.

### 클래스 로딩 절차도 알고 싶어요
자바 클래스가 메모리에 로딩되는 절차는 다음과 같다.

1. 주어진 클래스의 이름으로 class path에 있는 바이너리로 된 자바 클래스를 찾는다.
2. 자바 클래스를 정의한다.
3. 해당 클래스를 나타내는 java.lang 패키지의 Class 클래스의 객체를 생성한다.
4. 링크 작업이 수행된다. 이 단계에서 static 필드를 생성 및 초기화하고 메서드 테이블을 할당한다.
5. 클래스의 초기화가 진행되며 static 블록과 static 필드가 가장 먼저 초기화된다. 당연한 이야기지만 해당 클래스가 초기화 되기 전에 부모 클래스의 초기화가 먼저 이루어진다.

이렇게 나열하니 단계가 복잡해 보이지만, loading -> linking -> initializing 로 기억하면 된다.

### 예외는 JVM에서 어떻게 처리될까?
JVM은 자바 언어의 제약을 어겼을 때 예외(exception)라는 시그널로 처리한다. HotSpot VM 인터프리터, JIT 컴파일러 및 다른 HotSpot VM 컴포넌트는 예외 처리와 모두 관련되어 있다. 일반적인 예외 처리 경우는 아래 두 가지 경우다.

- 예외를 발생한 메서드에서 잡을 경우
- 호출한 메서드에 의해서 잡힐 경우

후자의 경우에는 보다 복잡하며 스택을 뒤져서 적당한 핸들러를 찾는 작업을 필요로 한다.

예외는,

- 던져진 바이트 코드에 의해서 초기화될 수 있으며,
- VM 내부 호출의 결과로 넘어올 수도 있고,
- JNI 호출로부터 넘어올 수도 있고,
- 자바 호출로부터 넘어올 수도 있다.

여기서 가장 마지막 경우는 단순히 앞의 세가지 경우의 마지막 단계에 속할 뿐이다.

VM이 예외가 던져졌다는 것을 알아차렸을 때, 해당 예외를 처리하는 가장 가까운 핸들러를 찾기 위해서 HotSpot VM 런타임 시스템이 수행된다. 이 때 핸들러를 찾기 위해서는 다음의 3개 정보가 사용된다.

- 현재 메서드
- 현재 바이트 코드
- 예외 객체

만약 현재 메서드에서 핸들러를 찾지 못했을 때는 현재 수행되는 스택 프레임을 통해서 이전 프레임을 찾는 작업을 수행한다. 적당한 핸들러를 찾으면, HotSpot VM 수행 상태가 변경되며, HotSpot VM은 핸들러로 이동하고 자바 코드 수행은 계속된다.

---

# 17. 도대체 GC는 언제 발생할까?

### 자바의 Runtime data area는 이렇게 구성된다
자바에서 데이터를 처리하기 위한 영역에는 어떤 것들이 있는지 살펴보자. 다음은 오라클에서 제공하는 자바 스펙 관련 문서에 명시된 영역들이다.

- PC 레지스터
- JVM 스택
- 힙(Heap)
- 메서드 영역
- 런타임 상수(constant) 풀
- 네이티브 메서드 스택

이 영역 중에서 GC가 발생하는 부분이 바로 힙 영역이다.

![java-runtime-data](/images/2019/04/06/java-runtime-data.png "java-runtime-data"){: .center-image }

상단에 있는 \'Class Loader Subsystem\'은 클래스나 인터페이스르 JVM으로 로딩하는 기능을 수행하고, \'Execution Engine\'은 로딩된 크래스의 메서드들에 포함되어 있는 모든 인스트럭션 정보를 실행한다. 이 그림을 보면 좀 복잡해 보이지만, 단순하게 이야기해서 자바의 메모리 영역은 \'Heap 메모리\'와 \'Non-Heap 메모리\'로 나뉜다.

### Heap 메모리
클래스 인스턴스, 배열이 이 메모리에 쌓인다. 이 메모리는 \'공유(shared) 메모리\'라고도 불리며 여러 스레드에서 공유하는 데이터들이 저장되는 메모리다.

### Non-heap 메모리
이 메모리는 자바의 내부 처리를 위해서 필요한 영역이다. 여기서 주된 영역이 바로 메서드 영역이다.

- **Method Area**: 메서드 영역은 모든 JVM 스레드에서 공유한다.
- **Java Stacks**: 스레드가 시작할 때 JVM 스택이 생성된다. 이 스택에는 메서드가 호출되는 정보인 프레임(frame)이 저장된다. 그리고 지역 변수와 임시 결과, 메서드 수행과 리턴에 관련된 정보들도 포함된다.
- **PC Registers**: 자바의 스레드들은 각자의 PC(Program Counter) 레지스터를 갖는다. 네이티브한 코드를 제외한 모든 자바 코드들이 수행될 때 JVM의 인스트럭션 주소를 PC 레지스터에 보관한다.
- **Native Method Stacks**: 자바 코드가 아닌 다른 언어로 된 코드들이 실행하게 될 때의 스택 정보를 관리한다.

> 스택의 크기는 고정하거나 가변적일 수 있다. 만약 연산을 하다가 JVM의 스택 크기의 최대치를 넘어섰을 경우에는 StackOverflowError가 발생한다.
> 그리고 가변적일 경우 스택의 크기를 늘이려고 할 때 메모리가 부족하거나 스레드를 생성할 때 메모리가 부족한 경우에는 OutOfMemoryError가 발생한다.

### GC의 원리
GC 작업을 하는 가비지 컬렉터(Garbage Collector)는 다음의 역할을 한다.

- 메모리 할당
- 사용 중인 메모리 인식
- 사용하지 않는 메모리 인식

사용하지 않는 메모리를 인식하는 작업을 수행하지 않으면 할당한 메모리 영역이 꽉 차서 JVM에 행(Hang)이 걸리거나, 더 많은 메모리를 할당하려는 현상이 발생할 것이다. 만약 JVM의 최대 메모리 크기를 지정해서 전부 사용한 다음 GC를 해도 더 이상 사용 가능한 메모리 영역이 없는데 계속 메모리를 할당하려고 하면 OutOfMemoryError가 발생하여 JVM이 다운될 수도 있다.

![Java-Memory-Model](/images/2019/04/06/Java-Memory-Model.png "Java-Memory-Model"){: .center-image }

자바의 메모리 영역은 크게 Young, Old, Perm 세 영역으로 나뉜다. Perm(Permanent) 영역은 없는 걸로 치자. 이 영역은 거의 사용이 되지 않는 영역으로 클래스와 메서드 정보와 같이 자바 언어 레벨에서 사용하는 영역이 아니기 때문이다. 게다가 JDK 8부터는 이 영역이 사라진다. Young 영역은 다시 Eden 영역 및 두 개의 Survivor 영역으로 나뉘므로 우리가 고려해야 할 자바의 메모리 영역은 총 4개 영역으로 나뉜다고 볼 수 있다.

- 일단 메모리에 객체가 생성되면, 가장 왼쪽인 Eden 영역에 객체가 지정된다.
- Eden 영역에 데이터가 꽉 차면, 이 영역에 있던 객체는 Survivor 영역으로 옮겨지거나 삭제된다. 두 개의 Survivor 영역 사이에 우선 순위가 있는 것은 아니다. 이 두 개의 영역 중 한 영역은 반드시 비어 있어야 한다. 그 비어 있는 영역에 Eden 영역에 있떤 객체 중 GC 후에 살아 남은 객체들이 이동한다.
- 이와 같이 Eden 영역에 있던 객체는 Survivor 영역의 둘 중 하나에 할당된다. 할당된 Survivor 영역이 차면, GC가 되면서 Eden 영역에 있는 객체와 꽉 찬 Survivor 영역에 있는 객체가 비어 있는 Survivor 영역으로 이동한다. 이러한 작업을 반복하면서 Survivor 1과 2를 왔다갔다 하던 객체들은 Old 영역으로 이동한다.
- Young 영역에서 Old 영역으로 넘어가는 객체 중 Survivor 영역을 거치지 않고 바로 Old 영역으로 이동하는 객체가 있을 수 있다. 객체의 크기가 아주 큰 경우인데 예를 들어, Survivor 영역의 크기가 16MB인데 20MB를 점유하는 객체가 Eden 영역에서 생성되면 Survivor 영역으로 옮겨 갈 수 없고 바로 Old 영역으로 이동하게 된다.

### GC의 종류
- Minor GC: Young 영역에서 발생하는 GC
- Major GC: Old 영역이나 Perm 영역에서 발생하는 GC

이 두 가지 GC가 어떻게 상호 작용하느냐에 따라 GC 방식에 차이가 나며, 성능에도 영향을 준다.

GC가 발생하거나 객체가 각 영역에서 다른 영역으로 이동할 때 애플리케이션의 병목이 발생하면서 성능에 영향을 주게 된다. 그래서 핫-스팟(Hot Spot) VM에서는 스레드 로컬 할당 버퍼(TLABs: Thread-Local Allocation Buffers)라는 것을 사용한다. 이를 통하여 각 스레드별 메모리 버퍼를 사용하면 다른 스레드에 영향을 주지 않는 메모리 할당 작업이 간으해진다.

### 5가지 GC 방식
JDK 7 이상에서 지원하는 GC 방식에는 다섯 가지가 있다.

**Serial Collector**<br/>
Young 영역과 Old 영역이 시리얼하게(연속적으로) 처리되며 하나의 CPU를 사용한다. Sun에서는 이 처리를 수행할 때를 Stop-the-world라고 표현한다.

![serial-collection-1](/images/2019/04/06/serial-collection-1.png "serial-collection-1"){: .center-image }

1. 살아 있는 객체들은 Eden 영역에 있다.
2. Eden 영역이 꽉차게 되면 To Survivor 영역(비어 있는 영역)으로 살아 있는 객체가 이동한다. 이때 Survivor 영역에 들어가기에 너무 큰 객체는 바로 Old 영역으로 이동한다. 그리고 From Survivor 영역의 살아 있는 객체는 To Survivor 영역으로 이동한다.
3. To Survivor 영역이 꽉 찼을 경우, Eden 영역이나 From Survivor 영역에 남아 있는 객체들은 Old 영역으로 이동한다.

![serial-collection-2](/images/2019/04/06/serial-collection-2.png "serial-collection-2"){: .center-image }

이후에 Old 영역이나 Perm 영역에 있는 객체들은 Mark-sweep-compact 콜렉션 알고리즘을 따른다. 이 알고리즘에 대해서 간단하게 말하면, 쓰이지 않는 객체를 표시해서 삭제하고 한 곳으로 모으는 알고리즘이다. 다음과 같이 수행된다.

1. Old 영역으로 이동된 객체들 중 살아 있는 객체를 식별(mark).
2. Old 영역의 객체들을 훑는 작업을 수행하여 쓰레기 객체를 식별(sweep).
3. 필요 없는 객체들을 지우고 살아 있는 객체들을 한 곳으로 모은다(compaction).

![serial-collection-3](/images/2019/04/06/serial-collection-3.png "serial-collection-3"){: .center-image }

이렇게 작동하는 시리얼 콜렉터는 일반적으로 클라이언트 종류의 장비에서 많이 사용된다. 다시 말하면 대기 시간이 많아도 큰 문제되지 않는 시스템에서 사용된다는 의미다. 시리얼 콜렉터를 명시적으로 지정하려면 자바 명령 옵션에 -XX:+UseSerialGC를 지정하면 된다.

**Parallel Collector**<br/>
다른 CPU가 대기 상태로 남아 있는 것을 최소화하는 것을 목표로 한다. Serial Collector와 달리 Young 영역에서의 콜렉션을 병렬(Parallel)로 처리한다. 많은 CPU를 사용하기 때문에 GC의 부하를 줄이고 애플리케이션의 처리량을 증가시킬 수 있다.

Old 영역의 GC는 Serial Collector와 마찬가지로 Mark-sweep-compact 콜렉션 알고리즘을 사용한다. 이 방법으로 GC를 지정하려면 -XX:+UseParallelGC 옵션을 추가하면 된다.

![parallel-collection](/images/2019/04/06/parallel-collection.png "parallel-collection"){: .center-image }

**Parallel Compacting Collector**<br/>
Parallel Collector와 다른 점은 Old 영역 GC에서 새로운 알고리즘을 사용한다.

1. Marking: 살아 있는 객체를 식별하여 표시
2. Summary: 이전에 GC를 수행하여 컴팩션된 영역에 살아 있는 객체의 위치를 조사하는 단계
3. Compaction: 컴팩션을 수행하는 단계. 수행 이후에는 컴팩션된 영역과 비어 있는 영역으로 나뉜다.

병렬 콜렉터와 동일하게 이 방식도 여러 CPU를 사용하는 서버에 적합하다. GC를 사용하는 스레드 개수는 -XX:ParallelGCThreads=n 옵션으로 조정할 수 있다. 이 방식을 사용하려면 -XX:UseParallelOldGC 옵션을 추가하면 된다.

**Concurrent Mark-Sweep(CMS) Collector**<br/>
힙 메모리 영역의 크기가 클 때 적합하다. Young 영역에 대한 GC는 Parallel Collector와 동일하고, Old 영역은 다음 단계를 거친다.

- Initial mark: 매우 짧은 대기 시간으로 살아 있는 객체를 찾는 단계
- Concurrent marking: 서버 수행과 동시에 살아 있는 객체에 표시를 해놓는 단계
- Remark: Concurrent marking 단계에서 표시하는 동안 변경된 객체에 대해서 다시 표시하는 단계
- Concurrent sweep: 표시되어 있는 쓰레기를 정리하는 단계

![cms-collector-1](/images/2019/04/06/cms-collector-1.png "cms-collector-1"){: .center-image }

![cms-collector-2](/images/2019/04/06/cms-collector-2.png "cms-collector-2"){: .center-image }

CMS 콜렉터 방식은 2개 이상의 프로세서를 사용하는 서버에 적당하다(웹서버). 이 방식을 사용하려면 -XX:UseConcMarkSweepGC 옵션을 추가하면 된다.

**G1 Collector**<br/>
지금까지 설명한 모든 GC는 Eden과 Survivor 영역으로 나뉘는 Young 영역과 Old 영역으로 구성되어 있다. 하지만 Garage First(G1)는 지금까지의 GC와는 다른 영역으로 구성되어 있다.

![g1-heap](/images/2019/04/06/g1-heap.png "g1-heap"){: .center-image }

각 바둑의 사각형을 region이라고 하는데, Young 영역과 Old 영역이 물리적으로 나뉘어 있지 않고 각 구역의 크기는 모두 동일하다. 이 바둑판 모양의 구역이 각각 Eden, Survivor, Old 영역의 역할을 변경해 가면서 하고, Humongous라는 영역도 포함된다. G1이 Young GC를 어떻게 하는지 살펴보자.

1. 몇 개의 구역을 선정하여 Young 영역으로 지정한다.
2. 이 Linear 하지 않은 구역에 객체가 생성되면서 데이터가 쌓인다.
3. Young 영역으로 할당된 구역에 데이터가 꽉 차면 GC를 수행한다.
4. GC를 수행하면서 살아있는 객체들만 Survivor 구역으로 이동시킨다.

이렇게 살아 남은 객체들이 이동된 구역은 새로운 Survivor 영역이 된다. 그 다음에 Young GC가 발생하면 Survivor 영역에 계속 쌓는다. 그러면서 몇 번의 aging 작업을 통해서 Old 영역으로 승격된다.

G1의 Old 영역 GC는 CMS GC의 방식과 비슷하며 아래 여섯 단계로 나뉜다.

- Initial mark: Old 영역에 있는 객체에서 Survivor 영역의 객체를 참조하고 있는 객체들을 표시한다.
- Root region scanning: Old 영역 참조를 위해서 Survivor 영역을 훑는다. 이 작업은 Young GC가 발생하기 전에 수행된다.
- Concurrent mark: 전체 힙 영역에 살아있는 객체를 찾는다. 만약 이때 Young GC가 발생하면 잠시 멈춘다.
- Remark: 힙에 살아있는 객체들의 표시 작업을 완료한다. 이때 Snapshot-At-The-Beginning(SATB) 알고리즘을 사용하며 이는 CMS GC에서 사용하는 방식보다 빠르다.
- Cleaning: 살아있는 객체와 비어 있는 구역을 식별하고, 필요없는 객체들을 지운다. 그리고 나서 비어있는 구역을 초기화한다.
- Copy: 살아있는 객체들을 비어있는 구역으로 모은다.

G1은 CMS GC의 단점을 보완하기 위해서 만들어졌으며 성능도 매우 빠르다.

---

# 18. GC가 어떻게 수행되고 있는지 보고 싶다

### 자바 인스턴스 확인을 위한 jps
jps는 해당 머신에서 운영중인 JVM의 목록을 보여준다.

```java
$ jps [-q] [-mlvV] [-Joption] [<hostid>]
```

### GC 상황을 확인하는 jstat
jstat는 GC가 수행되는 정보를 확인하기 위한 명령이다. jstat를 사용하면 유닉스 장비에서 vmstat나 netstat와 같이 라인 단위로 결과를 보여준다.

```java
$ jstat -<option> [-t] [-h<lines>] <vmid> [<interval> [<count>]]
```

### GC 튜닝할 때 가장 유용한 jstat 옵션은 두 개
jstat 명령에서 GC 튜닝을 위해서 필자가 가장 애용하는 옵션은 -gcutil과 -gccapacity이다. gccapacity 옵션은 각 영역의 크기를 알 수 있기 때문에 어떤 영역의 크기를 좀 더 늘리고 줄여야 할 지를 확인할 수 있다. gcutil 옵션은 힙 영역의 사용량을 %로 보여준다.

### 원격으로 JVM 상황을 모니터링하기 위한 jstatd
jstatd 명령어로 원격 모니터링에 사용할 수 있다.

```java
$ jstatd [-nr] [-p port] [-n rminame]
```

### verbosegc 옵션을 이용하여 gc 로그 남기기
jvmstat를 사용할 수 없는 상황이라면 어떻게 GC를 분석할 수 있을까? 자바 수행 시에 -verbosegc 옵션을 넣어주면 된다.

### 어설프게 아는 것이 제일 무섭다.
예를 들어 메모리를 2GB로 지정한 시스템에 초당 1건의 요청이 오는 곳에서 한 번 요청이 올 때 10MB의 메모리가 생성된다고 가정하다. 이 시스템의 Old 영역이 1% 증가하려면 얼마나 기다려야 할까?

한 번 요청 올 때 생성되는 10MB의 메모리는 Eden 영역에 쌓일 것이다. 이 데이터가 Survivor 영역으로 넘어가고 Old 영역으로 넘어갈 확률은 얼마나 될까? 보통의 경우 JVM이 자동으로 지정해주는 Young 영역과 Old 영역의 비율은 1:2 ~ 1:9 정도다. 그러면 2GB에서는 100~300MB 정도가 Young 영역에 할당될 것이다. 그럼 이 시스템의 Old 영역이 1% 증가하려면 얼마나 기다려야 할까? 정답은 없지만 적어도 5분에서 2시간 정도 소요될 것이다. 5분에 1%라면 한시간에 12%, 9시간 정도 되어야 100%에 도달하여 Full GC가 발생하게 될 것이다.

메모리 릭이 발생하는지 확인하는 가장 확실한 방법은 verbosegc를 남겨서 보는 방법이다. 그리고 간단하게 확인할 수 있는 가장 확실한 방법은 Full GC가 일어난 이후에 메모리 사용량을 보는 것이다. 정확하게 이야기해서 Full GC가 수행된 후에 Old 영역의 메모리 사용량을 보자. 만약 사용량이 80% 이상이면 메모리 릭을 의심해야 한다. 그런데 Full GC를 한번도 하지 않은 시스템에 메모리 릭이 있다고 생각할 수 있는가? 어떤 시스템도 Full GC가 한번도 발생하지 않는 상황에서 메모리 릭이 있다고 이야기할 수 없다.

---

# 19. GC 튜닝을 항상 할 필요는 없다
GC 튜닝이 필요 없다는 이야기는 운영 중인 Java 기반 시스템의 옵션에 기본적으로 다음과 같은 것들은 추가되어 있을 때의 경우다.

- -Xms, -Xmx 옵션으로 메모리 크기를 지정했다.
- -server 옵션이 포함되어 있다.

그리고 시스템의 로그에는 다음과 같은 타임아웃 관련 로그가 남아있지 않아야 한다.

- DB 작업과 관련된 타임아웃
- 다른 서버와의 통신시 타임아웃

그래서 JVM의 메모리 크기도 지정하지 않았고, Timeout이 지속적으로 발생하고 있다면 시스템에서 GC 튜닝을 하는 것이 좋다. 그런데 명심할 것은 GC 튜닝은 가장 마지막에 하는 작업이라는 것이다.

### Old 영역으로 넘어가는 객체의 수 최소화하기
Oracle JVM에서 제공하는 모든 GC는 Generational GC이다. 즉 Eden 영역에서 객체가 처음 만들어지고 Survivor 영역을 오가다가 끝까지 남아 있는 객체는 Old 영역으로 이동한다. 간혹 Eden 영역에서 만들어지다가 크기가 커져서 Old 영역으로 바로 넘어가는 객체도 있긴 하다. Old 영역의 GC는 New 영역의 GC에 비하여 상대적으로 시간이 오래 소요되기 때문에 Old 영역으로 이동하는 객체의 수를 줄이면 Full GC가 발생하는 빈도를 많이 줄일 수 있다.

### Full GC 시간 줄이기
Full GC의 수행 시간은 상대적으로 Young GC에 비하여 길다. 그래서 Full GC 실행에 시간이 오래 소요되면(1초 이상) 연계된 여러 부분에서 타임아웃이 발생할 수 있다. 그렇다고 Full GC 실행 시간을 줄이기 위해 Old 영역의 크기를 줄이면 OutOfMemoryError가 발생하거나 Full GC 횟수가 늘어난다. 반대로 Old 영역의 크기를 늘리면 Full GC 횟수는 줄어들지만 실행 시간이 늘어난다. Old 영역의 크기를 적절하게 \'잘\' 설정해야 한다.

### GC의 성능을 결정하는 옵션들

| 구분 | 옵션 | 설명 |
| :---: | :---: | :---: |
| 힙(heap) 영역 크기 | -Xms | JVM 시작 시 힙 영역 크기 |
| 힙(heap) 영역 크기 | -Xmx | 최대 힙 영역 크기 |
| New 영역 크기 | -XX:NewRatio | New 영역과 Old 영역의 비율 |
| New 영역 크기 | -XX:NewSize | New 영역의 크기 |
| New 영역 크기 | -XX:SurvivorRatio | Eden 영역과 Survivor 영역의 비율 |

GC 의 성능에 많은 영향을 주는 또 다른 옵션은 GC 방식이다.

| 구분 | 옵션 |
| :---: | :--- |
| Serial GC | -XX:+UseSerialGC |
| Parallel GC | -XX:+UseParallelGC<br/> -XX:ParallelGCTHreads=value |
| Parallel Compacting GC | -XX:+UseParallelOldGC |
| CMS GC | -XX:+UseConcMarkSweepGC<br/> -XX:+UseParNewGC<br/> -XX:+CMSParallelRemarkEnabled<br/> -XX:CMSInitiatingOccupancyFraction=value<br/> -XX:+UseCMSInitiatingOccupancyOnly |
| G1 | -XX:+UnlockExperimentalVMOptions<br/> -XX:+UseG1GC |

G1 GC를 제외하고는 각 GC 방식의 첫 번째 줄에 있는 옵션을 지정하면 GC 방식이 변경된다. Serial GC는 클라이언트 장비에 최적화되어 있기 때문에 특별히 신경쓸 필요가 없다.

### GC 튜닝 절차

1. GC 상황 모니터링
2. 모니터링 결과 분석 후 GC 튜닝 여부 결정<br/>
분석 결과 GC 수행에 소요된 시간이 0.1~0.3초 밖에 안된다면 굳이 튜닝할 필요 없다. 하지만 1~3초, 심지어 10초 이상 걸리면 GC 튜닝을 진행해야 한다.
3. GC 방식/메모리 크기 지정
4. 결과 분석
5. 결과가 만족스러울 경우 전체 서버에 반영 및 종료

---

# References
- [개발자가 반드시 알아야 할 자바 성능 튜닝 이야기](http://www.yes24.com/Product/Goods/11261731)
- [Understanding HotSpot VM Garbage Collectors (GC) in Depth](https://dzone.com/articles/understanding-garbage-collectorsgc-in-depth)
- [Understanding Just-In-Time Compilation and Optimization](https://docs.oracle.com/cd/E15289_01/JRSDK/underst_jit.htm)
- [Memory Management in the Java HotSpot™ Virtual Machine](https://www.oracle.com/technetwork/java/javase/tech/memorymanagement-whitepaper-1-150020.pdf)
