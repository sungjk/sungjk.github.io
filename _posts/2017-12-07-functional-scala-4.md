---
layout: entry
post-category: scala
title: Functional Programming in Scala 4
author: 김성중
author-email: ajax0615@gmail.com
description: Functional Programming in Scala의 5장(엄격성과 나태성)을 정리한 글입니다.
publish: true
---

# 1. 엄격한 함수와 엄격하지 않은 함수
비엄격성은 함수의 한 속성이다. 함수가 엄격하지 않다는 것은 그 함수가 하나 이상의 인수들을 평가하지 **않을** 수도 있다는 뜻이다. 반면 **엄격한** 함수는 자신의 인수들을 항상 평가한다. 대부분의 프로그래밍 언어는 인수들을 모두 평가하는(엄격한) 함수만 지원한다. 스칼라에서도 특별히 다르게 지정하지 않는 한 모든 함수 정의는 엄격한 함수다.

```
def square(x: Double): Double = x * x
```

square(41.0 + 1.0)으로 호출하면, 함수 square는 엄격한 함수이므로 평가된 값이 42.0을 받게 된다. square(sys.error(\"failure\"))라고 호출하면 square가 실제로 작업을 수행하기도 전에 예외가 발생한다. sys.error(\"failure\")라는 표현식이 square의 본문에 진입하기 전에 평가되기 때문이다.

스칼라를 비롯한 여러 프로그래밍 언어에서 볼 수 있는 부울 함수 &&와 \|\|의 단축 평가는 엄격하지 않다. 이들을 인수의 평가가 생략될 수도 있는 함수라고 생각해도 틀리지 않다. && 함수는 Boolean 인수 두개를 받되 첫째 인수가 true일 때에만 둘째 인수를 평가한다.

```
scala> false && { println("!!"); true } // 아무것도 출력하지 않음
res0: Boolean = false
```

그리고 \|\|는 첫 인수가 fale일 때에만 둘째 인수를 평가한다.

```
scala> true || { println("!!"); false } // 역시 아무것도 출력하지 않음
res0: Boolean = true
```

스칼라의 if 제어 구조 역시 비엄격성의 예이다.

```
val result = if (input.isEmpty) sys.error("empty input") else input
```

이 if 함수는 자신의 모든 인수를 평가하지는 않는다는 점에서 비엄격 함수이다. 좀 더 정확히 말하면, if 함수는 조건 매개변수에 대해서는 엄격하다. 두 분기 중 어떤 것을 취할 것인지 결정하려면 조건을 반드시 평가해야 하기 때문이다. 그러나 true와 false 두 분기에 대해서는 엄격하지 않다. 둘 중 하나만 조건에 따라 평가되기 때문이다.

스칼라에서는 인수들 중 일부가 평가되지 않아도 호출이 성립하는 비엄격 함수를 작성할 수 있다.

```
def if2[A](cond: Boolean, onTrue: () => A, onFalse: () => A): A =
  if (cond) onTrue() false onFlase()

if2(a < 22,
  () => println("a"), // () => A를 생성하는 함수 리터럴 구문
  () => println("b")
)
```

() => A 는 인수를 받지 않고 A를 돌려주는 함수이다. 일반적으로, 표현식의 평가되지 않은 형태를 **성크**(thunk)라고 부른다. 나중에 그 성크의 표현식을 평가해서 결과를 내도록 **강제** 할 수 있다. onTrue()나 onFalse()에서처럼 빈 인수 목록을 지정해서 함수를 호출하면 된다.

전반적으로 이러한 구문은 각각의 비엄격 매개변수에 대해 인수가 없는 함수를 넘겨주고, 함수 본문에서는 그 함수를 명시적으로 호출해서 결과를 얻는다는 작동 방식을 명확하게 표현한다. 스칼라는 이보다도 더 깔끔한 구문을 제공한다.

```
def if2[A](cond: Boolean, onTrue: => A, onFalse: => A): A =
  if (cond) onTrue() false onFlase()
```

평가되지 않은 채로 전달할 인수에서 그 형식 바로 앞에 화살표 => 만 붙인다. 그냥 보통의 함수 호출 구문을 사용하면 스칼라가 성크 안의 표현식을 알아서 감싸준다.

```
scala> if2(false, sys.error("fail"), 3)
res2: Int = 3
```

두 구문 모두에서, 평가되지 않은 채로 함수에 전달되는 인수는 함수의 본문에서 참조된 장소마다 한 번씩 평가된다. 즉, 스칼라는 인수 평가의 결과를 캐싱하지 않는다(기본적으로는).

```
scala> def maybeTwice(b: Boolean, i: => Int) = if (b) i + i else 0
maybeTwice: (b: Boolean, i: => Int)Int

scala> val x = maybeTwice(true, { println("hi"); 1+41 })
hi
hi
x: Int = 84
```

여기서 i는 maybeTwice의 본문 안에서 두 번 참조된다. 참조될 때마다 평가된다는 점이 확실히 드러나도록, 위의 예에서는 결과 42를 돌려주기 전에 하나의 부수 효과로서 hi를 출력하는 {println(\"hi\"); 1+41} 블록을 i로서 전달했다. 만일 캐싱을 적용해서 결과를 단 한 번만 평가되게 하려면 다음과 같이 lazy 키워드를 이용하면 된다.

```
scala> def maybeTwice2(b: Boolean, i: => Int) = {
    |     lazy val j = i
    |     if (b) j+j else 0
    |  }
maybeTwice: (b: Boolean, i: => Int)Int

scala> val x = maybeTwice2(true, { println("hi"); 1+41 })
hi
x: Int = 84
```

val 선언에서 lazy 키워드를 추가하면 스칼라는 lazy val 선언 우변의 평가를 우변이 처음 참조될 때까지 지연한다. 또한 평가 결과를 캐시에 담아 두고, 이후의 참조에서는 평가를 되풀이하지 않는다.

어법에 관해 이야기하자면, 스칼라에서 비엄격 함수의 인수는 **값으로**(by value) 전달되는 것이 아니라 **이름으로**(by name) 전달된다.

> **엄격성의 공식적인 정의**<br/>
> 어떤 표현식의 평가가 무한히 실행되면, 또는 한정된 값을 돌려주지 않고 오류를 던진다면, 그러한 표현식을 일컬어 **종료되지**(terminate) 않는 표현식 또는 **바닥**(bottom)으로 평가되는 표현식이라고 부른다. 만일 바닥으로 평가되는 모든 x에 대해 표현식 f(x)가 바닥으로 평가되면, 그러한 함수 f는 **엄격한** 함수이다.

# 2. 확장 예제: 게으른 목록
스칼라에서 나태성을 활용하는 한 예로, 함수적 프로그램의 효율성과 모듈성의 **게으른 목록**(lazy list) 또는 **스트림**(stream)을 이용해서 개선하는 방법을 살펴본다.

```
sealed trait Stream[+A]
case object Empty extends Stream[Nothing]
case class Cons[+A](h: () => A, t: () => Stream[A]) extends Stream[A]
object Stream {
  // 비지 않은 스트림의 생성을 위한 똑똑한 생성자
  def cons[A](hd: => A, tl: => Stream[A]): Stream[A] = {
    // 평가 반복을 피하기 위해 head와 tail을 게으른 값으로 캐싱한다.
    lazy val head = hd
    lazy val tail = tl
    Cons(() => head, () => tail)
  }

  // 특정 형식의 빈 스트림을 생성하기 위한 똑똑한 생성자.
  def empty[A]: Stream[A] = Empty

  // 여러 요소로 이루어진 Stream의 생성을 위한 편의용 가변 인수 메서드.
  def apply[A](as: A*): Stream[A] =
    if (as.isEmpty) empty else cons(as.head, apply(as.tail: _*))
}
```

이 형식은 이전의 List 목록과 거의 비슷하다. 단, Cons 자료 생성자가 보통의 엄격한 값이 아니라 명시적인 성크(() => A와 () => Stream[A])를 받는다는 점이 다르다. Stream을 조사하거나 순회하려면 이전에 if2의 정의에서 그랬듯이 이 성크들의 평가를 강제해야 한다.

```
def headOption: Option[A] = this match {
  case Empty => None
  case Cons(h, t) => Some(h())  // h()를 이용해서 성크 h를 명시적으로 강제한다.
}
```

h()를 이용해서 h를 명시적으로 강제해야 하긴 하지만, 그 외에는 코드가 List에서와 동일하게 작동함을 주목하기 바란다. 그러나 잠시 후에 보겠지만, 실제로 요구된 부분만 평가하는(Cons의 꼬리는 평가하지 않는다) Stream의 이러한 능력은 유용하다.

### 2.1 스트림의 메모화를 통한 재계산 피하기
Cons 노드가 일단 강제되었다면 그 값을 캐싱해 두는 것이 바람직하다. 예를 들어 다음과 같이 Cons 자료 생성자를 직접 사용한다면 expensive(x)가 두 번 계산된다.

```
val x = Cons(() => expensive(x), tl)
val h1 = x.headOption
val h2 = x.headOption
```

일반적으로 이런 문제는 일반적인 생성자와는 조금 다른 서명을 제공하는 자료 형식을 생성하는 함수인 **똑똑한**(smart) 생성자를 이용해서 피한다. 대체로 이런 똑똑한 생성자의 이름으로는 해당 자료 생성자의 첫 글자를 소문자로 바꾼 것을 사용하는 것이 관례이다. 생성자 cons는 Cons의 머리와 꼬리를 이름으로 전달받아서 메모화(memoization)를 수행한다. 이렇게 하면 성크는 오직 한 번만(처음으로 강제될 때) 평가되고 이후의 강제에서는 캐싱된 lazy val이 수행된다.

empty 똑똑한 생성자는 그냥 Empty를 돌려주나, Empty의 형식이 Stream[A]로 지정되어 있음을 주목하기 바란다. 경우에 따라서는 이 형식이 형식 추론에 더 적합하다(하위형식화). Stream.apply에서도 인수들을 cons 안에서 성크로 감싸는 작업은 스칼라가 처리해 준다. 따라서 as.head와 apply(as.tail: \_*) 표현식은 Stream을 강제할 때까지는 평가되지 않는다.

# 3. 프로그램 서술과 평가의 분리
함수형 프로그래밍의 주된 주제 중 하나는 **관심사의 분리**(separation of concerns)이다. 한 예로, 계산의 서술(description)을 그 계산의 실제 실행과 분리하는 것이 권장된다. 예를 들어 일급 함수는 일부 계산을 자신의 본문에 담고 있으나, 그 계산은 오직 인수들이 전달되어야 실행된다. 또한, Option은 오류가 발생했다는 사실을 담고 있을 뿐, 오류에 대해 무엇을 수행할 것인가는 그와는 분리된 관심사이다. 그리고 Stream을 이용하면 요소들의 순차열을 생성하는 계산을 구축하되 계산 단계들의 실행은 실제로 요소가 필요할 때까지 미룰 수 있다.

좀 더 일반화해서 말하면, 나태성을 통해서 표현식의 서술을 그 표현식의 평가와 분리할 수 있다. 여기서 표현식의 일부만 평가할 수 있다는 강력한 능력이 프로그래머에게 부여된다. 한 예로 Stream의 요소들 중 Boolean 함수와 부합하는 것이 하나라도 있는지 점검하는 함수 exists를 생각해 보자.

```
def exists(p: A => Boolean): Boolean = this match {
  case Cons(h, t) => p(h()) || t().exists(p)
  case _ => false
}
```

\|\|는 둘째 인수에 대해 엄격하지 않다. 만일 p(h())가 true를 돌려준다면 exists는 스트림을 더 훑지 않고 true를 돌려준다. 또한 스트림의 꼬리가 lazy val이라는 점도 기억하기 바란다. 따라서 그런 경우 스트림 순회가 일찍 종료될 뿐만 아니라, 스트림의 꼬리가 전혀 평가되지 않는다. 즉, 꼬리를 생성하도록 되어 있는 코드가 실제로 수행되는 일은 없다.

# Reference
- [Functional Programming in Scala](https://www.manning.com/books/functional-programming-in-scala)
