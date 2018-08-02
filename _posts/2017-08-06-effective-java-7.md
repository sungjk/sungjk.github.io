---
layout: entry
post-category: java
title: Effective Java(7)
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java의 8장(일반적인 프로그래밍 원칙들)을 정리한 글입니다.
publish: true
---

# 규칙 45. 지역 변수의 유효범위를 최소화하라
지역 변수의 유효범위를 최소화하면 가독성(readability)과 유지보수성(maintainability)이 좋아지고, 오류 발생 가능성도 줄어든다.

**지역 변수의 유효범위를 최소화하는 가장 강력한 기법은, 처음으로 사용하는 곳에서 선언하는 것이다.** 지역 변수를 너무 빨리 선언하면 유효범위가 너무 앞쪽으로 확장될 뿐 아니라, 뒤쪽으로도 확장된다.

**거의 모든 지역 변수 선언에는 초기값(initializer)이 포함되어야 한다.** 볌수를 적절히 초기화하기에 충분한 정보가 없다면, 그때까지는 선언을 미뤄야 한다.

순환문(loop)를 잘 쓰면 변수의 유효범위를 최소화할 수 있다. for문이나 for-each 문의 경우, *순환문 변수*(loop variable)이라는 것을 선언할 수 있는데, 그 유효범위는 선언된 지역(즉, for 다음에 오는 순환문 괄호()와 순환문 몸체 {} 내부 코드) 안으로 제한된다. 따라서 **while 문보다는 for 문을 쓰는 것이 좋다.**

예를 들어, 컬렉션을 순회할 때는 아래와 같이 하는 것이 좋다(규칙 46).

```java
// 컬렉션을 순회할 때는 이 숙어대로 하는 것이 바람직
for (Element e : c) {
  doSomething(e);
}
```

이런 for 순환문이 while 문보다 바람직한 이유는 아래 코드를 통해 확인할 수 있다.

```java
Iterator<Element> i = c.iterator();
while (i.hasNext()) {
  doSomething(i.next());
}
...

Iterator<Element> i2 = c2.iterator();
while (i.hasNext()) {     // 버그!
  doSomethingElse(i2.next());
}
```

두 번째 순환문에서 새로운 변수 i2를 초기화했으나 실제로는 옛날 변수 i를 써버렸다. i가 아직도 유효범위 안에 있는 관계로, 이 코드는 컴파일이 잘 될뿐 아니라 예외도 없이 실행되지만 이상하게 동작한다.

순환문 조건식(loop test) 안에서 메서드를 호출할 경우, 해당 메서드의 호출 결과로 반환되는 값이 순환문 각 단계마다 달라지지 않는다면, 항상 이 패턴대로 코딩하면 된다.

지역 변수의 유효범위를 최소화하는 마지막 전략은 **메서드의 크기를 줄이고 특정한 기능에 집중하라는 것이다.** 두 가지 서로 다른 기능을 한 메서드 안에 넣어두면 한 가지 기능을 수행하는 데 필요한 지역 변수의 유효범위가 다른 기능까지 확장되는 문제가 생긴다. 이런 일을 막으려면 각 기능을 나눠서 별도 메서드로 구현해야 한다.

---

# 46. for 문보다는 for-each 문을 사용하라
for-each 문의 장점은 여러 컬렉션에 중첩되는 순환문을 만들어야 할 때 더 빛난다.

```java
for (Suit suit : suits)
  for (Rank rank : ranks)
    deck.add(new Card(suit, rank));
```

for-each 문으로는 컬렉션과 배열뿐 아니라 Iteratable 인터페이스를 구현하는 어떤 객체도 순회할 수 있다. Iteratable 인터페이스는 메서드가 하나뿐인 아주 간단한 인터페이스다.

```java
public interace Iterable<E> {
  // 이 Iterable 안에 있는 원소들에 대한 반복자 반환
  Iterator<E> iterator();
}
```

### 요약
for-each 문은 전통적인 for 문에 비해 명료하고 버그 발생 가능성도 적으며, 성능도 뒤지지 않는다. 그러니 가능하다면 항상 사용해야 한다. 그러나 불행히도 아래의 세 경우에 대해서는 적용할 수 없다.

1. **필터링**(filtering): 컬렉션을 순회하다가 특정한 원소를 삭제할 필요가 있다면, 반복자를 명시적으로 사용해야 한다.
2. **변환**(transforming): 리스트나 배열을 순회하다가 그 원소 가운데 일부 또는 전부의 값을 변경해야 한다면, 원소의 값을 수정하기 위해서 리스트 반복자나 배열 첨자가 필요하다.
3. **병렬 순회**(parallel iteration): 여러 컬렉션을 병렬적으로 순회하고, 모든 반복자나 첨자 변수가 발맞춰 나가도록 구현해야 한다면 반복자나 첨자 변수를 명시적으로 제어할 필요가 있을 것이다.

---

# 규칙 47. 어떤 라이브러리가 있는지 파악하고, 적절히 활용하라
random 메서드를 만들려면 가상난수 생성기(pseudorandom number generator), 수 이론(number theory), 2의 보수 연산(two's complement arithmetic)에 대해서 많이 알아야 할 것이다. 그러나 이미 플랫폼 라이브러리에 해당 함수가 있다.

nextInt(int)가 어떻게 맡은 일을 다하는지 알 필요가 없다. 이 메서드는 알고리즘 지식을 갖춘 고급 엔지니어가 꽤 많은 시간을 들여 설계하고 구현하고 테스트한 다음에, 해당 분야 전문가 몇 명에게 보여주고 제대로 됐는지 확인한 메서드다. 표준 라이브러리(standard library)를 사용하면 그 라이브러리를 개발한 전문가의 지식뿐만 아니라 여러분보다 먼저 그 라이브러리를 사용한 사람들의 경험을 활용할 수 있다. 두 번째 장점은, 실제로 하려는 일과 큰 관련성도 없는 문제에 대한 해결 방법을 임의로 구현하느라 시간을 낭비하지 않아도 된다는 것이다. 세 번째 장점은, 별다른 노력을 하지 않아도 그 성능이 점차로 개선된다는 것이다.

이런 장점이 있다면 스스로 구현하기보다는 라이브러리에 있는 기능을 이용하는 것이 바람직해 보인다. 하지만 상당수의 프로그래머들은 그러지 않는다. **중요한 새 릴리스(major new release)가 나올 때마다 많은 기능이 새로 추가되는데, 그때마다 어떤 것들이 추가되었는지를 알아두는 것이 좋다.** 모든 문서를 다 공부할 필요는 없지만, **자바 프로그래머라면 java.lang, java.lang.util 안에 있는 내용은 잘 알고 있어야 하며, java.io의 내용도 어느 정도 알고 있어야 한다.**

### 요약
바퀴를 다시 발명하지 말라(don't reinvent the wheel). 일반적으로 보자면 직접 만든 코드보다는 라이브러리에 있는 코드가 더 낫고, 점차 개선될 가능성도 높다.

---

# 규칙 48. 정확한 답이 필요하다면 float과 double은 피하라
float과 double은 *이진 부동 소수점 연산*(binary floating-point arithmetic)을 수행하는데, 넓은 범위의 값(magnitude)에 대해 정확도가 높은 근사치를 제공할 수 있도록 설계된 연산이다. 하지만 정확한(exact) 결과를 제공하지는 않기 때문에 **돈과 관계된 계산에는 적합하지 않다.**

```java
// 금전 계산에 부동 소수점 연산을 사용하는 잘못된 프로그램
public static void main(String[] args) {
  double funds = 1.00;
  int itemsBought = 0;
  for (double price = .10; funds >= price; price += .10) {
    funds -= price;
    itemsBought++;
  }
  System.out.println(itemsBought + " items bought.");
  System.out.println("Change: $" + funds);
}
```

금전 계산을 하는 이 프로그램을 돌려 보면 살 수 있는 사탕은 세 개이고, 잔돈은 $0.3999999999999라고 출력될 것이다. 틀린 답이다. 이 문제를 제대로 풀려면 **돈 계산을 할 때는 BigDecimal, int 또는 long을 사용한다는 원칙을 지켜야 한다.**

위 프로그램을 double 대신 BigDecimal을 사용하는 코드로 바꿔 보면 아래와 같다.

```java
public static void main(String[] args) {
  final BigDecimal TEN_CENTS = new BigDecimal(".10");

  int itemsBought = 0;
  BigDecimal funds = new BigDecimal("1.00");
  for (BigDecimal price = TEN_CENTS;
      funds.compareTo(price) >= 0;
      price = price.add(TEN_CENTS)) {
    funds = funds.subtract(price);
    itemsBought++;
  }
  System.out.println(itemsBought + " items bought.");
  System.out.println("Money left over: $" + funds);
}
```

이렇게 고친 프로그램은 살 수 있는 사탕은 네 개이고, 잔돈은 $0.00라고 출력될 것이다. 정확한 답이다.

하지만 BigDecimal은 기본 산술연산 자료형(primitive arithmetic type)보다 사용이 불편하며, 느리다.

BigDecimal의 대안은 int나 long을 사용하는 것이다. 둘 중 어떤 자료형을 쓸 것이냐는 수의 크기, 그리고 소수점 이하 몇 자리까지를 표현할 것이냐에 따라 결정된다. 이 예제에 맞는 접근법은 모든 계산을 달러 대신 센트 단위로 하는 것이다.

```java
public static void main(String[] args) {
  int itemsBought = 0;
  int funds = 100;
  for (int price = 10; funds >= price; price += 10) {
    funds -= price;
    itemsBought++;
  }
  System.out.println(itemsBought + " items bought.");
  System.out.println("Money left over: " + funds + " cents");
}
```

### 요약
- 정확한 답을 요구하는 문제를 풀 때는 float나 double을 쓰지 마라.
- 성능이 중요하고 소수점 아래 수를 관리할 필요가 없다면, BigDecimal 대신에 int나 long을 써라.

---

# 규칙 49. 객체화된 기본 자료형 대신 기본 자료형을 이용하라
자바의 자료형 시스템은 int, double, boolean 등의 기본 자료형(primitive type)과 String, List 등의 *참조 자료형*(reference type)으로 나뉜다. 모든 자료형에는 대응되는 참조 자료형이 있는데, 이를 *객체화된 기본 자료형*(boxed primitive type)이라 부른다. int, double, boolean의 객체화된 기본 자료형은 각각 Integer, Double, Boolean이다.

기본 자료형과 객체화된 기본 자료형 사이에는 세 가지 큰 차이점이 있다.

1. 기본 자료형은 값만 가지지만 객체화된 기본 자료형은 값 외에 *신원*(identity)을 가진다. 따라서 객체화된 기본 자료형의 값이 같더라도 신원은 다를 수 있다.
2. 기본 자료형에 저장되는 값은 전부 기능적으로 완전한 값(fully functional value)이지만, 객체화된 기본 자료형에 저장되는 값에는 그 이외에도 아무 기능도 없는 값, 즉 null이 하나 있다.
3. 기본 자료형은 시간이나 공간 요구량 측면에서 일반적으로 객체 표현형보다 효율적이다.

```java
Comparator<Integer> naturalOrder = new Comparator<Integer>() {
  public int compare(Integer first, Integer second) {
    return first < second ? -1 : (first == second ? 0 : 1);
  }
};
```

`naturalOrder.compare(new Integer(42), new Integer(42))` 의 값을 찍어보면 동일한 값을 나타내므로 반환되는 값이 0이어야 하지만, 첫 번째 Integer 객체가 두 번째보다 크다는 1이 반환된다.

표현식 first < second는 first와 second가 참조하는 Integer 객체를 기본 자료형 값으로 *자동 변환* 한다. 따라서 first의 int 값이 second의 int 값보다 작다면 음수가 제대로 반환될 것이다. 하지만 연산자 ==는 객체 참조를 통해 *두 객체의 신원을 비교한다*(identity comparison). first와 second가 다른 Integer 객체인 경우 ==는 false를 반환할 것이므로 비교자는 1이라는 잘못된 값을 반환하게 된다. **객체화된 기본 자료형에 == 연산자를 사용하는 것은 거의 항상 오류라고 봐야 한다.**

```java
public class Unbelievable {
  static Integer i;

  public static void main(String[] args) {
    if (i == 42)
      System.out.println("Unbelievable");
  }
}
```

이 프로그램은 Unbelievable을 출력하지 않는데, Unbelievable을 출력하는 것만큼이나 이상한 짓을 한다. (i == 42)를 계산할 때 NullPointerException을 발생시킨다. 모든 객체 참조 필드가 그렇듯, 그 초기값은 null이다. 거의 모든 경우에, **기본 자료형과 객체화된 기본 자료형을 한 연산 안에 엮어 놓으면 객체화된 기본 자료형은 자동으로 기본 자료형으로 변환된다.** 위 코드도 null인 객체 참조를 기본 자료형으로 변환하려 시도하다가 NullPointerException이 발생한다.

```java
// 무시무시할 정도로 느린 프로그램. 어디서 객체가 생성되는지 알겠는가?
public static void main(String[] args) {
  Long sum = 0L;
  for (long i = 0; i < Integer.MAX_VALUE; i++) {
    sum += i;
  }
  System.out.println(sum);
}
```

지역 변수 sum을 long이 아니라 Long으로 선언했기 때문에 변수가 계속해서 객체화와 비객체화를 반복하면서 성능이 느려진다.

그렇다면 객체화된 기본 자료형은 언제 사용해야 하는가? 컬렉션의 요소, 키, 값으로 사용할 때다. *형인자 자료형*(parameterized type, 5장)의 형인자로는 객체화된 기본 자료형을 써야 한다는 일반 규칙의 특수한 형태다. 다시 말해, ThreadLocal\<int\> 같은 변수는 선언할 수 없다. 대신 ThreadLocal\<Integer\>를 써야 한다. 리플렉션을 통해 메서드를 호출할 때도 객체화된 기본 자료형을 사용해야 한다(규칙 53).

### 요약
- 가능하다면 기본 자료형을 사용하라(단순하고 더 빠름).
- **자동 객체화는 번거로운 일을 줄여주긴 하지만, 객체화된 기본 자료형을 사용할 때 생길 수 있는 문제들까지 없재주진 않는다.**
- **객체화된 기본 자료형과 기본 자료형을 한 표현식 안에 뒤섞으면 비객체화가 자동으로 일어나며, 그 과정에서 NullPointerException이 발생할 수 있다.**

---

# 규칙 50. 다른 자료형이 적절하다면 문자열 사용은 피하라
**문자열은 값 자료형(value type)을 대신하기에는 부족하다.** 일반적으로 말하자면, 적절한 값 자료형이 있다면 그것이 기본 자료형이건 아니면 객체 자료형이건 상관없이 해당 자료형을 사용해야 한다는 것. 적당한 자료형이 없다면 새로 만들어야 한다.

**문자열은 enum 자료형을 대신하기에는 부족하다.** 규칙 30에서 설명한 대로, enum은 문자열보다 훨씬 좋은 열거 자료형 상수(enumerated type constant)들을 만들어 낸다.

**문자열은 혼합 자료형(aggregate type)을 대신하기엔 부족하다.** 여러 컴포넌트가 있는 개체를 문자열로 표현하는 것은 좋은 생각이 아니다. 혼합 자료형을 표현할 클래스를 만드는 편이 더 낫다. 이런 클래스는 종종 private static 멤버 클래스로 선언된다(규칙 22).

**문자열은 권한(capability)을 표현하기엔 부족하다.**

```java
// 문자열을 권한으로 사용하는 잘못된 예제
public class ThreadLocal {
  private ThreadLocal() { }

  // 주어진 이름이 가리키는 스레드 지역 변수의 값 설정
  public static void set(String key, Object value);

  // 주어진 이름이 가리키는 스레드 지역 변수의 값 반환
  public static Object get(String key);
}
```

이 접근법의 문제는, 문자열이 스레드 지역 변수의 전역적인 이름공간(global namespace)이라는 것이다. 위 접근법이 통하려면 클라이언트가 제공하는 문자열 키의 유일성이 보장되어야 한다. 만일 두 클라이언트가 공교롭게도 같은 지역 변수명을 사용한다면 동일한 변수를 공유하게 되어서 보통은 둘 다 오류를 낼 것이다.

위 API의 문제는 문자열 대신 위조 불가능(unforgeable) 키로 바꾸면 해결된다(이런 키를 때로 권한*capability*이라 부른다).

```java
public class ThreadLocal {
  private ThreadLocal() { }

  public static class Key { // (권한)
    Key() { }
  }

  // 유일성이 보장되는, 위조 불가능 키를 생성
  public static Key getKey() {
    return new Key();
  }

  public static void set(Key key, Object value);
  publid static Object get(Key key);
}
```

여기서 정적 메서드들은 사실 더 이상 필요 없다. 키의 객체 메서드(instance method)로 만들 수 있다. 그렇게 하고 나면 키는 더 이상 스레드 지역 변수의 키가 아니라, 그것 자체가 스레드 지역 변수가 된다. 그렇게 고치면 객체를 만들 수 없는 최상위 클래스는 더 이상 하는 일이 없으므로 없애버린 다음에 중첩 클래스 이름을 ThreadLocal로 바꿔버릴 수 있다.

```java
public final class ThreadLocal {
  public ThreadLocal();
  public void set(Object value);
  public Object get();
}
```

그런데 이 API는 스레드 지역 변수에서 값을 꺼낼 때 Object에서 실제 자료형으로 형변환을 해야 하므로 형 안전성을 보장하지 못한다. 애초의 String 기반 API는 형 안정적으로 만들 수 없고, Key 기반의 API는 형 안정적으로 만들기가 어렵다. 하지만 위 API는 ThreadLocal 클래스를 제네릭으로 선언하기만 하면 간단하게 형 안정성을 보장하는 API로 만들 수 있다(규칙 26).

```java
public final class ThreadLocal<T> {
  public ThreadLocal();
  public void set(T value);
  public T get();
}
```

개략적으로, 이것이 바로 java.lang.ThreadLocal이 제공하는 API다. 문자열 기반 API의 문제를 해결할 뿐 아니라, 키 기반 API보다 빠르고 우아하다.

---

# 규칙 51. 문자열 연결시 성능에 주의하라
**n 개의 문자열에 연결 연산자를 반복 적용해서 연결하는 데 드는 시간은 n^2에 비례한다.** 문자열이 *변경 불가능*하기 때문이다(규칙 15).

아래 메서드는 한 줄의 문자열을 계속 연결해서 청구서(billing statement)를 만든다.

```java
// 문자열을 연결하는 잘못된 방법 - 성능이 엉망
public String statement() {
  String result = "";
  for (int i = 0; i < numItems(); i++)
    result += lineForItem(i); // String concatenation
  return result;
}
```

**만족스런 성능을 얻으려면 String 대신 StringBuilder를 써서** 청구서를 저장해야 한다. (StringBuilder 클래스는 릴리스 1.5에 추가된 것으로 StringBuffer에서 동기화synchronization 기능을 뺀 것이다. StringBuffer는 이제 지원되지 않는다.)

```java
public String statement() {
  StringBuilder b = new StringBuilder(numItems() * LINE_WIDTH);
  for (int i = 0; i < numItems(); i++)
    b.append(lineForItem(i));
  return b.toString();
}
```

첫 번째 메서드가 항목 숫자 제곱에 비례하는 성능을 보인다면, 두 번째 메서드는 항목 숫자에 비례하는 성능을 낸다. 따라서 항목의 개수가 많아지면 성능 차이는 극명해진다.

### 요약
- 성능이 걱정된다면 + 연산자 대신 StringBuilder의 append 메서드를 사용하라.

---

# 규칙 52. 객체를 참조할 때는 그 인터페이스를 사용하라
규칙 40의 내용은 인자의 자료형으로는 클래스 대신 인터페이스를 사용해야 한다는 것이었다. 더 일반적으로 말하면, 객체를 참조할 때는 클래스보다 인터페이스를 사용해야 한다는 것으로 이해할 수 있다. **만일 적당한 인터페이스 자료형이 있다면 인자나 반환값, 변수, 그리고 필드의 자료형은 클래스 대신 인터페이스로 선언하자.**

```java
// 인터페이스를 자료형으로 사용하고 있는, 바람직한 예제
List<Subscriber> subscribers = new Vector<Subscriber>();

// 클래스를 자료형으로 사용하는, 나쁜 예제
Vector<Subscriber> subscribers = new Vector<Subscriber>();
```

**인터페이스를 자료형으로 쓰는 습관을 들이면 프로그램은 더욱 유연해진다.** 가령 어떤 객체의 실제 구현을 다른 것으로 바꾸고 싶다면, 호출하는 생성자 이름만 다른 클래스로 바꾸거나 호출하는 정적 팩터리 메서드만 다른 것으로 바꿔주면 된다.

```java
List<Subscriber> subscribers = new ArrayList<Subscriber>();
```

**적당한 인터페이스가 없는 경우에는 객체를 클래스로 참조하는 것이 당연하다.** 다양한 구현을 염두에 두고 String과 BigInteger 같은 값 클래스를 만드는 일은 거의 없다. final인 경우가 많으며, 대응되는 인터페이스도 거의 없다. 그런 값 클래스는 당연히 인자나 변수, 필드, 반환값의 자료형으로 사용할 수 있다. 일반적으로 말해서, 연관된 인터페이스가 없는 객체 생성 가능 클래스의 경우, 그 클래스가 값 클래스인지의 여부에는 상관없이, 그 객체의 클래스를 통해 참조해야 한다.

---

# 규칙 53. 리플렉션 대신 인터페이스를 이용하라
java.lang.reflect의 *핵심 리플렉션 기능*(core reflection facility)을 이용하면 메모리에 적재된(load) 클래스의 정보를 가져오는 프로그램을 작성할 수 있다. Class 객체가 주어지면, 해당 객체가 나타나는 클래스의 생성자, 메서드, 필드 등을 나타내는 Constructor, Method, Field 객체들을 가져올 수 있는데, 이 객체들을 사용하면 클래스의 멤버 이름이나 필드 자료형, 메서드 시그니처 등의 정보들을 얻어낼 수 있다.

게다가 Constructor, Method, Field 객체를 이용하면, 거기 연결되어 있는 실제 생성자, 메서드, 필드들을 *반영적으로*(reflectively) 조작할 수 있다. 객체를 생성할 수도 있고, 메서드를 호출할 수도 있으며, 필드에 접근할 수도 있다. 또한, 소스 코드가 컴파일 될 당시에는 존재하지도 않았던 클래스를 이용할 수 있다. 하지만 이런 능력에는 대가가 따른다.

- 컴파일 시점에 자료형을 검사함으로써 얻을 수 있는 이점들을 포기해야 한다(예외 검사*exception checking* 포함). 리플렉션을 통해 존재하지 않는, 또는 접근할 수 없는 메서드를 호출하면 실행 도중에 오류가 발생할 것이다.
- 리플렉션 기능을 이용하는 코드는 보기 싫은데다 장황하다. 가독성도 떨어진다.
- 성능이 낮다.

**일반적인 프로그램은 프로그램 실행 중에 리플렉션을 통해 객체를 이용하려 하면 안 된다는 것이다.**

**리플렉션을 아주 제한적으로만 사용하면 오버헤드는 피하면서도 리플렉션의 다양한 장점을 누릴 수 있다.** 컴파일 시점에는 존재하지 않는 클래스를 이용해야 하는 프로그램 가운데 상당수는, 해당 클래스 객체를 참조하는 데 사용할 수 있는 인터페이스나 상위 클래스는(규칙 52) 컴파일 시점에 이미 갖추고 있는 경우가 많다. 그럴 때는, **객체 생성은 리플렉션으로 하고 객체 참조는 인터페이스나 상위 클래스를 통하면 된다.**

예를 들어, 아래의 프로그램은 명령줄(command line)에 주어진 첫 번째 인자와 같은 이름의 클래스를 이용해 Set\<String\> 객체를 만든다. 나머지 인자들은 전부 해당 집합에 집어넣고 출력한다. 첫 번째 인자가 무엇인지에 관계없이, 이 프로그램은 나머지 인자들에서 중복을 제거한 다음에 출력한다. 하지만 출력 순서는 첫 번째 인자로 어떤 클래스를 지정했느냐에 좌우된다. java.util.HashSet을 지정했다면 무작위 순서로 출력될 것이다. java.util.TreeSet을 지정했으면 알파벳 순서대로 출력될 것이다.

```java
// 객체 생성은 리플렉션으로, 참조와 사용은 인터페이스로
public static void main(String[] args) {
  // 클래스 이름을 Class 객체로 변환
  Class<?> cl = null;
  try {
    cl = Class.forName(args[0]);
  } catch (ClassNotFoundException e) {
    System.err.println("Class not found.");
    System.exit(1);
  }

  // 해당 클래스의 객체 생성
  Set<String> s = null;
  try {
    s = (Set<String>) cl.newInstance();
  } catch (IllegalAccessException e) {
    System.err.println("Class not accessible.");
    System.exit(1);
  } catch (InstantiationException e) {
    System.err.println("Class not instantiable.");
    System.exit(1);
  }

  // 집합 이용
  s.addAll(Arrays.asList(args).subList(1, args.length));
  System.out.println(s);
}
```

이 프로그램은 하나 이상의 객체를 공격적으로 조작하여 해당 구현이 Set의 일반 규약을 준수하는지 검증하는 일반적 집합 검사 도구(generic set tester)로 쉽게 변경될 수 있다. 마찬가지로, 일반적 집합 성능 분석 도구(generic performance analysis tool)로도 쉽게 바꿀 수 있다. 사실, 이 기법은 완벽한 *서비스 제공자 프레임워크*(규칙 1)를 구현할 수 있을 정도로 강력하다. 대부분의 경우, 리플렉션 기능은 이 정도만 사용해도 충분하다.

이 예제는 리플렉션의 두 가지 단점도 보여준다. 첫 번째는 세가지 실행시점 오류(runtime error)를 발생시키는데, 리플렉션으로 객체를 만들지 않았더라면 컴파일 시점에 검사할 수 있는 오류들이다. 두 번째로, 이름에 대응되는 클래스의 객체를 생성하기 위해 스무 줄 가량의 멍청한 코드를 사용하고 있는데, 생성자 호출로 대신했으면 한 줄이었으면 되었을 코드다.

### 요약
컴파일 시점에는 알 수 없는 클래스를 이용하는 프로그램을 작성하고 있다면, 리플렉션을 사용하되 가능하면 객체를 만들 때만 이용하고, 객체를 참조할 때는 컴파일 시에 알고 있는 인터페이스나 상위 클래스를 사용하라.

---

# 규칙 54. 네이티브 메서드는 신중하게 사용하라
자바의 네이티브 인터페이스(Java native interface, JNI)는 C나 C++ 등의 *네이티브 프로그래밍 언어*(native programming language)로 작성된 *네이티브 메서드*(native method)를 호출하는 데 이용되는 기능이다.

전통적으로 네이티브 메서드는 세 가지 용도로 쓰였다. 네이티브 메서드를 사용하면 레지스트리(registry)나 파일 락(file lock) 같은, 특정 플랫폼에 고유한 기능을 이용할 수 있다. 또한 이미 구현되어 있는 라이브러리를 이용할 수 있다. 마지막으로, 성능이 중요한 부분의 처리를 네이티브 언어에 맡길 수 있다.

일례로, 릴리스 1.4에 추가된 java.util.prefs를 이용하면 레지스트리 기능을 이용할 수 있고, 릴리스 1.6에 추가된 java.awt.SystemTray를 사용하면 데스크톱의 시스템 트레이(system tray) 영역을 이용할 수 있다.

**그러나 네이티브 메서드를 통해 성능을 개선하는 것은 추천하고 싶지 않다.** 릴리스 1.3 이전에나 필요했지, 현재 JVM은 *훨씬* 빠르다. 네이티브 메서드 없이도 그에 필적하는 성능을 낼 수 있다.

네이티브 메서드에는 심각한 문제가 있다. 네이티브 언어가 *안전하지 않으므로*(규칙 39), 메모리 훼손 문제(memory corruption error)로부터 자유로울 수가 없다. 게다가 플랫폼 종속적(platform dependent)이므로 이식성이 낮다. 또한 디버깅이 어렵다.

---

# 규칙 55. 신중하게 최적화하라
모든 프로그래머가 알아둬야 하는 최적화 관련 격언이 세 가지 있다.

> 맹목적인 어리석음(blind stupidity)을 비롯한 다른 어떤 이유보다도, 효율성이라는 이름으로 저질러지는 죄악이 더 많다(효율성을 반드시 성취하는 것도 아니면서 말이다). - 윌리엄 울프(William A. Wulf)

> 작은 효율성(small effciency)에 대해서는, 말하자면 97% 정도에 대해서는, 잊어버려라. 섣부른 최적화(premature optimization)는 모든 악의 근원이다. - 도널드 커누스(Donald E. Knuth)

> 최적화를 할 때는 아래의 두 규칙을 따르라.<br/>
> 규칙 1: 하지 마라.<br/>
> 규칙 2: (전문가들만 따를 것) 아직은 하지 마라. - 완벽히 명료한, 최적화되지 않은 해답을 얻을 때까지는. - M. A. 잭슨(M. A. Jackson)

최적화는 좋을 때보다 나쁠 때가 더 많으며, 섣불리 시도하면 더더욱 나쁘다는 것이다.

성능 때문에 구조적인 원칙(architectural principle)을 희생하지 마라. **빠른 프로그램이 아닌, 좋은 프로그램을 만들려 노력하라.** 좋은 프로그램은 *정보 은닉*(information hiding) 원칙을 지킨다. 설계에 관한 결정은 각 모듈 내부적으로 내려진다. 따라서 그 설계는 시스템의 다른 부분에는 영향을 주지 않으면서 독립적으로 변경될 수 있다(규칙 13).

**설계를 할 때는 성능을 제약할 가능성이 있는 결정들은 피하라.** 설계 가운데 성능에 문제가 있다는 사실이 발견된 후에 고치기가 가장 까다로운 부분은, 모듈 간 상호작용이나 외부와의 상호작용을 명시하는 부분이다. 그 중에서 가장 중요한 것은 API, 통신 프로토콜(wire-level protocol), 지속성 데이터 형식(persistent data format) 등이 있다. 이런 부분은 성능 문제가 발견된 후에는 수정하기 어렵거나 수정이 불가능하다.

**API를 설계할 때 내리는 결정들이 성능에 어떤 영향을 끼칠지를 생각하라.** public 자료형을 변경 가능하게 만들면 쓸데없이 방어적 복사를 많이 해야 할 수 있다(규칙 39). 마찬가지로, 구성(composition) 기법이 적절한 public 클래스에 계승(inheritance) 기법을 적용하면 해당 클래스는 영원히 상위 클래스에 묶이는데, 그 결과로 하위 클래스의 성능에 인위적인(artificial) 제약이 가해질 수도 있다(규칙 16). 또한 인터페이스가 적당한 API에 구현 자료형(implementation type)을 사용해 버리면 해당 API가 특정한 구현에 종속되므로 나중에 더 빠른 구현이 나와도 개선할 수 없게 된다(규칙 52).

다행인 것은, 잘 설계된 API는 일반적으로 좋은 성능을 보인다. **좋은 성능을 내기 위해 API를 급진적으로 바꾸는 것은 바람직하지 않다.**

프로그램을 신중히 설계한 결과로 명료하고 간결하며 구조가 잘 짜인 구현이 나왔다면, 바로 그때가 최적화를 고민할 시점일 것이다.

---

# 규칙 56. 일반적으로 통용되는 작명 관습을 따르라
철자에 관계된 작명 관습은 패키지, 클래스, 인터페이스, 메서드, 필드 그리고 자료형 변수에 관한 것이다. 이 규칙을 어기면 API는 사용하기 어렵고, 이 규칙을 어기는 구현은 유지보수하기 어렵다.

패키지 이름은 마침표를 구분점으로 사용하는 계층적 이름이어야 한다. 패키지 이름을 구성하는 각각의 컴포넌트는 알파벳 소문자로 구성하고, 숫자는 거의 사용하지 않는다. 조직 바깥에서 이용될 패키지 이름은 해당 조직의 인터넷 도메인 이름으로 시작해야 하는데, edu.cmu, com.sun, gov.sna처럼 최상위 도메인 이름이 먼저 온다.

패키지 이름의 나머지 부분은 어떤 패키지인지 설명하는 하나 이상의 컴포넌트로 구성된다. 패키지명 컴포넌트는 짧아야 하며, 보통 여덟 문자 이하로 만들어진다. 의미가 확실한 약어를 활용하면 좋다. 즉, utilities 대신 util이라고 하면 좋다.

패키지명 가운데 상당수는 인터넷 도메인 이름 이외에 단 하나의 컴포넌트만 사용한다. 여러 개의 정보 계층으로 나뉘어야 할 정도로 큰 기능이라면 추가 컴포넌트를 사용하는 것이 바람직하다. 예를 들어, javax.swing 패키지에는 javax.swing.plaf.metal 같은 이름을 갖는 패키지 계층이 풍부하다.

enum이나 어노테이션 자료형 이름을 비롯, 클래스나 인터페이스 이름은 하나 이상의 단어로 구성된다. 각 단어의 첫 글자는 대문자다. Timer나 FutureTask가 그 예다. 두문자 또는 max나 min처럼 널리 쓰이는 약어를 제외하면, 약어 사용은 피해야 한다.

메서드와 필드 이름은 클래스나 인터페이스 이름과 동일한 철자 규칙을 따른다. 다만 첫 글자는 소문자로 한다. remove나 ensureCapacity 등이 그 예다.

앞서 살펴본 규칙의 유일한 예외는 상수 필드(constant field)의 이름을 지을 때다. 상수 필드의 이름은 하나 이상의 대문자 단어로 구성되며, 단어 사이에는 밑줄 기호(_)를 둔다. VALUES나 NEGATIVE_INFINITY가 그 예다. 상수 필드는 그 값을 변경할 수 없는(immutable) static final 필드다. static final 필드가 기본 자료형이나 변경 불가능 참조 자료형(immutable reference type)일 때(규칙 15), 해당 필드는 상수 필드다. 예를 들어 enum 상수들은 정부 상수 필드다. static final 필드가 변경 가능 참조 자료형이더라도, 참조되는 객체가 변경 불가능하면 역시 상수 필드다.

지역 변수 이름은 멤버 이름과 같은 철자 규칙을 따르는데, 약어가 허용된다는 것만 다르다. 이름에 포함된 개별 문자나 짧은 문자열의 의미는 지역 변수가 위치한 부분의 문백에 따른다.

자료형 인자의 이름은 보통 하나의 대문자다. 가장 널리 쓰이는 것은 다섯 가지로, 임의 자료형인 경우에 T, 컬렉션의 요소 자료형인 경우에는 E, 맵의 키와 값에 대해서는 각각 K와 V, 예외인 경우에는 X를 사용한다. 임의의 자료형이 연속되는 경우에는 T, U, V처럼 하거나 T1, T2, T3처럼 나열한다.


| 식별자 자료형 | 예제                    |
| ---------- | ------------------------------ |
| 패키지      | com.google.inject, org.joda.time.format   |
| 클래스나 인터페이스   | Timer, FutureTask, LinkedHashMap, HttpServlet     |
| 메서드나 필드   | Remove, ensureCapacity, getCrc     |
| 상수 필드   | MIN_VALUE, NEGATIVE_INFINITY     |
| 지역 변수   | i, xref, houseNumber     |
| 자료형 인자   | T, E, K, V, X, T1, T2     |

문법적(grammatical) 작명 관습은 더 가변적일 뿐만 아니라, 철자 관습에 비해 논쟁의 여지가 많다. enum 자료형을 비롯한 클래스에는 단수형의 명사나 명사구(noun phrase)가 이름으로 붙는다. Timer, BufferedWriter, ChessPiece 등이 그 예다. 인터페이스도 클래스와 비슷한 작명 규칙을 따른다. Collection, Comparator 등이 그 예다. able이나 ible 같은 형용사격 어미가 붙기도 한다. Runnable, Iterable, Accessible 등이 그 예다. 어노테이션 자료형은 쓰임새가 너무 다양해서 딱히 지배적인 규칙이 없다.

어떤 동작을 수행하는 메서드는 일반적으로 동사나 동사구(목적어 포함)를 이름으로 갖는다. append나 drawImage 등이 그 예다. boolean 값을 반환하는 메서드의 이름은 보통 is, 드물게는 has로 시작하고, 그 뒤에는 명사나 명사구, 또는 형용사나 형용사구가 붙는다. isDigit, isProbablePrime, isEmpty, isEnabled, hasSiblings 등이 그 예다.

빈(bean) 클래스에 속한 메서드의 이름은 반드시 get으로 시작해야 한다. 클래스 안에 같은 속성을 설정(set)하는 메서드도 있다면 더욱 그래야 한다(getAttribute, setAttribute).

주의해야할 메서드 이름도 있다. 객체의 자료형을 변환하는 메서드, 다른 자료형의 독립적 객체를 반환하는 메서드에는 보통 toType 형태의 이름을 붙인다. toString, toArray 같은 이름이 그 예다. 인자로 전달받은 객체와 다른 자료형의 뷰(view) 객체를 반환하는 메서드에는(규칙 5) asType 형태의 이름을 붙인다. asList 같은 이름이 그 예다. 호출 대상 객체와 동일한 기본 자료형 값을 반환하는 메서드에는 typeValue와 같은 형태의 이름을 붙인다. intValue가 그 예다. 정적 팩터리 메서드에는 valueOf, of, getInstance, newInstance, getType, newType 같은 이름을 붙인다(규칙 1).

---

# Reference
- [Effective Java 2/E](http://www.insightbook.co.kr/%EB%8F%84%EC%84%9C-%EB%AA%A9%EB%A1%9D/programming-insight/%EC%9D%B4%ED%8E%99%ED%8B%B0%EB%B8%8C-%EC%9E%90%EB%B0%94effective-java-2e)
