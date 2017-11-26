---
layout: entry
title: Functional Programming in Scala 3
author: 김성중
author-email: ajax0615@gmail.com
description: Functional Programming in Scala의 4장(예외를 이용하지 않은 오류 처리)을 정리한 글입니다.
publish: true
---

1장에서 예외(exception)를 던지는 것이 하나의 부수 효과임을 간단히 언급했다. 함수적 코드에서 예외를 사용하지 않는다면, 그 대신 무엇을 사용할까? 이번 장에서는 오류를 함수적으로 제기하고 처리하는 데 필요한 기본 원리들을 배울 것이다. 여기서 핵심은, 실패 상황과 예외를 보통의 값으로 표현할 수 있으며, 일반적인 오류 처리, 복구 패턴을 추상화한 고차 함수를 작성할 수 있다는 것이다. 오류를 값으로서 돌려준다는 함수적 해법은 더 안전하고 참조 투명성을 유지한다는 장점이 있다. 게다가 고차 함수 덕분에 예외의 주된 이점인 **오류 처리 논리의 통합**(consolidation of error-handling logic)도 유지된다. 또한 이번 장에서는 예외를 좀 더 자세히 살펴보면서 예외의 몇 가지 문제점을 논의한 후 방금 말한 장점들이 어떻게 실현되는지도 이야기한다.

# 1. 예외의 장단점
예외가 왜 참조 투명성을 해칠까?

```
def failingFn(i: Int): Int = {
  val y: Int = throw new Exception("fail!")
  try {
    val x = 42 + 5
    x + y
  }
  catch { case e: Exception => 43 }
}
```

REPL에서 failingFn을 호출하면 예상대로 오류가 발생한다.

```
scala> failingFn(12)
java.lang.Exception: fail!
  ...
```

y가 참조에 투명하지 않음을 증명할 수 있다. 임의의 참조 투명 표현식을 그것이 지칭하는 값으로 치환해도 프로그램의 의미가 변하지 않는다는 점을 기억할 것이다. 만일 x + y의 y를 throw new Exception("fail!")로 치환하면 그전과는 다른 결과가 나온다. 이제는 예외를 잡아서 43을 돌려주는 try 블록 안에서 예외가 발생하기 때문이다.

```
def failingFn2(i: Int): Int = {
  try {
    val x = 42 + 5
    x + ((throw new Exception("fail!")): Int)
  }
  catch { case e: Exception => 43 }
}
```

이를 REPL에서 시연해 보자.

```
scala> failingFn2(12)
res1: Int = 43
```

참조 투명성이라는 것을, 참조에 투명한 표현식의 의미는 **문맥(context)에 의존하지 않으며** 지역적으로 추론할 수 있지만, 참조에 투명하지 않은 표현식의 의미는 **문맥에 의존적이고**(contxt-dependent) 좀 더 전역의 추론이 필요하다는 것으로 이해해도 될 것이다. 예를 들어 참조 투명 표현식 42 + 5의 의미는 그 표현식을 포함한 더 큰 표현식에 의존하지 않는다. 그 표현식은 항상, 그리고 영원히 47과 같다. 그러나 throw new Exception("fail")이라는 표현식의 의미는 문맥에 크게 의존한다.

예외의 주된 문제 두 가지는 다음과 같다.
- **예외는 참조 투명성을 위반하고 문맥 의존성을 도입한다.** 따라서 치환 모형의 간단한 추론이 불가능해지고 예외에 기초한 혼란스러운 코드가 만들어진다. 이것이 예외를 오류 처리에만 사용하고 흐름의 제어에는 사용하지 말아야 한다는 속설의 근원이다.
- **예외는 형식에 안전하지 않다.** failingFn의 형식인 Int => Int만 보고는 이 함수가 예외를 던질 수 있다는 사실을 전혀 알 수 없으며, 그래서 컴파일러는 failingFn의 호출자에게 그 예외들을 처리하는 방식을 결정하라고 강제할 수 없다. 프로그래머가 실수로 failingFn의 예외 점검 코드를 추가하지 않으면 그 예외는 실행시점에서야 검출된다.

이런 단점들이 없으면서도 예외의 기본 장점인 **오류 처리 논리의 통합과 중앙집중화** 를 유지하는(오류 처리 논리를 코드 기반의 여기저기에 널어 놓지 않아도 되도록) 대안이 있으면 좋을 것이다. 지금부터 소개하는 대안 기법은 \"예외를 던지는 대신, 예외적인 조건이 발생헀음을 뜻하는 값을 돌려준다\"라는 오래된 착안에 기초한다. C에서 예외 처리를 위해 오류 부호(error code)를 돌려준 적이 있는 사람이라면 이런 방식에 익숙할 것이다. 단, 이 기법에서는 오류 부호를 직접 돌려주는 대신 그런 \'미리 정의해 둘 수 있는 값들\'을 대표하는 새로운 일반적 형식을 도입하고, 오류의 처리와 전파에 관한 공통적인 패턴들을 고차 함수들을 이용해서 캡슐화한다. C 스타일의 오류 부호와는 달리, 우리가 사용하는 오류 처리 전략은 **형식에 완전히 안전하며,** 최소한의 구문적 잡음으로도 스칼라의 형식 점검기의 도움을 받아서 실수를 미리 발견할 수 있다. 구체적으로 어떤 방식인지는 잠시 후에 이야기하겠다.

> **점검된 예외**<br/>
> java의 점검된 예외(checked exception)는 적어도 오류를 처리할 것인지 다시 발생시킬 것인지의 결정을 강제하나, 결과적으로 호출하는 쪽에 판에 박힌(boilerplate) 코드가 추가된다. 더욱 중요한 점은, 점검된 예외는 **고차 함수에는 통하지 않는다** 는 점이다. 고차 함수에서는 인수가 구체적으로 어떤 예외를 던질지 미리 알 수 없기 때문이다. 예를 들어 이전에 List에 대해 정의한 map 함수를 생각해 보자.
> ```
> def map[A, B](l: List[A])(f: A => B): List[B]
> ```
> 이 함수가 유용하고 고도로 일반적임은 명백하나, 점검된 예외와는 잘 맞지 않는다는 점도 명백하다. 모든 가능한(f가 던질 수 있는) 점검된 예외마다 map의 개별적인 버전을 만들 수는 없는 일이다. 그렇게 하기로 했다고 해도, 어떤 예외가 가능한지 map이 알 수 있게 할 방법이 없다. 이는 심지어 Java에서도 일반적 코드가 RuntimeException이나 어떤 공통의 점검된 Exception 형식에 의존할 수 밖에 없는 이유이다.

# 2. 예외의 가능한 대안들
예외 대신 사용할 만한 여러 가지 접근방식을 조사해 보자.

```
def mean(xs: Seq[Double]): Double =
  if (xs.isEmpty)
    throw new ArithmeticException("mean of empty list!")
  else xs.sum / xs.length
```

mean 함수는 소위 **부분 함수**(partial function)의 예이다. 부분 함수란 일부 입력에 대해서는 정의되지 않는 함수를 말한다. 자신이 받아들이는 입력에 대해 입력 형식만으로는 결정되지 않는 어떤 가정을 두는 함수는 대부분 부분 함수이다. 받아들일 수 없는 입력에 대해 예외를 던질 수도 있지만, 꼭 그래야 하는 것은 아니다. 그럼 mean에 대해 예외 대신 사용할 수 있는 대안 몇 가지를 살펴보자.

첫 번째 대안은 Double 형식의 가짜 값을 돌려주는 것이다. 모든 경우에 그냥 xs.sum / xs.length를 돌려준다면 빈 목록에 대해서는 0.0/0.0을 돌려주게 되는데, 이는 Double.NaN이다. 아니면 다른 어떤 경계 값(sentinel value)을 돌려줄 수도 있겠다. 상황에 따라서는 원하는 형식의 값 대신 null을 돌려줄 수도 있다. 이런 부류의 접근방식은 예외 기능이 없는 언어에서 오류를 처리하는 데 흔히 쓰인다. 그러나 이 책에서는 이런 접근방식을 거부한다. 이유는 여러 가지이다.

- 오류가 소리 없이 전파될 수 있다. 호출자가 이런 오류 조건의 점검을 실수로 빼먹어도 컴파일러가 경고해 주지 않으며, 그러면 이후의 코드가 제대로 작동하지 않을 수 있다.
- 실수의 여지가 많다는 점 외에, 호출하는 쪽에 호출자가 \'진짜\' 결과를 받았는지 점검하는 명시적 if 문들로 구성된 판에 박힌 코드가 상당히 늘어난다. 여러 함수를 호출한다면 그런 판박이 코드가 크게 늘어난다. 각 호출마다 오류 코드를 점검하고 어떤 방식으로든 취합해야 하기 때문이다.
- 다형적 코드에는 적용할 수 없다. 출력 형식에 따라서는 그 형식의 경계 값을 결정하는 것이 **불가능** 할 수도 있다. 주어진 순차열에서 커스텀 비교 함수에 근거해서 최댓값을 찾는 max 함수를 생각해 보자. 구체적인 서명이 def max\[X\](xs: Seq[A])(greater: (A, A) => Boolean): A 라고 할 때, A 형식의 값 중 입력이 빈 순차열임을 나타내는 데 사용할 하나의 값을 정하는 것은 불가능하다. null도 사용할 수 없다. null은 오직 기본 형식이 아닌 형식에만 유효한데, A는 Double이나 Int 같은 기본 형식일 수도 있기 때문이다.
- 호출자에게 특별한 방침이나 호출 규약을 요구한다. mean 함수를 제대로 사용하려면 호출자가 그냥 mean을 호출해서 그 결과를 사용하는 것 이상의 작업을 수행해야 한다. 함수에 이런 특별한 방침을 부여하면, 모든 인수를 균일한 방식으로 처리해야 하는 고차 함수에 전달하기 어려워진다.

또 다른 대안은 함수가 입력을 처리할 수 없는 상황에 처했을 때 무엇을 해야 하는지 말해주는 인수를 호출자가 지정하는 것이다.

```
def mean_1(xs: IndexedSeq[Double], onEmpty: Double): Double =
  if (xs.isEmpty) onEmpty
  else xs.sum / xs.length
```

이렇게 하면 mean은 부분 함수가 아닌 완전 함수(total function)가 된다. 그러나 여기에는 결과가 정의되지 않는 경우의 처리 방식을 함수의 **직접적인** 호출자가 알고 있어야 하고, 그런 경우에도 항상 하나의 Double 값을 결과로 돌려주어야 한다는 단점이 있다. 예를 들어 어떤 더 큰 계산 과정에서 mean을 호출하는데, 만일 mean이 정의되지 않으면 그 계산 자체를 취소해야 한다면 어떻게 해야 할까? 또는, 더 큰 계산에서 지금과는 완전히 다른 분기로 넘어가야 한다면? 단순히 onEmpty 매개변수를 넘겨주는 것만으로는 그런 유연성을 얻을 수 없다.

우리에게 필요한 것은, 정의되지 않는 경우가 가장 적당한 수준에서 처리되도록 그 처리 방식의 결정을 미룰 수 있게 하는 방법이다.

# 3. Option 자료 형식
해법은, 함수가 항상 답을 내지 못한다는 점을 반환 형식을 통해서 명시적으로 표현하는 것이다. 이를, 오류 처리 전략을 호출자에게 미루는 것으로 생각해도 된다. 이를 위해 Option 이라는 새로운 형식을 도입한다.

```
sealed trait Option[+A]
case class Some[+A](get: A) extends Option[A]
case object None extends Option[Nothing]
```

Option에는 두 개의 경우 문이 있다. Option을 정의할 수 있는 경우에는 Some이 되고, 정의할 수 없는 경우에는 None이 된다. 이제 Option을 이용해서 mean을 구현하면 다음과 같은 코드가 된다.

```
def mean(xs: Seq[Double]): Option[Double] =
  if (xs.isEmpty) None
  else Some(xs.sum / xs.length)
```

이제는 이 함수의 결과가 항상 정의되지는 않는다는 사실이 함수의 반환 형식에 반영되어 있다. 함수가 항상 선언된 반환 형식(이제는 Option[Double])의 결과를 돌려주어야 한다는 점은 여전하므로, mean은 이제 하나의 **완전 함수** 이다. 이 함수는 입력 형식의 모든 값에 대해 정확히 하나의 출력 헝식 값을 돌려준다.

### 3.1 Option의 사용 패턴
스칼라에서는 부분 함수의 부분성을 흔히 Option 같은 자료 형식(또는 Either)으로 처리한다. Option이 편리한 이유는, 오류 처리의 공통 패턴을 고차 함수들을 이용해서 추출함으로써 예외 처리 코드에 흔히 수반되는 판에 박힌 코드를 작성하지 않아도 된다는 점이다. 이번 절에서는 Option을 다루는 몇 가지 기본 함수를 살펴본다.

**Option에 대한 기본적인 함수들**<br/>
Option은 최대 하나의 원소를 담을 수 있다는 점을 제외하면 List와 비슷하다. 실제로 Option에는 이전에 본 여러 List 함수에 대응되는 함수들이 있다.

```
trait Option[+A] {
  def map[B](f: A => B): Option[B]
  def flatMap[B](f: A => Option[B]): Option[B]
  def getOrElse[B >: A](default: => B): B
  def orElse[B >: A](ob: => Option[B]): Option[B]
  def filter(f: A => Boolean): Option[A]
}
```

이 예제에는 몇 가지 새로운 구문이 쓰였다. getOrElse의 default: => B라는 형식 주해는(그리고 orElse의 비슷한 형식 주해는) 해당 인수의 형식이 B이지만 그 인수가 함수에서 실제로 쓰일 때까지는 평가되지 않음을 뜻한다. 이런 **비엄격성**(non-strictness) 개념은 다음 장에서 자세히 이야기하겠다. 그리고 getOrElse와 orElse 함수의 B >: A 형식 매개변수는 B가 반드시 A와 같거나 A의 **상위형식**(supertype)이어야 함을 뜻한다. 스칼라가 Option[+A]를 A의 공변 형식으로 선언해도 안전하다고 추론하게 하려면 반드시 이렇게 지정해야 한다.

**기본적인 Option 함수들의 용례**<br/>
하나의 Option에 대해 명시적인 패턴 부합을 적용할 수도 있지만, 거의 모든 경우에는 위에서 말한 고차 함수들을 사용하게 된다.

map 함수는 Option 안의 결과(가 있다면)를 변환하는 데 사용할 수 있다. 이를 오류가 발생하지 않았다는 가정하에서 계산을 진행하는 것으로 생각해도 될 것이다. 또한, 이는 오류 처리를 나중의 코드에 미루는 수단이기도 하다.

```
case class Employee(name: String, department: String)

def lookupByName(name: String): Option[Employee] = ...

val joeDepartment: Option[String] =
  lookupByName("Joe").map(_.department)
```

이 예에서 lookupByName(\"Joe\")는 Option[Employee]를 돌려준다. 그것을 map으로 변환하면 Joe가 속한 부서의 이름을 뜻하는 Option[String]이 나온다. 여기서 lookupByName(\"Joe\")의 결과를 명시적으로 점검하지 않음을 주목하기 바란다. 그냥 오류가 전혀 발생하지 않았다는 듯이 map의 인수 안에서 계산을 계속 진행한다. 만일 lookupByName(\"Joe\")가 None을 돌려주었다면 계산의 나머지 부분이 취소되어서 map은 \_.department 함수를 전혀 호출하지 않는다.

```
// Joe가 직원이면 Joe의 부서, 아니면 None
lookupByName("Joe").map(_.department)

// Joe가 어떤 부서에 속해 있으면 Joe의 부서, 아니면 "Default Dept"
lookupByName("Joe").map(_.department).getOrElse("Default Dept")
```

변환을 위해 지정한 함수 자체가 실패할 수 있다는 점만 빼면 flatMap도 이와 비슷하다. flatMap을 이용하면 여러 단계로 이루어진 계산을 수행하되 어떤 단계라도 실패하면 그 즉시 모든 과정이 취소되는 방식으로 수행할 수 있다. 이는 None.flatMap(f)가 f를 실행하지 않고 즉시 None을 돌려주기 때문이다.

orElse는 getOrElse와 비슷하되 첫 Option이 정의되지 않으면 다른 Option을 돌려준다는 점이 다르다. 이는 실패할 수 있는 계산들을 연결해서 첫 계산이 성공하지 않으면 둘째 것을 시도하고자 할 때 유용하다.

흔한 관용구로, o.getOrElse(throw new Exception(\"FAIL\"))은 Option의 None 경우를 예외로 처리되게 만든다. 이와 관련된 일반적인 법칙은, 합리적인 프로그램이라면 결코 예외를 잡을 수 없을 상황에서만 예외를 사용한다는 것이다. 어떤 호출자가 복구 가능한 오류로 처리할 수 있을 만한 상황이라면 예외 대신 Option(또는 Either)을 돌려주어서 호출자에게 유연성을 부여한다.

이상에서 보듯이 오류를 보통의 값으로서 돌려주면 코드를 짜기가 편해지며, 고차 함수를 사용함으로써 예외의 주된 장점인 오류 처리 논리의 통합과 격리도 유지할 수 있다. 계산의 매 단계마다 None을 점검할 필요가 없음을 주목하기 바란다. 그냥 일련의 변환을 수행하고, 나중에 원하는 장소에서 None을 점검하고 처리하면 된다. 또한 추가적인 안전성도 얻게 된다. Option[A]는 A와는 다른 형식이므로, None일 수 있는 상황의 처리를 명시적으로 지연 또는 수행하지 않으면 컴파일러가 오류를 낸다.

### 3.2 예외 지향적 API의 Option 합성과 승급, 감싸기
일단 Option을 사용하기 시작하면 코드 기반 전체에 Option이 번지게 되리라는 성급한 결론을 내리는 독자도 있을 것이다. 즉, Option을 받거나 돌려주는 메서드를 호출하는 모든 코드를 Some이나 None을 처리하도록 수정해야 한다고 추측할 수 있다. 그러나 실제로 그런 부담을 질 필요가 없다. 보통의 함수를 Option에 대해 작용하는 함수로 **승급시킬**(lift) 수 있기 때문이다.

예를 들어 map 함수가 있으면 Option[A] 형식의 값들을 A => B 형식의 함수를 이용해서 변환한 후 하나의 Option[B]를 결과로 돌려주게 하는 것이 가능하다. 이를 map이 A => B 형식의 함수 f를 Option[A] => Option[B] 형식의 함수로 변환한다고 이해해도 좋을 것이다.

```
def lift[A, B](f: A => B): Option[A] => Option[B] = _ map f
```

이러한 lift가 있으면 지금까지 나온 그 어떤 함수라도 한 Option 값의 **문맥 안에서** 작용하도록 변환할 수 있다. 예를 하나 보자.

```
val absO: Option[Double] => Option[Double] = lift(math.abs)
```

math 객체에는 abs나 sqrt, exp를 비롯한 여러 표준적인 수학 함수들이 들어 있다. 앞의 예에서 보듯이, 선택적(optional) 값에 작용하는 math.abs 함수를 직접 작성할 필요가 없다. 그냥 그 함수를 Option 문맥으로 승급시키면 된다. 이러한 승급은 **모든** 함수에 가능하다. 또 다른 예로, 자동차 보험 회사의 웹 사이트에서 사용자가 즉석 온라인 견적을 요구하는 양식을 제출하는 페이지를 위한 논리를 구현하다고 하자. 양식에 담긴 정보를 분석한 후, 결과적으로 다음과 같은 보험료율(insurance rate) 함수를 호출하게 될 것이다.

```
def insuranceRateQuote(age: Int, numberOfSpeedingTickets: Int): Double
```

이 함수를 호출하려면 고객의 나이와 고객이 받은 속도위반 딱지의 수를 알아야 한다. 그런데 고객이 제출한 웹 페이지의 양식에서 그러한 정보는 보통의 문자열로 되어 있으므로 적절히 정수 값으로 파싱해야 한다. 그러한 파싱이 실패할 수도 있다. 주어진 문자열 s를 s.toInt를 이용해서 Int로 파싱해 보았을 때 만일 문자열이 유효한 정수를 나타내지 않는다면 s.toInt는 NumberFormatException이라는 예외를 던진다.

그럼 toInt의 예외 기반 API를 Option으로 변환하고 parseInsuranceRateQuote 함수를 구현해 보자. 이 함수는 나이와 속도위반 딱지 수를 받고, 두 값의 정수 파싱이 성공하면 insuranceRateQuote를 호출한다.

```
def parseInsuranceRateQuote(age: String, numberOfSpeedingTickets: String): Option[Double] = {
  val optAge: Option[Int] = Try(age.toInt)
  val optTickets: Option[Int] = Try(numberOfSpeedingTickets.toInt)
  insuranceRateQuote(optAge, optTickets)
}

// A 인수를 엄격하지 않은 방식으로 받아들인다.
// a를 평가하는 도중에 예외가 발생하면 그것을 None으로 변환할 수 있게 하기 위해서이다.
def Try[A](a: => A): Option[A] =
  try Some(a)
  catch { case e: Exception => None }
```

Try 함수는 예외 기반 API를 Option 지향적 API로 변환하는 데 사용할 수 있는 범용 함수이다. 이 함수는 엄격하지 않은 또는 \'게으른(lazy)\' 인수를 사용한다. a의 형식 주해 => A가 바로 그 점을 나타낸다. 게으른 인수에 대해서는 다음 장에서 훨씬 자세히 논의한다.

# 4. Either 자료 형식
이번 장의 핵심은 실패와 예외를 보통의 값으로 표현할 수 있다는 점과 오류 처리 및 복구에 대한 공통의 패턴을 추상화하는 함수를 작성할 수 있다는 점이다. Option은 실패 시 이 형식은 그냥 유효한 값이 없음을 뜻하는 None을 돌려줄 뿐이다. 그러나 그 외의 것이 필요할 때도 있다. 예를 들어 좀 더 자세한 정보를 담은 String을 돌려준다거나, 예외가 발생한 경우 실제로 발생한 오류가 어떤 것인지 알 수 있는 무언가를 돌려주면 좋을 것이다.

실패에 관해 알고 싶은 정보가 어떤 것이든 그것을 부호화하는 자료 형식을 만드는 것은 물론 가능하다. 그냥 실패가 발생했음을 알면 충분한 때에는 Option을 사용하면 된다. 이번 절에서는 Option을 간단하게 확장해서, 실패의 **원인** 을 추적할 수 있는 Either 자료 형식을 만들어 본다.

```
sealed trait Either[+E, +A]
case class Left[+E](value: E) extends Either[E, Nothing]
case class Right[+A](value: A) extends Either[Nothing, A]
```

Option처럼 Either도 case가 두 개뿐이다. 아주 개괄적으로 말하자면, Either 자료 형식은 둘 중 하나일 수 있는 값들을 대표한다. 이 형식은 두 형식의 **분리합집합**(disjoint union; 서로 소 합집합)이라 할 수 있다. 이 형식을 성공 또는 실패를 나타내는 데 사용할 때에는, Right 생성자를 성공을 나타내는 데 사용하고(\"오른쪽[right]이 옳은[right] 쪽\"이라는 말장난에서 비롯됨) Left는 실패에 사용한다. 왼쪽 형식 매개변수의 이름으로는 error(오류)를 의미하는 E를 사용한다.

그럼 mean 예제를 다시 보자. 이번에는 실패의 경우에 String을 돌려준다.

```
def mean(xs: IndexedSeq[Double]): Either[String, Double] =
  if (xs.isEmpty)
    Left("mean of empty list!")
  else
    Right(xs.sum / xs.length)
```

오류에 대한 추가 정보, 이를테면 소스 코드에서 오류가 발생한 위치를 알 수 있는 스택 추적 정보가 있으면 편리한 경우가 종종 있다. 그런 경우 Either의 Left 쪽에서 그냥 예외를 돌려주면 된다.

```
def safeDiv(x: Int, y: Int): Either[Exception, Int] =
  try Right(x / y)
  catch { case e: Exception => Left(e) }
```

Option에서 했듯이, 던져진 예외를 값으로 변환한다는 이러한 공통의 패턴을 추출한 함수 Try를 작성해 보자.

```
def Try[A](a: => A): Either[Exception, A] =
  try Right(a)
  catch { case e: Exception => Left(e) }
```

# Reference
- [Functional Programming in Scala](https://www.manning.com/books/functional-programming-in-scala)
