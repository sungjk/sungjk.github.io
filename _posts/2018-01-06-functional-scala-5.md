---
layout: entry
post-category: scala
title: Functional Programming in Scala 5
author: 김성중
author-email: ajax0615@gmail.com
description: Functional Programming in Scala의 6장(순수 함수적 상태)을 정리한 글입니다.
next_url: /2018/05/16/functional-scala-6.html
publish: true
---

# 1. 부수 효과를 이용한 난수 발생

```
// 현재 시스템 시간을 seed로 해서 새 난수 발생기를 만든다.
scala> val rng = new scala.util.Random

scala> rng.nextDouble
res1: Double = 0.9867076608154569

scala> rng.nextDouble
res2: Double = 0.8455696498024141

scala> rng.nextInt
res3: Int = -456352452

scala> rng.nextInt(10)  // 0 이상 9 이하의 정수 난수를 얻는다.
res4: Int = 4
```

scala.util.Random 안에서 일어나는 일을 알지 못한다고 해도, 난수 발생기(random number generator, RNG) 객체 rng에는 메서드 호출 때마다 갱신되는 어떤 내부 상태가 존재한다고 가정할 수 있다. 그렇지 않다면 nextInt나 nextDouble을 호출할 때마다 같은 값을 얻게 될 것이기 때문이다. **상태 갱신은 부수 효과로서 수행되므로 이 메서드들은 참조에 투명하지 않다.**

육면체 주사위 굴림으로 **반드시** 1 이상 6 이하의 정수를 돌려주는 메서드를 만들고 싶지만, 아래와 같이 작성하면 실제로 0 이상 5 이하의 값을 받게 된다. 이 메서드는 명세대로 작동하지 않지만, 그래도 여섯 번 중 다섯 번은 검사에 통과한다. 그리고 검사에 실패했을 때에는 실패 상황을 신뢰성 있게 재현할 수 있다면 이상적이다. 여기서 중요한 것은 이 구체적인 예가 아니라 전반적인 개념임을 주의하기 바란다.

```
def rollDie: Int = {
  val rng = new scala.util.Random
  rng.nextInt(6)  // 0 이상 5 이하의 난수를 돌려준다.
}
```

한 가지 해결책은 난수 발생기를 인수로 전달하게 하는 것이다. 그러면 실패한 검사를 재현해야 할 때, 당시에 쓰인 것과 동일한 난수 발생기를 전달하기만 하면 된다.

```
def rollDie(rng: scala.util.Random): Int = rng.nextInt(6)
```

이 또한 문제점이 있는데, \'동일한\' 발생기는 seed값과 기타 내부 상태가 동일해야 한다. **상태가 동일하다는 것은 발생기를 만든 후 그 메서드들이 원래의 발생기의 메서드 호출 횟수와 동일한 횟수로 호출되었음을 뜻한다.** 그러나 이를 보장하기는 아주 어렵다. 예를 들어 nextInt를 호출할 때마다 난수 발생기의 이전 상태가 파괴되기 때문이다.


# 2. 순수 함수적 난수 발생
참조 투명성을 되찾는 관건은 상태 갱신을 **명시적으로** 드러내는 것이다. 즉, **상태를 부수 효과로서 갱신하지 말고, 그냥 새 상태를 발생한 난수와 함께 돌려주면 된다.**

```
trait RNG {
  def nextInt: (Int, RNG)
}
```

이 인터페이스는 난수와 새 상태를 돌려주고 기존 상태는 수정하지 않는다. 이는 다음 상태를 **계산** 하는 관심사와 새 상태를 프로그램 나머지 부분에 **알려** 주는 관심사를 분리하는 것에 해당한다. 새 상태로 무엇을 할 것인지는 전적으로 nextInt 호출자의 마음이다. 그래도, 이 API의 사용자가 난수 발생기 자체의 구현에 대해서는 아무것도 모른다는 점에서, 상태는 여전히 발생기 안에 **캡슐화** 되어 있음을 주목하기 바란다.

```
case class SimpleRNG(seed: Long) extends RNG {
  def nextInt: (Int, RNG) = {
    val newSeed = (seed * 0x5DEECE66DL + 0xBL) & 0xFFFFFFFFFFFFL
    val nextRNG = SimpleRNG(newSeed)
    val n = (newSeed >>> 16).toInt  // 빈자리를 0으로 채우는 Right Shift
    (n, nextRNG)
  }
}

scala> val rng = SimpleRNG(42)
rng: SimpleRNG = SimpleRNG(42)

scala> val (n1, rng2) = rng.nextInt
n1: Int = 16159453
rng2: RNG = SimpleRNG(1059025964525)

scala> val (n2, rng3) = rng.nextInt
n2: Int = -1281479697
rng3: RNG = SimpleRNG(2352748563841)
```

이 예를 여러 번 되풀이해서 실행해도 항상 같은 값들이 나온다. 다시 말해서 이 API는 순수하다.


# 3. 상태 있는 API를 순수하게 만들기
겉보기에 상태 있는 API를 순수하게 만드는 문제와 그 해법(API가 실제로 뭔가를 변이하는 대신 다음 상태를 **계산** 하게 하는 것)이 난수 발생에만 국한된 것은 아니다. 이 문제는 자주 등장하며, 항상 동일한 방식으로 해결할 수 있다.

```
class Foo {
  private var s: FooState = ...
  def bar: Bar
  def baz: Int
}
```

bar와 baz가 각각 s를 변이한다고 하자. 한 상태에서 다음 상태로의 전이를 명시적으로 드러내는 과정을 기계적으로 진행해서 이 API를 순수 함수적 API로 변환할 수 있다.

```
trait Foo {
  def bar: (Bar, Foo)
  def baz: (Int, Foo)
}
```

이 패턴을 적용한다는 것은 계산된 다음 상태를 프로그램의 나머지 부분에 전달하는 책임을 호출자에게 지우는 것에 해당한다. 앞에서 본 순수 RNG 인터페이스에서 만일 이전의 RNG를 재사용한다면 이전에 발생한 것과 같은 값을 낸다. 예를 들어 다음 코드에서 i1과 i2는 같다.

```
def randomPair(rng: RNG): (Int, Int) = {
  val (i1, _) = rng.nextInt
  val (i2, _) = rng.nextInt
  (i1, i2)
}
```

서로 다른 두 수를 만들려면, 첫 nextInt 호출이 돌려준 RNG를 이용해서 둘째 Int를 발생해야 한다.

```
def randomPair(rng: RNG): ((Int, Int), RNG) = {
  val (i1, rng2) = rng.nextInt
  val (i2, rng3) = rng2.nextInt
  ((i1, i2), rng3)
}
```

# 4. 상태 동작을 위한 더 나은 API
앞의 구현들을 보면 모든 함수가 어떤 타입 A에 대해 RNG => (A, RNG) 형태의 타입을 사용한다는 공통의 패턴을 발견할 수 있다. 한 RNG 상태를 다른 RNG 상태로 변환한다는 점에서, 이런 종류의 함수를 **상태 동작**(state action) 또는 **상태 전이**(state transition)라고 부른다. 이 상태 동작들은 고차 함수인 **combinator** 를 이용해서 조합할 수 있다. 상태를 호출자가 직접 전달하는 것은 지루하고 반복적이므로, 조합기가 자동으로 한 동작에서 다른 동작으로 상태를 넘겨주게 하는 것이 바람직하다.

먼저 RNG 상태 동작 자료 형식에 대한 alias를 만들어 두자.

```
type Rand[+A] = RNG => (A, RNG)
```

Rand[A] 형식의 값을 \"무작위로 생성(발생)된 A\"라고 생각해도 되지만, 아주 정확한 것은 아니다. 이것은 하나의 상태 동작(특정 RNG)에 의존하며, 그것을 이용해서 A를 생성하고, RNG를 다른 동작이 이후에 사용할 수 있는 새로운 상태로 전이하는 하나의 프로그램이다.

```
val int: Rand[Int] = _.nextInt

// 간단한 형태의 RNG 상태 전이
def unit[A](a: A): Rand[A] = rng => (a, rng)

// 상태 동작의 출력을 변환하되 상태 자체는 수정하지 않는 map
def map[A,B](s: Rand[A])(f: A => B): Rand[B] =
  rng => {
    val (a, rng2) = s(rng)
    (f(a), rng2)
  }

// 0 이상, Int.MaxValue 이하의 난수 정수를 생성하는 함수
def nonNegativeInt(rng: RNG): (Int, RNG) = {
  val (i, r) = rng.nextInt
  (if (i < 0) -(i + 1) else i, r)
}

// 0보다 크거나 같고 2로 나누어지는 Int 구하기
def nonNegativeEven: Rand[Int] = map(nonNegativeInt)(i => i - i % 2)
```

### 4.1 상태 동작들의 조합

```
// 두 상태 동작 ra 및 rbb와 이들의 결과를 조합하는 함수 f를 받고 두 동작을 조합한 새 동작을 돌려준다.
def map2[A,B,C](ra: Rand[A], rb: Rand[B])(f: (A, B) => C): Rand[C] =
  rng => {
    val (a, r1) = ra(rng)
    val (b, r2) = rb(rng)
    (f(a, b), r2)
  }
```

map2를 한 번만 작성해 두면 이를 이용해서 임의의 RNG 상태 동작들을 조합할 수 있다. 에를 들어 A 타입의 값을 만드는 액션과 B 타입의 값을 만드는 액션이 있다면, 이 둘을 조합해서 A와 B의 쌍을 만드는 액션을 얻을 수 있다.

```
def both[A,B](ra: Rand[A], rb: Rand[B]): Rand[(A,B)] =
  map2(ra, rb)((_, _))

val randIntDouble: Rand[(Int, Double)] = both(int, double)
val randDoubleInt: Rand[(Double, Int)] = both(double, int)
```

### 4.2 내포된 상태 동작
다음 코드는 nonNegativeInt가 32비트 정수를 벗어나지 않는 n의 최대 배수보다 큰 수를 발생했다면 더 작은 수가 나오길 바라면서 **재시도** 하는 구현이다.

```
def nonNegativeLessThan(n: Int): Rand[Int] =
  map(nonNegativeInt) { i =>
    val mod = i % n
    if (i + (n-1) - mod >= 0) mod else nonNegativeLessThan(n)(???)
  }

<console> error: type mismatch;
 found   : (Int, RNG)
 required: Int
           if (i + (n-1) - mod >= 0) mod else nonNegativeLessThan(n)(???)
```

이 코드에서 nonNegativeLessThan(n)의 형식이 그 자리에 맞지 않는다는 문제가 있다. 이 함수는 Rand\[Int\]를 돌려주어야 하며, 이는 RNG 하나를 인수로 받는 **함수** 이다. 그런데 지금은 그런 함수가 없다. 이를 해결하려면 nonNegativeInt가 돌려준 RNG가 nonNegativeLessThan에 대한 재귀적 호출에 전달되도록 어떤 식으로든 호출들을 연결해야 한다.

```
// map을 사용하지 않고 명시적으로 전달
def nonNegativeLessThan(n: Int): Rand[Int] = { rng =>
  val (i, rng2) = nonNegativeInt(rng)
  val mod = i % n
  if (i + (n-1) - mod >= 0)
    (mod, rng2)
  else nonNegativeLessThan(n)(rng2)
}
```

이러한 전달을 처리해 주는 콤비네이터 flatMap을 이용하면 Rand[A]로 무작위 A를 발생하고 그 A의 값에 기초해서 Rand[B]를 선택할 수 있다.

```
def flatMap[A,B](f: Rand[A])(g: A => Rand[B]): Rand[B] =
  rng => {
    val (a, r1) = f(rng)
    g(a)(r1)
  }

// flatMap으로 재구현한 map
def _map[A,B](s: Rand[A])(f: A => B): Rand[B] =
  flatMap(s)(a => unit(f(a)))
```

# 5. 일반적 상태 동작 자료 형식
unit, map, map2, flatMap 등은 상태 동작에 대해 작용하는 범용 함수들(general-purpose functions)로, 상태의 구체적인 종류는 신경 쓰지 않는다. 이 함수에 다음과 같은 일반적인 시그니처를 부여할 수 있다.

```
def map[S,A,B](a: S => (A,S))(f: A => B): S => (B,S)
```

이제 임의의 상태를 처리할 수 있는, Rand보다 더 일반적인 타입을 생각해 보자.

```
type State[S,+A] = S => (A,S)
```

여기서 State는 **어떤 상태를 유지하는 계산**, 즉 **state action**(또는 **state transition**)를 나타낸다. 심지어 **명령문** 을 대표한다고 할 수도 있다.

```
// State를 함수로 감싼 독립적인 클래스 형태로 만들기
case class State[S,+A](run: S => (A,S))

// Rand를 State의 type alias로 만들
type Rand[A] = State[RNG, A]
```

# 6. 순수 함수적 명령식 프로그래밍
이전 절들에서 특정한 패턴을 따르는 함수들을 작성했다. State action을 실행하고, 그 결과를 val에 배정하고, 그 val을 사용하는 또 다른 State action을 실행하고, 그 결과를 또 다른 val에 배정하는 등으로 이어졌다. 그런데 그런 방식은 **명령식** 프로그래밍(imperative programming)과 아주 비슷하다.

명령식 프로그래밍 패러다임에서 하나의 프로그램은 일련의 명령문(statement)들로 이루어지며, 각 명령문은 프로그램의 상태를 수정할 수 있다. 앞에서 한 것이 바로 그런 방식이다. 단, 실제로는 명령문이 아니라 상태 동작 State이고, 이것은 사실 함수이다. 함수로서의 State action은 그냥 인수를 받음으로써 현재 프로그램 상태를 읽고, 그냥 값을 돌려줌으로써 프로그램 상태를 수정한다.

> **명령식 프로그래밍과 함수형 프로그래밍은 상극이 아닌가??** <br/>
> 절대 아니다. 함수형 프로그래밍은 단지 부수 효과가 없는 프로그래밍이다. 명령식 프로그래밍은 일부 프로그램 상태를 수정하는 명령문들로 프로그램을 만드는 것이고, 앞에서 보았듯이 부수 효과 없이 상태를 유지,관리하는 것도 전적으로 타당하다.<br/>
> 함수형 프로그래밍은 명령식 프로그램의 작성을 아주 잘 지원한다. 게다가 참조 투명성 덕분에 그런 프로그램을 등식적으로 추론할 수 있다는 추가적인 장점도 있다. 이는 제2부에서 자세히 다룬다.

map이나 map2 같은 콤비네이터를 사용해 한 명령문에서 다음 명령문으로의 상태 전이를 처리하는 flatMap까지 작성했고, 이 과정에서 명령식 프로그램의 성격이 많이 사라졌다.

```
val ns: Rand[List[Int]] =
  int.flatMap(x =>  // int는 하나의 정수 난수를 발생하는 Rand[Int] 타입의 값
    int.flatMap(y =>
      ints(x).map(xs => // ints(x)는 길이가 x인 목록
        xs.map(_ % y))))  // 목록의 모든 요소를 y로 나눈 나머지로 치환

// for-comprehension을 이용해서 명령식 스타일을 복구
for {
  x <- int
  y <- int
  xs <- ints(x)
} yield xs.map(_ % y)
```

아래쪽에 잇는 코드는 읽고 쓰기가 훨씬 쉽다. 이 코드가 어떤 상태를 유지하는 명령식 프로그램이라는 점이 코드의 형태 자체에 잘 반영되어 있기 때문이다. 그러나 이는 위쪽에 있는 코드와 **같은 코드** 이다.

for-comprehension을 활용해서 상태를 읽는 콤비네이터 get과 상태를 쓰는 콤비네이터 set만 있으면, 상태를 임의의 방식으로 수정하는 콤비네이터를 다음과 같이 구현할 수 있다.

```
def modift[S](f: S => S): State[S, Unit] = for {
  s <- get        // 현재 상태를 얻어서 s에 할당
  _ <- set(f(s))  // 새 상태를 s에 f를 적용한 결과로 설정
} yield ()

// 입력 상태를 전달하고 그것을 반환값으로 돌려준다.
def get[S]: State[S, S] = State(s => (s, s))

// 새 상태 s를 받아서,
// 그것을 새 상태로 치환하며, 의미 있는 값 대신 ()을 돌려준다.
def set[S](s: S): State[S, Unit] = State(_ => ((), s))
```

get과 set과 이전에 작성한 State 콤비네이터들(unit, map, map2, flatMap)만 있으면 어떤 종류의 State machine이라고 순수 함수적 방식으로 구현할 수 있다.

#### 요약
상태(State)와 상태 전이(state propagation)를 다루는 아이디어는 심플하다. 상태를 인수로 받고 새 상태를 결과와 함께 돌려주는 순수 함수를 사용한다.

# Reference
- [Functional Programming in Scala](https://www.manning.com/books/functional-programming-in-scala)
