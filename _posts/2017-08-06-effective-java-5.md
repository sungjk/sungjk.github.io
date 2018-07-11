---
layout: entry
post-category: java
title: Effective Java(5)
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java의 6장(열거형(enum)과 어노테이션)을 정리한 글입니다.
next_url: /2017/08/06/effective-java-6.html
publish: true
---

# 규칙 30. int 상수 대신 enum을 사용하라
열거 자료형(enumerated type)은 고정 개수의 상수들로 값이 구성되는 자료형이다.

```java
// int를 사용한 enum 패턴 - 지극히 불만족스럽다
public static final int APPLE_FUJI = 0;
public static final int APPLE_PIPPIN = 1;
public static final int APPLE_GRANNY_SMITH = 2;

public static final int ORANGE_NAVEL = 0;
public static final int ORANGE_TEMPLE = 1;
public static final int ORANGE_BLOOD = 2;
```

이 기법은 *int enum 패턴* 으로 알려져 있는데, 단점이 많다. 형 안전성 관점에서도 그렇고, 편의상 관점에서 봐도 그렇다. 오렌지를 기대하는 메서드에 사과를 인자로 넘겨도 컴파일러는 불평하지 않는다. == 연산자를 사용해 사과를 오렌지와 비교해도 마찬가지다.

int enum 패턴을 사용하는 프로그램은 깨지기 쉽다. int enum 상수는 컴파일 시점 상수(compile-time constant)이기 때문에 상수를 사용하는 클라이언트 코드와 함께 컴파일된다. 상수의 int 값이 변경되면 클라이언트도 다시 컴파일해야 한다.

int enum 상수는 인쇄 가능한 문자열로 변환하기도 쉽지 않다. 이런 상수를 출력하거나 디버거로 확인해보면 보이는 것은 숫자뿐이라서 크게 도움이 되지 않는다.

이 패턴의 변종 가운데는 int 대신 String 상수를 사용하는 것인데 더 나쁜 패턴이다. 상수 이름을 화면에 출력할 수 있다는 장점은 있지만 상수 비교를 할 때 문자열 비교를 해야 하므로 성능이 떨어질 수 있다. 더 큰 문제는 아무 생각 없는 사용자가 필드 이름 대신 하드코딩된 문자열 상수를 클라이언트 코드에 박아버릴 수 있다는 점이다.

1.5부터는 int와 String enum 패턴의 문제점을 해소하는 대안이 도입되었는데 장점이 많고, *enum 자료형* 이라고 불린다.

```java
public enum Apple { FUJI, PIPPIN, GRANNY_SMITH }
public enum Orange { NAVEL, TEMPLE, BLOOD }
```

C, C++, C# 에서 제공하는 것과 다르게, 자바의 enum 자료형은 완전한 기능을 갖춘 클래스로 다른 언어의 enum보다 강력하다. 다른 언어들의 enum은 결국 int 값이다.

자바의 enum 자료형은 열거 상수(enumeration constant)별로 하나의 객체를 public static final 필드 형태로 제공한다. 이는 final로 선언된 것이나 마찬가지인데, 클라이언트가 접근할 수 있는 생성자가 없기 때문이다. 클라이언트가 enum 자료형을 새로운 객체를 생성하거나 계승을 통해 확장할 수 없기 때문에, 이미 선언된 enum 상수 이외의 객체는 사용할 수 없다. 따라서, enum 자료형의 개체 수는 엄격히 통제된다.

enum 자료형은 컴파일 시점 형 안전성(compile-time type safety)을 제공한다. Apple 형의 인자를 받는다고 선언한 메서드는 반드시 Apple 값 세 개 가운데 하나만 인자로 받는다. 엉뚱한 자료형의 값을 인자로 전달하려 하면, 자료형 불일치 때문에 컴파일 할 때 오류가 발생한다. == 연산자를 사용해 서로 다른 자료형의 enum 상수를 비교하려 해도 마찬가지다.

enum 자료형은 이름공간(namespace)이 분리되기 때문에 같은 이름의 상수가 공존할 수 있도록 한다. 상수를 추가하거나 순서를 변경해도 클라이언트는 다시 컴파일할 필요가 없다. 상수를 제공하는 필드가 enum 자료형과 클라이언트 사이에서 격리 계층(layer of insulation) 구실을 하기 때문이다. int enum 패턴과 달리, 상수 값이 클라이언트 코드와 함께 컴파일되는 일은 생기지 않는다. 또한, enum 자료형은 toString 메서드를 호출하면 인쇄 가능 문자열로 쉽게 변환할 수 있다.

enum 자료형은 임의의 메서드나 필드도 추가할 수 있고, 임의의 인터페이스를 구현할 수도 있다. Object에 정의된 모든 고품질 메서드들이 포함되어 있으며 Comparable 인터페이스와 Serializable 인터페이스가 구현되어 있다. enum 상수의 직렬화 형식은 enum 자료형상의 변화 대부분을 견딜 수 있도록 설계되어 있다.

enum 자료형에 메서드나 필드를 추가하는 이유 중 하나는 상수에 데이터를 연계시키면 좋기 때문이다. Apple과 Orange 자료형의 경우에 과일의 색이나 사진을 반환하는 메서드를 추가하면 좋을 것이다. enum 자료형은 enum 상수 묶음에서 출발해서 점차로 완전한 기능을 갖춘 추상화 단위(abstraction)로 진화해 나갈 수 있다.

```java
// 데이터와 연산을 구비한 enum 자료형
public enum Planet {
  MERCURY (3.302e+23, 2.439e6),
  VENUS   (4.869e+24, 6.052e6),
  EARTH   (5.975e+24, 6.378e6),
  MARS    (6.419e+23, 3.393e6),
  JUPITER (1.899e+27, 7.149e7),
  SATURN  (5.685e+26, 6.027e7),
  URANUS  (8.683e+25, 2.556e7),
  NEPTUNE (1.024e+26, 2.477e7);

  private final double mass;
  private final double radius;
  private final double surfaceGravity;
  private static final double G = 6.67300E-11;

  Planet(double mass, double radius) {
    this.mass = mass;
    this.radius = radius;
    surfaceGravity = G * mass / (radius * radius);
  }

  public double mass() { return mass; }
  public double radius() { return radius; }
  public double surfaceGravity() { return surfaceGravity; }

  public double surfaceWeight(double mass) {
    return mass * surfaceGravity;
  }
}
```

**enum 상수에 데이터를 넣으려면 객체 필드(instance field)를 선언하고 생성자를 통해 받은 데이터를 그 필드에 저장하면 된다.** enum은 원래 변경 불가능하므로(immutable) 모든 필드는 final로 선언되어야 한다(규칙 15). 필드는 public으로 선언할 수도 있지만, private로 선언하고 public 접근자(accessor)를 두는 편이 더 낫다(규칙 14).

Planet enum 자료형은 아주 단순하지만 놀랄 만큼 강력하다. 아래에 어떤 물체의 지표면상 무게를 입력 받아서(어떤 단위라도 가능) 모든 8개 행성 표면에서 측정한 무게(전부 같은 단위)로 변환한 표를 출력하는 프로그램 예제를 보자.

```java
public class WeightTable {
  public static void main(String[] args) {
    double earthWeight = Double.parseDouble(args[0]);
    double mass = earthWeight / Planet.EARTH.surfaceGravity();
    for (Planet p : Planet.values())
      System.out.printf("Weight on %s is %f%n", p, p.surfaceWeight(mass));
  }
}
```

모든 enum 자료형에는 모든 enum 상수를 선언된 순서대로 저장하는 배열을 반환하는 static values 메서드가 기본으로 정의되어 있다. 또한 출력하기 쉽게 toString 메서드도 이미 갖추어져 있고, 재정의(override)할 수도 있다.

일반 클래스와 마찬가지로, enum에 정의한 메서드를 클라이언트에게까지 공개할 특별한 이유가 없다면 private나 package-private로 선언하라(규칙13).

일반적으로 유용하게 쓰일 enum이라면, 최상위(top-level) public 클래스로 선언해야 한다. 특정한 최상위 클래스에서만 쓰이는 enum이라면 해당 클래스의 멤버 클래스로 선언해야 한다(규칙 22). 예를 들어 java.math.RoundingMode enum은 십진수의 소수점 이하 부분을 어떻게 올림처리 할 것인지를 나타낸다. 이 enum의 상수들은 BigDecimal 클래스가 이용하는데, 이곳 뿐만 아니라 다른 개발자들이 올림 연산 수행 방식을 구별할 필요가 있을 때 해당 enum을 재사용하도록 장려했는데, 그러면 API 사이의 일관성이 향상된다.

때로는 상수들이 제각기 다른 방식으로 동작하도록 만들어야 할 때도 있다. 예를 들어, 기본적인 네 가지 산술 연산을 표현하는 enum 자료형을 만든다고 하자. 각 상수는 자기가 표현하는 산술 연산을 실제로 실행하는 메서드를 제공해야 한다. 한 가지 방법은, enum 상수에 따라 분기하는 switch 문을 사용하는 것이다.

```java
// 자기 값에 따라 분기하는 enum 자료형
public enum Operation {
  PLUS, MINUS, TIMES, DIVIDE;

  // 'this' 상수가 나타내는 산술 연산 실행
  double apply(double x, double y) {
    switch(this) {
      case PLUS: return x + y;
      case MINUS: return x - y;
      case TIMES: return x * y;
      case DIVIDE: return x / y;
    }
    throw new AssertionError("Unknown op: " + this);
  }
}
```

동작은 하지만 깨지기 쉬운 코드다. 새로운 enum 상수를 추가할 때 switch 문에 case를 추가하지 않아도 이 코드는 컴파일 된다. 하지만 프로그램 실행 중에 새 연산을 이용하게 되면 오류가 난다.

이를 개선해보자면 enum 자료형에 abstract apply 메서드를 선언하고, 각 *상수별 클래스 몸체*(constant-specific class body) 안에서 실제 메서드로 재정의하는 것이다. 이런 메서드는 *상수별 메서드 구현*(constant-specific method implementation)이라 부른다.

```java
public enum Operation {
  PLUS   { double apply(double x, double y) { return x + y; }},
  MINUS  { double apply(double x, double y) { return x - y; }},
  TIMES  { double apply(double x, double y) { return x * y; }},
  DIVIDE { double apply(double x, double y) { return x / y; }};

  abstract double apply(double x, double y);
}
```

이 enum에 새로운 상수를 추가할 때는 apply 메서드 구현을 잊을 가능성이 거의 없다. 상수 선언 다음에 메서드가 바로 나오기 때문이다. 설사 잊더라도 컴파일러가 오류를 내 줄 것이다. enum 자료형의 abstract 메서드는 모든 상수가 반드시 구현해야 하기 때문이다.

enum 자료형에는 자동 생성된 valueOf(String) 메서드가 있는데, 이 메서드는 상수의 이름을 상수 그 자체로 변환하는 역할을 한다. enum 자료형의 toString 메서드를 재정의할 경우에는 fromString 메서드를 작성해서 toString이 뱉어내는 문자열을 다시 enum 상수로 변환할 수단을 제공해야 할지 생각해 봐야 한다. 각각의 상수가 고유한 문자열로 표현된다면 아래의 코드를 사용하면 될 것이다.

```java
// enum 자료형에 대한 fromString 메서드 구현
private static final Map<String, Operation> stringToEnum = new HashMap<String, Operation>();
static { // 상수 이름을 실제 상수로 대응시키는 맵 초기화
  for (Operation op : values())
    stringToEnum.put(op.toString(), op);
}

// 문자열이 주어지면 그에 대한 Operation 상수 반환. 잘못된 문자열이면 null 반환
public static Operation fromString(String symbol) {
  return stringToEnum.get(symbol);
}
```

Operation 상수를 stringToEnum 맵에 넣는 것은 상수가 만들어진 다음에 실행되는 static 블록 안에서 한다는 것에 주의하자. 각각의 상수가 생성자 안에서 맵에 자기 자신을 넣도록 하면 컴파일 할 때 오류가 발생한다. enum 생성자 안에서는 enum의 static 필드를 접근할 수 없다(컴파일 시점에 상수인 static 필드는 제외). 생성자가 실행될 때 static 필드는 초기화된 상태가 아니기 때문에 필요한 제약이다.

상수별 메서드 구현의 단점은 enum 상수끼리 공유하는 코드를 만들기가 어렵다는 것이다. 예를 들어, 급여 명세서에 찍히는 요일을 표현하는 enum 자료형이 있다고 하자. 요일을 나타내는 enum 자료형 상수에는 직원의 시급과 해당 요일에 일한 시간을 인자로 주면 해당 요일의 급여를 계산하는 메서드가 있다. 그런데 주중에는 초과근무 시간에 대해서만 초과근무 수당을 주어야 하고, 주말에는 몇 시간을 일했건 전부 초과근무 수당으로 처리해야 한다. switch 문을 만들 때 case 레이블을 경우에 따라 잘 붙이기만 하면 쉽게 원하는 계산을 할 수 있을 것이다.

```java
// enum 상수에 따라 분기하는 switch 문을 이용해서 코드 공유 - 좋은 방법인가?
enum PayrollDay {
  MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;
  private static final int HOURS_PER_SHIFT = 8;

  double pay(double hoursWorked, double payRate) {
    double basePay = hoursWorked * payRate;

    double overtimePay;	// 초과근무수당 계산
    switch(this) {
      case SATURDAY: case SUNDAY:
        overtimePay = hoursWorked * payRate / 2;
        break;
      default: // Weekdays
        overtimePay = hoursWorked <= HOURS_PER_SHIFT ?
          0 : (hoursWorked - HOURS_PER_SHIFT) * payRate / 2;
    }

    return basePay + overtimePay;
  }
}
```

간결한 코드지만, 유지보수(maintenance) 관점에서는 위험한 코드다. enum에 새로운 상수를 추가한다고 하자. 아마도 휴가 등을 나타내는 특별한 값일 것이다. 그런데 switch 문에 해당 상수에 대한 case를 추가하는 것을 잊었다면? 컴파일은 되겠지만, 휴가 때 일한 시간에 대해서도 같은 급여를 직브하는 프로그램이 되어버릴 것이다.

상수별 메서드 구현을 통해 급여 계산을 하는 코드를 만든다면, 아마 초과근무 수당을 계산하는 부분을 상수마다 중복하거나, 주중 급여와 주말 급여를 계산하는 식을 각각 별도의 도움 메서드로 마든 다음 각 상수 안에서 호출하도록 해야 할 것이다. 이는 가독성도 떨어지고 오류 발생 확률도 높아진다.

이를 해결할 한 가지 방법은 PayrollDay에 있는 abstract 메서드 overtimePay를 주중 초과근무 수당을 계산하는 메서드로 바꾸는 것이다. 그러면 주말을 나타내는 상수에만 해당 메서드를 재정의하면 된다. 하지만 이 방법에도 switch 문과 같은 문제가 있다. 새 상수를 추가할 때 overtimePay 메서드를 재정의하지 않으면 주중 근무와 같은 초과근무 수당이 적용될 것이다.

다른 좋은 방법은 새로운 enum 상수를 추가할 때 초과근무 수당 계산 정책을 반드시 선택하도록 하는 것이다. 초과근무 수당을 계산하는 부분을 private로 선언된 중첩 enum 자료형에 넣고, PayrollDay enum의 생성자가 이 *전략 enum*(strategy enum) 상수를 인자로 받게 하는 것이다. PayrollDay enum 상수가 초과근무 수당 계산을 이 정책 enum 상수에 위임하도록 하면 switch 문이나 상수별 메서드 구현은 없앨 수 있다. 이 패턴을 적용한 코드가 switch 문을 써서 만든 코드보다는 복잡하지만 안전할 뿐더러 유연성도 높다.

```java
enum PayrollDay {
  MONDAY(PayType.WEEKDAY), TUESDAY(PayType.WEEKDAY), WEDNESDAY(PayType.WEEKDAY),
  THURSDAY(PayType.WEEKDAY), FRIDAY(PayType.WEEKDAY), SATURDAY(PayType.WEEKEND),
  SUNDAY(PayType.WEEKEND);

  private final PayType payType;
  PayrollDay(PayType payType) { this.payType = payType; }

  double pay(double hoursWorked, double payRate) {
    return payType.pay(hoursWorked, payRate);
  }

	// 정책 enum 자료형
  private enum PayType {
		WEEKDAY {
      double overtimePay(double hours, double payRate) {
        return hours <= HOURS_PER_SHIFT ? 0 :
          (hours - HOURS_PER_SHIFT) * payRate / 2;
      }
    },
    WEEKEND {
      double overtimePay(double hours, double payRate) {
        return hours * payRate / 2;
      }
    };

    private static final int HOURS_PER_SHIFT = *;

    abstract double overtimePay(double hrs, double payRate);

		double pay(double hoursWorked, double payRate) {
      double basePay = hoursWorked * payRate;
      return basePay + overtimePay(hoursWorked, payRate);
    }
  }
}
```

enum에서 switch 문을 사용해 상수별로 다르게 동작하는 코드를 만드는 것이 바람직하지 않다면, switch 문을 대체 어디에 적합한가? **외부(external) enum 자료형 상수별로 달리 동작하는 코드를 만들어야 할 때는 enum 상수에 switch 문을 적용하면 좋다.** 예를 들어, Operation enum이 다른 누군가가 작성한 자료형이고, 그 각 상수가 나타내는 연산의 반대 연산을 반환하는 메서드를 만들때, 아래와 같은 정적 메서드를 만들면 될 것이다.

```java
// 기존 enum 자료형에 없는 메서드를 switch 문을 사용해 구현한 사례
public static Operation inverse(Operation op) {
  switch(op) {
    case PLUS:  return Operation.MINUS;
    case MINUS:  return Operation.PLUS;
    case TIMES:  return Operation.TIMES;
    case DIVIDE:  return Operation.DIVIDE;
    default: throw new AssertionError("Unknown op: " + op);
  }
}
```

일반적으로 enum은 int 상수와 성능 면에서 비등하다. 자료형을 메모리에 올리고 초기화하는 공간적/시간적 비용 떄문에 약간 손해를 보긴 하지만, 실제로는 별 차이가 느껴지지 않을 것이다.

그렇다면 언제 enum을 써야 하나? 고정된 상수 집합이 필요할 때다. 물론 거기에는 태양계 행성이나, 요일이나 장기판 말과 같은 \"원래 열거형인 자료형(natural enumerated type)들\"이 포함된다. 컴파일 시점에 모든 가능한 값의 목록을 알 수 있는 집합에도 적용할 수 있다. 하지만 enum 자료형에 포함된 상수들이 항상 불변인 것은 아니다. enum은 수정되더라도 이진 호환성(binary compatibility)이 보장되도록 설계되어 있다.

### 요약
- enum을 사용한 코드는 가독성이 높고, 안전하며, 더 강력하다.
- 상당수의 enum은 생성자나 멤버가 필요 없으나, 데이터 또는 그 데이터에 관계된 메서드를 추가해서 기능을 향상시킬 수 있다.
- 상수별로 다르게 동작하도록 만들 수도 있다. 이때는 switch 문 대신 상수별 메서드를 구현하기 바란다.
- 여러 enum 상수가 공통 기능을 이용해야 하는 일이 생기면 정책 enum 패턴 사용을 고려하기 바란다.

---

# 규칙 31. ordinal 대신 객체 필드를 사용하라
상당수의 enum 상수는 자연스럽게 int 값 하나에 대응된다. 모든 enum에는 ordinal이라는 메서드가 있는데, enum 자료형 안에서 enum 상수의 위치를 나타내는 정수값을 반환한다. 그러니 ordinal 메서드를 통해 enum 상수에 대응되는 정수값을 구하면 편리하지 않을까 생각할 수도 있다.

```java
// ordinal을 남용한 사례
public enum Ensemble {
  SOLO, DUET, TRIO, QUARTET, QUINTET,
  SEXTET, SEPTET, OCTET, NONET, DECTET;

  public int numberOfMusicians() { return ordinal() + 1; }
}
```

동작은 하지만 유지보수 관점에서 보면 끔직한 코드다. 상수 순서를 변경하는 순간 numberOfMusicians 메서드는 깨지고 만다. 게다가 이미 사용한 정수 값에 대응되는 새로운 enum 상수를 정의하는 것은 아예 불가능하다.

게다가, 새로운 상수가 나타내는 int 값은 순서상 바로 앞에 오는 상수의 int 값보다 정확히 1만큼 커야 한다. 그렇지 않으면 새 상수를 추가할 수 없다. 예를 들어, 삼사중주단(triple quartet)을 나타내는 상수를 추가하고 싶다고 해보자. 삼사중주단의 단원 수는 12다. 문제는 단원 수가 11명인 악단을 표현하는 표준적 이름이 없다는 것이다. 따라서 사용하지도 않는 상수를 만들어 11이라는 값을 갖도록 만들어야 한다.

다행히도 이 문제는 간단히 해결할 수 있다. **enum 상수에 연계되는 값을 ordinal을 사용해 표현하지 말라는 것이다. 그런 값이 필요하다면 그 대신 객체 필드(instance field)에 저장해야 한다.**

```java
public enum Ensemble {
  SOLO(1), DUET(2), TRIO(3), QUARTET(4), QUINTET(5),
  SEXTET(6), SEPTET(7), OCTET(8), DOUBLE_QUARTET(8),
  NONET(9), DECTET(10), TRIPLE_QUARTET(12);

  private final int numberOfMusicians;
  Ensemble(int size) { this.numberOfMusicians = size; }
  public int numberOfMusicians() { return numberOfMusicians; }
}
```

---

# 규칙 32. 비트 필드(bit field) 대신 EnumSet을 사용하라
열거 자료형 원소들이 주로 집합에 사용될 경우, 전통적으로는 int enum 패턴을 이용했다(규칙 30). 각 상수에 2의 거듭제곱 값을 대입하는 것이다.

```java
// 비트 필드 열거형 상수
public class Text {
  public static final int STYLE_BOLD = 1 << 0; // 1
  public static final int STYLE_ITALIC = 1 << 1; // 2
  public static final int STYLE_UNDERLINE = 1 << 2; // 4
  public static final int STYLE_STRIKETHROUGH = 1 << 3; // 8

  // 이 메서드의 인자는 STYLE_ 상수를 비트별(bitwise) OR 한 값이거나 0.
  public void applyStyles(int styles) { ... }
}
```

이렇게 하면 상수들을 집합(비트 필드)에 넣을 때 비트별 OR 연산을 사용할 수 있다.

```java
text.applyStyles(STYLE_BOLD | STYLE_ITALIC);
```

집합을 비트 필드로 나타내 비트 단위 산술 연산(bitwise arithmetic)을 통해 합집합이나 교집합 등의 집합 연산도 효율적으로 실행할 수 있다. 하지만 비트 필드는 int enum 패턴과 똑같은 단점들을 갖고 있다. 비트 필드를 출력한 결과는 int enum 상수를 출력한 결과보다도 이해하기 어렵다.

어떤 개발자는 int 상수 대신 enum을 사용하면서도, 상수 집합을 여기저기 전달할 때는 비트 필드를 쓴다. 그러나 java.util 패키지에 EnumSet이라는 클래스가 있는데, 이 클래스를 사용하면 특정한 enum 자료형의 값으로 구성된 집합을 효율적으로 표현할 수 있다. 내부적으로는 비트 벡터(bit vector)를 사용한다. enum 값 개수가 64 이하인 경우 EnumSet은 long 값 하나만 사용한다. 따라서 비트 필드에 필적하는 성능이 나온다.

비트 필드 대신 enum을 사용하도록 고친 예제를 아래에 보였다. 더 짧고 간결하고 안전하다.

```java
// EnumSet
public class Text {
  public enum Style { BOLD, ITALIC, UNDERLINE, STRIKETHROUGH }

  // 어떤 Set 객체도 인자로 전달할 수 있으나, EnumSet이 최선
  public void applyStyles(Set<Style> styles) { ... }
}
```

applyStyles 메서드에 EnumSet 객체를 전달하는 클라이언트 코드는 아래와 같다. EnumSet에는 정적 팩터리 메서드가 다양하게 준비되어 있어서 편하게 객체를 만들 수 있는데, 그 가운데 하나를 사용했다.

```java
text.applyStyles(EnumSet.of(Style.BOLD, Style.ITALIC));
```

applyStyles 메서드가 EnumSet\<Style\>이 아니라 Set\<Style\> 형의 인자를 받도록 선언되어 있다는 것에 유의하자. 이 메서드를 호출하는 클라이언트는 항상 EnumSet을 인자로 이용할 것 같긴 하지만, 인터페이스를 자료형으로 쓰는 것이 낫다. 그래야 좀 특별한 클라이언트가 EnumSet 이외의 Set을 인자로 전달하려 하더라도 처리할 수 있고, 인터페이스를 자료형으로 쓰는 것에는 딱히 문제가 없기 때문이다.

### 요약
**열거 자료형을 집합에 사용해야 한다고 해서 비트 필드로 표현하면 곤란하다.** EnumSet 클래스를 사용하자.

---

# 규칙 33. ordinal을 배열 첨자로 사용하는 대신 EnumMap을 이용하라
때로, ordinal 메서드가(규칙 31) 반환하는 값을 배열 첨자로 이용하는 코드를 만날 때가 있다. 예를 들어, 아래와 같이 요리용 허브를 표현하는 간단한 클래스다.

```java
class Herb {
  enum Type { ANNUAL, PERENNIAL, BIENNIAL }

  final String name;
  final Type type;

  Herb(String name, Type type) {
    this.name = name;
    this.type = type;
  }

  @Override
  public String toString() {
    return name;
  }
}
```

이제, 화단에 심은 허브들을 품종별로 나열해야 한다고 해보자. 그러려면 품종별 집합을 세 개 만든 다음에, 허브 각각을 그 품종에 맞는 집합에 넣어야 한다. 어떤 프로그래머는 이 집합을 배열에 넣어둔다. 이 배열의 첨자로는 품종을 나타내는 enum 자료형 상수의 ordinal 값이 사용된다.

```java
// ordinal() 값을 배열 첨자로 사용
Herb[] garden = ...;

Set<Herb>[] herbsByType = // Index by Herb.Type.ordinal()
  (Set<Herb>[]) new Set[Herb.Type.values().length];
for (int i = 0; i < herbsByType.length; i++)
  herbsByType[i] = new HashSet<Herb>();

for (Herb h : garden)
  herbsByType[h.type.ordinal()].add(h);

// 결과 출력
for (int i = 0; i < herbsByType.length; i++) {
  System.out.printf("%s: %s%n", Herb.Type.values()[i], herbsByType[i]);
}
```

배열은 제네릭과 호환되지 않으므로(규칙 25) 배열을 쓰려면 무점검 형변환이 필요하며 깔끔하게 컴파일되지 않는다. 게다가 배열은 첨자가 무엇을 나타내는지 모르므로, 출력 결과에 붙일 레이블은 수동으로 만들어 줘야 한다. 가장 심각한 문제는 enum의 ordinal 값으로 배열 원소를 참조할 때, 정확한 int 값이 사용되도록 해야 한다는 것이다. int는 enum과 같은 수준의 형 안전성을 보장하지 않는다.

하지만 더 좋은 방법이 있다. 위의 배열은 enum 상수를 어떤 값에 대응시킬 목적으로 사용되고 있는데, 그런 용도로 설계된 성능이 아주 우수한 EnumMap을 쓰면 된다.

```java
// EnumMap을 사용해 enum 상수별 데이터를 저장하는 프로그램
Map<Herb.Type, Set<Herb>> herbsByType =
  new EnumMap<Herb.Type, Set<Herb>>(Herb.Type.class);
for (Herb.Type t : Herb.Type.values())
  herbsByType.put(t, new HashSet<Herb>());
for (Herb h : garden)
  herbsByType.get(h.type).add(h);
System.out.println(herbsByType);
```

이 프로그램은 더 짧고 깔금하고 안전하며, ordinal을 이용해 구현한 것과 성능 면에서 비등하다. 무점검 형변환도 없고, 레이블을 손수 만들 필요도 없다. Map에 보관된 키가 enum이니, 출력 가능한 문자열로 알아서 변환되기 때문. EnumMap 생성자는 키의 자료형을 나타내는 Class 객체를 인자로 받는다. 이런 Class 객체를 *한정적 자료형 토큰*(bounded type token)이라 부르는데, 시행시점 제네릭 자료형 정보(runtime generic type information)를 제공한다.

ordinal 값을 첨자로 사용하는 배열을 사용해서 두 개 enum 상수 사이의 관계를 표현하는 코드를 보게 될 때가 있다. 아래 프로그램은 상전이(phase transition) 관계를 표현하려고 그런 배열을 이용한다.(액체 *LIQUID* 에서 고체 *SOLID* 로 변하는 것은 언다 *FREEZE* 고 하고, 액체에서 기체 *GAS* 로 변하는 것은 끓는다 *BOIL* 고 한다.)

```java
// ordinal() 값을 배열의 배열 첨자로 사용
public enum Phase {
  SOLID, LIQUID, GAS;

  public enum Transition {
    MELT, FREEZE, BOIL, CONDENSE, SUBLIME, DEPOSIT;

    // 아래 배열의 행은 상전이 이전 상태를 나타내는 enum 상수의 ordinal 값을
    // 첨자로 사용하고, 열은 상전이 이후 상태를 나타내는 enum 상수의
    // ordinal 값을 첨자로 사용한다.
    private static final Transition[][] TRANSITIONS = {
      { null, MELT, SUBLIME },
      { FREEZE, null, BOIL },
      { DEPOSIT, CONDENSE, null }
    };

    // 특정 상전이 과정을 표현하는 enum 상수를 반환
    public static Transition from(Phase src, Phase dst) {
      return TRANSITIONS[src.ordinal()][dst.ordinal()];
    }
  }
}
```

앞서 살펴보았던 허브 정원 예제와 마찬가지로, 컴파일러는 ordinal 값과 배열 첨자 사이의 관계에 대해서는 모른다. 그러니 상전이 테이블(TRANSITIONS)을 올바르게 만들지 않았거나 Phase 또는 Phase.Transition을 수정한 다음에 상전이 테이블을 제대로 고쳐놓지 않았다면 실행 도중에 오류를 일으킬 것이다.

EnumMap을 쓰면 훨씬 좋은 프로그램을 만들 수 있다. 안쪽 맵은 상전이 이전 상태를 나타내는 enum 상수를 상전이 명칭을 나타내는 enum 상수에 대응시키고, 바깥쪽 맵은 상전이 이전 상태를 나타내는 enum 상수를 안쪽 맵에 대응시키도록 하는 것이다. 상전이 명칭에 관계된 두 개 상태 정보는 상전이 명칭을 나타내는 enum 상수에 데이터로 넣어두면 되며, 이 데이터를 사용해 중첩된 EnumMap을 초기화하면 된다.

```java
// EnumMap을 중첩해서 enum 쌍에 대응되는 데이터를 저장한다.
public enum Phase {
  SOLID, LIQUID, GAS;

  public enum Transition {
    MELT(SOLID, LIQUID), FREEZE(LIQUID, SOLID),
    BOIL(LIQUID, GAS), CONDENSE(GAS, LIQUID),
    SUBLIME(SOLID, GAS), DEPOSIT(GAS, SOLID);

    private final Phase src;
    private final Phase dst;

    Transition(Phase src, Phase dst) {
      this.src = src;
      this.dst = dst;
    }

    // 상전이 맵 초기화
    private static final Map<Phase, Map<Phase, Transition>> m =
      new EnumMap<Phase, Map<Phase, Transition>>(Phase.class);

    static {
      for (Phase p : Phase.values())
        m.put(p, new EnumMap<Phase, Transition>(Phase.class));
      for (Transition trans : Transition.values())
        m.get(trans.src).put(trans.dst, trans);
    }

    public static Transition from(Phase src, Phase dst) {
      return m.get(src).get(dst);
    }
  }
}
```

상전이 맵을 초기화하는 코드는 다소 복잡해 보이지만 그렇게 끔찍하지는 않다. 이 맵의 자료형은 Map\<Pahse, Map\<Phase, Transition\>\>인데, \"상전이 이전 상태를, 상전이 이후 상태와 상전이 명칭 사이의 관계를 나타내는 맵에 대응시키는 맵\"이라는 뜻이다. static 블록 안의 첫 번째 순환문은 세 개의 빈 안쪽 맵을 값으로 사용하는 바깥 맵을 초기화하는 코드다. 두 번째 순환문은 각각의 상전이 명칭 상수에 보관된 상전이 이전 상태와 이후 상태 정보를 사용해서 안쪽 맵을 초기화하는 코드다.

EnumMap으로 만든 맵의 맵은 내무적으로는 배열의 배열일 터이니, 메모리 요구량이나 수행성능 측면에서 손해를 보는 일도 없을 터이고, 대신 프로그램은 더 명료해지고 안전해지며 유지보수하기 쉬워질 것이다.

### 요약
**ordinal 값을 배열 첨자로 사용하는 것은 적절치 않다는 것이다. 대신 EnumMap을 써라.**

---

# 규칙 34. 확장 가능한 enum을 만들어야 한다면 인터페이스를 이용하라
형 안전 enum 패턴을 쓸 경우에는 다른 열거 자료형(enumerated type)을 계승해서 새로운 열거 자료형을 만드는 것이 가능하지만 enum 자료형으로는 그럴 수 없다는 이야기다. 그러나 이것을 단점이라 볼 수 없는데, enum 자료형을 계승한다는 것은 대체로 바람직하지 않기 때문. 확장된 자료형의 상수들이 기본 자료형의 상수가 될 수 있다는 것, 그러나 그 반대는 될 수 없다는 것은 혼란스럽다. 게다가 기본 자료형과 그 모든 하위 자료형의 enum 상수들을 순차적으로 살펴볼 좋은 방법도 없다. 마지막으로, 계승을 허용하게 되면 설계와 구현에 관계된 많은 부분이 까다로워진다.

하지만 열거 자료형의 확장이 가능하면 좋은 경우가 적어도 하나는 있다. 연산 코드(operation code)를 만들어야 할 때다.

다행스럽게도, enum 자료형으로도 이런 효과를 낼 수 있는 좋은 방법이 있다. 기본 아이디어는 enum 자료형이 임의의 인터페이스를 구현할 수 있다는 사실을 이용하는 것이다. 연산 코드 자료형에 대한 인터페이스를 먼저 정의하고, 해당 인터페이스를 구현하는 enum 자료형을 만드는 것이다. 이 enum 자료형은 해당 인터페이스의 표준 구현(standard implementation) 역할을 하게 된다.

```java
// 인터페이스를 이용해 확장 가능하게 만든 enum 자료형
public interface Operation {
  double apply(double x, double y);
}

public enum BasicOperation implements Operation {
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

  BasicOperation(String symbol) {
    this.symbol = symbol;
  }

  @Override public String toString() {
    return symbol;
  }
}
```

BasicOperation은 enum 자료형이라 계승할 수 없지만 Operation은 인터페이스라 확장이 가능하다. API가 사용하는 모든 연산은 이 인터페이스로 표현한다. 따라서 이 인터페이스를 계승하는 새로운 enum 자료형을 만들면 Operation 객체가 필요한 곳에 해당 enum 자료형의 상수를 이용할 수 있게 된다. 예를 들어, 위의 기본 연산을 확장해서 지수 연산(exponentiation)과 나머지(remainder) 연산을 추가하고 싶다면 아래와 같이 Operation을 구현하는 새로운 enum 자료형을 만들기만 하면 된다.

```java
// 인터페이스를 이용해 기존 enum 자료형을 확장하는 사례
public enum ExtendedOperation implements Operaiont {
  EXP("^") {
    public double apply(double x, double y) {
      return Math.pow(x, y);
    }
  },
  REMAINDER("%") {
    public double apply(double x, double y) {
      return x % y;
    }
  };

  private final String symbol;

  ExtendedOperation(String symbol) {
    this.symbol = symbol;
  }

  @Override public String toString() {
    return symbol;
  }
}
```

새로 만든 연산들은 기존 연산들이 쓰였던 곳에는 어디든 사용할 수 있다. API가 BasicOperation이 아니라 Operation을 사용하도록 작성되어 있기만 하면 된다. 게다가 기존 enum 자료형이 쓰인 곳에서 확장된 enum 자료을 통째로 전달해서, 기존 enum 상수 대신 확장된 enum 상수가 쓰이게 하거나, 확장된 enum 상수가 기존 enum 상수와 함께 쓰이도록 할 수도 있다.

```java
public static void main(String[] args) {
  double x = Double.parseDouble(args[0]);
  double y = Double.parseDouble(args[1]);
  test(ExtendedOperation.class, x, y);
}

private static <T extends Enum<T> & Operation> void test(
    Class<T> opSet, double x, double y) {
  for (Operation op : opSet.getEnumConstants())
    System.out.printf("%f %s %f = %f%n", x, op, y, op.apply(x, y));
}
```

확장된 연산을 나타내는 자료형의 class 리터럴인 ExtendedOperation.class가 main에서 test로 전달되고 있음에 유의하자. 이 class 리터럴은 *한정적 자료형 토큰*(bounded type token) 구실을 한다(규칙 29). opSet의 형인자 T는 굉장히 복잡하게 선언되어 있는데 \<\<T extends Enum\<T\> \& Operation\>\>, Class 객체가 나타내는 자료형이 enum 자료형인 동시에 Operation의 하위 자료형이 되도록 한다.

두 번째 방법은 *한정적 와일드카드 자료형*(규칙 28) Collection\<? extends Operation\>을 opSet 인자의 자료형으로 사용하는 것이다.

```java
public static void main(String[] args) {
  double x = Double.parseDouble(args[0]);
  double y = Double.parseDouble(args[1]);
  test(Arrays.asList(ExtendedOperation.values(), x, y));
}

private static void test(Collection<? extends Operation> opSet,
    double x, double y) {
  for (Operation op : opSet)
    System.out.printf("%f %s %f = %f%n", x, op, y, op.apply(x, y));
}
```

메서드를 호출할 때, 여러 enum 자료형에 정의한 연산들을 함께 전달할 수 있도록 하기 위한 것이다. 그러나 이렇게 하면 EnumSet이나(규칙 32) EnumMap(규칙 33)을 사용할 수 없기 때문에, 여러 자료형에 정의한 연산들을 함께 전달할 수 있도록 하는 유연성이 필요 없다면, 한정적 자료형 토큰을 쓰는 편이 낭르 것이다.

### 요약
**계승 가능 enum 자료형은 만들 수 없지만, 인터페이스를 만들고 그 인터페이스를 구현하는 기본 enum 자료형을 만들면 계승 가능 enum 자료형을 흉내낼 수 있다.**

---

# 규칙 35. 작명 패턴 대신 어노테이션을 사용하라
자바 1.5 이전에는 테스트를 구별하기 위해 *작명 패턴*(naming pattern)을 썼다. 일례로 JUnit에서는 테스트 메서드 이름을 test로 시작해야 했다. 하지만 절차를 틀리면 알아채기 힘든 문제가 생긴다.

두 번째 단점은, 특정한 프로그램 요소에만 적용되도록 만들 수 없다는 것이다. 예를 들어 testSafetyMechanisms라는 이름의 클래스를 만들었다고 해 보자. 클래스 이름을 이렇게 지으면 JUnit이 그 메서드 전부를, 이름에 상관없이 자동으로 실행하지 않을까 하는 바람에서다. 하지만 JUnit은 역시 이번에도 아무런 불평 없이 모든 테스트를 무시한다.

세 번째 단점은, 프로그램 요소에 인자를 전달할 마땅한 방법이 없다는 것이다. 예를 들어, 특정 예외가 발생해야 성공으로 판정하는 테스트를 지원하고 싶다면, 해당 테스트에는 예외 자료형이 반드시 인자로 전달되어야 할 것이다. 아울러 컴파일러는 메서드 이름에 포함된 문자열이 예외 이름인지 알 도리가 없다.

어노테이션은 이 모든 문제를 멋지게 해결한다.

```java
// 표식 어노테이션 자료형(marker annotation type) 선언
import java.lang.annotation.*;

// 어노테이션이 붙은 메서드가 테스트 메서드임을 표시.
// 무인자(parameterless) 정적 메서드에만 사용 가능.
@Retension(RetensionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Test {
}
```

어노테이션 자료형 선언부에 붙는 어노테이션은 *메타-어노테이션*(meta-annotation이라 부른다. \@Retension(RetensionPolicy.RUNTIME)은 Test가 런타임에도 유지되어야 하는 어노테이션이라는 뜻이다. \@Target(ElementType.METHOD)는 Test가 메서드 선언부에만 적용할 수 있는 어노테이션이라는 뜻이다. 클래스나 필드 등 다른 프로그램 요소에는 적용할 수 없다.

**어노테이션이 있으므로 더 이상은 작명 패턴에 기대면 안 된다.**

---

# 규칙 36. Override 어노테이션은 일관되게 사용하라
대부분의 프로그래머에게 가장 중요하게 쓰이는 것은 Override 어노테이션이다. 메서드 선언부에만 사용할 수 있고, 상위 자료형(supertype)에 선언된 메서드를 재정의한다는 사실을 표현한다. 아래 클래스 Bigram은 알파벳 두 개가 연결된 문자열(bigram)을 나타낸다.

```java
// 버그가 어디 있는지 보이는가?
public class Bigram {
  private final Char first;
  private final Char second;

  public Bigram(char first, char second) {
    this.first = first;
    this.second = second;
  }
  public boolean equals(Bigram b) {
    return b.first == first && b.second == second;
  }
  public static void main(String[] args) {
    Set<Bigram> s = new HashSet<Bigram>();
    for (int i = 0; i < 10; i++)
      for (char ch = 'a'; ch <= 'z'; ch++)
        s.add(new Bigram(ch, ch));
    System.out.printf(s.size());
  }
}
```

Bigram 클래스의 프로그래머는 equals 메서드를 재정의하고자 했으며(규칙 8) equals 메서드를 재정의할 때는 hashCode도 재정의해야 한다는 것까지 기억했지만(규칙 9), 불행히도 equals 메서드는 재정의 대신 오버로딩(overloading)되었다(규칙 41). Object의 equals를 재정의하기 위해서는 equals를 선언할 때 인자의 자료형을 Object로 해야 하는데, Bigram의 equals 메서드를 보면 자료형이 Object가 아니라 Bigram으로 되어 있다. 따라서 Bigram에는 Object의 equals가 그대로 계승된다.

컴파일러가 이런 오류를 찾도록 도와주기 위해 Object.equals를 재정의하려 한다는 사실을 알려줘야 한다. Bigram.equals에 \@Override 어노테이션을 아래와 같이 붙여주면 된다.

```java
@Override
public boolean equals(Object o) {
  if (!(o instanceof Bigram))
    return false;
  Bigram b = (Bigram) o;
  return b.first == first && b.seoncd == second;
}
```

**상위 클래스에 선언된 메서드를 재정의할 때는 반드시 선언부에 Override 어노테이션을 붙어야 한다.** 비-abstract 클래스에서 abstract 메서드를 재정의할 때는 Override 어노테이션을 붙이지 않아도 된다. 하지만 상위 클래스 메서드를 재정의한다는 사실을 명시적으로 표현하고 싶은 경우에는 붙여도 상관없다.

### 요약
상위 자료형에 선언된 메서드를 재정의하는 모든 메서드에 Override 어노테이션을 붙이도록 하면 굉장히 많은 오류를 막을 수 있다.

---

# 규칙 37. 자료형을 정의할 때 표식 인터페이스를 사용하라
표식 인터페이스(marker interface)는 아무 메서드도 선언하지 않는 인터페이스다. 클래스를 만들 때 표식 인터페이스를 구현하는 것은, 해당 클래스가 어떤 속성을 만족한다는 사실을 표시하는 것과 같다. 이 인터페이스를 구현하는 클래스를 만든다는 것은, 해당 클래스로 만든 객체들은 ObjectOutputStream으로 출력할 수 있다는(\"직렬화\"할 수 있다는) 뜻이다.

표식 어노테이션(규칙 35)과 비교했을 때, 표식 인터페이스에는 두 가지 장점이 있다. **가장 중요한 첫 번째 장점은, 표식 인터페이스는 결국 표식 붙은 클래스가 만드는 객체들이 구현하는 자료형이라는 점이다. 표식 어노테이션은 자료형이 아니다.** 표식 인터페이스는 자료형이므로, 표식 어노테이션을 쓴다면 프로그램 실행 중에나 발견하게 될 오류를 컴파일 시점에 발견할 수 있다.

표식 인터페이스가 어노테이션보다 나은 점 두 번째는, 적용 범위를 좀 더 세밀하게 지정할 수 있다는 것이다. 어노테이션 자료형을 선언할 때 target을 ElementType.TYPE으로 지정하면 해당 어노테이션은 어떤 클래스나 인터페이스에도 적용 가능하다. 그런데 특정한 인터페이스를 구현한 클래스에만 적용할 수 있어야 하는 표식이 필요하다고 해 보자. 표식 인터페이스를 쓴다면, 그 특정 인터페이스를 extends 하도록 선언하기만 하면 된다. 그러면 표식 붙은 모든 자료형은 자동으로 그 특정 인터페이스의 하위 자료형이 된다.

표식 어노테이션의 주된 장점은, 프로그램 안에서 어노테이션 자료형을 쓰기 시작한 뒤에도 더 많은 정보를 추가할 수 있다는 것이다. 기본값(default)을 갖는 어노테이션 자료형 요소(annotation type element)들을 더해 나가면 된다.

표식 어노테이션은 더 큰 어노테이션 기능(facility)의 일부라는 장점도 갖는다. 다양한 프로그램 요소에 어노테이션을 붙일 수 있도록 하는 프레임워크 안에서, 표식 어노테이션은 개발자가 일관성을 유지할 수 있도록 해 준다.

클래스나 인터페이스 이외의 프로그램 요소에 적용되어야 하는 표식은 어노테이션으로 만들어야 한다. 클래스나 인터페이스에만 적용할 표식이라면, 스스로 질문해봐야 한다. 이 표식이 붙은 객체만 인자로 받을 수 있는 메서드를 만들것인가? 그렇다면 어노테이션 대신 표식 인터페이스를 써야 한다.

### 요약
표식 인터페이스와 표식 어노테이션은 쓰임새가 다르다. 새로운 메서드가 없는 자료형을 정의하고자 한다면 표식 인터페이스를 이용해야 한다. 클래스나 인터페이스 이외의 프로그램 요소에 표식을 달아야 하고, 앞으로 표식에 더 많은 정보를 추가할 가능성이 있다면, 표식 어노테이션을 사용해야 한다. **만일 ElementType.TYPE에 적용될 표식 어노테이션 자료형을 작성하고 있다면, 반드시 어노테이션 자료형에 구현해야 하는지, 표식 인터페이스로 만드는 것이 바람직하지는 않은지 고민해보기 바란다.**

---

# Reference
- [Effective Java 2/E](http://www.insightbook.co.kr/%EB%8F%84%EC%84%9C-%EB%AA%A9%EB%A1%9D/programming-insight/%EC%9D%B4%ED%8E%99%ED%8B%B0%EB%B8%8C-%EC%9E%90%EB%B0%94effective-java-2e)
