---
layout: entry
post-category: java
title: 자바 성능 튜닝 이야기 - 1
author: 김성중
author-email: ajax0615@gmail.com
description: 이상민님의 '자바 성능 튜닝 이야기'를 읽고 정리한 글입니다.
keywords: Java, 자바
next_url: /2019/03/30/java-performance-tuning-2.html
publish: true
---

![java_performance_tuning](/images/2019/03/28/java_performance_tuning.jpeg "java_performance_tuning"){: .center-image }

# 1. 디자인 패턴 꼭 써야 한다
디자인 패턴은 [임백준님의 개발자의 초식, 디자인 패턴「그러나…」](http://www.zdnet.co.kr/view/?no=00000039131344)에도 잘 드러나있듯이 과거의 소프트웨어 개발 과정에서 발견한 설계의 노하우를 일종의 패턴으로 정리해 놓은 것이다. 따라서 문제점에 대해서 검증된 방법으로 해결 방안을 찾을 수 있고, 시스템을 만들기 위해서 전체 중 일부 의미 있는 클래스들을 묶기 위해 사용될 수 있다. 반복되는 의미 있는 집합을 정의하고 이름을 지정해서, 누가 이야기하더라도 동일한 의미의 패턴이 되도록 만들어 놓은 것이다.

J2EE 디자인 패턴에 대해 간단히 알아보자.

![J2EE Design Pattern](/images/2019/03/28/j2ee-pattern.gif "J2EE Design Pattern"){: .center-image }

- Intercepting Filter 패턴: 요청 타입에 따라 다른 처리를 하기 위한 패턴
- Front Controller 패턴: 요청 전후에 처리하기 위한 컨트롤러를 지정하는 패턴
- View Helper 패턴: 프레젠테이션 로직과 상관 없는 비즈니스 로직을 헬퍼로 지정하는 패턴
- Composite View 패턴: 최소 단위의 하위 컴포넌트를 분리하여 화면을 구성하는 패턴
- Service to Worker 패턴: Front Controller와 View Helper 사이에 디스패처를 두어 조합하는 패턴
- Dispatcher View 패턴: Front Controller와 View Helper로 디스패처 컴포넌트를 형성한다. 뷰 처리가 종료될 때까지 다른 활동을 지연한다는 점이 Service to Worker 패턴과 다르다.
- Business Delegate 패턴: 비즈니스 서비스 접근을 캡슐화하는 패턴
- Service Locator 패턴: 서비스와 컴포넌트 검색을 쉽게 하는 패턴
- Session Facade 패턴: 비즈니스 티어 컴포넌트를 캡슐화하고, 원격 클라이언트에서 접근할 수 있는 서비스를 제공하는 패턴
- Composite Entity 패턴: 로컬 엔티티 빈과 POJO를 이용하여 큰 단위의 엔티티 객체를 구현
- Transfer Object 패턴: 일명 Value Object 패턴이라고 많이 알려져 있다. 데이터를 전송하기 위한 객체에 대한 패턴
- Transfer Object Assembler 패턴: 하나의 Transfer Object로 모든 타입 데이터를 처리할 수 없으므로, 여러 Transfer Object를 조합하거나 변형한 객체를 생성하여 사용하는 패턴
- Value List Handler 패턴: 데이터 조회를 처리하고, 결과를 임시 저장하며, 결과 집합을 검색하여 필요한 항목을 선택하는 역할
- Data Access Object 패턴: 일명 DAO라고 많이 알려져 있다. DB에 접근을 전담하는 클래스를 추상화하고 캡슐화한다.
- Service Activator 패턴: 비동기적 호출을 처리하기 위한 패턴

여기 명시된 패턴 중 성능과 가장 밀접한 관련이 있는 패턴은 Service Locator 패턴이다. 그리고 애플리케이션 개발 시 반드시 사용해야 하는 Transfer Object 패턴도 중요하다.

---

# 2. 내가 만든 프로그램의 속도를 알고 싶다
시스템의 성능이 느릴 때 가장 먼저 해야 하는 작업은 **병목 지점을 파악**하는 것이다. 자바 기반의 시스템에 대하여 응답 속도나 각종 데이터를 측정하는 프로그램은 많다. 애플리케이션의 속도에 문제가 있을 때 분석하기 위한 툴로는 프로파일링 툴이나 APM 툴 등이 있다. 이 툴을 사용하면, 고속도로 위에서 헬기나 비행기로 훑어보듯이 병목 지점을 쉽게 파악할 수 있다.

APM 툴을 프로파일링 툴과 비교하면 프로파일링 툴은 개발자용 툴이고, APM 툴은 운영 환경용 툴이라고 할 수 있다.

### 프로파일링 툴
- 소스 레벨의 분석을 위한 툴이다.
- 애플리케이션의 세부 응답 시간까지 분석할 수 있다.
- 메모리 사용량을 객체나 클래스, 소스의 라인 단위까지 분석할 수 있다.
- 가격이 APM 툴에 비해서 저렴하다.
- 보통 사용자 수 기반으로 가격이 정해진다.
- 자바 기반의 클라이언트 프로그램 분석을 할 수 있다.

### APM 툴
- 애플리케이션의 장애 상황에 대한 모니터링 및 문제점 진단이 주 목적이다.
- 서버의 사용자 수나 리소스에 대한 모니터링을 할 수 있다.
- 실시간 모니터링을 위한 툴이다.
- 가격이 프로파일링 툴에 비하여 비싸다.
- 보통 CPU 수를 기반으로 가격이 정해진다.

프로파일링 툴이 기본적으로 제공하는 기능은 어떤 것이 있을까? 각 툴이 제공하는 기능은 다양하고 서로 상이하지만, 응답 시간 프로파일링과 메모리 프로파일링 기능을 기본적으로 제공한다.

- **응답 시간 프로파일링**: 응답 시간을 측정하기 위함이다. 하나의 클래스 내에서 사용되는 메서드 단위의 응답 시간을 측정한다. 툴에 따라서 소스 라인 단위로 응답 속도를 측정할 수 있다. 응답 시간 프로파일링을 할 때는 보통 CPU 시간과 대기 시간이 제공된다.
- **메모리 프로파일링**: 잠깐 사용하고 GC의 대상이 되는 부분을 찾거나, 메모리 부족 현상(Memory leak)이 발생하는 부분을 찾기 위함이다. 클래스 및 메서드 단위의 메모리 사용량이 분석된다.

> CPU 시간과 대기 시간이란 하나의 메서드, 한 라인을 수행하는데 소요되는 시간은 무조건 CPU 시간과 대기 시간으로 나뉜다. CPU 시간은 CPU를 점유한 시간을 의미하고, 대기 시간은 CPU를 점유하지 않고 대기하는 시간을 의미한다. 따라서 CPU 시간와 대기 시간을 더하면 실제 소요 시간(Clock time)이 된다. CPU 시간은 툴에 따라 스레드(Thread) 시간으로 표시되기도 한다. 해당 스레드에서 CPU를 점유한 시간이기 때문에 표현만 다르지 사실은 같은 시간이다.

### System 클래스
모든 System 클래스의 메서드는 static으로 되어 있고, 그 안에서 생성된 in, out, err과 같은 객체들도 static으로 선언되어 있으며, 생성자도 없다. 본론에 들어가기 전에, 자주 사용하지는 않지만 알아두면 매우 유용한 메서드들을 알아보자.

```java
/*
특정한 배열을 복사할 때 사용한다. 여기서 src는 복사 원본 배열, dest는 복사한 값이 들어가는 배열이다. srcPos는 원본의 시작 위치, destPos는 복사본의 시작 위치, length는 복사하는 개수이다.
*/
static void arracopy(Object src, int srcPos, Object dest, int destPos, int length)

/*
현재 자바 속성 값들을 받아 온다. 자바의 JVM에서 사용할 수 있는 설정은 속성(Property)값과 환경(Environment)값이 있다. 속성은 JVM에서 지정된 값들이고, 환경은 장비(서버)에 지정되어 있는 값들이다.
*/
static Properties getProperties()

// key에 지정된 자바 속성 값을 받아 온다.
static String getProperties(String key)

// key에 지정된 자바 속성 값을 받아 온다. def는 해당 key가 존재하지 않을 경우 지정할 기본값이다.
static String getProperty(String key, String def)

// props 객체에 담겨 있는 내용을 자바 속성에 지정한다.
static void setProperties(Prope props)

// 자바 속성에 지정된 key의 값을 value 값으로 변환한다.
static String setProperties(String key, String value)

// 현재 시스템 환경 값 목록을 스트링 형태의 맵으로 리턴한다.
static Map<String, String> getenv()

// name에 지정된 환경 변수의 값을 얻는다.
static String getenv(String name)

// 파일명을 지정하고 네이티브 라이브러리를 로딩한다.
static void load(String filename)

// 라이브러리의 이름을 지정하여 네이티브 라이브러리를 로딩한다.
static void loadLibrary(String libname)
```

그리고 여러분들이 운영중인 코드에서 절대로 사용해서는 안되는 메서드가 있다.

```java
// 자바에서 사용하는 메모리를 명시적으로 해제하도록 GC를 수행하는 메서드다.
static void gc()

// 현재 수행중인 JVM을 멈춘다. 이 메서드는 절대로 수행하면 안 된다.
static void exit(int status)

/*
Object 객체에 있는 finalize()라는 메서드는 자동으로 호출되는데, 가비지 콜렉터가 알아서
해당 객체를 더 이상 참조할 필요가 없을 때 호출한다. 하지만 이 메서드를 호출하면 참조 해제
작업을 기다리는 모든 객체의 finalize() 메서드를 수동으로 수행해야 한다.
*/
static void runFinalization()
```

### currentTimeMills와 nanoTime

```java
// 현재의 시간을 ms로 리턴한다(1/1000초).
static long currentTimeMills()

// 현재의 시간을 ns로 리턴한다(1/1,000,000,000초).
static long nanoTime()
```

nanoTime 메서드는 나노 단위의 시간을 리턴해 주기 때문에 currentTimeMills 메서드보다 비교 측정시에 더 정확하게 사용될 수 있다.

추가로 시간 측정시 초기에 성능이 느리게 나온 이유는 여러 가지이지만, 클래스가 로딩되면서 성능 저하도 발생하고, JIT Optimizer가 작동하면서 성능 최적화도 되기 때문이라고 보면 된다.

JMH(Java Microhenchmark Harness)는 JDK를 오픈 소스로 제공하는 OpenJDK에서 만든 성능 측정용 라이브러리다. JMH는 여러 개의 스레드로 테스트도 가능하고, 워밍업 작업도 자동으로 수행해주기 때문에 정확한 측정이 가능하다. 여러 결과를 제공하지만, 굵은 글씨로 표시된 값만 확인하면 된다.

---

# 3. 자꾸 String을 쓰지 말라는 거야
다음은 일반적으로 사용하는 쿼리 작성 문장이다.

```java
String strSQL = "";
strSQL += "select * ";
strSQL += "from ( ";
strSQL += "select A_column, ";
strSQL += "B_column, ";
// 중간 생략(약 400라인)
...
```

이와 같은 메서드를 한 번 수행하면, 다음과 같은 메모리 사용량을 확인할 수 있다.

| 구분 | 결과 |
| :---: | :---: |
| 메모리 사용량 | 10회 평균 약 5MB |
| 응답 시간 | 10회 평균 약 5ms |

위 코드를 메모리 사용량과 응답 시간을 줄이기 위해 StringBuilder로 변경하였다.

```java
StringBuilder strSQL = new StringBuilder();
strSQL.append(" select * ");
strSQL.append(" from ( ");
strSQL.append(" select A_column, ");
strSQL.append(" B_column, ");
// 중간 생략(약 400라인)
...
```

이렇게 변경한 후 수행한 결과는 다음과 같다.

| 구분 | 결과 |
| :---: | :---: |
| 메모리 사용량 | 10회 평균 약 371KB |
| 응답 시간 | 10회 평균 약 0.3ms |

### StringBuffer 클래스와 StringBuilder 클래스
StringBuffer 클래스나 StringBuilder 클래스에서 제공하는 메서드는 동일하다. 하지만 StringBuffer 클래스는 스레드에 안전하게(ThreadSafe) 설계되어 있으므로, 여러 개의 스레드에서 하나의 StringBuffer 객체를 처리해도 전혀 문제가 되지 않는다. 하지만 StringBuilder는 단일 스레드에서의 안전성만을 보장한다.

### String vs. StringBuffer vs. StringBuilder
String, StringBuffer, StringBuilder 셋 중 어느 것이 가장 빠르고 메모리를 적게 사용할까?

- 10,000회 반복하여 문자열을 더하고, 이러한 작업을 10회 반복한다.

프로파일링 툴의 결과는 다음과 같다.

| 주요 소스 부분 | 응답 시간(ms) | 비고 |
| :---: | :---: | :---: |
| a+=aValue; | 95,801.41ms | 95초 |
| b.append(aValue); | 247.48ms | 0.24초 |
| c.append(aValue); | 174.17ms | 0.17초 |

그리고 메모리 사용량을 다음과 같다.

| 주요 소스 부분 | 메모리 사용량(bytes) | 생성된 임시 객체수 | 비고 |
| :---: | :---: | :---: | :---: |
| a+=aValue; | 100,102,000,000 | 4,000,000 | 약 95Gb |
| b.append(aValue); | 29,493,600 | 1,200 | 약 28Mb |
| c.append(aValue); | 29,493,600 | 1,200 | 약 28Mb |

응답 시간은 String보다 StringBuffer가 약 367배 빠르며, StringBuilder가 약 512배 빠르다. 메모리는 StringBuffer와 StringBuilder보다 String에서 약 3,390배 더 사용한다. 이러한 결과가 왜 발생하는지 알아보자.

```
a += aValue; // a = a + aValue
```

a에 aValue를 더하면 새로운 String 클래스의 객체가 만들어지고, 이전에 있던 a 객체는 필요 없는 쓰레기 값이 되어 GC 대상이 되어 버린다. 이러한 작업이 반복 수해오디면서 메모리를 많이 사용하게 되고, 응답 속도에도 많은 영향을 미치게 된다. GC를 하면 할수록 시스템의 CPU를 많이 사용하게 되고 시간도 많이 소요된다.

- String은 짧은 문자열을 더할 경우 사용한다.
- StringBuffer는 스레드에 안전한 프로그램이 필요할 때나, 개발 중인 시스템의 대부분이 스레드에 안전한지를 모를 경우 사용하면 좋다. 만약 클래스에 static으로 선언된 문자열을 변경하거나, singleton으로 선언된 클래스에 선언된 문자열일 경우에는 이 클래스를 사용해야만 한다.
- StringBuilder는 스레드에 안전한지의 여부와 전혀 관계 없는 프로그램을 개발할 때 사용하면 좋다. 만약 메서드 내에 변수를 선언했다면, 해당 변수는 그 메서드 내에서만 살아있으므로, StringBuilder를 사용하면 된다.

---

# 4. 어디에 담아야 하는지...

![Collection](/images/2019/03/28/java-collection.png "Collection"){: .center-image }

- Collection: 가장 상위 인터페이스
- Set: 중복을 허용하지 않는 집합을 처리하기 위한 인터페이스
- SortedSet: 오름차순을 갖는 Set 인터페이스
- List: 순서가 있는 집합을  처리하기 위한 인터페이스이기 때문에 인덱스가 있어 위치를 지정하여 값을 찾을 수 있다.
- Queue: 여러 개의 객체를 처리하기 전에 담아서 처리할 때 사용하기 위한 인터페이스이다. 기본적으로 FIFO를 따른다.
- Map: 키와 값의 쌍으로 구성된 객체의 집합을 처리하기 위한 인터페이스. 중복되는 키를 허용하지 않는다.
- SortedMap: 키를 오름차순으로 정렬하는 Map 인터페이스

Set 인터페이스를 구현한 클래스로는 HashSet, TreeSet, LinkedHashSet 세 가지가 있다.

- HashSet: 데이터를 해쉬 테이블에 담는 클래스로 순서 없이 저장된다.
- TreeSet: red-black이라는 트리에 데이터를 담는다. 값에 따라서 순서가 정해진다. 데이터를 담으면서 동시에 정렬하기 때문에 HashSet보다 성능상 느리다.
- LinkedHashSet: 해쉬 테이블에 데이터를 담는데, 저장된 순서에 따라서 순서가 결정된다.

List 인터페이스를 구현한 클래스들은 담을 수 있는 크기가 자동으로 증가되므로, 데이터의 개수를 확실히 모를 때 유용하게 사용된다.

- Vector: 객체 생성 시에 크기를 지정할 필요가 없는 배열 클래스이다.
- ArrayList: Vector와 비슷하지만, 동기화 처리가 되어 있지 않다.
- LinkedList: ArrayList와 동일하지만, Queue 인터페이스를 구현했기 때문에 FIFO 큐 작업을 수행한다.

List의 가장 큰 단점은 **데이터가 많은 경우 처리 시간이 늘어난다** 는 점이다. 가장 앞에 있는 데이터를 지우고 그 다음 1번 데이터부터 마지막 데이터까지 한 칸씩 옮기는 작업을 수행하야 하므로, 데이터가 적을 때는 상관없지만, 데이터가 많으면 많을수록 가장 앞에 있는 데이터를 지우는데 소요되는 시간이 증가한다.

Queue 인터페이스를 구현한 클래스는 두 가지로 나뉜다. java.util 패키지에 속하는 LinkedList와 PriorityQueue는 일반적인 목적의 큐 클래스이며, java.util.concurrent 패키지에 속하는 클래스들은 ConcurrentQueue 클래스이다.

- PriorityQueue: 큐에 추가된 순서와 상관없이 먼저 생성된 객체가 먼저 나오도록 되어 있는 Queue
- LinkedBlockingQueue: 저장할 데이터의 크기를 선택적으로 정할 수도 있는 FIFO 기반의 링크 노드를 사용하는 블로킹 Queue
- ArrayBlockingQueue: 저장되는 데이터의 크기가 정해져 있는 FIFO 기반의 블로킹 Queue
- PriorityBlockingQueue: 저장되는 데이터의 크기가 정해져 있지 않고, 객체의 생성순서에 따라서 순서가 저장되는 블로킹 Queue
- DelayQueue: 큐가 대기하는 시간을 지정하여 처리하도록 되어 있는 Queue
- SynchronousQueue: put() 메서드를 호출하면, 다른 스레드에서 take() 메서드가 호출될 때까지 대기하도록 되어 있는 Queue. 이 큐에는 저장되는 데이터가 없다. API에서 제공하는 대부분의 메서드는 0이나 null을 리턴한다.

> Blocking Queue란 크기가 지정되어 있는 큐에 더 이상 공간이 없을 때, 공간이 생길 때까지 대기하도록 만들어진 큐를 의미한다.

![Map](/images/2019/03/28/java-map.png "Map"){: .center-image }

Map은 Key와 Value 쌍으로 저장되는 구조체이다. 그래서, 단일 객체만 저장되는 다른 Collection API들과는 다르게 따로 구분되어 있다.

- HashTable: 데이터를 해쉬 테이블에 담는 클래스이다. 내부에서 관리하는 해쉬 테이블 객체가 동기화되어 있다.
- HashMap: 데이터를 해쉬 테이블에 담는 클래스이다. HashTable 클래스와는 다르게 null 값을 허용한다는 것과 동기화되어 있지 않다.
- TreeMap: red-black 트리에 데이터를 담는다. TreeSet과는 다르게 키에 의해 순서가 정해진다.
- LinkedHashMap: HashMap과 거의 동일하며 이중 연결 리스트(Doubly-LinkedList)라는 방식을 사용하여 데이터를 담는다는 점만 다르다.

### List 관련 클래스 중 무엇이 빠를까?

| 대상 | 평균 응답 시간(마이크로초) |
| :---: | :---: |
| ArrayList | 4 |
| Vector | 105 |
| LinkedList | 1,512 |
| LinkedListPeek | 0.16 |

- LinkedList는 Queue 인터페이스를 상속받기 때문에, get()보다는 순차적으로 결과를 받아오는 peek()이나 poll() 메서드를 사용해야 한다.
- Vector는 여러 스레드에서 접근할 경우를 방지하기 위해 get() 메서드에 synchronized가 선언되어 있어서 성능 저하가 발생할 수 밖에 없다.

### Map 관련 클래스 중 무엇이 빠를까?
대부분의 클래스들이 동일하지만, 트리 형태로 처리하는 TreeMap 클래스가 가장 느리다.

### Collection 관련 클래스의 동기화
HashSet, TreeSet, LinkedHashSet, ArrayList, LinkedList, HashMap, TreeMap, LinkedHashMap은 동기화(synchronized)되지 않은 클래스이다. 이와는 반대로 동기화되어 있는 클래스로는 Vector와 HashTable이 있다.

Map의 경우 키 값들을 Set으로 가져와 Iterator를 통해 데이터를 처리하는 경우가 발생한다. 이때 ConcurrentModificationException이라는 예외가 발생할 수 있다. 이 예외가 발생하는 여러 가지 원인 중 하나는 스레드에서 Iterator로 어떤 Map 객체의 데이터를 꺼내고 있는데, 다른 스레드에서 해당 Map을 수정하는 경우다.

---

# 5. 지금까지 사용하던 for 루프를 더 빠르게 할 수 있다고?
JDK 5.0 이전에는 for 구문을 다음과 같이 사용하였다.

```java
for (int loop = 0; loop < list.size(); loop++)
```

매번 반복하면서 list.size() 메서드를 호출하기 때문에 다음과 같이 수정해야 한다.

```java
int listSize = list.size();
for (int loop = 0; loop < listSize; loop++)
```

---

# References
- [개발자가 반드시 알아야 할 자바 성능 튜닝 이야기](http://www.yes24.com/Product/Goods/11261731)
- [Core J2EE Patterns](http://www.corej2eepatterns.com/)
