---
layout: entry
title: Functional Programming in Scala 1
author: 김성중
author-email: ajax0615@gmail.com
description: 1장. 함수형 프로그래밍이란 무엇인가?
publish: true
---

함수형 프로그래밍(functional programming, FP)은 간단하지만 심오한 뜻을 담은 전제에 기초로 한다. 그 전제란, 프로그램을 오직 **순수 함수**(pure function)들로만, 다시 말해서 **부수 효과**(side effect)가 없는 함수들로만 구축한다는 것이다. 부수 효과가 무엇일까? 그냥 결과를 돌려주는 것 이외의 어떤 일을 수행하는 함수를 가리켜 부수 효과가 있는 함수라고 칭한다. \"그냥 결과를 돌려주는 것 이외의 어떤 일\"의 예를 몇 가지 들자면 다음과 같다.

- 변수를 수정한다.
- 자료구조를 제자리에서 수정한다.
- 객체의 필드를 설정한다.
- 예외(exception)를 던지거나 내면서 실행을 중단한다.
- 콘솔에 출력하거나 사용자의 입력을 읽어들인다.
- 파일에 기록하거나 파일에서 읽어들인다.
- 화면에 그린다.

위와 같은 일들을 전혀 수행할 수 없거나 수행할 수 있는 때와 장소가 크게 제한된 상태로 프로그래밍 한다는 것이 어떤 것인지 생각해 보자. 과연 유용한 프로그램을 만드는 것이 가능하긴 할까? 변수에 값을 다시 배정할 수 없다면, 루프 *loop* 같은 프로그램을 어떻게 작성해야 할까? 변하는 자료는 어떻게 다루어야 할 것이며, 예외를 던지지 않고 오류를 처리하려면 또 어떻게 해야 할까? 화면에 뭔가를 그리거나 파일을 읽어들이는 등의 입출력을 수행하는 프로그램은 어떻게 작성할까? 이에 대한 답은, 함수형 프로그래밍은 우리가 프로그램을 작성하는 **방식** 에 대한 제약이지 표현 가능한 프로그램의 **종류** 에 대한 제약이 아니라는 것이다.

# 1.1 FP의 이점: 간단한 예제 하나

### 1.1.1 부수 효과가 있는 프로그램
커피숍에서 커피를 구매하는 과정을 처리하는 프로그램을 구현한다고 가정하자. 우선 구현에서 부수 효과를 사용하는(이를 **불순한**[impure] 프로그램) 스칼라 프로그램부터 보자.

```
class Cafe {
  def buyCoffee(cc: CreditCard): Coffee = {
    val cup = new Coffee()
    cc.charge(cup.price)  // 부수효과. 신용카드를 실제로 청구한다.
    cup
  }
}
```

cc.charge(cup.price)가 부수 효과의 예이다. 신용카드 청구(charge)에는 외부 세계와의 일정한 상호작용이 관여한다. 이를테면 어떤 웹 서비스를 통해서 신용카드 회사와 접촉해서 거래(트랜잭션)을 승인하고, 대금을 청구하고, (그것이 성공한다면)이후 참조를 위해 거래 기록을 영구적으로 기록하는 등의 작업이 필요할 것이다. 그러나 이 함수 자체는 단지 하나의 Coffee 객체를 돌려줄 뿐이고, 그 외의 동작은 모두 **부수적으로**(on the side) 일어난다. 여기서 \'부수 효과\'라는 용어가 비롯되었다.

부수 효과가 있기 때문에 이 코드는 검사하기 어렵다. 코드를 검사하기 위해 실제로 신용카드 회사와 연결해서 카드 이용 대금을 청구하고 싶지는 않기 때문이다. 코드에 검사성(testability)이 부족하다면 설계를 변경해 볼 필요가 있다. 실제 대금 결제를 위해 신용카드 회사와 연동하는 방법에 관한 지식을 CreditCard에 집어넣는 것은 좋지 않다. 또한 이 결제에 관한 정보를 우리의 내부 시스템에 영속적으로 기록하는 방법에 대한 지식도 집어넣지 말아야 할 것이다. CreditCard가 그런 부분을 알지 못하게 만들고, 대신 지급을 위한 Payments 객체를 buyCoffee에 전달한다면 코드의 모듈성과 검사성을 좀 더 높일 수 있다.

```
class Cafe {
  def buyCoffee(cc: CreditCard, p: Payments): Coffee = {
    val cup = new Coffee()
    p.charge(cc, cup.price)
    cup
  }
}
```

p.charge(cc, cup.price)를 호출할 때 여전히 부수 효과가 발생하지만, 적어도 검사성은 조금 높아졌다. Payments를 하나의 인터페이스로 만들고 그 인터페이스의 모의(mock) 구현(검사에 적합한)을 작성하면 검사를 수월하게 진행할 수 있다. 그러나 그 역시 이상적인 방식은 아니다. 그러자면 반드시 Payments를 인터페이스로 만들어야 하며, 구체(concrete) 클래스를 잘 만든다고 해도 모의 구현은 사용하기가 어색할 수 있다. 예를 들어 buyCoffee 호출 이후에 조사해야 할 어떤 내부 상태가 존재할 수 있는데, 그러면 검사 과정에서는 charge 호출에 의해 그 상태가 적절히 변경(**변이**[mutation])되었는지 확인해야 한다. 이런 부분을 **모의 프레임워크**(mock framework) 같은 것으로 처리할 수도 있겠지만, 지금처럼 그냥 buyCoffee의 청구 금액이 커피 한잔 가격과 동일하지만 검사하는 데 그런 프레임워크를 사용한다는 것은 배보다 배꼽이 더 큰 일이다.

검사 문제 외에도 이 구현에는 buyCoffee를 재사용하기 어렵다는 또 다른 문제가 있다. 예를 들어 앨리스라는 손님이 커피 열 두잔을 주문한다고 하자. 그러면 루프를 돌려서 buyCoffee를 열두 번 호출하면 될 것이다. 그러나 지금 구현에서는 지급 시스템과 12회 연결해서 앨리스의 신용카드에 열두 번이나 청구해야 한다. 그러면 카드 수수료가 추가되므로 앨리스에게나 커피숍에나 좋지 않다.

어떻게 해야 할까? 대금을 누적하는 특별한 논리(logic)를 갖춘 buyCoffees라는 완전히 새로운 함수를 작성하면 된다. 지금 예에서는 buyCoffee의 논리가 아주 단순하므로 그런 새 함수를 만드는 것이 별로 어려운 일이 아니다. 그러나 복제할 논리가 그리 간단하지 않을 때에는 코드의 재사용과 합성(composition) 능력에 해가 될 수 있다.

### 1.1.2 함수적 해법: 부수 효과의 제거
이에 대한 함수적 해법은 부수 효과들을 제거하고 buyCoffee가 Coffee뿐만 아니라 **청구 건을 하나의 값으로 돌려주게** 하는 것이다. 청구 금액을 신용카드 회사에 보내고 결과를 기록하는 등의 처리 문제(concern)는 buyCoffee 바깥의 다른 어딘가에서 해결하도록 한다. 다음은 스칼라로 표현된 함수적 해법이 어떤 모습인지 보여주는 에이다.

```
class Cafe {
  def buyCoffee(cc: CreditCard): (Coffee, Charge) = {
    val up = new Coffee()
    (cup, Charge(cc, cup.price))
  }
}
```

이제 청구건의 **생성** 문제가 청구건의 **처리** 또는 **연동** 문제와 분리되었다. buyCoffee 함수는 이제 Coffee 뿐만 아니라 Charge도 돌려준다. 이런 변경 덕분에 여러 잔의 커피를 한 번의 거래로 구매하기 위해 이 함수를 재사용하기 쉬워졌음을 잠시 후에 보게 될 것이다. 그런데 Charge가 구체적으로 무엇일까?

```
case class Charge(cc: CreditCard, amount: Double) {
  def combine(other: Charge): Charge =
    if (cc == other.cc)
      Charge(cc, amount + other.amount)
    else
      throw new Exception("Can't combine charges to different cards")
}
```

그럼 커피 n잔의 구매를 구현한 buyCoffees 함수를 보자. 이전과는 달리, 이 함수는 buyCoffee를 이용해서 구현되어 있다.

```
class Cafe {
  def buyCoffee(cc: CreditCard): (Coffee, Charge) = ...

  def buyCoffees(cc: CreditCard, n: Int): (List[Coffee], Charge) = {
    val purchases: List[(Coffee, Charge)] = List.fill(n)(buyCoffee(cc))
    val (coffees, charges) = purchases.unzip
    // 한 번에 청구건 두 개를 combine을 이용해서 하나로 결합하는 과정을 반복함으로써 청구건들의 목록 전체를 하나의 청구건으로 환원한다.
    (coffees, charges.reduce((c1, c2) => c1.combine(c2)))
  }
}
```

전반적으로, 이 해법은 이전보다 뚜렷이 개선되었다. 이제는 buyCoffee를 직접 재사용해서 buyCoffees 함수를 정의할 수 있으며, 두 함수 모두 Payments 인터페이스의 복잡한 모의 구현을 정의하지 않고도 손쉽게 검사할 수 있다. 실제로 Cafe는 이제 Charge의 대금이 어떻게 처리되는지 전혀 알지 못한다. 물론 실제 청구 처리를 위해서 여전히 Payments 클래스가 필요하겠지만, Cafe는 그에 대해 알 필요가 없다.

Charge를 일급(first-class) 값으로 만들면, 청구건들을 다루는 업무 논리(business logic)를 좀 더 쉽게 조립할 수 있다는 예상치 못했던 또 다른 이득이 생긴다. 예를 들어 앨리스가 노트북을 들고 와서 커피숍에서 몇 시간 일하면서 커피를 여러 번 주문했다고 하자. 커피숍이 그 주문들을 하나로 모아서 청구한다면 신용카드 수수료를 아낄 수 있을 것이다. Charge가 일급 값인 덕분에, 같은 카드에 대한 청구건들을 하나의 List[Charge]로 취합하는 다음과 같은 함수를 작성하는 것이 가능하다.

```
def coalesce(charges: List[Charge]): List[Charge] =
  charges.groupBy(_.cc).values.map(_.reduce(_ combine _)).toList
```

이 코드는 다수의 함수들을 값으로서 groupBy와 map, reduce 메서드에 전달한다. 이후의 여러 장에서 이런 한 줄 짜리 코드(one-liner)를 읽고 쓰는 방법을 배우게 될 것이다. `_.cc` 와 `_ combine _` 은 **익명 함수**(anonymous function)을 위한 구문이다.

# 1.2 (순수)함수란 구체적으로 무엇인가?
앞에서 FP가 순수 함수들로 프로그래밍하는 것이며, 순수 함수는 효과(부수 효과)가 없는 함수라고 말했다. 커피숍 예제를 논의하면서 효과와 순수라는 개념을 비공식적으로만 언급했는데, 함수적으로 프로그래밍한다는 것이 무슨 뜻인지 좀 더 구체적으로 이해하려면 그 개념을 공식적으로 정의할 필요가 있다.

입력 형식이 A이고 출력 형식이 B인 함수 f(스칼라에서는 A => B라는 하나의 형식으로 표기한다)는 형식이 A인 모든 값 a를 각각 형식이 B인 하나의 값 b에 연관시키되, b가 오직 a의 값에 의해서만 결정된다는 조건을 만족하는 계산이다. 내부 또는 외부 공정의 상태 변경 f(a)의 결과를 개선하는 데 어떠한 영향도 주지 않는다. 예를 들어 Int => String 형식의 intToString 함수는 모든 정수를 그에 대응되는 문자열을 대응시킨다. 그리고 이것이 만일 실제 **함수** 이면, 그 외의 일은 전혀 하지 않는다.

다른 말로 하면, 함수는 주어진 입력으로 뭔가를 계산하는 것 이외에는 프로그램의 실행에 그 어떤 관찰 가능한 영향도 미치지 않는다. 이를 두고 함수에 부수 효과가 없다고 말한다. 그런 함수를 좀 더 명시적으로 **순수**(pure) 함수라고 부르기도 한다.

익숙한 함수들 중에도 순수 함수가 많이 있다. 정수에 대한 더하기(+) 함수를 생각해 보자. 이 함수는 정수 값 두 개를 받고 정수 값 하나를 돌려준다. 주어진 임의의 두 정수에 대해 이 함수는 **항상 같은 값을 돌려준다.** 그리고 Java나 스칼라 등 문자열의 수정이 불가능한(즉, 문자열이 불변이 값인) 다른 여러 언어에서 String 객체의 length 메서드도 순수 함수이다. 주어진 임의의 문자열에 대해 이 메서드는 항상 같은 길이를 돌려주며, 그 외의 일은 전혀 일어나지 않는다.

순수 함수의 이러한 개념을 **참조 투명성**(referential transparency, RT)이라는 개념을 이용해서 공식화할 수 있다. 참조 투명성은 함수가 아니라 **표현식**(expression)의 한 속성이다. 지금 논의에서 표현식이란 프로그램을 구성하는 코드 중 하나의 결과로 평가될 수 있는 임의의 코드 조각이라고 생각하면 된다. 즉, 스칼라 해석기(interpreter)에 입력했을 때 답이 나오는 것이면 모두 표현식이다. 예를 들어 2 + 3은 하나의 표현식이다. 이 표현식은 값 2와 3(그 둘도 표현식)에 순수 함수 +를 적용한다. 이 표현식에는 부수 효과가 없다. 이 표현식의 평가(evaluation)는 항상 5라는 같은 결과를 낸다.

이것이 바로 표현식의 참조 투명성의 전부이다. 즉, 임의의 프로그래에서 만일 어떤 표현식을 그 평가 결과로 바꾸어도 프로그래의 의미가 변하지 않는다면 그 표현식은 참조에 투명한 것이다. 그리고 만일 어떤 함수를 참조에 투명한 인수들로 호출하면, 그 함수도 참조에 투명하다.

# 1.3 참주 투명성, 순수성, 그리고 치환 모형
참조 투명성의 정의가 원래의 buyCoffee 예제에 어떻게 적용되는지 살펴보자.

```
def buyCoffee(cc: CreditCard): Coffee = {
  val cup = new Coffee()
  cc.charge(cup.price)
  cup
}
```

cc.charge(cup.price)의 반환 형식이 무엇이든, buyCoffee는 그 반환값을 폐기한다. 따라서 buyCoffee(aliceCreditCard)의 평가 결과는 그냥 cup이며, 이는 new Coffee()와 동등하다. 앞의 참조 투명성 정의하에서 buyCoffee가 순수하려면 **임의의**(any) p에 대해 p(buyCoffee(aliceCreditCard))가 p(new Coffee())와 동일하게 작동해야 한다. 이 조건이 참이 아님은 명백하다. new Coffee() 라는 프로그램은 아무 일도 하지 않지만 buyCoffee(aliceCreditCard)는 신용카드 회사에 연결해서 대금을 청구하기 때문이다.

참조 투명성은 함수가 **수행하는** 모든 것이 함수가 돌려주는 **값**(함수의 결과 형식을 따르는)으로 대표되는 불변(invariant) 조건을 강제한다. 이러한 제약을 지키면 **치환 모형**(substitution model)이라고 부르는, 프로그램 평가에 대한 간단하고도 자연스러운 추론 모형이 가능해진다. 참조에 투명한 표현식들의 계산 과정은 마치 대수 방정식을 풀 때와 아주 비슷하다. 즉, 표현식의 모든 부분을 전개(확장)하고, 모든 변수를 해당 값으로 치환하고, 그런 다음 그것들을 가장 간단한 형태로 환원(축약)하면 된다. 각 단계마다 하나의 항(term)을 그에 동등한 것으로 대체한다. 즉, 계산은 **등치 대 등치**(equals for equals) 치환을 통해서 진행된다. 다른 말로 하면, 참조 투명성은 프로그램에 대한 **등식적 추론**(equational reasoning)을 가능하게 한다.

예제 두 개를 더 보자. 하나는 모든 표현식이 참조에 투명하며 치환 모형을 이용해서 추론할 수 있는 반면, 다른 하나는 일부 표현식이 참조 투명성을 위반한다.

```
scala> val x = "Hello, World"
x: java.lang.String = Hello, World

scala> val r1 = x.reverse
r1: String = dlrow, olleH

scala> val r2 = x.reverse // r1과 r2는 같다
r2: String = dlrow, olleH
```

x 항의 모든 출현을 x가 지칭하는 표현식(해당 **정의**)으로 치환하면 다음과 같은 모습이 된다.

```
scala> val r1 = "Hello, World".reverse
r1: String = dlrow, olleH

scala> val r2 = "Hello, World".reverse  // r1과 r2는 여전히 같다.
r2: String = dlrow, olleH
```

이러한 변환은 결과에 영향을 미치지 않는다. 이전 예에서처럼 r1과 r2의 값은 동일하며, 따라서 x는 참조에 투명하다. 더 나아가서 r1과 r2도 참조 투명성을 가지므로, 만일 더 큰 프로그램의 다른 어떤 부분에 이들이 출현하면 그것들을 모두 해당 값으로 치환할 수 있으며, 그래도 프로그램에는 영향을 미치지 않는다.

이번에는 참조에 투명하지 **않은** 함수를 살펴보겠다. java.lang.StringBuilder 클래스의 append 함수를 생각해 보자. 이 함수는 StringBuilder를 그 자리에서(in place) 조각한다. append를 호출하고 나면 StringBuilder의 이전 상태는 파괴된다.

```
scala> val x = new StringBuilder("Hello")
x: java.lang.StringBuilder = Hello

scala> val y = x.append(", World")
y: java.lang.StringBuilder = Hello, World

scala> val r1 = y.toString
r1: java.lang.StringBuilder = Hello, World

scala> val r2 = y.toString
r2: java.lang.StringBuilder = Hello, World  // r1과 r2는 같다.
```

지금까지는 좋다. 그럼 이 부수 효과가 어떻게 참조 투명성을 위반하는지 살펴보자. 앞에서처럼, y의 모든 출현을 해당 append 호출로 치환하면 어떻게 될까?

```
scala> val x = new StringBuilder("Hello")
x: java.lang.StringBuilder = Hello

scala> val r1 = x.append(", World").toString
r1: java.lang.StringBuilder = Hello, World

scala> val r2 = x.append(", World").toString
r2: java.lang.StringBuilder = Hello, World, World // 이제 r1과 r2는 같지 않다.
```

이러한 변환에 의해 프로그램은 이전과는 다른 결과를 낸다. 따라서 StringBuilder.append는 순수 함수가 **아니라는** 결론을 내릴 수 있다. 부연하자면, 비록 r1과 r2가 같은 표현식처럼 보이지만 사실은 동일한 StringBuilder의 서로 다른 두 값을 참조한다. r2가 x.append를 호출하는 시점에서 r1은 이미 x가 참조하는 객체를 변이시켰다. 이 부분이 어렵게 느껴져도 걱정하지 마시길. 실제로 이는 추론하기 어려운 부분이다. 부수 효과가 존재하면 프로그램의 행동에 관한 추론이 어려워진다.

반면 치환 모형은 추론이 간단하다. 평가의 부수 효과가 전적으로 국소적(local, 지역적)이기 때문이다(즉, 부수 효과는 오직 평가되는 표현식에만 영향을 미친다). 따라서 코드 블록을 이해하기 위해 머릿속에서 일련의 상태 갱신들을 따라갈 필요가 없다. **국소 추론**(local reasoning)만으로도 코드를 이해할 수 있다. 함수의 실행 이전과 이후에 발생할 수 있는 모든 상태 변화들을 머릿속으로 짚어 나가지 않고도 함수가 하는 일을 이해할 수 있는 것이다. 그냥 함수의 정의를 보고 함수 본문에서 인수들을 치환하기만 하면 된다. 비록 \'치환 모형\'이라는 구체적인 용어를 사용하지 않았더라도, 자신의 코드를 추론할 때 독자도 아마 이런 모형을 사용해 왔을 것이다.

순수성의 개념을 이런 식으로 공식화해 보면, 함수적 프로그래밍의 모듈성이 다른 경우에 비해 더 좋은 경우가 많은 이유를 짐작할 수 있다. 모듈적인 프로그램은 전체와는 독립적으로 이해하고 재사용할 수 있는 구성요소(component)들로 구성된다. 그런 프로그램에서 프로그램 전체의 의미는 오직 구성요소들의 의미와 구성요소들의 합성에 관한 규칙들에만 의존한다. 즉, 구성요소들은 **합성 가능**(composable)하다. 순수 함수는 모듈적이고 합성 가능한데, 이는 순수 함수에서 계산 자체의 논리가 \"결과로 무엇을 할 것인가\"나 \"입력을 어떻게 얻을 것인가\"와는 분리되어 있기 때문이다. 즉, 순수 함수는 하나의 블랙박스이다. 입력이 주어지는 방식은 단 하나이다. 입력은 항상 함수에 대한 인수들로만 주어진다. 그리고 함수는 결과를 계산해서 돌려줄 뿐, 그것이 어떻게 쓰이는지 신경 쓰지 않는다. 이러한 관심사의 분리 덕분에 계산 논리의 재사용성이 높아진다. 결과에 관련된 부수 효과나 입력을 얻는 데 관련된 부수 효과가 모든 문맥에서 적절한지 걱정하지 않고 함수를 재사용할 수 있다. 이 점을 buyCoffee 예제에서 이미 보았다. 출력에 대한 지급처리의 부수 효과를 제거한 덕분에, 검사를 위해서든 추가적 합성(buyCoffees와 coalesce를 작성하는 등의)을 위해서든 함수의 논리를 재사용하기가 훨씬 쉬워졌다.

# Reference
- [Functional Programming in Scala](https://www.manning.com/books/functional-programming-in-scala)
