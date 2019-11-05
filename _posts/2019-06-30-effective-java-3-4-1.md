---
layout: entry
post-category: java
title: Effective Java 3 - 클래스와 인터페이스(1)
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java 3판의 4장(클래스와 인터페이스)을 정리한 글입니다.
keywords: Java, 자바, Effective Java, 이팩티브 자바
next_url: /2019/06/30/effective-java-3-4-2.html
publish: true
---

# 15. 클래스와 멤버의 접근 권한을 최소화하라
어설프게 설계된 컴포넌트와 잘 설계된 컴포넌트의 가장 큰 차이는 클래스 내부 데이터와 내부 구현 정보를 외부 컴포넌트로부터 얼마나 잘 숨겼느냐다. 정보 은닉의 장점은 다음과 같다.

- 시스템 개발 속도를 높인다. 여러 컴포넌트를 병렬로 개발할 수 있기 때문이다.
- 시스템 관리 비용을 낮춘다. 각 컴포넌트를 더 빨리 파악하여 디버깅할 수 있고, 다른 컴포넌트로 교체하는 부담도 적기 때문이다.
- 정보 은닉 자체가 성능을 높여주지는 않지만, 성능 최적화에 도움을 준다. 완성된 시스템을 프로파일링해 최적화할 컴포넌트를 정한 다음(아이템 67), 다른 컴포넌트에 영향을 주지 않고 해당 컴포넌트만 최적화할 수 있기 때문이다.
- 소프트웨어 재사용성을 높인다. 외부에 거의 의존하지 않고 독자적으로 동작할 수 있는 컴포넌트라면 그 컴포넌트와 함께 개발하지 않은 낯선 환경에서도 유용하게 쓰일 가능성이 크기 때문이다.
- 큰 시스템을 제작하는 난이도를 낮춘다. 시스템 자체가 아직 완성되지 않은 상태에서도 개별 컴포넌트의 동작을 검증할 수 있기 때문이다.

정보 은닉의 기본 원칙은 **모든 클래스와 멤버의 접근성을 가능한 좁히는 것이다.** 톱레벨 클래스와 인터페이스에 부여할 수 있는 접근 수준은 package-private과 public 두 가지다. 톱레벨 클래스나 인터페이스를 public으로 선언하면 공개 API가 되며, package-private으로 선언하면 해당 패키지 안에서만 이용할 수 있다. 패키지 외부에서 쓸 이유가 없다면 package-private으로 선언하자.

한 클래스에서만 사용하는 package-private 톱레벨 클래스나 인터페이스는 이를 사용하는 클래스 안에 private static으로 중첩시켜보자. 톱레벨로 두면 같은 패키지의 모든 클래스가 접근할 수 있지만, private static으로 중첩시키면 바깥 클래스 하나에서만 접근할 수 있다. public일 필요가 없는 클래스의 접근 수준을 package-private 톱레벨 클래스로 좁혀야 한다.

멤버(필드, 메서드, 중첩 클래스, 중첩 인터페이스)에 부여할 수 있는 접근 수준은 네 가지다.

- private: 멤버를 선언한 톱레벨 클래스에서만 접근할 수 있다.
- package-private: 멤버가 소속된 패키지 안의 모든 클래스에서 접근할 수 있다.
- protected: package-private의 접근 범위를 포함하며, 이 멤버를 선언한 클래스의 하위 클래스에서도 접근할 수 있다.
- public: 모든 곳에서 접근할 수 있다.

public 클래스에서는 멤버의 접근 수준을 package-private에서 protected로 바꾸는 순간 그 멤버에 접근할 수 있는 대상 범위가 엄청나게 넓어진다. public 클래스의 protected 멤버는 공개 API이므로 영원히 지원돼야 한다. 또한 내부 동작 방식을 API 문서에 적어 사용자에게 공개해야 할 수도 있다. 따라서 protected 멤버의 수는 적을수록 좋다.

**public 클래스의 인스턴스 필드는 되도록 public이 아니어야 한다.** 필드가 가변 객체를 참조하거나, final이 아닌 인스턴스 필드를 public으로 선언하면 그 필드에 담을 수 있는 값을 제한할 힘을 잃게 된다. 그 필드와 관련된 모든 것은 불변식을 보장할 수 없게 된다는 뜻이다. 필드가 수정될 때 (락 획득 같은) 다른 작업을 할 수 없게 되므로 **public 가변 필드를 갖는 클래스는 일반적으로 스레드 안전하지 않다.**

해당 클래스가 표현하는 추상 개념을 완성하는 데 꼭 필요한 구성요소로써의 상수라면 public static final 필드로 공개해도 좋다. 관례상 이런 상수의 이름은 대문자 알파벳으로 쓰며, 각 단어 사이에 밑줄(\_)을 넣는다. 이런 필드는 반드시 기본 타입 값이나 불변 객체를 참조해야 한다.

길이가 0이 아닌 배열은 모두 변경 가능하지 주의하자. 따라서 **클래스에서 public static final 배열 필드를 두거나 이 필드를 반환하는 접근자 메서드를 제공해서는 안 된다.**

```java
// 보안 허점
public static final Thing[] VALUES = { ... };

// 방법 1. private으로 만들고 public 불변 리스트를 추가
private static final Thing[] PRIVATE_VALUES = { ... };
public static final List<Thing> VALUES =
  Collections.unmodifiableList(Arrays.asList(PRIVATE_VALUES));

// 방법 2. private으로 만들고 복사본을 반환하는 public 메서드 추가(방어적 복사)
private static final Thing[] PRIVATE_VALUES = { ... };
public static final Thing[] values() {
  return PRIVATE_VALUES.clone();
}
```

---

# 16. public 클래스에서는 public 필드가 아닌 접근자 메서드를 사용하라

**패키지 바깥에서 접근할 수 있는 클래스라면 접근자를 제공** 함으로써 클래스 내부 표현 방식을 언제든 바꿀 수 있는 유연성을 얻을 수 있다.

```java
// 접근자와 변경자(mutator) 메서드를 활용해 데이터를 캡슐화한다.
class Point {
  private double x;
  private double y;

  public Point(double x, double y) {
    this.x = x;
    this.y = y;
  }

  public double getX() { return x; }
  public double getY() { return y; }

  public void setX(double x) { this.x = x; }
  public void setY(double y) { this.y = y; }
}
```

하지만 **package-private 클래스 혹은 private 중첩 클래스라면 데이터 필드를 노출한다 해도 하등의 문제가 없다.** 이 방식은 클래스 선언 면에서나 이를 사용하는 클라이언트 코드 내부 표현에 묶이기는 하나, 클라이언트도 어차피이 클래스를 포함하는 패키지 안에서만 동작하는 코드일 뿐이다. 따라서 패키지 바깥 코드는 전혀 손대지 않고도 데이터 표현 방식을 바꿀 수 있다. private 중첩 클래스의 경우라면 수정 범위가 더 좁아져서 이 클래스를 포함하는 외부 클래스까지로 제한된다.

---

# 17. 변경 가능성을 최소화하라
불변 클래스는 가변 클래스보다 설계하고 구현하고 사용하기 쉬우며, 오류가 생길 여지도 적고 훨씬 안전하다. 클래스를 불변으로 만들려면 다음 다섯 가지 규칙을 따르면 된다.

- **객체의 상태를 변경하는 메서드(변경자)를 제공하지 않는다.**
- **클래스를 확장할 수 없도록 한다.** 하위 클래스에서 부주의하게 혹은 나쁜 의도로 객체의 상태를 변하게 만드는 사태를 막아준다.
- **모든 필드를 final로 선언한다.** 시스템이 강제하는 수단을 이용해 설계자의 의도를 명확히 드러내는 방법이다. 새로 생성된 인스턴스를 동기화 없이 다른 스레드로 건네도 문제없이 동작하게끔 보장하는 데도 필요하다.
- **모든 필드를 private으로 선언한다.** 필드가 참조하는 가변 객체를 클라이언트에서 직접 접근해 수정하는 일을 막아준다. 기술적으로 기본 타입 필드나 불변 객체를 참조하는 필드를 public final로만 선언해도 불변 객체가 되지만, 이렇게 하면 다음 릴리스에서 내부 표현을 바꾸지 못하므로 권하지는 않는다.
- **자신 외에는 내부의 가변 컴포넌트에 접근할 수 없도록 한다.** 클래스에 가변 객체를 참조하는 필드가 하나라도 있다면 클라이언트에서 그 객체의 참조를 얻을 수 없도록 해야 한다.

```java
// 불변 복소수 클래스
public final class Complex {
  private final double re;
  private final double im;

  public Complex(double re, double im) {
    this.re = re;
    this.im = im;
  }

  public Complex plus(Complex c) {
    return new Complex(re + c.re, im + c.im);
  }

  public Complex minus(Complex c) {
    return new Complex(re - c.re, im - c.im);
  }

  public Complex times(Complex c) {
    return new Complex(re * c.re - im * c.im, re * c.im + im * c.re);
  }

  public Complex dividedBy(Complex c) {
    double tmp = c.re * c.re + c.im * c.im;
    return new Complex((re * c.re + im * c.im) / (tmp, im * c.re - re * c.im) / tmp);
  }

  ...
}
```

사칙연산 메서드(plus, minus, times, dividedBy)들이 인스턴스 자신은 수정하지 않고 새로운 Complex 인스턴스를 만들어 반환하는 모습에 주목하자. 이처럼 피연산자에 함수를 적용해 그 결과를 반환하지만, 피연산잔자 자체는 그대로인 프로그래밍 패턴을 함수형 프로그래밍이라 한다.

함수형 프로그래밍에 익숙하지 않다면 조금 부자연스러워 보일 수도 있지만, 이 방식으로 프로그래밍하면 코드에서 불변이 되는 영역의 비율이 높아지는 장점을 누릴 수 있다. **불변 객체는 단순하다.** 모든 생성자가 클래스 불변식(class invariant)를 보장한다면 그 클래스를 사용하는 프로그래머가 다른 노력을 들이지 않더라도 영원히 불변으로 남는다.

**불변 객체는 근본적으로 스레드 안전하며 따로 동기화할 필요 없다.** 불변 객체에 대해서는 그 어떤 스레드도 다른 스레드에 영향을 줄 수 없으니 **불변 객체는 안심하고 공유할 수 있다.**

**불변 객체는 자유롭게 공유할 수 있음은 물론, 불변 객체끼리는 내부 데이터를 공유할 수 있다.** 예컨대 BigInteger 클래스는 내부에서 갑의 부호(sign)와 크기(magnitude)를 따로 표현한다. 부호에는 int 변수를, 크기(절댓값)에는 int 배열을 사용하는 것이다. 한편 negate 메서드는 크기가 같고 부호만 반대인 새로운 BigInteger를 사용하는데, 이때 배열은 비록 가변이지만 복사하지 않고 원본 인스턴스와 공유해도 된다.

**객체를 만들 때 다른 불변 객체들을 구성요소로 사용하면 이점이 많다.** 값이 바뀌지 않는 구성요소들로 이뤄진 객체라면 그 구조가 아무리 복잡하더라도 불변식을 유지하기 훨씬 수월하기 때문이다.

**불변 객체는 그 자체로 실패 원자성을 제공한다.** 상태가 절대 변하지 않으니 잠깐이라도 불일치 상태에 빠질 가능성이 없다.

**불변 클래스에도 단점은 있다. 값이 다르면 반드시 독립된 객체로 만들어야 한다는 것이다.** 값의 가짓수가 많다면 이들을 모두 만드는 데 큰 비용을 치러야 한다. 이 문제에 대처하는 방법은 두 가지다. 첫 번째는 흔히 쓰일 다단계 연산(multistep operation)들을 예측하여 기본 기능으로 제공하는 방법이다. 이러한 다단계 연산을 기본으로 제공한다면 더 이상 각 단계마다 객체를 생성하지 않아도 된다.

클라이언트들이 원하는 복잡한 연산들을 정확히 예측할 수 있다면 package-private의 가변 동반 클래스만으로 충분하다. 그렇지 않다면 이 클래스를 public으로 제공하는 게 최선이다.

클래스가 불변임을 보장하려면 자신을 상속하지 못하게 해야 함을 기억하는가? 자신을 상속하지 못하게 하는 가장 쉬운 방법은 final 클래스로 선언하는 것이지만, 더 유연한 방법이 있다. 모든 생성자를 private 혹은 package-private으로 만들고 public 정적 팩터리를 제공하는 방법이다.

```java
// 생성자 대신 정적 팩터리를 사용한 불변 클래스
public class Complex {
  private final double re;
  private final double im;

  private Complex(double re, double im) {
    this.re = re;
    this.im = im;
  }

  public static Complex valueOf(double re, double im) {
    return new Complex(re, im);
  }

  ...
}
```

바깥에서 볼 수 없는 package-private 구현 클래스를 원하는 만큼 만들어 활용할 수 있으니 훨씬 유연하다. 패키지 바깥의 클라이언트에서 바라본 이 불변 객체는 사실상 final이다. public이나 protected 생성자가 없으니 다른 패키지에서는 이 클래스를 확장하는 게 불가능하기 때문이다. 정적 팩터리 방식은 다수의 구현 클래스를 활용한 유연성을 제공하고, 이에 더해 다음 릴리스에서 객체 캐싱 기능을 추가해 성능을 끌어올릴 수도 있다.

게터(getter)가 있다고 해서 무조건 세터(setter)를 만들지는 말자. **클래스는 꼭 필요한 경우가 아니라면 불변이어야 한다.** 불변 클래스는 장점이 많으며, 단점이라곤 특정 상황에서의 잠재적 성능 저하뿐이다. Complex 같은 단순한 값 객체는 항상 불변으로 만들자. String과 BigInteger처럼 무거운 값 객체도 불변으로 만들 수 있는지 고심해야 한다. 성능 때문에 어쩔 수 없다면 불변 클래스와 쌍을 이루는 가변 동반 클래스를 public 클래스로 제공하도로고 하자.

한편, 모든 클래스를 불변으로 만들 수는 없다. **불변으로 만들 수 없는 클래스라도 변경할 수 있는 부분을 최소한으로 줄이자.** 객체가 가질 수 있는 상태의 수를 줄이면 그 객체을 예측하기 쉬워지고 오류가 생길 가능성이 줄어든다. 그러니 꼭 변경해야 할 필드를 뺀 나머지 모두를 final로 선언하자. **다른 합당한 이유가 없다면 모든 필드는 private final이어야 한다.**

**생성자는 불변식 설정이 모두 완료된, 초기화가 완벽히 끝난 상태의 객체를 생성해야 한다.** 확실한 이유가 없다면 생성자와 정적 팩터리 외에는 그 어떤 초기화 메서드도 public으로 제공해서는 안 된다.

---

# 18. 상속보다는 컴포지션을 사용하라
상속은 코드를 재사용하는 강력한 수단이지만, 항상 최선은 아니다. 상위 클래스와 하위 클래스를 모두 같은 프로그래머가 통제하는 패키지 안에서라면 안전한 방법이다. 확장할 목적으로 설계되었고 문서화도 잘 된 클래스도 마찬가지로 안전하다. 하지만 일반적인 구체 클래스를 패키지 경계를 넘어, 즉 다른 패키지의 구체 클래스를 상속(클래스가 다른 클래스를 확장하는 구현 상속)하는 일은 위험하다.

**메서드 호출과 달리 상속은 캡슐화를 깨뜨린다.** 다르게 말하면, 상위 클래스가 어떻게 구현되느냐에 따라 하위 클래스의 동작에 이상이 생길 수 있다.

구체적인 예를 살펴보자. HashSet의 성능을 높이도록 처음 생성된 이후 원소가 몇 개 더해졌는지 알 수 있게 add와 addAll을 재정의했다.

```java
// 잘못된 예 - 상속을 잘못 사용했다!
public class InstrumentedHashSet<E> extends HashSet<E> {
  // 추가된 원소의 수
  private int addCount = 0;

  public InstrumentedHashSet() {}

  public InstrumentedHashSet(int initCap, float loadFactor) {
    super(initCap, loadFactor);
  }

  @Override public boolean add(E d) {
    addCount++;
    return super.add(e);
  }

  @Override public boolean addAll(Collection<? extends E> c) {
    addCount += c.size();
    return super.addAll(c);
  }

  public int getAddCount() {
    return addCount;
  }
}
```

자바 9부터 지원하는 정적 팩터리 메서드인 List.of로 리스트를 생성해서 addAll을 해보겠다.

```java
InstrumentedHashSet<String> s = new InstrumentedHashSet<>();
s.addAll(List.of("틱", "탁탁", "펑"));
```

리스트를 추가하고 getAddCount 메서드를 호출하면 3을 반환하리라 기대하겠지만, 실제로는 6을 반환한다. InstrumentedHashSet의 addAll은 각 원소를 add 메서드를 호출해 추가하는데, 이때 불리는 add는 InstrumentedHashSet에 재정의한 메서드다. 따라서 addCount에 값이 중복해서 더해져, 최종값이 6으로 늘어난 것이다.

addAll 메서드를 주어진 컬렉션을 순회하며 원소 하나당 add 메서드를 한 번만 호출하는 형태로 재정의할 수도 있다. 이 방식은 HashSet의 addAll을 더 이상 호출하지 않으니 addAll이 add를 사용하는지와 상관없이 결과가 옳다는 점에서 조금은 나은 해법이다. 하지만 상위 클래스의 메서드 동작을 다시 구현하는 이 방식은 어렵고, 시간도 더 들고, 자칫 오류를 내거나 성능을 떨어뜨릴 수도 있다. 또한 하위 클래스에서는 접근할 수 없는 private 필드를 써야 하는 상황이라면 이 방식으로는 구현 자체가 불가능하다.

다행히 이상의 문제를 모두 피해가는 묘안이 있다. 기존 클래스를 확장하는 대신, 새로운 클래스를 만들고 private 필드로 기존 클래스의 인스턴스를 참조하게 하자. 기존 클래스가 새로운 클래스의 구성요소로 쓰인다는 뜻에서 이러한 설계를 컴포지션(composition; 구성)이라 한다. 새 클래스의 인스턴스 메서드들은 (private 필드로 참조하는) 기존 클래스의 대응하는 메서드를 호출해 그 결과를 반환한다. 이 방식을 전달(forwarding)이라 하며, 새 클래스의 메서드들을 전달 메서드(forwarding method)라 부른다. 그 결과 새로운 클래스는 기존 클래스의 내부 구현 방식의 영향에서 벗어나며, 심지어 기존 클래스에 새로운 메서드가 추가되더라도 전혀 영향받지 않는다. 구체적인 예시를 위해 InstrumentedHashSet을 컴포지션과 전달 방식으로 다시 구현한 코드를 준비했다.

```java
// 래퍼 클래스 - 상속 대신 컴포지션을 사용했다.
public class InstrumentedSet<E> extends ForwardingSet<E> {
  private int addCount = 0;

  public InstrumentedHashSet(Set<E> s) {
    super(s);
  }

  @Override public boolean add(E d) {
    addCount++;
    return super.add(e);
  }

  @Override public boolean addAll(Collection<? extends E> c) {
    addCount += c.size();
    return super.addAll(c);
  }

  public int getAddCount() {
    return addCount;
  }
}

// 재사용할 수 있는 전달 클래스
public class ForwardingSet<E> implements Set<E> {
  private final Set<E> s;

  public ForwardingSet(Set<E> s) { this.s = s; }

  public void clear() { s.clear(); }
  public boolean contains(Object o) { return s.contains(o); }
  public boolean isEmpty() { return s.isEmpty(); }
  ...
}
```

Set 인터페이스를 구현했고, Set의 인스턴스를 인수로 받는 생성자를 하나 제공한다. 임의의 Set에 계측 기능을 덧씌워 새로운 Set으로 만드는 것이 이 클래스의 핵심이다.

```java
Set<Instant> times = new InstrumentedSet<>(new TreeSet<>(cmp));
Set<E> s = new InstrumentedSet<>(new HashSet<>(INIT_CAPACITY));

static void walk(Set<Dog> dogs) {
  InstrumentedSet<Dog> iDogs = new InstrumentedSet<>(dogs);
  ... // 이 메서드에서는 dogs 대신 iDogs를 사용한다.
}
```

다른 Set 인스턴스를 감싸고(wrap) 있다는 뜻에서 InstrumentedSet 같은 클래스를 래퍼 클래스라 하며, 다른 Set에 계측 기능을 덧씌운다는 뜻에서 데코레이터 패턴(Decorator pattern)이라고 한다. 래퍼 클래스는 단점이 한 가지, 래퍼 클래스가 콜백(callback) 프레임워크와는 어울리지 않는다는 점만 주의하면 된다.

상속은 반드시 하위 클래스가 상위 클래스의 \'진짜\' 하위 타입인 상황에서만 쓰여야 한다. 다르게 말하면, 클래스 B가 클래스 A와 is-a 관계일 때만 클래스 A를 상속해야 한다. 클래스 A를 상속하는 클래스 B를 작성하려 한다면 \"B가 정말 A인가?\"라고 자문해보자.

---

# 19. 상속을 고려해 설계하고 문서화하라. 그러지 않았다면 상속을 금지하라.
상속을 고려한 설계와 문서화란 정확히 무얼 뜻할까?

우선, 메서드를 재정의하면 어떤 일이 일어나는지를 정확히 정리하여 문서로 남겨야 한다. 달리 말하면, **상속용 클래스는 재정의할 수 있는 메서드들을 내부적으로 어떻게 이용하는지(자기사용) 문서로 남겨야 한다.** 클래스의 API로 공개된 메서드에서 클래스 자신의 또 다른 메서드를 호출할 수도 있다. 그런데 마침 호출되는 메서드가 재정의 가능 메서드라면 그 사실을 호출하는 메서드의 API 설명에 적시해야 한다. 덧붙여서 어떤 순서로 호출하는지, 각각의 호출 결과가 이어지는 처리에 어떤 영향을 주는지도 담아야 한다(\'재정의 가능\'이란 public과 protected 메서드 중 final이 아닌 모든 메서드를 뜻한다).

내부 메커니즘을 문서로 남기는 것만이 상속을 위한 설계의 전부는 아니다. 효율적인 하위 클래스를 큰 어려움 없이 만들 수 있게 하려면 **클래스의 내부 동작 과정 중간에 끼어들 수 있는 훅(hook)을 잘 선별하여 protected 메서드 형태로 공개해야 할 수도 있다.**

**상속용 클래스를 시험하는 방법은 직접 하위 클래스를 만들어보는 것이 \'유일\'하다.** 꼭 필요한 protected 멤버를 놓쳤다면 하위 클래스를 작성할 때 그 빈자리가 확연히 드러난다. 거꾸로, 하위 클래스를 여러 개 만들 때까지 전혀 쓰이지 않는 protected 멤버는 사실 private이었어야 할 가능성이 크다.

널리 쓰일 클래스를 상속용으로 설계한다면 문서화한 내부 사용 패턴과, protected 메서드와 필드를 구현하면서 선택한 결정에 영원히 책임져야 함을 잘 인식해야 한다. **상속용으로 설계한 클래스는 배포 전에 반드시 하위 클래스를 만들어 검증해야 한다.**

상속을 허용하는 클래스가 지켜야 할 제약이 아직 몇 개 남았다. **상속용 클래스의 생성자는 직접적으로든 간접적으로든 재정의 가능 메서드를 호출해서는 안 된다.** 이 규칙을 어기면 프로그램이 오동작할 것이다. 상위 클래스의 생성자가 하위 클래스의 생성자보다 먼저 실행되므로 하위 클래스에서 재정의한 메서드가 하위 클래스의 생성자보다 먼저 호출된다. 이때 그 재정의한 메서드가 하위 클래스의 생성자에서 초기화하는 값에 의존한다면 의도대로 동작하지 않을 것이다.

```java
public class Super {
  // 잘못된 예 - 생성자가 재정의 가능 메서드를 호출한다.
  public Super() {
    overrideMe();
  }

  public void overrideMe() {
  }
}
```

다음은 하위 클래스의 클래스의 코드로, overrideMe 메서드를 재정의했다. 상위 클래스의 생성자가 호출해 오동작을 일으키는 바로 그 메서드다.

```java
public final class Sub extends Super {
  // 초기화되지 않은 final 필드. 생성자에서 초기화한다.
  private final Instant instant;

  Sub() {
    instant = Instant.now();
  }

  // 재정의 가능 메서드. 상위 클래스의 생성자가 호출한다.
  @Override public void overrideMe() {
    System.out.println(instant);
  }

  public static void main(String[] args) {
    Sub sub = new Sub();
    sub.overrideMe();
  }
}
```

이 프로그램 instant를 두 번 출력하리라 기대했겠지만, 첫 번째는 null을 출력한다. 상위 클래스의 생성자는 하위 클래스의 생성자가 인스턴스 필드를 초기화하기도 전에 overrideMe를 호출하기 때문이다. final 필드의 상태가 이 프로그램에서는 두 가지임에 주목하자(정상이라면 단 하나뿐이어야 한다). overrideMe에서 instant 객체의 메서드를 호출하려 한다면 상위 클래스의 생성자가 overrideMe를 호출할 때 NullPointerException을 던지게 된다. 이 프로그램이 NullPointerException을 던지지 않는 유일한 이유는 println이 null 입력도 받아들이기 때문이다.

clone과 readObject 메서드는 생성자와 비슷한 효과를 낸다(새로운 객체를 만든다). 따라서 상속용 클래스에서 Cloneable이나 Serializable을 구현할지 정해야 한다면, 이들을 구현할 때 따르는 제약도 생성자와 비슷하다는 점에 주의하자. 즉, **clone과 readObject 모두 직접적으로든 간접적으로든 재정의 가능 메서드를 호출해서는 안 된다.** readObject의 경우 하위 클래스의 상태가 미처 다 역직렬화되기 전에 재정의한 메서드부터 호출하게 된다. clone의 경우 하위 클래스의 clone 메서드가 복제본의 상태를 (올바른 상태로) 수정하기 전에 재정의한 메서드를 호출한다.

이제 **클래스를 상속용으로 설계하려면 엄청난 노력이 들고 그 클래스에 안기는 제약도 상당함을 알았다.** 그렇다면 그 외의 일반적인 구체 클래스는 어떨까? 클래스에 변화가 생길 때마다 하위 클래스를 오동작하게 만들 수 있다. 실제로도 보통 구체 클래스를 그 내부만 수정했음에도 이를 확장한 클래스에서 문제가 생겼다는 버그 리포트를 많이 받는다.

**이 문제를 해결하는 가장 좋은 방법은 상속용으로 설계하지 않은 클래스는 상속을 금지하는 것이다.** 쉬운 방법은 클래스를 final로 선언하는 방법이다. 두번째는 모든 생성자를 private이나 package-private으로 선언하고 public 정적 팩터리를 만들어주는 방법이다. 정적 팩터리 방법은 내부에서 다양한 하위 클래스를 만들어 쓸 수 있는 유연성을 준다.

---

# 20. 추상 클래스보다는 인터페이스를 우선하라
인터페이스와 추상 클래스의 가장 큰 차이는 추상 클래스가 정의한 타입을 구현하는 클래스는 반드시 추상 클래스의 하위 클래스가 되어야 한다는 점이다. 자바는 단일 상속만 지원하니, 추상 클래스 방식은 새로운 타입을 정의하는 데 커다란 제약을 안게 되는 셈이다. 반면 인터페이스가 선언한 메서드를 모두 정의하고 그 일반 규약을 잘 지킨 클래스라면 다른 어떤 클래스를 상속했든 같은 타입으로 취급된다.

**기존 클래스에도 손쉽게 새로운 인터페이스를 구현해넣을 수 있다.** 인터페이스가 요구하는 메서드를 추가하고, 클래스 선언에 implements 구문만 추가하면 끝이다.

**인터페이스는 믹스인(mixin) 정의에 안성맞춤이다.** 믹스인이란 클래스가 구현할 수 있는 타입으로, 믹스인을 구현한 클래스에 원래의 \'주된 타입\' 외에도 특정 선택적 행위를 제공한다고 선언하는 효과를 준다.

**인터페이스로는 계층구조가 없는 타입 프레임워크를 만들 수 있다.**

```java
public interface Singer {
  AudioClip sing(Song s);
}

public interface Songwriter {
  Song compose(int chartPosition);
}

// Singer와 Songwriter 모두를 확장하고 새로운 메서드까지 추가
public interface SingerSongwriter extends Singer, Songwriter {
  AudioClip strum();
  void actSensitive();
}
```

래퍼 클래스 관용구(아이템 18)와 함께 사용하면 **인터페이스는 기능을 향상시키는 안전하고 강력한 수단이 된다.** 타입을 추상 클래스로 정의해두면 그 타입에 기능을 추가하는 방법은 상속뿐이다. 상속해서 만든 클래스는 래퍼 클래스보다 활용도가 떨어지고 깨지기는 더 쉽다.

인터페이스와 추상 골격 구현(skeletal implementation) 클래스를 함께 제공하는 식으로 인터페이스와 추상 클래스의 장점을 모두 취하는 방법도 있다. 인터페이스로는 타입을 정의하고, 필요하면 디폴트 메서드 몇 개도 함께 제공한다. 그리고 골격 구현 클래스는 나머지 메서드들까지 구현한다. 이렇게 해두면 단순히 골격 구현을 확장하는 것만으로 이 인터페이스를 구현하는 데 필요한 일이 대부분 완료된다. 바로 *템플릿 메서드 패턴* 이다.

다음 코드는 완벽히 동작하는 List 구현체를 반환하는 정적 팩터리 메서드로, AbstractList 골격 구현으로 활용했다.

```java
// 골격 구현을 사용해 완성한 구체 클래스
static List<Integer> intArrayAsList(int[] a) {
  Objects.requireNonNull(a);

  // 다이아몬드 연산자를 이렇게 사용하는 건 자바 9부터 가능하다.
  // 더 낮은 버전을 사욯안다면 <Integer>로 수정하자.
  return new AbstractList<>() {
    @Override public Integer get(int i) {
      return a[i];  // 오토박싱(아이템 6)
    }

    @Override public Integer set(int i, Integer val) {
      int oldVal = a[i];
      a[i] = val;     // 오토언박싱
      return oldVal;  // 오토박싱
    }

    @Override public int size() {
      return a.length;
    }
  };
}
```

이 예는 int 배열을 받아 Integer 인스턴스의 리스트 형태로 보여주는 어댑터이기도 하다. int 값과 Integer 인스턴스 사이의 변환(박싱과 언박싱) 때문에 성능은 그리 좋지 않다. 골격 구현 클래스의 아름다움은 추상 클래스처럼 구현을 도와주는 동시에, 추상 클래스로 타입을 정의할 때 따라오는 심각한 제약에서는 자유롭다는 점에 있다.

---

# Reference
- [Effective Java 3/E](http://www.kyobobook.co.kr/product/detailViewKor.laf?ejkGb=KOR&mallGb=KOR&barcode=9788966262281&orderClick=LAG&Kc=)
