---
layout: entry
title: Effective Java 3 - 람다와 스트림
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java 3판의 7장(람다와 스트림)을 정리한 글입니다.
keywords: Java, 자바
publish: true
---

# 42. 익명 클래스보다는 람다를 사용하라
자바 8에서 추상 메서드 하나짜리 인터페이스는 특별한 의미를 인정받았다. 함수형 인터페이스라 부르는 이 인터페이스들의 인스턴스를 람다식(lambda expression)을 사용해 만들 수 있게 된 것이다. 람다는 함수나 익명 클래스와 개념은 비슷하지만 코드는 훨씬 간결하다.

```java
// 익명 클래스의 인스턴스를 함수 객체로 사용 - 낡은 기법
Collections.sort(words, new Comparator<String>() {
  public int compare(String s1, String s2) {
    return Integer.compare(s1.length(), s2.length());
  }
});

// 람다식을 함수 객체로 사용 - 익명 클래스 대체
Collections.sort(words, (s1, s2) -> Integer.compare(s1.length(), s2.length()));

// 비교자 생성 메서드 사용
Collections.sort(words, comparingInt(String::length));

// List 인터페이스에 추가된 sort 메서드 이용
words.sort(comparingInt(String::length));
```

람다, 매개변수(s1, s2), 반환값의 타입은 각각 (Comparator\<String\>), String, int지만 코드에서는 언급이 없다. 컴파일러가 문맥을 살펴 타입을 추론해준 것이다. **타입을 명시해야 코드가 더 명확할 때만 제외하고는, 람다의 모든 매개변수 타입은 생략하자.**

Operation 열거 타입을 예로 들어보자. apply 메서드의 동작이 상수마다 달라야 해서 상수별 클래스 몸체를 사용해 각 상수에서 apply 메서드를 재정의한 것이다.

```java
// 상수별 클래스 몸체와 데이터를 사용한 열거 타입
public enum Operation {
  PLUS("+") {
    public double apply(double x, double y) { return x + y; }
  },
  MINUS("-") {
    public double apply(double x, double y) { return x - y; }
  },
  TIMES("*") {
    public double apply(double x, double y) { return x * y; }
  },
  DIVIDE("/") {
    public double apply(double x, double y) { return x / y; }
  };

  private final String symbol;

  Operation(String symbol) { this.symbol = symbol; }
  public abstract double apply(double x, double y);
}

// 함수 객체(람다)를 인스턴스 필드에 저장해 상수별 동작을 구현한 열거 타입
public enum Operation {
  PLUS ("+", (x, y) -> x + y),
  MINUS ("-", (x, y) -> x - y),
  TIMES ("*", (x, y) -> x * y),
  DIVIDE ("/", (x, y) -> x / y);

  private final String symbol;
  private final DoubleBinaryOperator op;

  Operation(String symbol, DoubleBinaryOperator op) {
    this.symbol = symbol;
    this.op = op;
  }

  @Override public String toString() { return symbol; }

  public double apply(double x, double y) {
    return op.applyAsDouble(x, y);
  }
}
```

메서드나 클래스와 달리, **람다는 이름이 없고 문서화도 못한다. 따라서 코드 자체로 동작이 명확히 설명되지 않거나 코드 줄 수가 많아지면 람다를 쓰지 말아야 한다.**

열거 타입 생성자에 넘겨지는 인수들의 타입도 컴파일타임에 추론된다. 따라서 열거 타입 생성자 안의 람다는 열거 타입의 인스턴스 멤버에 접근할 수 없다(인스턴스는 람다에 만들어지기 때문이다). 람다에서의 this 키워드는 바깥 인스턴스를 가리킨다. 반면 익명 클래스의 this는 익명 클래스의 인스턴스 자신을 가리킨다. 그래서 함수 객체가 자신을 참조해야 한다면 반드시 익명 클래스를 써야 한다.

람다도 익명 클래스처럼 직렬화 형태로 구현별로 다를 수 있다. 따라서 **람다를 직렬화하는 일은 극힘 삼가야 한다.**

---

# 아이템 43. 람다보다는 메서드 참조를 사용하라.
람다가 익명 클래스보다 나은 점 중에서 가장 큰 특징은 간결함이다. 그리고 메서드 참조(method reference)로 함수 객체를 람다보다도 더 간결하게 만들 수 있다.

```java
// 람다
map.merge(key, 1, (count, incr) -> count + incr);

// 메서드의 참조를 전달
map.merge(key, 1, Integer::sum);
```

람다로 구현했을때 너무 길거나 복잡하다면 메서드 참조가 좋은 대안이 되어준다. 즉, 람다로 작성할 코드를 새로운 메서드에 담은 다음, 람다 대신 메서드 참조를 사용하는 식이다.

| 메서드 참조 유형 | 예 | 같은 기능을 하는 람다 |
| --- | --- | --- |
| 정적 | Integer::parseInt | str -> Integer.parseInt(str) |
| 한정적(인스턴스) | Instance.now()::isAfter | Instance then = Instance.now();<br/> t -> then.isAfter(t) |
| 비한정적(인스턴스) | String::toLowerCase | str -> str.toLowerCase() |
| 클래스 생성자 | TreeMap<K, V>::new | () -> new TreeMap<K, V>() |
| 배열 생성자 | int[]::new | len -> new int[len] |

메서드 참조는 람다의 간단명료한 대안이 될 수 있다. **메서드 참조 쪽이 짧고 명확하다면 메서드 참조를 쓰고, 그렇지 않을 때만 람다를 사용하라.**

---

# 44. 표준 함수형 인터페이스를 사용하라
과거에는 상위 클래스의 기본 메서드를 재정의해 원하는 동작을 구현하는 템플릿 메서드 패턴을 사용했다면, 이를 대체하는 현대적인 해법은 같은 효과의 함수 객체를 받는 정적 팩ㅌ너리나 생성자를 제공하는 것이다.

LinkedHashMap을 생각해보자. 이 클래스의 protected 메서드인 removeEldestEntry를 재정의하면 캐시로 사용할 수 있다. 맵에 새로운 키를 추가하는 put 메서드는 이 메서드를 호출하여 true가 반환되면 맵에서 가장 오래된 원소를 제거한다. 예컨대 removeEldestEntry를 다음처럼 재정의하면 맵에 원소가 100개가 될 때까지 커지다가, 그 이상이 되면 새로운 키가 더해질 때마다 가장 오래된 원소를 하나씩 제거한다. 즉, 가장 최근 원소 100개를 유지한다.

```java
protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
  return size() > 100;
}
```

removeEldestEntry는 size()를 호출해 맵 안의 원소 수를 알아내는데, removeEldestEntry가 인스턴스 메서드라 가능한 방식이다. 하지만 생성자에 넘기는 함수 객체는 이 맵의 인스턴스 메서드가 아니다. 팩터리나 생성자를 호출할 때는 맵의 인스턴스가 존재하지 않기 때문이다. 따라서 맵은 자기 자신도 함수 객체에 건네줘야 한다.

```java
// 불필요한 함수형 인터페이스 - 대신 표준 함수형 인터페이스를 사용하라.
@FunctionalInterface
Integer EldestEntryRemovalFunction<K, V> {
  boolean remove(Map<K, V> map, Map.Entry<K, V> eldest);
}
```

이 인터페이스도 잘 동작하기는 하지만, 굳이 사용할 이유가 없다. java.util.function 패키지를 보면 다양한 용도의 표준 함수형 인터페이스가 담겨 있다. **필요한 용도에 맞는게 있다면, 직접 구현하지 말고 표준 함수형 인터페이스를 활용하라.** 예컨대 Predicate 인터페이스는 프레디키트(predicate)들을 조합하는 메서드를 제공한다. 앞의 LinkedHashMap 예에서는 직접 만든 EldestEntryRemovalFunction 대신 표준 인터페이스인 BiPredicate<Map<K, V>, Map.Entry<K, V>> 를 사용할 수 있다.

| 인터페이스 | 함수 시그니처 | 예 |
| --- | --- | --- |
| UnaryOperator<T> | T apply(T t) | String::toLowerCase |
| BinaryOperator<T> | T apply(T t1, T t2) | BigInteger::add |
| Predicate<T> | boolean test(T t) | Collection::isEmpty |
| Function<T, R> | R apply(T t) | Arrays::asList |
| Supplier<T> | T get() | Instant::now |
| Consumer<T> | void accept(T t) | System.out::println |

표준 함수형 인터페이스 대부분은 기본 타입만 지원한다. 그렇다고 **기본 함수형 인터페이스에 박싱된 기본 타입을 넣어 사용하지는 말자.**

이 중 하나 이상을 만족한다면 전용 함수형 인터페이스를 구현해야 하는 건 아닌지 진중히 고민해야 한다. 전용 함수형 인터페이스로 작성하기로 했다면, 자신이 작성하는 게 다른 것도 아닌 \'인터페이스\'임을 명심해야 한다. 아주 주의해서 설계해야 한다는 뜻이다(아이템 21).

1. 자주 쓰이며, 이름 자체가 용도를 명확히 설명해준다.
2. 반드시 따라야 하는 규약이 있다.
3. 유용한 디폴트 메서드를 제공할 수 있다.

@FunctionalInterface 애너테이션은 프로그래머의 의도를 명시하는 것으로, 크게 세 가지 목적이 있다.

1. 해당 클래스의 코드나 설명 문서를 읽을 이에게 그 인터페이스가 람다용으로 설계된 것임을 알려준다.
2. 해당 인터페이스가 추상 메서드를 오직 하나만 가지고 있어야 컴파일되게 해준다.
3. 그 결과 유지보수 과정에서 누군가 실수로 메서드를 추가하지 못하게 막아준다.

그러니 **직접 만든 함수형 인터페이스에는 항상 @FunctionalInterface 애너테이션을 사용하라.**

---

# 45. 스트림은 주의해서 사용하라
스트림 API는 다량의 데이터 처리 작업(순차적이든 병렬적이든)을 돕고자 자바 8에 추가되었다. 이 API의 추상 개념 중 핵심은 두 가지다.

1. 스트림(stream)은 데이터 원소의 유한 혹은 무한 시퀀스(sequence)를 뜻한다.
2. 스트림 파이프라인(stream pipeline)은 이 원소들로 수행하는 연산 단계를 표현하는 개념이다.

대표적으로는 컬렉션, 배열, 파일, 정규표현식 패턴 매처, 난수 생서기, 혹은 다른 스트림이 있다. 스트림 안의 데이터 원소들은 객체 참조나 기본 타입 값이다. 기본 타입 값으로는 int, long, double 이렇게 세 가지를 지원한다.

스트림 파이프라인은 소스 스트림에서 시작해 종단 연산(terminal operation)으로 끝나며, 그 사이에 하나 이상의 중간 연산(intermediate operation)이 있을 수 있다. 각 중간 연산은 스트림을 어떠한 방식으로 변환(transform)한다.

스트림 파이프라인은 지연 평가(lazy evaluation)된다. 평가는 종단 연산이 호출될 때 이뤄지며, 종단 연산에 쓰이지 않는 데이터 원소는 계산에 쓰이지 않는다. 이러한 지연 평가가 무한 스트림을 다룰 수 있게 해주는 열쇠다.

스트림 API는 메서드 연쇄를 지원하는 플루언트 API다. 즉, 파이프라인 하나를 구성하는 모든 호출을 연결하여 단 하나의 표현식으로 완성할 수 있다.

**람다에서는 타입 이름을 자주 생략하므로 매개변수 이름을 잘 지어야 스트림 파이프라인의 가독성이 유지된다.**

```java
"Hello world!".chars().forEach(System.out::print);

// 명시적으로 형변환
"Hello world!".chars().forEach(x -> System.out.print((char) x));
```

Hello World!를 출력하리라 기대했지만, 7210110810811132119111111410810033을 출력한다. \"Hello world!\".chars()가 반환하는 스트림의 원소는 char가 아닌 int 값이기 때문이다. 올바른 print 메서드를 호출하게 하려면 형변환을 명시적으로 해줘야한다. 하지만 **char 값들을 처리할 때는 스트림을 삼가는 편이 낫다.**

스트림을 처음 쓰기 시작하면 모든 반복문을 스트림으로 바꾸고 싶은 유혹이 일겠지만, 서두르지 않는게 좋다. 스트림으로 바꾸는게 가능할지라도 코드 가독성과 유지보수 측면에서는 손해를 볼 수 있기 때문이다. 그러니 **기존 코드는 스트림을 사용하도록 리팩터링하되, 새 코드가 더 나아 보일 때만 반영하자.**

다음 일들에는 스트림이 아주 안성맞춤이다.

- 원소들의 시퀀스를 일관되게 변환한다.
- 원소들의 시퀀스를 필터링한다.
- 원소들의 시퀀스를 하나의 연사을 사용해 결합한다(더하기, 연결하기, 최솟값 구하기 등).
- 원소들의 시퀀스를 컬렉션에 모은다(공통된 속성을 기준으로 묶어가며).
- 원소들의 시퀀스에서 특정 조건을 만족하는 원소를 찾는다.

```java
static Stream<BigInteger> primes() {
  return Stream.iterate(TWO, BigInteger::nextProbablePrime);
}
```

메서드 이름 primes는 스트림의 원소가 소수임을 말해준다. 스트림을 반환하는 메서드 이름은 이처럼 원소의 정체를 알려주는 복수 명사로 쓰기를 강력히 추천한다.









































###
