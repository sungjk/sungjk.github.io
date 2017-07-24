---
layout: entry
title: 함수형 사고(6)
author: 김성중
author-email: ajax0615@gmail.com
description: 함수형 사고 - 객체지향 개발자에서 함수형 개발자로 거듭나기
publish: true
---

# 6.1 함수형 언어의 디자인 패턴
함수형 언어에서는 빌딩블록과 문제의 접근 방법이 다르기 때문에, 전통적인 GoF 패턴들 중의 일부는 사라지고, 나머지는 근본적으로 다른 방법으로 같은 문제를 풀게 된다.

함수형 프로그래밍에서는 전통적인 디자인 패턴들이 다음과 같은 세 가지로 나타난다.

- 패턴이 언어에 흡수된다.
- 패턴 해법이 함수형 패러다임에도 존재하지만, 구체적인 구현 방식은 다르다.
- 해법이 다른 언어나 패러다임에 없는 기능으로 구현된다(예를 들어 메타프로그래밍을 사용한 해법들은 깔끔하고 멋있다. 이런 해법은 자바에서는 불가능하다).

# 6.2 함수 수준의 재사용
**구성(composition)**(주어진 매개변수와 일급 함수들의 형태로 이루어진다)은 함수형 프로그래밍 라이브러리에서 재사용의 방식으로 자주 사용된다. 함수형 언어들은 객체지향 언어들보다 더 큰 단위로 재사용을 한다. 그러기 위해서 매개변수로 커스터마이즈된 공통된 작업들을 추출해낸다.

디자인 패턴을 통한 재사용은 궁극적으로 작은 단위의 재사용이다. 한 가지 해법(예를 들어 플라이웨이트 패턴)은 다른 것(메멘토 패턴)과 전혀 상관이 없다. 디자인 패턴으로 해결할 수 있는 문제들은 아주 특정하고, 그런 특정한 문제들을 자주 발견한다면 요긴하게 사용할 수 있다. 하지만 패턴이 그 문제에만 적용되기 때문에 그 사용 범위는 좁을 수 밖에 없다.

함수형 프로그래머들도 코드를 재사용하고 싶어 하지만 그들은 다른 빌딩블록을 사용한다. 함수형 프로그래밍은 구조물들 간에 잘 알려진 관계(커플링 coupling)을 만들기보다는, 큰 단위의 재사용 메커니즘을 추출하려 한다. 이런 노력은 객체 간의 관계(모피즘 morphism)를 규정하는 수학의 한 분야인 카테고리 이론에 근거를 둔다. 대부분의 애플리케이션들은 목록을 사용한다. 상황에 따라 달라지고(contextualized) 이동 가능한(portable) 코드다. 함수형 언어들은 일급 함수(언어의 다른 구조물들이 사용되는 모든 곳에서 사용될 수 있는 함수)를 매개변수나 리턴 값으로 사용한다.

filter() 메서드에서처럼 코드를 매개변수로 전달하는 기능은 코드 재사용의 다른 접근 방법을 제시해준다. 전통적인 디자인 패턴을 사용하는 객체지향의 관점에서 볼 때는 클래스나 메서드를 만들어서 문제를 푸는 방식이 더 편해 보일 수도 있다.

하지만 함수형 언어들은 어떤 토대(scaffolding)나 보일러플레이트를 사용하지 않고도 같은 결과를 얻을 수 있게 해준다. 궁극적으로 디자인 패턴의 존재 목적은 언어의 결함을 메꾸기 위함일 뿐이다. 쓸데없이 뼈대뿐인 클래스를 래핑하지 않고 행동을 전달할 수 없는 결함 같은 것 말이다.

#### **6.2.1 템플릿 메서드**
템플릿 메서드는 하나의 알고리즘의 뼈대만 정의하고, 세부 절차는 하위 클래스가 주어진 알고리즘의 구조를 바꾸지 않고 정의하게끔 한다.

예제 6-1. 템플릿 메서드의 \'표준\' 구현

```java
abstract class Customer {
  def plan

  def Customer() {
    plan = []
  }

  def abstract checkCredit()
  def abstract checkInventory()
  def abstract ship()

  def process() {
    checkCredit()
    checkInventory()
    ship()
  }
}
```

process() 메서드는 checkCredit(), checkInventory(), ship()에 의존한다. 이들은 추상 메서드이기 때문에 하위 클래스가 그 정의를 제공해야 한다.

일급 함수는 다른 여느 자료구조처럼 사용할 수 있으므로, 위 코드는 다음과 같이 정의할 수 있다.

예제 6-2. 일급 함수를 사용한 템플릿 메서드

```java
class CustomerBlocks {
  def plan, checkCredit, checkInventory, ship

  def CustomerBlocks() {
    plan = []
  }

  def process() {
    checkCredit()
    checkInventory()
    ship()
  }
}
```

[예제 6-2]에서 알고리즘의 각 단계는 클래스에 할당할 수 있는 성질에 불과하다. 이것이 상세한 구현 방법을 언어의 기능으로 감추는 일례다. 함수들의 구현을 나중으로 미루고, 이 패턴을 이 문제의 해법으로 생각할 수 있다.

앞의 두 해법은 동등하지 않다. 전통적인 [예제 6-1]의 템플릿 메서드는 하위 클래스가 추상 클래스에서 정해준 메서드를 구현해야 한다. 물론 하위 클래스가 텅 빈 메서드를 구현할 수도 있지만, 추상 메서드의 정의는 하위 클래스를 구현하는 개발자에게 알려주는 일종의 문서 역할을 한다. 좀 더 유동성이 요구되는 상황에서는 이렇게 고정화된 메서드 선언이 적합하지 않을 수도 있다. 예를 들어 어떤 메서드도 받아서 실행할 수 있는 Customer 클래스를 만들 수도 있기 때문이다.

#### **6.2.2 전략**
일급 함수의 사용으로 간편해진 디자인 패턴으로는 전략 패턴을 들 수 있다. 전략 패턴은 각자 캡슐화되어 서로 교환 가능한 알고리즘 군을 정의한다. 이것은 클라이언트에 상관없이 알고리즘을 바꿔서 사용할 수 있게 해주는 패턴이다. 일급 함수를 사용하면 전략을 만들고 조작하기가 쉽다.

#### **6.2.3 플라이웨이트 디자인 패턴과 메모이제이션**
플라이웨이트 패턴은 많은 수의 조밀한 객체의 참조들을 공유하는 최적화 기법이다. 참조들을 객체 풀에 생성하여 특정 뷰를 위해 사용한다.

플라이웨이트는 같은 자료형의 모든 객체를 대표하는 하나의 객체, 즉 표준 객체라는 아이디어를 사용한다. 애플리케이션 내에서 각 사용자를 위해 상품 목록을 모두 생성하기보다는, 표준 상품들의 목록을 하나 만들고 각 사용자는 원하는 상품의 참조를 가지는 식이다.

#### **6.2.4 팩토리와 커링**
디자인 패턴 차원에서 보면, 커링은 함수의 팩토리처럼 사용된다. 함수형 프로그래밍 언어에서 보편적인 기능은 함수를 여느 구조처럼 사용할 수 있게 해주는 일급 함수들이다. 이 기능 덕분에, 주어진 조건에 따라 다른 함수들을 리턴하는 함수를 만들 수 있다. 이것이 사실상 팩토리의 본질이다.

예제 6-13. 함수 팩토리로 사용되는 커링

```
def adder = { x, y -> x + y }

def incrementer = adder.curry(1)

println "increment 7: ${incrementer(7)}"
```

위 코드에서는 우선 첫 매개변수를 1로 커링하여, 변수 하나만 받는 함수를 리턴한다. 실질적으로 함수 팩토리를 만든 셈이다.

예제 6-14. 스칼라에서의 재귀적 필터링

```java
object CurryTest extends App {
  def filter(xs: List[Int], p: Int => Boolean): List[Int] =
    if (xs.isEmpty) xs
    else if (p(xs.head)) xs.head :: filter(xs.tail, p)
    else filter(xs.tail, p)

  // 커링할 함수를 정의한다.
  def dividesBy(n: Int)(x: Int) = ((x % n) == 0)

  val nums = List(1, 2, 3, 4, 5, 6, 7, 8)
  // filter는 컬렉션(nums)과 일인수 함수(커링된 dividesBy() 함수)를 매개변수로 받는다.
  println(filter(nums, dividesBy(2)))
  println(filter(nums, dividesBy(3)))
}
```

이 예제는 이 절의 시작에서 언급한 함수형 프로그래밍에서의 패턴의 두 가지 형태를 보여준다. 첫째, 커링이 언어나 런타임에 내장되어 있기 때문에, 함수 팩토리의 개념이 이미 녹아들어 있어 다른 구조물이 필요 없다. 둘째, 내가 지적한 다양한 구현 방법에 대한 중요성을 보여준다. 디자인 패턴이란 문제를 풀기 위해 구조물에 의존하므로 간단히 구현하기 어려운 큰 문제들을 푸는 방법이라고 생각하는 반면, 일반화된 함수에서 특정한 dividesBy() 함수를 만드는 것은 작은 문제라고 생각하게 때문이다. **일반적** 함수에서 **특정한** 함수를 만들 때는 커링을 사용하라.

# 6.3 구조형 재사용과 함수형 재사용
객체지향의 한 가지 목적은 캡슐화와 상태 조작을 쉽게 하는 것이다. 그래서 객체지향형 추상화는 문제 해결을 위해 주로 상태를 이용한다. 마이클 페더스가 언급한 \'움직이는 부분\'인 클래스와 클래스 간의 상호 관계를 주로 사용하게 된다.

함수형 프로그래밍은 구조물들을 연결하기보다는 부분들로 구성하여 움직이는 부분을 최소화하려고 노력한다. 객체지향 언어의 경험만 있는 개발자들은 이 미묘한 개념의 차이를 쉽게 보지 못한다.

#### **6.3.1 구조물을 사용한 코드 재사용**
명령형 및 객체지향형 프로그래밍 스타일에서는 구조물과 메시징이 빌딩블록이다. 객체지향 코드를 재사용하려면, 대상이 되는 코드를 다른 클래스로 옮기고 상속을 통해 접근해야 한다.

예제 6-15. 명령형 자연수 분류기

```java
public class ClassifierAlpha {
  private int number;

  public ClassifierAlpha(int number) {
    this.number = number;
  }

  public boolean isFactor(int potential_factor) {
    return number % potential_factor == 0;
  }

  public Set<Integer> factors() {
    HashSet<Integer> factors = new HashSet<>();
    for (int i = 1; i <= sqrt(number); i++)
      if (isFactor(i)) {
        factors.add(i);
        factors.add(number / i);
      }
    return factors;
  }

  static public int sum(Set<Integer> factors) {
    Iterator it = factors.iterator();
    int sum = 0;
    while (it.hasNext())
      sum += (Integer) it.next();
    return sum;
  }

  public boolean isPerfect() {
    return sum(factors()) - number == number;
  }

  public boolean isAbundant() {
    return sum(factors()) - number > number;
  }

  public boolean isDeficient() {
    return sum(factors()) - number < number;
  }
}
```

예제 6-16. 명령형으로 소수 찾기

```java
public class PrimeAlpha {
  private int number;

  public PrimeAlpha(int number) {
    this.number = number;
  }

  public boolean isPrime() {
    Set<Integer> primeSet = new HashSet<Integer>() {
      add(1);
      add(number);
    };
    return number > 1 &&
      factors.equals(primeSet);
  }

  public boolean isFactor(int potential_factor) {
    return number % potential_factor == 0;
  }

  public Set<Integer> factors() {
    HashSet<Integer> factors = new HashSet<>();
    for (int i = 1; i <= sqrt(number); i++)
      if (isFactor(i)) {
        factors.add(i);
        factors.add(number / i);
      }
    return factors;
  }
}
```

**구성을 사용한 코드 재사용**<br/>

예제 6-21. 함수형 소수 찾기

```java
public class FPrime {
  public static boolean isPrime(int number) {
    Set<Integer> factors = Factors.of(number);
    return number > 1 &&
      factors.size() == 2 &&
      factors.contains(1) &&
      factors.contains(number);
  }
}
```

명령형 버전에서 했던 것처럼 중복된 코드를 Factors 클래스로 추출한 버전이 아래 코드이다. factors() 메서드는 가독성을 위해 of()로 이름을 바꿨다.

예제 6-22. 함수형으로 리팩토링한 Factors 클래스

```java
public class Factors {
  static public boolean isFactor(int number, int potential_factor) {
    return number % potential_factor == 0;
  }

  static public Set<Integer> of(int number) {
    HashSet<Iteger> factors = new HashSet<>();
    for (int i = 1; i <= sqrt(number); i++)
      if( isFactor(number, i)) {
        factors.add(i);
        factors.add(number / i);
      }
    return factors;
  }
}
```

함수형 버전의 모든 상태는 매개변수로 주어지기 때문에, 이 추출한 클래스에는 공유된 상태가 없다. 일단 클래스를 추출해내면, 그것을 사용하여 함수형 분류기와 소수 찾기를 리팩토링할 수 있다.

예제 6-23. 리팩토링한 자연수 분류기

```java
public class FClassifier {
  public static int sumOfFactors(int number) {
    Iterator<Integer> it = Factors.of(number).iterator();
    int sum = 0;
    while (it.hasNext())
      sum += it.next();
    return sum;
  }

  public static boolean isPerfect(int number) {
    return sumOfFactors(number) - number == number;
  }

  public static boolean isAbundant(int number) {
    return sumOfFactors(number) - number > number;
  }

  public static boolean isDeficient(int number) {
    return sumOfFactors(number) - number < number;
  }
}
```

더 함수형으로 만들기 위해 특별한 라이브러리나 언어를 사용하지 않았다. 단지 코드의 재사용을 위해 **커플링** 대신에 **구성** 을 사용하였다. 커플링과 구성의 차이점은 작지만 중요하다.

# Reference
[함수형 사고](http://www.hanbit.co.kr/store/books/look.php?p_code=B6064588422)
