---
layout: entry
post-category: scala
title: 간단한 Monad Transformers 만들어보기
author: 김성중
author-email: ajax0615@gmail.com
description: Future[Option[T]] 타입을 Monad Transformers로 처리하는 방법에 대해서 알아봅니다.
keywords: 스칼라, 모나드, Scala, Monad
publish: true
---

# Future
스칼라로 비동기 코드를 작성하고자 하면 가장 먼저 접하는 녀석이 **Future** 입니다. 자바에도 Future(Java 5)가 있지만 스칼라와 아주 다릅니다. 두 퓨쳐 모두 비동기적인 계산의 결과를 표현하지만, 자바의 퓨처에서는 블로킹(blocking) 방식의 get을 사용해 결과를 얻어와야 합니다. 반면, 스칼라의 Future에서는 계산 결과의 완료 여부와 관계없이 결과 값에 대해 변환(transform)을 수행할 수 있습니다. 각 변환은 원래의 Future를 지정한 함수에 따라 변환한 결과를 비동기적으로 담은 것을 표현하는 새로운 Future를 만듭니다. 여기서 실제로 계산을 수행하는 스레드(thread)는 암시적으로 제공되는 실행 컨텍스트(execution context)를 사용해 결정됩니다. 이런 방식을 사용하면 불변값에 대한 일련의 변환으로 비동기 계산을 표현할 수 있고, 공유 메모리나 락(lock)에 대해 신경을 쓸 필요가 없어서 쉽게 동시성을 지원할 수 있습니다.

---

# Monad
Future에 대해 좀 더 공부하다 보면 Monad와 같은 단어를 접하게 됩니다. 그리고 Monad에 대한 설명을 찾아보면 다음과 같은 그림을 수도 없이 보게 됩니다(실제로 엄청 도움됨).

![Monads](/images/2019/01/27/monads.png "Monads"){: .center-image }
<center>Monads [1]</center>

간단히 말하자면 Monad는 어떤 값을 감싸는 Wrapper인데, 모든 Wrapper들이 Monad가 되는 것이 아니라 아래와 같은 3가지 법칙을 만족해야 합니다.

```java
1. Associativity
m flatMap f flatMap g == m flatMap (x => f(x) flatMap g)

2. Left unit
unit(x) flatMap f == f(x)

3. Right unit
m flatMap unit == m
```

그리고 이 Wrapper는 다음과 같은 2가지 기능을 제공합니다.

- identity (하스켈: return, 스칼라: unit)
- bind (하스켈: »=, 스칼라: flatMap)

identity는 특정 값을 감싸는 역할을 하고, bind는 감싼 값을 꺼내서 변형(transform)하고 그 값을 다시 감싸서 반환하는 역할을 합니다. Java 8이나 Rx를 경험해보신 분들이라면 CompletableFuture, Observable이 모나드이기 때문에 이를 생각하면서 공부하시면 이해하기가 좀 더 수월할거에요. 더 자세한 설명은 [Javascript Functor, Applicative, Monads in pictures](https://medium.com/@tzehsiang/javascript-functor-applicative-monads-in-pictures-b567c6415221), [Functors, Applicatives, And Monads In Pictures](http://adit.io/posts/2013-04-17-functors,_applicatives,_and_monads_in_pictures.html), [Functor and monad examples in plain Java](https://gist.github.com/jooyunghan/e14f426839454063d98454581b204452), [Why do we need monads?](https://stackoverflow.com/a/28139260) 등을 참고해주세요!!

---

# Why use Monad Transformers?
Future만 사용하면 아무런 문제가 없지만 개발을 하다보면 Future[Option[T]] 타입을 다뤄야할 때가 엄청 많습니다. 시스템에 userId에 해당하는 유저가 존재한다면 Future.Some(Int)를 리턴할 것이고, 그렇지 않으면 Future.None을 리턴할 것입니다.

```java
def getUserAge(userId: UserId): Future[Option[Int]]
```

아직까지는 괜찮습니다. 하지만 리턴될 결과값에 다음과 같이 맵핑을 하고 싶다면 먼저 Future에 맵핑을 하고, 그다음 Option에도 맵핑을 해야합니다.

```java
getUserAge(1).map(ageOpt => ageOpt.map(age => age + 1))
```

약간 지저분하지만 아직까지도 봐줄만 합니다. 하지만 getUserAge 같은 Future[Option[T]] 타입 N개를 처리해야 할 때는 어떻게 해야할까요? 일단 먼저 생각나는 방법으로 처리해보겠습니다.

```java
val ageOpt1 = getUserAge(1)
val ageOpt2 = getUserAge(2)

for {
    age1 <- ageOpt1
    age2 <- ageOpt2
} yield {
    age1 + age2 // compile error!
}
```

for-comprehension으로 처리해서 코드는 괜찮아 보이지만, 이 코드는 컴파일되지 않습니다. 이 문제를 해결하려면 yield 문안에 Option에 대한 처리를 추가해주어야 합니다.

```java
val ageOptFuture1 = getUserAge(1)
val ageOptFuture2 = getUserAge(2)

for {
    ageOpt1 <- ageOptFuture1
    ageOpt2 <- ageOptFuture2
} yield {
    for {
        age1 <- ageOpt1
        age2 <- ageOpt2
    } yield {
        age1 + age2
    }
}
```

이런 중첩된 코드를 깔끔하게 해줄 수 있는게 바로 Monad Transformers의 역할입니다. 스칼라에는 [Scalaz](https://scalaz.github.io/7/)나 [Cats](https://typelevel.org/cats/) 라이브러리가 이러한 Transformers를 구현체로 제공하고 있습니다. 여기서는 이 라이브러리를 사용하지 않고 간단한 Transformers를 만들어 보겠습니다.

---

# Option Transformer
Monad Transformers는 모나드에 적용할 변환기인데, 사실 스칼라의 Future는 Monad의 3가지 법칙 중 결합법칙을 만족하고 있지 않아서 모나드가 아니라 모나드의 일종인 Monadic이라는 표현을 쓰고 있습니다(참고: [Is Future in Scala a monad?
Ask Question](https://stackoverflow.com/a/27467037)). 그럼 일단 Monad를 흉내낼만한 trait을 하나 만들어보겠습니다.

```java
trait Monad[T[_]] {
    def map[A, B](value: T[A])(f: A => B): T[B]

    def flatMap[A, B](value: T[A])(f: A => T[B]): T[B]

    def pure[A](x: A): T[A]
}
```

여기서 Monad는 타입 파라미터로 T[\_]를 받는 타입 생성자이고, map, flatMap, pure 함수를 가지고 있습니다. 그럼 이 타입 생성자를 가지고 나만의 FutureMonad를 구현해보겠습니다. Future와 동일하게 맵핑이 가능해야 하므로 trait에 있는 map, flatMap, pure를 구현해줍니다.

```java
implicit val futureMonad = new Monad[Future] {
    def map[A, B](value: Future[A])(f: (A) => B) = value.map(f)

    def flatMap[A, B](value: Future[A])(f: (A) => Future[B]) = value.flatMap(f)

    def pure[A](x: A): Future[A] = Future(x)
}
```

FutureMonad는 만들었으니 이제 Option에 대한 Transformer를 만들어보겠습니다. OptionTransformer class는 T 타입으로 감싼 Option과 하나의 Monad 인스턴스(타입 파라미터를 T로 받은)를 생성자의 값으로 받습니다. 그리고 for-comprehension에 사용될 수 있도록 map, flatMap을 구현해줍니다.

```java
case class OptionTransformer[T[_], A](value: T[Option[A]])(implicit m: Monad[T]) {
    def map[B](f: A => B): OptionTransformer[T, B] =
        OptionTransformer[T, B](m.map(value)(_.map(f)))

    def flatMap[B](f: A => OptionTransformer[T, B]): OptionTransformer[T, B] = {
        val result: T[Option[B]] = m.flatMap(value)(a => a.map(b => f(b).value).getOrElse(m.pure(None)))
        OptionTransformer[T, B](result)
    }
}
```

OptionTransformer의 map은 먼저 Monad 인스턴스에 대해 map을 호출하고, 그다음 map의 인자로 넘겨준 function을 적용해 map을 호출합니다(이건 쉬움). flatMap은 좀 어려우니 천천히 살펴보겠습니다. Monad flatMap의 정의를 다시 생각해보면 적용할 함수(f: A => T[B])를 인자로 받아 T[A]를 T[B]로 변형시킵니다.

```java
def flatMap[A, B](value: T[A])(f: A => T[B]): T[B]
```

flatMap의 value는 OptionTransformer의 생성자로 주어진 값을 넘겨주고, 적용할 함수(f) 자리에는 `a => a.map(b => f(b).value).getOrElse(m.pure(None))` 를 넘겨주는데요. flatMap의 인자로 받은 함수가 호출되면 `a.map(b => f(b).value)` 값이 나오게 되는데 이 값은 `Option[T[Option[B]]]` 타입을 가지게 됩니다. 그리고 이 타입에서 값을 추출하거나 값이 없으면 None을 리턴하기 위해 FutureMonad에 있는 pure 함수에 None 값을 넣어 getOrElse를 적용합니다.

이제 Future[Option[T]] 타입을 위에서 만든 OptionTransformer로 감싸면 Future 안에 있는 Option까지 자동으로 처리할 수 있습니다.

```java
val ageOpt1 = OptionTransformer(getUserAge(1))
val ageOpt2 = OptionTransformer(getUserAge(2))

val sum = for {
    age1 <- ageOpt1
    age2 <- ageOpt2
} yield {
    age1 + age2
}
```

---

# 끝으로
함수형 프로그래밍에서는 반복되는 작업들을 최소화하기 위해 함수 합성(function composition)을 효과적으로 할 줄 알아야 한다고 생각합니다. 그리고 이러한 방법 중 하나가 위에서 작성한 OptionTransformer 같은 것을 만드는 것인데 직접 구현해서 사용하는 것보다 Scalaz나 Cats 라이브러리에서 지원하는 강력한 타입 클래스들을 사용하시는 것을 추천드립니다.

피드백이나 질문은 <a href="mailto:ajax0615gmail.com">이메일</a>로 주시면 최선을 다해 답변드리겠습니다. 짧지 않은 글을 읽어주셔서 감사드립니다.

---

# Reference
- [1] [Javascript Functor, Applicative, Monads in pictures](https://medium.com/@tzehsiang/javascript-functor-applicative-monads-in-pictures-b567c6415221)
