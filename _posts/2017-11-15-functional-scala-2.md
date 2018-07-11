---
layout: entry
post-category: scala
title: Functional Programming in Scala 2
author: 김성중
author-email: ajax0615@gmail.com
description: Functional Programming in Scala의 3장(함수적 자료구조)을 정리한 글입니다.
next_url: /2017/11/25/functional-scala-3.html
publish: true
---

함수적 프로그램은 변수를 갱신하거나 변이 가능한(mutable) 자료구조를 수정하는 일이 없다고 했다. 그렇다면 함수형 프로그래밍에서 **사용할 수 있는** 자료구조는 어떤 것일까? 스칼라에서 그런 자료구조를 정의하고 조작하는 방법은 무엇인가? 이번 장에서는 **함수적 자료구조**(functional data structure)가 무엇이고 그것을 어떻게 다루는지 설명한다. 그리고 이를 기회로 삼아서 함수형 프로그래밍에서 자료구조를 정의하는 방법을 소개하고, 관련 기법인 **패턴 부합** 도 설명한다. 또한, 순수 함수의 작성과 일반화도 실습한다.

# 1. 함수적 자료구조의 정의
짐작했겠지만, 함수적 자료구조란 오직 순수 함수만으로 조작되는 자료구조이다. 순수 함수는 자료를 그 자리에서 변경하거나 기타 부수 효과를 수행하는 일이 없어야 함을 기억하기 바란다. **따라서 함수적 자료구조는 정의에 의해 불변이**(immutable)이다. 예를 들어 빈 목록(스칼라에서는 List()나 Nil)은 정수 값 3이나 4처럼 영원히 불변이 값이다. 그리고 3 + 4 를 평가하면 3이나 4가 수정되는 일 없이 새로운 정수 7이 나오는 것처럼, 두 목록을 연결하면(목록 a와 b를 연결하는 구문은 a ++ b이다) 두 입력 목록은 변하지 않고 새로운 목록이 만들어진다.

그런데 자료구조가 그런 식으로 조작된다면 여분의 복사가 많이 일어나지 않을까? 놀랄지도 모르겠지만, 답은 \"그렇지 않다\"이다. 그 이유는 잠시 후에 보게 될 것이다. 일단 지금은 가장 보편적인 함수적 자료구조라 할 수 있는 단일 연결 목록(singly linked list)을 살펴보자. 다음의 단일 연결 목록 정의는 사실상 스칼라의 표준 라이브러리에 정의되어 있는 List 자료 형식의 것과 개념적으로 동일하다(좀 더 간단하긴 하지만). 다음의 코드에는 새로운 구문과 개념이 많이 등장하는데, 차차 자세히 설명하겠다.

```
sealed trait List[+A]
case object Nil extends List[Nothing]
case class Cons[+A](head: A, tail: List[A]) extends List[A]

object List {
  def sum(ints: List[Int]): Int = ints match {
    case Nil => 0
    case Cons(x, xs) => x + sum(xs)
  }

  def product(ds: List[Double]): Double = ds match {
    case Nil => 1.0
    case Cons(0.0, _) => 0.0
    case Cons(x, xs) => x * product(xs)
  }

  def apply[A](as: A*): List[A] =
    if (as.isEmpty) Nil
    else Cons(as.head, apply(as.tail: _*))
}
```

우선 sealed trait라는 키워드들로 시작하는 자료 형식의 정의부터 보자. 일반적으로 자료 형식을 도입할 때에는 trait 키워드를 사용한다. trait 키워드로 정의하는 \'특질(trait)\'은 하나의 추상 인터페이스로, 필요하다면 일부 메서드의 구현을 담을 수도 있다. 지금 예에서는 trait을 이용해서 List라는 특질을 정의한다. 이 특질에는 메서드가 하나도 없다. trait 앞에 sealed를 붙이는 것은 이 특질의 모든 구현이 반드시 이 파일 안에 선언되어 있어야 함을 뜻한다.

그다음에 있는 case 키워드로 시작하는 두 줄은 List의 두 가지 구현, 즉 두 가지 **자료 생성자**(data constructor)이다. 이들은 List가 취할 수 있는 두 가지 형태를 나타낸다. 다음 그림에서 보듯이, List는 자료 생성자 Nil로 표기되는 빈 목록일 수도 있고 자료 생성자 Cons(관례상 construct의 줄임말로 쓰인다)로 표기되는 비지 않은 목록일 수도 있다. 비지 않은 목록은 초기 요소 head 다음에 나머지 요소들을 담은 하나의 List(tail: 빈 목록일 수도 있다)로 구성된다.

```
case object Nil extends List[Nothing]
case class Cons[+A](head: A, tail: List[A]) extends List[A]
```

함수를 다형적으로 만들 수 있듯이, 자료 형식도 다형적으로 만들 수 있다. sealed trait List 다음에 형식 매개변수 [+A]를 두고 Cons 자료 생성자 안에서 그 A 매개변수를 사용함으로써, 목록에 담긴 요소들의 형식에 대해 다형성이 적용되는 List 자료 형식이 만들어진다. 그러면 하나의 동일한 정의로 Int 요소들의 목록(List[Int]로 표기), Double 요소들의 목록(List[Double]), String 요소들의 목록(List[String]) 등등을 사용할 수 있게 된다(형식 매개 변수 A에 있는 +는 공변[covariant]을 뜻한다).

> **공변과 불변에 대해**<br/>
> trait List[+A] 선언에서 형식 매개변수 A 앞에 붙은 +는 A가 List의 **공변**(covariant) 매개 변수임을 뜻하는 **가변 지정자**(variance annotation: 가변 주해)이다. 그러한 매개변수를 \'양의(positive)\' 매개변수라고 부르기도 한다. 이것이 뜻하는 바는, 예를 들어 만일 Dog가 Animal의 하위형식(subtype)이면 List[Dog]가 List[Animal]의 하위형식으로 간주된다는 것이다. (좀 더 일반화하자면, X가 Y의 하위형식이라는 조건을 만족하는 모든 형식 X와 Y에 대해, List[X]는 List[Y]의 하위형식이다.) 반면, 만일 A 앞에 +가 없으면 그 형식 매개변수에 대해 List는 **불변**(invariant)이다.<br/>
> 그런데 Nil이 List[Nothing]을 확장(extends)함을 주목하자. Nothing은 모든 형식의 하위형식이고 A가 공변이므로 Nil을 List[Int]나 List[Double] 등 그 어떤 형식의 목록으로도 간주할 수 있다. 이는 우리가 정확히 원했던 것이다.<br/>
> 공변/불변에 관한 이러한 사항들이 현재의 논의에 아주 중요하지는 않다. 이들은 사실 스칼라가 하위형식을 이용해서 자료 생성자를 부호화하는 방식에 기인한 군더더기에 가까우므로, 지금 당장 이들이 명확히 이해되지 않는다고 해도 걱정할 필요는 없다. 가변 지정자를 전혀 사용하지 않고 코드를 작성하는 것도 얼마든지 가능하며, 그러면 함수 서명들이 다소 간단해진다(반면 형식 추론은 더 나빠지는 경우가 많겠지만).

자료 생성자 선언은 해당 형태의 자료 형식을 구축하는 함수를 도입한다. 다음은 자료 생성자의 용례 몇 가지이다.

```
val ex1: List[Double] = Nil
val ex2: List[Int] = Cons(1, Nil)
val ex3: List[String] = Cons("A", Cons("b", Nil))
```

case object Nil에 의해 Nil이라는 표기를 이용해서 빈 List를 구축할 수 있게 되며, case class Cons는 Cons(1, Nil), Cons(\"a\", Cons(\"b\", Nil)) 같은 표기를 통해서 임의의 길이의 단일 연결 목록을 구축할 수 있게 한다. List는 형식 A에 대해 매개변수화되어 있으므로, 이 함수들 역시 서로 다른 형식의 A에 대해 인스턴스화되는 다형적 함수들이다. 위의 예에서 ex2는 A 형식 매개변수를 Int로 인스턴스화하는 반면 ex3은 String으로 인스턴스화한다. ex1의 예는 Nil이 List[Double] 형식으로 인스턴스화된다는 점에서 흥미롭다. 이것이 허용되는 이유는, 빈 목록에는 아무 요소도 없으므로 그 어떤 형식의 목록으로도 간주할 수 있기 때문이다.

각 자료 생성자는 sum이나 product 같은 함수들에서처럼 **패턴 부합**(pattern matching)에 사용할 수 있는 **패턴** 도 도입한다.

# 2. 패턴 부합
그럼 object List에 속한 함수 sum과 product를 자세히 살펴보자. 이런 함수들을 List의 **동반 객체**(companion object)라고 부르기도 한다. 두 함수 모두 패턴 부합을 활용한다.

```
def sum(ints: List[Int]): Int = ints match {
  case Nil => 0
  case Cons(x, xs) => x + sum(xs)
}

def product(ds: List[Double]): Double = ds match {
  case Nil => 1.0
  case Cons(0.0, _) => 0.0
  case Cons(x, xs) => x * product(xs)
}
```

예상했겠지만, sum 함수의 정의는 빈 목록의 합이 0이라고 말한다. 한편 비지 않은 목록의 합은 첫 요소 x에 나머지 요소들의 합 xs를 더한 것이다. 마찬가지로, product 함수의 정의에 의하면 빈 목록의 곱이 1.0이고, 0.0으로 시작하는 임의의 목록의 곱은 0.0, 그렇지 않은 비지 않은 목록의 곱은 첫 요소에 나머지 요소들의 곱을 곱한 것이다. 이들이 재귀적인 정의임을 주목하기 바란다. List 같은 재귀적인 자료 형식(Cons 자료 생성자에서 자신을 재귀적으로 참조함을 주목할 것)을 다루는 함수들을 작성할 때에는 이처럼 재귀적인 정의를 사용하는 경우가 많다.

> **스칼라의 동반 객체**<br/>
> 자료 형식과 자료 생성자와 함께 **동반 객체**(또는 짝 객체)를 선언하는 경우가 많다. 동반 객체는 자료 형식과 같은 이름(지금 예에서는 List)의 object로, 자료 형식의 값들을 생성하거나 조작하는 여러 편의용 함수들을 담는 목적으로 쓰인다.<br/>
> 예를 들어 요소 a의 복사본 n개로 이루어진 List를 생성하는 def fill[A](n: Int, a: A): List[A]라는 함수가 필요하다면, 그러한 함수를 List의 동반 객체의 메서드로 만드는 것이 바람직하다. 스칼라에서 동반 객체는 관례에 가깝다. 이 모듈의 이름을 Foo라고 해도 안 될 것은 없지만, List라고 하면 이 모듈이 목록을 다루는 데 관련된 함수를 담고 있음이 좀 더 명확해진다.

패턴 부합은 표현식의 구조를 따라 내려가면서 그 구조의 부분 표현식을 추출하는 복잡한 switch 문과 비슷하게 작동한다. 패턴 부합 구문은 ds 같은 표현식으로 시작해서 그다음에 키워드 match가 오고, 그다음에 일련의 경우(case) 문들이 {}로 감싸인 형태이다. 부합의 각 경우 문은 =>의 좌변에 **패턴**(Cons(x, xs) 등)이 있고, 그 우변에 **결과**(x * product(xs))가 있는 형태이다. 대상이 경우 문의 패턴과 **부합** 하면, 그 경우 문의 결과가 전체 부합 표현식의 결과가 된다. 만일 대상과 부합하는 패턴이 여러 개이면 스칼라는 처음으로 부합한 경우 문을 선택한다.

- List(1, 2, 3) match { case _ => 42 } 는 42가 된다. 이 예는 임의의 표현식과 부합하는 변수 패턴 _ 을 사용한다. _ 대신 x나 foo를 사용해도 되지만, 경우 문의 결과 안에서 그 값이 무시되는 변수를 나타낼 때에는 이처럼 _ 를 사용하는 것이 보통이다.
- List(1, 2, 3) match { case Cons(h, _ ) => h } 의 경과는 1이다. 이 예는 자료 생성자 패턴과 변수들을 함께 사용해서 대상의 부분 표현식을 **묶는다.**
- List(1, 2, 3) match { case Cons(_ , t) => t } 의 결과는 List(2, 3)이다.
- List(1, 2, 3) match { case Nil => 42 } 의 결과는 실행시점 MatchError 오류이다. MatchError는 부합 표현식의 경우 문 중 대상과 부합하는 것이 하나도 없음을 뜻한다.

패턴이 표현식과 부합하는지 판정하는 규칙은 무엇일까? 패턴은 3이나 \"hi\" 같은 **리터럴** 과 x나 xs 같이 소문자나 밑줄로 시작하는 식별자로 된 **변수**, 그리고 Cons(x, xs)나 Nil 같은 자료 생성자로 구성된다. 변수는 모든 것에 부합하는 반면 자료 생성자는 해당 형태의 값에만 부합한다. (패턴으로서의 NIl은 오직 Nil 값에만 부합하고, 패턴으로서의 Cons(h, t)나 Cons(x, xs)는 오직 Cons 값들에만 부합한다.) 패턴의 이러한 요소들을 임의로 내포될 수 있다. 예를 들어 Cons(x1, Cons(x2, Nil))와 Cons(y1, Cons(y2, Cons(y3, _ ))) 는 유효한 패턴들이다. 만일 패턴의 변수들을 대상의 부분 표현식들에 배정한 결과가 대상과 **구조적으로 동등**(structurally equivalent)하다면 패턴과 대상은 **부합** 한다. 대상과 부합한 패턴 경우 문(case 문)의 우변에서는 해당 지역 범위에서 그 변수들에 접근할 수 있다.

패턴 부합이 어떤 식으로 일어나는지 감을 잡고 싶다면 REPL에서 여러 가지로 시험해 보길 강력히 권장한다.

> **스칼라의 가변 인수 함수**<br/>
> object List의 apply 함수는 **가변 인수 함수***(variadic function)이다. 이는 이 함수가 A 형식의 인수를 0개 이상 받을(즉, 하나도 받지 않거나 하나 또는 여러 개를 받을) 수 있음을 뜻한다.<br/>
> ```
> def apply[A](as: A*): List[A] =
>   if (as.isEmpty) Nil
>   else Cons(as.head, apply(as.tail: _*))
> ```
> 자료 형식을 만들 때에는, 자료형식의 인스턴스를 편리하게 생성하기 위해 가변 인수 apply 메서드를 자료 형식의 동반 객체에 집어넣는 관례가 흔히 쓰인다. 그런 생성 삼수의 이름을 apply로 해서 동반 객체에 두면, List(1, 2, 3, 4)나 List("hi", "bye")처럼 임의의 개수의 인수들을 쉼표로 구분한 구문(이를 **목록 리터럴**[list literal] 또는 그냥 **리터럴** 구문이라고 부르기도 한다)으로 함수를 호출할 수 있다.<br/>
> 가변 인수 함수는 요소들의 순차열을 나타내는 Seq를 생성하고 전달하기 위한 작은 구문적 겉치레일 뿐이다. Seq는 스칼라의 컬렉션 라이브러리에 있는 하나의 인터페이스로, 목록이나 대기열, 벡터 같은 순차열 비슷한 자료구조들이 구현하도록 마련된 것이다. apply 안에서 인수 as는 Seq[A]에 묶인다. Seq[A]에는 head(첫 요소를 돌려줌)와 tail(첫 요소를 제외한 나머지 모든 요소를 돌려줌)이라는 함수가 있다. 특별한 형식 주해인 _ 는 Seq를 가변 인수 메서드에 전달할 수 있게 한다.

# 3. 함수적 자료구조의 자료 공유
자료가 불변이라면, 예를 들어 목록에 요소를 추가하거나 목록에서 요소를 제거하는 함수는 어떻게 작성해야 할까? 답은 간단하다. 기존 목록(이를테면 xs)의 앞에 1이라는 요소를 추가하려면 Cons(1, xs)라는 새 목록을 만들면 된다. 목록은 불변이므로, xs를 실제로 복사할 필요는 없다. 그냥 재사용하면 된다. 이를 **자료 공유**(data sharing)라고 부른다. 불변 자료를 공유하면 함수를 좀 더 효율적으로 구현할 수 있을 때가 많다. 이후의 코드가 지금 이 자료를 언제 어떻게 수정할지 걱정할 필요 없이, 항상 불변이 자료구조를 돌려주면 된다. 자료가 변하거나 깨지지 않도록 방어적으로 복사본을 만들어 둘 필요가 없는 것이다.

마찬가지로, 목록 mylist = Cons(x, xs)의 앞(첫) 요소를 제거하려 한다면 그냥 목록의 꼬리인 xs를 돌려주면 된다. 실질적인 제거는 일어나지 않는다. 원래의 목록은 여전히 사용 가능한 상태이다. 이를 두고 함수적 자료구조는 **영속적**(persistent)이라고 말한다. 이는 자료구조에 연산이 가해져도 기존의 참조들이 결코 변하지 않음을 뜻한다.

### 3.1 자료 공유의 효율성
자료 공유의 더욱 놀라운 예로, 다음 함수는 한 목록의 모든 요소를 다른 목록의 끝에 추가한다.

```
def append[A](a1: List[A], a2: List[A]): List[A] =
  a1 match {
    case Nil => a2
    case Cons(h, t) => Cons(h, append(t, a2))
  }
```

이 정의는 오직 첫 목록이 다 소진될 때까지만 값들을 복사함을 주의하기 바란다. 따라서 이 함수의 실행 시간과 메모리 사용량은 오직 a1의 길이에만 의존한다. 목록의 나머지는 그냥 a2를 가리킬 뿐이다. 만일 이 함수를 배열 두 개를 이용해서 구현한다면 두 배열의 모든 요소를 결과 배열에 복사해야 했을 것이다. 이 경우 불변이 연결 목록이 배열보다 훨씬 효율적이다.

단일 연결 목록의 구조 때문에, Cons의 tail을 치환할 때마다 반드시 이전의 모든 Cons 객체를 복사해야 한다(심지어 tail이 목록의 마지막 Cons 일 때에도). 서로 다른 연산들을 효율적으로 지원하는 순수 함수적 자료구조를 작성할 때의 관건은 자료 공유를 현명하게 활용하는 방법을 찾아내는 것이다. 그런 자료구조들의 작성 방법을 사용하는 것으로 만족하기로 하자. 이미 작성된 자료구조들이 어떤 것인지 맛볼 수 있는 예로, 스칼라 표준 라이브러리의 순수 함수적 순차열 구현인 Vector가 있다. 이 자료구조는 상수 시간 임의 접근, 갱신, head, tail, init, 그리고 상수 시간 요소 추가(순차열 앞과 뒤)를 지원한다.

### 3.2 고차 함수를 위한 형식 추론 개선
dropWhile 같은 고차 함수에는 흔히 익명 함수를 넘겨준다. 그럼 전형적인 예를 하나 보자.

```
def dropWhile[A](l: List[A], f: A => Boolean): List[A]
```

인수 f에 익명 함수를 지정해서 호출하기 위해서는 그 익명 함수의 인수(아래의 x)의 형식을 명시해야 한다.

```
val xs: List[Int] = List(1, 2, 3, 4, 5)
val ex1 = dropWhile(xs, (x: Int) => x < 4)
```

ex1의 값은 List(4, 5)이다.

x의 형식이 Int임을 명시적으로 표기해야 한다는 것은 다소 번거롭다. dropWhile의 첫 인수는 List[Int]이므로, 둘째 인수의 함수는 반드시 Int를 받아야 한다. 다음처럼 dropWhile의 인수들을 두 그룹으로 묶으면 스칼라가 그러한 사실을 추론할 수 있다.

```
def dropWhile[A](as: List[A])(f: A => Boolean): List[A] =
  as match {
    case Cons(h, t) if f(h) => dropWhile(t)(f)
    case _ => as
  }
```

이 버전의 dropWhile을 호출하는 구문은 dropWhile(xs)(f)의 형태이다. 즉, dropWhile(xs)는 하나의 함수를 돌려주며, 그 함수를 인수 f로 호출한다(다른 말로 하면 dropWhile은 커링되었다). 인수들을 이런 식으로 묶는 것은 스칼라의 형식 추론을 돕기 위한 것이다. 이제는 dropWhile을 다음과 같이 형식 주해 없이 호출할 수 있다.

```
val xs: List[Int] = List(1, 2, 3, 4, 5)
val ex1 = dropWhile(xs)(x => x < 4)
```

x의 형식을 명시적으로 지정하지 않았음을 주목하기 바란다.

좀 더 일반화하자면, 함수 정의에 여러 개의 인수 그룹이 존재하는 경우 형식 정보는 그 인수 그룹들을 따라 왼쪽에서 오른쪽으로 흘러간다. 지금 예에서 첫 인수 그룹은 dropWhile의 형식 매개변수 A를 Int로 고정시키므로, x => x < 4에 대한 형식 주해는 필요하지 않는다.

이처럼, 형식 추론이 최대로 일어나도록 함수 인수들을 적절한 순서의 여러 인수 목록들로 묶는 경우가 많다.

# 4. 목록에 대한 재귀와 고차 함수로의 일반화
sum과 product의 구현을 다시 살펴보자. product의 구현은 0.0의 점검을 위한 \'평가 단축(short-circuiting)\' 논리를 포함하지 않도록 조금 단순화되었다.

```
def sum(ints: List[Int]): Int = ints match {
  case Nil => 0
  case Cons(x, xs) => x + sum(xs)
}

def product(ds: List[Double]): Double = ds match {
  case Nil => 1.0
  case Cons(x, xs) => x * product(xs)
}
```

두 정의가 아주 비슷하다는 점에 주목하자. 둘은 각자 다른 형식을 다루지만(List[Int] 대신 List[Double]), 그 점을 제외할 때 유일한 차이는 빈 목록일 때의 반환값(sum은 0, product는 1.0)과 결과를 결합(조합)하는 데 쓰이는 연산(sum은 +, product는 \*)뿐이다. 이런 코드 중복을 발견했다면 부분 표현식들을 추출해서 함수 인수로 대체함으로써 코드를 일반화하는 것이 항상 가능하다. 그럼 직접 실행해 보자. 일반화된 함수는 빈 목록일 때의 반환값을 비지 않은 목록일 때 결과에 요소를 추가하는 함수를 인수로 받는다.

```
def foldRight[A, B](as: List[A], z: B)(f: (A, B) => B): B =
  as match {
    case Nil => z
    case Cons(x, xs) => f(x, foldRight(xs, z)(f))
  }

def sum2(ns, List[Int]) =
  foldRight(ns, 0)((x, y) => x + y)

def product2(ns: List[Double]) =
  foldRight(ns, 1.0)(_ * _)
```

foldRight는 하나의 요소 형식에만 특화되지 않았다. 그리고 일반화 과정에서 우리는 이 함수가 돌려주는 값이 목록의 요소와 같은 형식일 필요가 없다는 점도 알게 되었다. foldRight가 하는 일을 이런 식으로 설명할 수 있다: 이 함수는 다음에서 보듯이 목록의 생성자 Nil과 Cons를 z와 f로 치환한다.

```
Cons(1, Cons(2, Nil))
f   (1, f   (2, z  ))
```

그럼 구체적인 예로, foldRight(Cons(1, Cons(2, Cons(3, Nil))), 0)((x, y) => x + y)의 평가 과정을 **추적**(trace)해 보자. foldRight의 적용을 foldRight의 정의로 치환하는 과정을 되풀이하면 된다.

```
foldRight(Cons(1, Cons(2, Cons(3, Nil))), 0)((x, y) => x + y)
1 + foldRight(Cons(2, Cons(3, Nil)), 0)((x, y) => x + y)
1 + (2 + foldRight(Cons(3, Nil), 0)((x, y) => x + y))
1 + (2 + (3 + foldRight(Nil, 0)((x, y) => x + y)))
1 + (2 + (3 + 0)))
6
```

foldRight가 하나의 값으로 축약(collapsing)되려면 반드시 목록의 끝까지 순회(traversal)해야 함을 주목하기 바란다.

# 5. 트리
List는 소위 **대수적 자료 형식**(algebraic data type, ADT)이라고 부르는 것의 한 예일 뿐이다. (이 ADT를 다른 분야에서 말하는 **추상 자료 형식**[abstract data type]과 혼동하지 말기 바란다.) ADT는 하나 이상의 자료 생성자들로 이루어진 자료 형식일 뿐이다. 그러한 자료 생성자들은 각각 0개 이상의 인수를 받을 수 있다. 이러한 자료 형식을 해당 자료 생성자들의 **합**(sum) 또는 **합집합**(union)이라고 부르며, 각각의 자료 생성자는 해당 인수들의 **곱**(product)이라고 부른다. 대수적 자료 형식이라는 이름에 걸맞게 **대수학**(algebra)의 용어들이 쓰임을 주목하기 바란다.

대수적 자료 형식을 다른 자료구조의 정의에 사용할 수 있다. 그럼 간단한 이진 트리 자료구조를 정의해 보자.

```
sealed trait Tree[+A]
case class Left[A](value: A) extends Tree[A]
case class Branch[A](left: Tree[A], right: Tree[A]) extends Tree[A]
```

# Reference
- [Functional Programming in Scala](https://www.manning.com/books/functional-programming-in-scala)
