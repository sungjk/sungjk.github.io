---
layout: entry
title: Tagless Final in Scala Example
author: 김성중
author-email: ajax0615@gmail.com
keywords: scala
publish: true
---

- 사용자로서 특정 알고리즘으로부터 추천을 받기 원하는데 만약 추천이 없거나 어떤 알고리즘을 사용해야 하는지 지정하는 것을 잊어버렸다면, 시스템에서 제일 나은 알고리즘으로부터 디폴트 추천을 받고 싶다.
- 사용자로서 요청한 추천 알고리즘이 틀리면 메시지를 받고 싶다.
- 사용자로서 제한된 수의 추천을 받을 수 있기를 원한다.

```java
def getUser(userId: Option[Int]): Option[Int] =
  userId.filter(id => users.exists(_.userId == id))

def getAlgorithm(recommenderId: Option[String]]): Option[Algorithm] =
  recommenderId.orElse(algoDefault).flatMap(algorithms.get(_))

def program(userId: Option[Int], recommenderId: Option[String] = None, limit: Option[Int] = None): Unit = {
  val user = getUser(userId)
  val algorithm = getAlgorithm(recommenderId)
  val result = algorithm.flatMap(_.run(UserId(user.get))).orElse(Some(emptyRecs(user.get)))
  val limitFilter = limit.getOrElse(limitDefault)
  val resultFiltered = result.map(_.copy(recs = recs.slice(0, limitFilter).toList))
  resultFiltered match {
    case Some(recs) => {
      println(s"\nRecommnedations for userId ${recs.userId}...")
      println(s"Algorithm ${algorithm.get.name}")
      println(s"Recs: ${recs.recs}")
    }
    case None => println(s"No recommendations found for userId $userId")
  }
}
```

이런 명령형(imperative) 코드 스타일도 괜찮지만, 모두 Option[+A] 타입을 다루고 있기에 이 코드를 for-comprehension syntax로 변경하면 다음과 같다.

```java
def program(userId: Option[Int], recommenderId: Option[String] = None, limit: Option[Int] = None): Unit = {
  val result = for {
    user <- getUser(userId)
    algorithm <- getAlgorithm(recommenderId)
    result <- algorithm.run(UserId(user))
    limitFilter <- limit.getOrElse(limitDefault)
    resultFiltered <- result.copy(recs = recs.slice(0, limitFilter).toList)
  } yield Result(algorithm, resultFiltered)

  result match {
    case Some(algoRes) => {
      println(s"Recommnedations for userId ${algoRes.recs.userId}...")
      println(s"Algorithm ${algoRes.algorithm.get.name}")
      println(s"Recs: ${algoRes.recs.recs}")
    }
    case None => println(s"No recommendations found for userId $userId")
  }
}
```

program은 2가지 함수로 나눌 수 있다.

- **getRecommendations**: program 로직을 다루는 for-comprehension
- **printResults**: 결과나 에러를 유저에게 출력

```java
def getRecommendations(userId: Option[Int], recommenderId: Option[String] = None, limit: Option[Int] = None): Option[Result] = {
  for {
    user <- getUser(userId)
    algorithm <- getAlgorithm(recommenderId)
    result <- executeAlgorithm(user, algorithm)
    limitFilter <- limit.getOrElse(limitDefault)
    resultFiltered <- filterResults(result, limitFilter)
  } yield Result(algorithm, resultFiltered)
}

def printResults(userId: Option[Int], result: Option[Result]): Unit = {
  result.fold(println(s"No recommendations found for userId $userId"))(algoRes => {
    println(s"Recommnedations for userId ${algoRes.recs.userId}...")
    println(s"Algorithm ${algoRes.algorithm.get.name}")
    println(s"Recs: ${algoRes.recs.recs}")
  })
}

private def getUser(userId: Option[Int]): Option[UserId] =
  userId.filter(user => users.exists(_.userId == user)).map(UserId)

private def getAlgorithm(recommenderId: Option[String]): Option[Algorithm] =
  recommenderId.orElse(algoDefault).flatMap(algorithms.get(_))

private def executeAlgorithm(user: UserId, algorithm: Algorithm): Option[UserRec] =
  algorithm.run(user)

private def filterResults(result: UserRec, limitFilter: Int): Option[UserRec] =
  Some(result.copy(recs = recs.slice(0, limitFilter).toList))
```

명령형 코드 스타일이 보기 좋게 바꼈다. 하지만 개인적으로 함수형 프로그래밍(Functional Programming) 스타일을 좋아하기 때문에 이 코드를 **Tagless Final Encoding** 으로 코드를 리팩토링 해보자!!

---

# Tagless Final Encoding
**Tagless Final Encoding** 은 Scala, Haskell, OCaml 같은 **Type Functional Language** 에서 **DSL**(Domain Specific Language)을 임베딩하기 위해 사용하는 방법이다.

- **Algebras**: 구조체에서 연산의 집합
- **Interpreter**: 특정 타입


### Algebras
그럼 먼저 도메인과 관련된 문제를 해결하기 위해 연산을 정의할 필요가 있다. 여기서 연산을 정의한다는 행위가 Algebras를 정의하는 것이라고 보면 된다. 명령형 프로그래밍에 익숙하다면 이러한 연산을 정의하는데 어렵지 않을 것이다.

```java
def getUser(...)
def getAlgorithm(...)
def executeAlgorithm(...)
def filter(...)
```

그리고나서 동작하는 구조에 따라 서로 다른 Algebra로 묶어준다.

- User: 유저를 다루는 연산
- Algorithm: 알고리즘을 다루는 연산
- Filter: 결과를 필터링하는 연산

Algebra는 연산에 대한 정의일 뿐이므로 추상화하기 위해 *trait* 을 사용할 것이다.

```java
object algebras {
  trait UserRepo[F[_]] {
    def getUser(userId: Option[Int]): F[UserId]
  }

  object UserRepo {
    def apply[F[_]](implicit userRepo: UserRepo[F]): UserRepo[F] = userRepo
  }

  trait Filter[F[_]] {
    def filter(userRec: UserRec, limit: Int): F[UserRec]
  }

  object Filter {
    def apply[F[_]](implicit filter: Filter[F]): Filter[F] = filter
  }

  trait AlgorithmRepo[F[_]] {
    def getAlgorithm(recommenderId: Option[String]): F[Algorithm]
    def execute(algo: Algorithm, userId: UserId): F[UserRec]
  }

  object AlgorithmRepo {
    def apply[F[_]](implicit algoRepo: AlgorithmRepo[F]): AlgorithmRepo[F] = algoRepo
  }
}
```

각 Interpreter에서 사용될 컨테이너 구조를 추상화하기 위해 **Higher-Kinded Types** 파라미터 (F[\_]) 를 정의하였다. *Higher-Kinded Type* 이나 *Type Constructor* 는 타입 파라미터를 기반으로 새로운 타입을 만드는 타입이다. 예를 들어, Option[+A]는 하나의 타입을 받는 타입 생성자(Type Constructor)이다. String이 주어지면 최종 타입인 Option[String]가 만들어진다. 직접 Scala console에서 *:kind* 명령어로 확인해볼 수 있다.

![:kind](/images/2020/05/09/kind-command.png ":kind"){: .center-image }

그리고 Companion Object Trait의 생성자를 사용하여 implicit value를 얻을 수 있게끔 Companion objects를 추가하였다. 이런 방법을 사용하면 Companion objects를 호출하거나 함수를 호출하지 않고도 유틸리티 함수를 추가할 수 있다.

```java
def getUser[F[_]: UserRepo](userId: Option[Int]): F[UserId] =
  UserRepo[F].getUser(userId)

def filter[F[_]: Filter](userRec: UserRec, limit: Int): F[UserRec] =
  Filter[F].filter(userRec, limit)

def getAlgorithm[F[_]: AlgorithmRepo](recommenderId: Option[String]): F[Algorithm] =
  AlgorithmRepo[F].getAlgorithm(recommenderId)

def execute[F[_]: AlgorithmRepo](algo: Algorithm, userId: UserId): F[UserRec] =
  AlgorithmRepo[F].execute(algo, userId)
```

이제 작성한 Algebras를 getRecommendations에서 사용해보자. 이를 위해 컴파일러가 컨텍스트로부터 implicit values를 추론할 수 있도록 [Context Bounds](https://docs.scala-lang.org/tutorials/FAQ/context-bounds.html)를 사용한다.

```java
def getRecommendations[F[_]: UserRepo: AlgorithmRepo: Filter](userId: Option[Int], recommenderId: Option[String], limit: Option[Int]): Option[Result] = {
  for {
    user <- getUser(userId)
    algorithm <- getAlgorithm(recommenderId)
    result <- executeAlgorithm(user, algorithm)
    limitFilter <- limit.getOrElse(limitDefault)
    resultFiltered <- filterResults(result, limitFilter)
  } yield Result(algorithm, resultFiltered)
}
```

### Algebra's Interpreter
Algebra를 실제로 구현한 Interpreter가 적어도 하나는 필요하다. 모든 곳에서 Option[+A]를 다루고 있기 때문에 Interpreter 또한 Option[+A] 타입에 있어야 한다.

```java
object Interpreter {
  import algebras._

  implicit object UserRepoOption extends UserRepo[Option] {
    override def getUser(userId: Option[Int]): Option[UserId] =
      userId.filter(id => users.exists(_.userId == id)).map(UserId)
  }

  implicit object AlgorithmRepoOption extends AlgorithmRepo[Option] {
    override def getAlgorithm(recommenderId: Option[String]): Option[Algorithm] =
      recommenderId.orElse(algoDefault).flatMap(algorithms.get(_))

    override def execute(algo: Algorithm, userId: UserId): Option[UserRec] =
      algo.run(userId)
  }

  implicit object FilterOption extends Filter[Option] {
    override def filter(userRec: UserRec, limit: Int): Option[UserRec] =
      Some(userRec.copy(recs = recs.slice(0, limit).toList))
  }
}
```

컴파일러가 컨텍스트에서 implicit 값을 가져오도록 유추할 수 있게 해줘야 한다.

```java
def program(userId: Option[Int], recommenderId: Option[String] = None, limit: Option[Int] = None): Unit = {
  import Interpreter._

  val result: Option[Result] = getRecommendations[Option](userId, recommenderId, limit)
  printResults(userId, result)
}
```

**Higher-Kinded Type** 이나 **Type Constructor** 로 Option[+A]를 사용하여 getRecommendations를 호출하고 있죠? getRecommendations에서 F[\_]로 UserRepo와 AlgorithmRepo와 Filter에 의해 Context Bounds 됨을 표시하고, 컴파일러는 F가 Option[+A]인 각 Algebra에 대해 implicit value를 찾아야 한다.

### Program Syntax
getRecommendations를 **for-comprehension** 문법으로 바꿔보자.

```java
// Algebra에서는 다음과 같이 바꾼다:
trait Program[F[_]] {
  def flatMap[A, B](fa: F[A], afb: A => F[B]): F[B]
  def map[A, B](fa: F[A], ab: A => B): F[B]
}

object Program {
  def apply[F[_]](implicit F: Program[F]): Program[F] = F
}

implicit class ProgramSyntax[F[_], A](fa: F[A]) {
  def map[B](f: A => B)(implicit F: Program[F]): F[B] = F.map(fa, f)
  def flatMap[B](afb: A => F[B])(implicit F: Program[F]): F[B] = F.flatMap(fa, afb)
}


// Interpreter에서는 Option[+A] 바인드를 위해 다음과 같이 바꾼다:
implicit object ProgramOption extends Program[Option] {
  override def flatMap[A, B](fa: Option[A], afb: A => Option[B]): Option[B] = fa.flatMap(afb)
  override def map[A, B](fa: Option[A], ab: A => B): Option[B] = fa.map(ab)
}


// getRecommendations에 Program Constraint를 추가한다.
def getRecommendations[F[_]]: UserRepo: AlgorithmRepo: Filter: Program](userId: Option[Int], ...) = {
  for {
    ...
  }
}
```

---

### Reference
- [Context Bounds](https://docs.scala-lang.org/tutorials/FAQ/context-bounds.html)
- [EXPLORING TAGLESS FINAL PATTERN FOR EXTENSIVE AND READABLE SCALA CODE](https://scalac.io/tagless-final-pattern-for-scala-code/)
