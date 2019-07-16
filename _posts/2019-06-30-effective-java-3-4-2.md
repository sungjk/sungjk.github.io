---
layout: entry
post-category: java
title: Effective Java 3 - 클래스와 인터페이스(2)
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java 3판의 4장(클래스와 인터페이스)을 정리한 글입니다.
keywords: Java, 자바, Effective Java, 이팩티브 자바
publish: true
---

# 21. 인터페이스는 구현하는 쪽을 생각해 설계하라
자바 8에서는 핵심 컬렉션 인터페이스들에 다수의 디폴트 메서드가 추가되었다. 주로 람다(7장 참조)를 활용하기 위해서다. 자바 라이브러리의 디폴트 메서드는 코드 품질이 높고 범용적이라 대부분 상황에서 잘 동작한다. 하지만 **생각할 수 있는 모든 상황에서 불변식을 해치지 않는 디폴트 메서드를 작성하기란 어려운 법이다.**

**디폴트 메서드는 (컴파일에 성공하더라도) 기존 구현체에 런타임 오류를 일으킬 수 있다.**

기존 인터페이스에 디폴트 메서드로 새 메서드를 추가하는 일은 꼭 필요한 경우가 아니면 피해야 한다. 추가하려면 디폴트 메서드가 기존 구현체들과 충돌하지는 않을지 심사숙고해야 함도 당연하다. 반면, 새로운 인터페이스를 만드는 경우라면 표준적인 메서드 구현을 제공하는 데 아주 유용한 수단이며, 그 인터페이스를 더 쉽게 구현해 활용할 수 있게끔 해준다(아이템 20).

한편, 디폴트 메서드는 인터페이스로부터 메서드를 제거하거나 기존 메서드의 시그니처를 수정하는 용도가 아님을 명심해야 한다.

디폴트 메서드라는 도구가 생겼더라도 **인터페이스를 설계할 때는 여전히 세삼한 주의를 기울여야 한다.**

새로운 인터페이스라면 릴리스 이전에 반드시 테스트를 거쳐야 한다. 수많은 개발자가 그 인터페이스를 나름의 방식으로 구현할 것이니, 여러분도 서로 다른 방식으로 최소한 세 가지는 구현해봐야 한다. 또한 각 인터페이스의 인스턴스를 다양한 작업에 활용하는 클라이언트도 여러 개 만들어봐야 한다. 새 인터페이스가 의도한 용도에 잘 부합하는지를 확인하는 길은 이처럼 험난하다. **인터페이스를 릴리스한 후라도 결함을 수정하는 게 가능한 경우도 있겠지만, 절대 그 가능성에 기대서는 안 된다.**

---

# 22. 인터페이스는 타입을 정의하는 용도로만 사용하라
인터페이스는 자신을 구현한 클래스의 인스턴스를 참조할 수 있는 타입 역할을 한다. 인터페이스는 오직 이 용도로만 사용해야 한다.

이 지침에 맞지 않는 예로 소위 상수 인터페이스라는 것이 있다. 상수 인터페이스란 메서드 없이, 상수를 뜻하는 static final 필드로만 가득 찬 인터페이스를 말한다.

```java
// 상수 인터페이스 안티패턴 - 사용하지 말 것!
public interface PhysicalConstants {
  // 아보가드로 수(1/mod)
  static final double AVOGADROS_NUMBER = 6.02214199e23;

  // 볼쯔만 상수(J/K)
  static final double BOLTZMAN_CONSTANT = 1.3806503e-23;

  // 전자 질량(kg)
  static final double ELECTRON_MASS = 9.10938188e-31;
}
```

**상수 인터페이스 패턴은 인터페이스를 잘못 사용한 예다.** 클래스 내부에서 사용하는 상수는 외부 인터페이스가 아니라 내부 구현에 해당한다. 따라서 상수 인터페이스를 구현하는 것은 이 내부 구현을 클래스의 API로 노출하는 행위다.

열거 타입으로 나타내기 적합한 상수라면 열거 타입으로 만들어 공개하면 된다(아이템 34).

```java
// 상수 유틸리티 클래스
public class PhysicalConstants {
  private PhysicalConstants() {} // 인스턴스화 방지

  // 아보가드로 수(1/mod)
  public static final double AVOGADROS_NUMBER = 6.02214199e23;

  // 볼쯔만 상수(J/K)
  public static final double BOLTZMAN_CONSTANT = 1.3806503e-23;

  // 전자 질량(kg)
  public static final double ELECTRON_MASS = 9.10938188e-31;
}
```

---

# 23. 태그 달린 클래스보다는 클래스 계층구조를 활용하라
두 가지 이상의 의미를 표현할 수 있으며, 그중 현재 표현하는 의미를 태그 값으로 알려주는 클래스를 본 적이 있을 것이다.

```java
// 태그 달린 클래스 - 클래스 계층구조보다 훨씬 나쁘다!
class Figure {
  enum Shape { RECTANGLE, CIRCLE };

  // 태그 필드 - 현재 모양을 나타낸다.
  final Shape shape;

  // 사각형(RECTANGLE)일 때만 쓰인다.
  double length;
  double width;

  // 원(CIRCLE)일 때만 쓰인다.
  double radius;

  // 원용 생성자
  Figure(double radius) {
    shape = Shape.CIRCLE;
    this.radius = radius;
  }

  // 사각형용 생성자
  Figure(double length, double width) {
    shape = Shape.RECTANGLE;
    this.length = length;
    this.width = width;
  }

  double area() {
    switch(shape) {
      case RECTANGLE:
        return length * width;
      case CIRCLE:
        return MATH.PI * (radius * radius);
      default:
        throw new AssertionError();
    }
  }
}
```

태그 달린 클래스에는 단점이 한가득이다. 우선 열거 타입 선언, 태그 필드 switch 문 등 쓸데없는 코드가 많다. 여러 구현이 한 클래스에 혼합돼 있어서 가독성도 나쁘다. 필드들을 final로 선언하려면 해당 의미에 쓰이지 않는 필드들까지 생성자에서 초기화해야 한다. 또 다른 의미를 추가하려면 코드를 수정해야 한다. 마지막으로, 인스턴스의 타입만으로는 현재 나타내는 의미를 알 길이 전혀 없다. 한마디로, **태그 달린 클래스는 장황하고, 오류를 내기 쉽고, 비효율적이다.**

태그 달린 클래스를 클래스 계층구조로 바꾸는 방법을 알아보자. 가장 먼저 계층구조의 루트(root)가 될 추상 클래스를 정의하고, 태크 값에 따라 동작이 달라지는 메서드들을 루트 클래스의 추상 메서드로 선언한다. 그런 다음 태그 값에 상관없이 동작이 일정한 메서드들을 루트 클래스에 일반 메서드로 추가한다. 모든 하위 클래스에서 공통으로 사용하는 데이터 필드들도 전부 루트 클래스로 올린다. 다음으로, 루트 클래스를 확장한 구체 클래스를 의미별로 하나씩 정의한다. 그런 다음 루트 클래스가 정의한 추상 메서드를 각자의 의미에 맞게 구현한다.

```java
abstract class Figure {
  abstract double area();
}

class Circle extends Figure {
  final double radius;

  Circle(double radius) {
    this.radius = radius;
  }

  @Override double area() {
    return Math.PI * (radius * radius);
  }
}

class Rectangle extends Figure {
  final double length;
  final double width;

  Rectangle(double length, double width) {
    this.length = length;
    this.width = width;
  }

  @Override double area() {
    return length * width;
  }
}
```

---

# 24. 멤버 클래스는 되도록 static으로 만들라
중첩 클래스(nested class)란 다른 클래스 안에 정의된 클래스를 말한다. 중첩 클래스는 자신을 감싼 바깥 클래스에서만 쓰여야 하며, 그 외의 쓰임새가 있다면 톱레벨 클래스로 만들어야 한다. 중첩 클래스의 종류는 정적 멤버 클래스, (비정적) 멤버 클래스, 익명 클래스, 지역 클래스, 이렇게 네 가지다. 이 중 첫번째를 제외한 나머지는 내부 클래스(inner class)에 해당한다.

가장 간단한 정적 멤버 클래스를 알아보자. 정적 멤버 클래스는 다른 클래스 안에 선언되고, 바깥 클래스의 private 멤버에도 접근할 수 있다는 점만 제외하고는 일반 클래스와 똑같다. 정적 멤버 클래스는 다른 정적 멤버와 똑같은 접근 규칙을 적용받는다. 예컨대 private으로 선언하면 바깥 클래스에서만 접근할 수 있는 식이다.

정적 멤버 클래스와 비정적 멤버 클래스의 구문상 차이는 단지 static이 붙어있고 없고 뿐이지만, 의미상 차이는 의외로 꽤 크다. 그래서 비정적 멤버 클래스의 인스턴스는 바깥 클래스의 인스턴스와 암묵적으로 연결된다. 그래서 비정적 멤버 클래스의 인스턴스 메서드에서 정규화된 this를 사용해 바깥 인스턴스의 메서드를 호출하거나 바깥 인스턴스의 참조를 가져올 수 있다. 정규화된 this란 **클래스명**.this 형태로 바깥 클래스의 이름을 명시하는 용법을 말한다. 따라서 개념상 중첩 클래스의 인스턴스가 바깥 인스턴스와 독립적으로 존재할 수 있다면 정적 멤버 클래스로 만들어야 한다. 비정적 멤버 클래스는 바깥 인스턴스 없이는 생성할 수 없기 때문이다.

비정적 멤버 클래스의 인스턴스와 바깥 인스턴스 사이의 관계는 멤버 클래스가 인스턴스화될 때 확립되며, 더 이상 변경할 수 없다. 이 관계는 바깥 클래스의 인스턴스 메서드에서 비정적 멤버 클래스의 생성자를 호출할 때 자동으로 만들어지는 게 보통이지만, 드물게는 직접 **바깥 인스턴스의 클래스**.new MemberClass(args)를 호출해 수동으로 만들기도 한다.

비정적 멤버 클래스는 어댑터를 정의할 때 자주 쓰인다. 즉, 어떤 클래스의 인스턴스를 감싸 마치 다른 클래스의 인스턴스처럼 보이게 하는 뷰로 사용하는 것이다.

```java
public class MySet<E> extends AbstractSet<E> {
  ...

  @Override public Iterator<E> iterator() {
    return new MyIterator();
  }

  private class MyIterator implements Iterator<E> {
    ...
  }
}
```

**멤버 클래스에서 바깥 인스턴스에 접근할 일이 없다면 무조건 static을 붙여서 정적 멤버 클래스로 만들자.** static을 생략하면 바깥 인스턴스로의 숨은 외부 참조를 갖게 된다.

익명 클래스에는 당연히 이름이 없다. 또한 익명 클래스는 바깥 클래스의 멤버도 아니다. 멤버와 달리, 쓰이는 시점에 선언과 동시에 인스턴스가 만들어진다. 그리고 오직 비정적인 문맥에서 사용될 때만 바깥 클래스의 인스턴스를 참조할 수 있다. 정적 문맥에서라도 상수 변수 이외의 정적 멤버는 가질 수 없다.

지역 클래스는 네 가지 중첩 클래스 중 가장 드물게 사용된다. 지역 클래스는 지역변수를 선언할 수 있는 곳이면 어디서든 선언할 수 있고, 유효 범위도 지역변수와 같다. 익명 클래스처럼 비정적 문맥에서 사용될 때만 바깥 인스턴스를 참조할 수 있으며, 정적 멤버는 가질 수 없으며, 가독성을 위해 짧게 작성해야 한다.

---

# 25. 톱레벨 클래스는 한 파일에 하나만 담으라
Utensil 클래스와 Dessert 클래스가 Utensil.java 라는 한 파일에 정의되어 있다고 해보자.

```java
// 두 클래스가 한 파일(Utensil.java)에 정의되었다. - 따라 하지 말 것!
class Utensil {
  static final String NAME = "pan";
}

class Dessert {
  static final String NAME = "cake";
}
```

우연히 똑같은 두 클래스를 담은 Dessert.java 라는 파일을 만들었다고 해보자.

```java
// 두 클래스가 한 파일(Dessert.java)에 정의되었다. - 따라 하지 말 것!
class Utensil {
  static final String NAME = "pan";
}

class Dessert {
  static final String NAME = "cake";
}
```

컴파일러가 어느 소스 파일을 먼저 건네느야에 따라 동작이 달라진다.

해결책은 간단하다. 톱레벨 클래스들을 서로 다른 소스 파일로 분리하면 그만이다. 굳이 여러 톱레벨 클래스를 한 파일에 담고 싶다면 정적 멤버 클래스(아이템 24)를 사용하는 방법을 고민해볼 수 있다. 다른 클래스에 딸린 부차적인 클래스라면 정적 멤버 클래스로 만드는 쪽이 더 나을 것이다. 읽기 좋고, private으로 선언하면(아이템 15) 접근 범위도 최소로 관리할 수 있기 때문이다.

```java
// 톱레벨 클래스들을 정적 멤버 클래스로 바꿔본 모습
public class Test {
  public static void main(String[] args) {
    System.out.println(Utensil.NAME + Dessert.NAME);
  }

  private static class Utensil {
    static final String NAME = "pan";
  }

  private static class Dessert {
    static final String NAME = "cake";
  }
}
```































---

# Reference
- [Effective Java 3/E](http://www.kyobobook.co.kr/product/detailViewKor.laf?ejkGb=KOR&mallGb=KOR&barcode=9788966262281&orderClick=LAG&Kc=)
