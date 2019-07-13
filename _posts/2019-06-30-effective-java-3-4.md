---
layout: entry
title: Effective Java 3 - 클래스와 인터페이스
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java 3판의 4장(클래스와 인터페이스)을 정리한 글입니다.
keywords: Java, 자바
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

public 클래스에서는 멤버의 접근 수준을 package-private에서 protected로 바꾸는 순간 그 멤버에 접근할 수 있는 대상 범위가 엄청나게 넓어진다. public 클래스의 protected 멤버는 공개 API이므로 영원히 지원돼야 한다. 또한 내부 동작 방식을 API 문서에 적어 사용자에게 공개해야 할 수도 있다. 따라서 protected 멤버의 수는 적을수록 ㅗㅈㅎ다.

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













































---

# Reference
- [Effective Java 3/E](http://www.kyobobook.co.kr/product/detailViewKor.laf?ejkGb=KOR&mallGb=KOR&barcode=9788966262281&orderClick=LAG&Kc=)
