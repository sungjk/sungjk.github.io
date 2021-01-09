---
layout: entry
post-category: java
title: Practical 모던 자바
author: 김성중
author-email: ajax0615@gmail.com
keywords: Practical 모던 자바, Java
publish: true
---

# 2. 인터페이스와 클래스

최초 자바 버전에서는 인터페이스에 다음과 같은 제약이 있었다.
- 상수를 선언할 수 있다. 해당 상수는 반드시 값이 할당되어 있어야 하며 값을 변경할 수 없다. 명시적으로 final을 선언하지 않더라도 final로 인식된다.
- 메서드는 반드시 추상(abstract) 메서드여야 한다. 즉, 구현체가 아니라 메서드 명세만 정의되어 있어야 한다.
- 인터페이스를 구현한 클래스는 인터페이스에서 정의한 메서드를 구현하지 않았다면 반드시 추상 클래스로 선언되어야 한다.
- 인터페이스에 선언된 상수와 메서드에 public을 선언하지 않더라도 public으로 인식한다.

```java
public interface Vehicle {
  // public static final로 인식한다.
  int SPEED_LIMIT = 200;

  // public으로 인식한다.
  int getSpeedLimit();
}

public VehicleImpl implements Vehicle {
  // 반드시 public으로 선언되어야 한다.
  public int getSpeedLimit() {
    // SPEED_LIMIT 속성이 public static final로 인식된다.
    return Vehicle.SPEED_LIMIT;
  }
}
```

자바 1.2부터는 위의 두 가지 항목 외에 선언할 수 있는 항목이 추가되었다.
- 중첩(Nested) 클래스를 선언할 수 있다. 선언은 내부(Inner) 클래스 같지만 실제로는 중첩 클래스로 인식한다.
- 중첩(Nested) 인터페이스를 선언할 수 있다.
- 위의 중첩 클래스와 중첩 인터페이스는 모두 public과 static이어야 하며 생략 가능하다.
> 중첩 클래스는 클래스나 인터페이스 내부에 static으로 선언된 클래스이다. 인터페이스 내부의 클래스는 비록 static으로 선언하지 않더라도 static과 동일한 것으로 간주하기 때문에 내부 클래스가 아니라 중첩 클래스가 맞다.

자바 5에서 추가된 새로운 기능인 제네릭과 열거형(Enum) 그리고 어노테이션이 인터페이스에도 영향을 주었다.
- 중첩(Nested) 열거형(Enum)을 선언할 수 있다.
- 중첩(Nested) 어노테이션을 선언할 수 있다.
- 제네릭의 등장으로 인터페이스 선언문과 메서드 언언에 모두 타입 파라미터를 사용할 수 있게 되었다.

자바 8에서 적용된 가장 큰 변경 사항은 메서드에 실제 구현된 코드를 정의할 수 있다는 점이다.
- 실제 코드가 완성되어 있는 static 메서드를 선언할 수 있다.
- 실제 코드가 완성되어 있는 default 메서드를 선언할 수 있다.

자바 9에서도 인터페이스에 선언할 수 있는 항목이 하나 추가되었다.
- private 메서드를 선언할 수 있다.
> 클래스 외부에는 공개되지 않더라도 인터페이스 내부의 static 메서드와 default 메서드의 로직을 공통화하고 재사용하는데 유용하다.

### default, static, private 메서드
default 키워드에는 public 메서드라는 것이 함축되어 있다. 이렇게 구현한 메서드는 해당 인터페이스를 구현한 클래스에 메서드의 명세와 기능이 상속된다. 마치 implements 키워드를 이용한 것이 아니라 extends 키워드를 이용해서 클래스를 정의한 것과 비슷하다.

default 메서드의 경우는 메서드를 직접 구현하겠다고 컴파일러에게 알려주는 역할을 하지만 static 메서드와 private 메서드에는 별도의 키워드 정의 없이 메서드의 명세를 선언하고 내용을 정의하면 된다. 이때 인터페이스 내에 static과 private 메서드로 정의한 다음 코드를 작성하지 않으면 컴파일 에러가 발생한다는 점에 주의해야 한다.

왜 default 메서드는 다른 메서드와 구분하기 위한 별도의 키워드가 필요하고 static과 private은 아무런 키워드나 표시 없이 바로 메서드를 정의하고 구현해도 될까? static과 private은 과거에는 인터페이스에 허용되지 않던 메서드 형태라서 컴파일러가 혼란을 일으키지 않기 때문이다. 이와 달리 default로 선언되는 메서드는 키워드를 제외하면 인터페이스의 추상 메서드와 일치하므로 컴파일러가 혼동을 일으킨다. 그래서 default라는 키워드를 통해 컴파일러에게 이것은 특별한 메서드 유형이라고 알리는 것이다.

### 클래스와의 차이점과 제약 조건
추상 클래스와 인터페이스의 가장 큰 차이점은 두 가지다.
- 추상 클래스는 멤버 변수를 가질 수 있지만 인터페이스는 멤버 변수를 가질 수 없다. 물론 인터페이스도 static으로 정의된 변수를 내부적으로 선언할 수 있지만 멤버 변수는 선언할 수 없다.
- 클래스를 구현할 때 오직 하나의 클래스만을 상속받을 수 있는 반면에 인터페이스는 여러 개를 상속받거나 구현할 수 있다.

### 다중 상속 관계
자바에서는 상위 클래스 혹은 인터페이스를 상속/구현하기 위해 다음 두 개의 키워드를 제공한다.
- extends: 상속. 클래스가 상위 클래스를 상속받을 때 사용하며 인터페이스가 상위 인터페이스를 상속받을 때도 사용할 수 있다.
- implements: 구현. 클래스가 인터페이스를 구현할 때 사용한다.

우선 private 메서드는 자바의 접근 규칙에 따라 하위 클래스로 상속되지 않는다. 그러므로 private 메서드를 인터페이스에 정의할 수 있더라도 이를 구현해야 하는 클래스에는 아무런 영향을 미치지 못한다. static 메서드도 인터페이스 레벨 혹은 클래스 레벨로 정의되는 메서드이기 때문에 메서드 오버라이드의 범위에 속하지 않는다. 하지만 default 메서드의 경우 앞에 default라는 키워드를 붙였을 뿐 메서드 규격은 기존 인터페이스에서 정의하던 것과 동일하므로 여러 개의 인터페이스를 implements 키워드를 이용해서 하나의 클래스에서 구현할 경우 **다중 상속의 효과**를 얻게 된다.

인터페이스에서 default 메서드를 제공하게 되면서 제한적이긴 하지만 자바에서 다중 상속이 가능해졌다. 따라서 이에 대한 원칙 및 호출 관계를 반드시 이해해야 한다. 가장 중요한 원칙 3가지는 다음과 같다.
1. 클래스가 인터페이스에 대해 우선순위를 가진다. 동일한 메서드가 인터페이스와 클래스에 둘 다 있다면 클래스가 먼저 호출된다.
2. 위의 조건을 제외하고 상속 관계에 있을 경우에는 하위 클래스/인터페이스가 상위 클래스/인터페이스보다 우선 호출된다.
3. 위의 두 가지 경우를 제외하고 메서드 호출 시 어떤 메서드를 호출해야 할지 모호할 경우 컴파일 에러가 발생할 수 있으며, 반드시 호출하고자 하는 클래스 혹은 인터페이스를 명확하게 지정해야 한다.

---

# 3. 함수형 프로그래밍
자바 8에서는 인터페이스에 하나의 메서드만 정의한 것을 함수형 인터페이스라고 부른다.

```java
// 함수형 인터페이스
public interface TravelInfoFilter {
  public boolean isMatched(TravelInfoVO TravelInfo);
}

...

// 외부에서 전달된 조건으로 검색
public List<TravelInfoVO> searchTravelInfo(TravelInfoFilter searchCondition) {
  List<TravelInfoVO> returnValue = new ArrayList<>();

  for (TravelInfoVO travelInfo : travelInfoList) {
    if (searchCondition.isMatched(travelInfo)) {
      returnValue.add(travelInfo);
    }
  }
  return returnValue;
}

...

public static void main(String[] args) {
  ...
  // 조회 조건을 외부로 분리
  List<TravelInfoVO> searchTravel = travelSearch.searchTravelInfo(new TravelInfoFilter() {
    @Override
    public boolean isMatched(TravelInfoVO travelInfo) {
      return travelInfo.getCountry().equals("vietnam");
    }
  });
}
```

searchTravelInfo 메서드만 보면 isMatched에 내부적으로 어떤 조건을 구현해 놓았는지 알지 못하지만 그 결과값에 따라 true/false 값을 확인할 수 있으므로 외부에서 들어오는 다양한 조건에 대해 처리가 가능하다.

### 메서드 참조
람다 표현식을 사용하면 익명 클래스의 소스 코드 중복성은 해결할 수 있지만, 소스 코드의 재사용이라는 측면에서는 활용도가 떨어진다. 이 경우 람다 표현식을 하나의 함수로 선언하고 이 함수를 다른 곳에서 활용하면 재사용성을 높일 수 있다.

---

# 4. 람다와 함수형 인터페이스
익명 클래스를 많이 만들면 비즈니스 로직의 구현보다 그것을 담기 위한 코드를 더 많이 작성하게 되고 중복되는 코드가 많아지는 문제가 생긴다. 이는 코드의 양을 비대하게 만들고 가독성도 떨어진다.

### 익명 클래스를 람다 표현식 변경
1. 익명 클래스를 이용해서 메서드를 정의한다.
2. 익명 클래스를 생성하기 위해서 선언한 인터페이스 이름 부분을 삭제한다. 삭제 후에는 메서드 선언 부분만 남는다.
3. 메서드의 파라미터 목록과 구현한 바디 영역을 제외하고 리턴 타입, 메서드명을 삭제한다. 삭제 후에는 파라미터 목록과 바디 영역만 남는다.
4. 람다 문법에 맞게 '->'를 이용해서 문장을 완성한다.

```java
// 익명 클래스를 이용해서 Runnable 인터페이스 구현
Thread thread = new Thread(new Runnable() {
  @Override
  public void run() {
    System.out.println("Hello world");
  }
});

// 1단계. 익명 클래스 선언 부분 제거
Thread thread = new Thread(
  @Override
  public void run() {
    System.out.println("Hello world");
  }
);

// 2단계. 메서드 선언 부분 제거
// 리턴 타입이 생략되더라도 컴파일러가 데이터 타입을 추론해준다.
Thread thread = new Thread(
  () {
    System.out.println("Hello world");
  }
);
);

// 3단계. 람다 문법으로 정리
Thread thread = new Thread(() -> System.out.println("Hello world"));
```

람다 표현식을 쓸 수 있는 인터페이스는 오직 public 메서드 하나만 가지고 있는 인터페이스여야 한다. 이러한 인터페이스를 **함수형 인터페이스** 라고 부르고, 함수형 인터페이스에서 제공하는 단 하나의 추상 메서드를 함수형 메서드라고 부른다.

```java
@FunctionalInterface
public interface Consumer<T> {
  ...
}
```

어노테이션을 붙이면 좀 더 명확하게 함수형 인터페이스임을 알 수 있고, 실수로 함수형 인터페이스에 메서드를 추가했을 때 컴파일 에러를 일으켜서 문제를 사전에 예방할 수 있다.

**Consumer 인터페이스**<br/>
아무런 값도 리턴하지 않고 요청 받은 내용을 처리한다.

**Function 인터페이스**<br/>
인터페이스의 함수형 메서드는 T를 인수로 받아서 R로 리턴하는 메서드를 가지고 있다. 주로 데이터를 가공하거나 매핑하는 용도로 많이 사용한다.

**Predicate 인터페이스**<br/>
리턴 타입 중 특별히 참/거짓 중 하나를 선택하는 불 타입을 필요로 할 때 사용할 수 있는 인터페이스

**Supplier 인터페이스**<br/>
get 메서드를 제공하고, 입력 파라미터는 없고 리턴 타입만 존재한다.

### 메서드 참조
메서드 참조의 장점은 람다 표현식과는 달리 코드를 여러 곳에서 재사용할 수 있고 자바의 기본 제공 메서드뿐만 아니라 직접 개발한 메서드도 사용할 수 있다는 점이다.

```java
// 람다 표현식
(String name) -> System.out.println(name)

// 정적 메서드 참조
Integer::parseInt

// 비한정적 메서드 참조
String::toUpperCase

// 한정적 메서드 참조
Calendar.getInstance()::getTime

// 생성자 참조
Class::new
```

**정적 메서드 참조**<br/>
static으로 정의한 메서드를 참조할 때 사용한다. static 메서드는 호출할 때 객체를 생성하지 않기 때문에 정적 메서드 참조일 때도 코드가 명확해 보인다.

**비한정적 메서드 참조**<br/>
public 혹은 protected로 정의한 메서드를 참조할 때 사용하며 static 메서드를 호출하는 것과 유사하다. 비한정적(unbound)이란 특정한 객체를 참조하기 위한 변수를 지정하지 않는다는 의미다. 스트림에서 필터와 매핑 용도로 많이 사용한다.

**한정적 메서드 참조**<br/>
이미 외부에 선언된 객체의 메서드를 호출하거나, 객체를 직접 생성해서 메서드를 참조할 때 사용한다. 한정적(bound)이란 참조하는 메서드가 특정 객체의 변수로 제한된다는 의미다.

**생성자 참조**<br/>
메서드는 클래스 혹은 객체 단위로 접근 권하만 있으면 언제든 호출할 수 있지만 생성자는 오직 객체가 생성될 때만 호출할 수 있으며, 객체를 생성할 때 초기화하는 개념을 가진다.

```java
Calendar cal = Calendar.getInstance(); // 객체 생성
cal::getTime; // 메서드 참조 구문. cal 변수를 참조한다.
```

한정적 메서드 참조는 외부에서 생성한 변수를 람다 표현식에서 활용한다. 그러므로 메서드 참조 수식에서 of 메서드나 getInstance 등의 메서드로 생성할 필요 없이 이미 생성되어 있는 객체를 참조로 전달할 수 있다. 한정적 메서드 참조는 외부에서 정의한 객체의 메서드를 참조할 때 사용하며, 비한정적 메서드 참조는 람다 표현식 내부에서 생성한 객체의 메서드를 참조할 때 사용한다.

---

# 5. 스트림 API
스트림 API의 주된 목적은 람다 표현식과 메서드 참조 등의 기능과 결합해서 매우 복잡하고 어려운 데이터 처리 작업을 쉽게 조회하고 필터링하고 변환하고 처리할 수 있도록 하는 것이다.

### 스트림 인터페이스
스트림에서 가장 기본이 되는 인터페이스는 BaseStream이다.

```
<T, S extends BaseStream<T, S>>
- T: 스트림에서 처리할 데이터의 타입
- S: BaseStream을 구현한 스트림 구현체
```

여기서 S 타입으로 지정한 타입은 AutoCloseable 인터페이스의 close 메서드를 반드시 구현해야 한다.

- **Intermediate operation**: 리턴 타입이 Stream인 메서드들은 리턴 결과를 이용해서 ㄷ이터를 중간에 변형 혹은 필터링한 후 다시 Stream 객체를 만들어서 결과를 리턴한다.
- **Terminal operation**: 리턴 타입이 없는 void형 메서드들은 주로 Stream을 이용해서 데이터를 최종적으로 소비한다.
- **Immutable**: 중간 연산 작업과 함꼐 병렬 처리가 가능하기 때문에 데이터의 정합성을 확보하기 위함이다.

DoubleStream, IntStream, LongStream 인터페이스를 이용하면 데이터가 자동으로 박싱/언박싱되지 않기 때문에 처리 속도가 빨라진다.

### 스트림 객체 생성
컬렉션 프레임워크의 최상위 인터페이스인 java.util 패키지의 Collection 인터페이스를 살펴보면 자바 8 버전부터 아래 default 메서드가 추가되었다.

```
default Stream<E> stream()
```

| 리턴 타입 | 메서드 | 설명 |
| void &nbsp;&nbsp;&nbsp;&nbsp; | accept(T t) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | 스트림 빌더에 데이터를 추가하기 위한 메서드다. |
| Stream.Builder<T> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | add(T t) | 스트림 빌더에 데이터를 추가하기 위한 메서드.<br/> 기존에 추가한 데이터와 현재 추가한 데이터가 포함된 Stream.Builder 객체를 리턴한다. |
| Stream<T> | build() | Stream.Builder 객체에 데이터를 추가하는 작업을 종료한다. |

### 주요 스트림 연산 상세
**distinct 메서드는 성능을 저하시킬 수 있다**<br/>
병렬 처리를 목적으로 스트림을 생성하면 distinct 메서드는 성능이 떨어진다. 데이터 중복을 제거하기 위해 여러 스레드에 분산해 놓은 데이터를 동기화해서 비교해야 하기 때문. 따라서 중복 제거를 위해 distinct 메서드를 쓰고 싶다면 병렬 스트림보다는 순차 스트림을 이용하는 것이 더 빠르다.

**중복 제거가 안 될 수도 있다**<br/>
스트림 항목의 중복 여부를 확인하기 위해 equals 메서드가 내부적으로 호출된다는 것을 기억해야 한다. 정확한 equals 결과를 얻기 위해서는 equals 메서드 외에도 hashCode 메서드도 오버라이드해야 한다.

distinctByKey 메서드는 스트림의 개수만큼 반복 호출되는 것이 아니라 한 번만 실행되며, distinctByKey의 리턴 객체인 Predicate 객체의 test 메서드가 반복적으로 호출된다. 그러므로 다음의 메서드는 오직 한 번 실행되며 filter를 위한 조건을 생성하는 역할만 수행한다.

```java
public static <T> Predicate<T> distinctByKey(Function<? super T, ?> key) {
  Map<Object, Boolean> seen = new ConcurrentHashMap<>();
  return t -> seen.putIfAbsent(key.apply(t), Boolean.TRUE) == null;
}
```

limit의 경우 스트림의 데이터 중 정수값만큼 데이터의 개수를 제한해서 새로운 스트림 객체로 리턴한다.

skip 메서드는 주어진 입력 파라미터의 값만큼 데이터를 건너뛰라는 이미다.

### 데이터 정렬
값이 서로 동일한지 여부를 판단하기 위해서는 equals 메서드를 사용하고, 객체의 크고 작음을 판단하기 위해서는 Comparable 인터페이스를 구현해야 한다.

```java
sorted(Comparator<? super T> comparator)
```

- Comparable 인터페이스를 구현하지 않은 객체를 정렬할 때
- 역순으로 정렬하고 싶을때
- 정렬하고자 하는 객체의 키 값을 다르게 하고 싶을 때

클래스에 Comparable 인터페이스를 이요해서 compareTo 메서드를 정의하면 오직 하나의 정렬 규칙을 만들 수 있지만 sorted 메서드에 Comparator를 이용할 경우 개발자가 원하는 다양한 조합을 적용할 수 있다.

```java
int compare(T o1, T o2)
```

- 첫 번째 파라미터가 값이 클 경우: 음수를 리턴한다.
- 두 번쨰 파라미터가 값이 클 경우: 0 혹은 양수를 리턴한다.

### 컬렉션으로 변환
컬렉션 프레임워크로 변경하기 위한 메서드는 스트림 인터페이스에서 두 개가 제공되고 있다.

```java
collect(Supplier<R> supplier, BiConsumer<R, ? super T> accumulator, BiConsumer<R, R> combiner)
collect(Collector<? super T, A, R> collector)
```

- T: 리듀스 연산의 입력 항목으로 사용하는 데이터 타입
- A: 리듀스 연산의 변경 가능한 누적값으로 사용하는 데이터 타입
- R: 리듀스 연산의 최종 결과 데이터 타입

---

# 6. 병렬 프로그래밍
TODO

---

##

### References
- [Practical 모던 자바](http://www.yes24.com/Product/Goods/92529658)
