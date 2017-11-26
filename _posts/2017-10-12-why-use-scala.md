---
layout: entry
title: 프로젝트에 스칼라 도입하기!
author: 김성중
author-email: ajax0615@gmail.com
description: 기술 스택에 스칼라를 도입하면서 겪었던 것들을 위주로 작성한 회고록입니다.
publish: true
---

지난 16년 10월 18일에 [더널리](http://jointips.or.kr/bbs/board.php?bo_table=team&wr_id=253) 팀에 합류하여 [Rework](https://reworkapp.com/)의 웹 프론트엔드 개발을 하였고, 만 1년이 되어가는 지금은 다른 프로젝트를 진행하고 있습니다. 현재 진행하고 있는 프로젝트 *String* 에서 사용 중인 기술 스택과 관련한 함수형 프로그래밍에 대한 설명, 그리고 도입 과정에서 겪었던 것들을 위주로 한 회고록을 작성해 보았습니다.

---

# Scala와 Netty
더널리의 첫 프로젝트인 Rework의 백엔드는 [Scala](https://www.scala-lang.org/)와 [Netty](http://netty.io/)로 구성되어 있습니다. 그리고 두 번째 프로젝트를 시작할 즈음, 기술 선정에 있어서 자유도가 높았기 때문에 Node.js, Spring 아니면 기존의 Scala & Netty 구조를 이어갈 지 고민을 하였습니다. 한가지 고려해야 할 사항은 빠른 프로토타이핑이 가능해야 한다는 것이었습니다. 그래서 하고 싶은 것을 하되 잘 모르는 것은 이 악물고 밤새 공부하면서 개발해야겠구나라는 생각부터 들더군요. 해보고 싶은게 너무 많았지만, 기존의 Scala & Netty 구조를 이어가기로 결정하였습니다. 평소 함수형 프로그래밍에 굉장히 관심이 많았고, 팀원 그리고 스터디원들의 조언을 통해 결정하게 되었습니다.

**Scala** 에 대한 소개는 참고할 만한 레퍼런스가 많기 때문에 설명을 짧게 하도록 하겠습니다. 자바 가상 머신(JVM) 위에서 동작하기 때문에 이미 존재하는 자바 코드와 나란히 실행될 수 있고, 관련한 라이브러리를 직접 사용할 수 있습니다. 그리고 자바와 철학적 기반을 공유하고 있어서 정적 타이핑을 사용합니다. 스칼라가 가장 강력하다고 생각되는 부분은 동시성(concurrency) 처리를 위해 불변성(Immutability)와 같은 순수한 함수 스타일로 프로그래밍할 수 있는 도구를 제공하는 것입니다.

![Scala-logo](/images/2017/10/09/scala-logo.png "scala-logo"){: .center-image .image-half-width }

**Netty** 는 [아파치 미나 프로젝트](https://mina.apache.org/)를 창시한 소프트웨어 엔지니어인 이희승님이 오픈소스로 공개한 비동기 네트워크 프레임워크입니다. [이전 포스팅](https://sungjk.github.io/2016/11/08/NettyThread.html)에서도 설명하였듯이 네티는 Non-blocking IO를 지원합니다. 또한 네티의 채널은 하나의 이벤트 루프에 등록되는데(스레드라고 생각하면 됨), 하나의 이벤트 루프에서 여러 개의 커넥션(Session)을 처리할 수 있도록 설계되어 있습니다. 또한 [단순히 초당 250만 정도의 요청을 처리](https://www.techempower.com/benchmarks/#section=data-r14&hw=ph&test=plaintext)할 수 있기 때문에 초기 동접자 수와 퍼포먼스 관리를 모두 만족하는 네트워크 프로그램을 만들 수 있습니다.

![Netty-logo](/images/2017/10/09/netty-logo.png "netty-logo"){: .center-image .image-half-width }

---

# Scala Future와 Monad
개발을 하다보면 빼놓을 수 없는 것이 바로 **동시성(concurrency)** 에 대한 이야기입니다. 저 또한 어떻게 하면 동시성을 고려하면서 클라이언트의 요청을 처리할 수 있을지 고민해 봤지만, 이는 함수형이라는 도구를 사용해 해결할 수 있었습니다. 자바와 비교해보자면, 자바는 공유 메모리(shared memory)와 락(lock)을 기반으로 하는 동시성을 지원하지만, 공유 자원에 대한 제어를 제대로 해주기가 아주 어렵다는 사실을 모두 알고 있을것입니다. 하지만 스칼라에서는 **Future** 를 사용해 변경 불가능한 상태를 비동기적으로 변환하는 것에 집중하는 방식으로 이러한 어려움을 피할 수 있게 해줍니다.

자바에도 Future(자바 5)가 있지만 스칼라와 아주 다릅니다. 두 퓨쳐 모두 비동기적인 계산의 결과를 표현하지만, 자바의 퓨처에서는 블로킹(blocking) 방식의 get을 사용해 결과를 얻어와야 합니다. 반면, 스칼라의 Future에서는 계산 결과의 완료 여부와 관계없이 결과 값에 대해 변환(transform)을 수행할 수 있습니다. 각 변환은 원래의 Future를 지정한 함수에 따라 변환한 결과를 비동기적으로 담은 것을 표현하는 새로운 Future를 만듭니다. 여기서 실제로 계산을 수행하는 스레드(thread)는 암시적으로 제공되는 실행 컨텍스트(execution context)를 사용해 결정됩니다. 이런 방식을 사용하면 불변값에 대한 일련의 변환으로 비동기 계산을 표현할 수 있고, 공유 메모리나 락(lock)에 대해 신경을 쓸 필요가 없어서 쉽게 동시성을 지원할 수 있습니다.

> 자바 8의 CompletableFuture는 자바 5의 Future 인터페이스를 Non-blocking 방식으로 구현된 Future라서 여기서 설명한 것과는 다릅니다.

Future에 대해 좀 더 공부하다 보면 Monad와 같은 단어를 접하게 됩니다. 저 또한 함수형 프로그래밍 스터디를 하면서 이 개념에 대해 익히 알고 있었습니다만, 더글라스 크락포드가 모나드에 대해 말했던 것처럼 이해하고 나서 이걸 어떻게 설명하면 좋을지 막막했습니다.

> The curse of the monad is that once you get the epiphany, once you understand - \"oh that's what it is\" - you lose the ability to explain it to anybody. - Douglas Crockford

간단히 말하자면 Monad는 어떤 값을 감싸는 Wrapper로 생각하면 됩니다. Monad를 만족시키기 위해서는 아래와 같은 3가지 법칙을 만족해야 하는데, 마교수님(Martin Ordersky)의 강의를 들으면 도움이 될 것입니다.

- Associativity: `m flatMap f flatMap g == m flatMap (x => f(x) flatMap g)`
- Left unit: `unit(x) flatMap f == f(x)`
- Right unit: `m flatMap unit == m`

그리고 이 Wrapper는 다음과 같은 2가지 기능을 제공합니다.

- **identity** (하스켈: return, 스칼라: unit)
- **bind** (하스켈: >>=, 스칼라: flatMap)

identity는 특정 값을 감싸는 역할을 하고, bind는 감싼 값을 꺼내서 변형(transform)하고 그 값을 다시 감싸서 반환하는 역할을 합니다. Java 8이나 Rx를 경험해보신 분들이라면 CompletableFuture, Observable이 모나드이기 때문에 좀 더 이해하기가 수월할 것입니다.

하지만 제가 Scala로 개발을 시작하기 전에 이와 같은 경험이 없었기 때문에(React 개발하면서 redux-observable을 다뤄봤지만 제대로 이해하지 않고 사용한듯..) Scala의 Future를 이용해 비동기 프로그래밍을 하는데에 많은 애를 먹었습니다.

> 여기서 잠깐, Scala의 Future는 실제로 Monad가 될 수 있는 3가지 규칙 중 결합 법칙(Associativity)을 만족시키지 못해 Monad가 아닌 Monadic type라고 합니다. 자세한 내용은 [Is Future in Scala a monad?](https://stackoverflow.com/a/27467037/5236107)를 참고하세요.

빠른 프로토타이핑을 위해 Scala 문법 공부에 더해 Netty까지 학습해야 했기 때문에 Future를 제대로 다루는 방법을 이해하지 않은채 개발을 시작했습니다. 그러다보니 비동기 코드를 좀 더 깔끔하게 다룰 수 있는 for comprehension나 Future.sequence와 같은 방법을 익히는데 괜한 수고가 많이 들었습니다.

---

# Scala Future 가지고 놀기
Netty는 Non-blocking IO를 지원하기 때문에 이를 사용해 데이터를 가져오면 결과 값이 Future에 담기게 됩니다. 자바의 것과 마찬가지로 Blocking I/O(Await.result)를 사용해 값을 꺼낼 수 있지만, 여기서는 함수 합성을 통해 변형하고 Future를 사용하는 방법에 대해 알아보겠습니다.

#### **1. Future와 Promise**
*scala.concurrent* 패키지 안에는 비슷한 역할을 하는 것처럼 보이는 **Future** 와 **Promise** 를 Scala 공식 문서에서는 다음과 같이 정의를 하고 있습니다.

- **Future** is an object holding a value which may become available at some point.
- While futures are defined as a type of read-only placeholder object created for a result which doesn’t yet exist, a **promise** can be thought of as a writable, single-assignment container, which completes a future

정의에 따르면 **Future는 생성될 당시에 존재하지 않으나 언젠가 사용 가능해지는(read-only) placeholder** 이고, **Promise는 값을 쓸 수 있고(writable) 계산이 끝나면 future가 되는 placeholder** 입니다. 둘 다 비동기적으로 데이터 흐름을 관리하기 위해 사용되는 것인데, future는 데이터가 도착하기를 구독하고 있는 것이고, promise는 데이터를 제공하는 것입니다. 말을 이렇게 써놓으니까 굉장히 헷갈리는 것 같은데 실제 코드에서 어떤 식으로 사용되는지 보면 이해하기가 수월할 것입니다.

데이터베이스에서 특정 키 값으로 조회한 결과를 언젠가 사용 가능해지는 Future라는 Context에 감싸서 사용할 수 있습니다.

```java
def getUser(userId: UserId): Future[Option[UserInfo]] =
	Future { selectOpt("userId = ?", userId) }
```

데이터베이스에서 userId에 해당하는 유저의 정보를 비동기적으로 가져오는데, 해당 계산이 다 끝났을때(computed) 유저의 정보가 있다면 `UserInfo`가 반환될 것이고, 없다면 `None` 값을 가지게 됩니다.

Future는 값이 계산되면 꺼낼 수 있는(pulled out) 것이라고 한다면, Promise는 값을 채울 수 있는(pushed in) 것입니다. 그래서 생성 당시에 값을 채울 수 없는 Future와 달리 Promise는 생성 당시 빈 컨테이너(Empty container)이지만 값이 계산되면 채워지기 때문에 다음과 같이 사용할 수 있습니다.

```
def createCustomToken[T](userId: UserId)(handler: String => T): Future[T] = {
	val promise = Promise[T]

	Firebase.auth.createCustomToken(userId.toString)
		.addOnSuccessListener(new OnSuccessListener[String]() {
			override def onSuccess(customToken: String): Unit =
				promise.success(handler(customToken))
		})
		.addOnFailureListener(new OnFailureListener {
			override def onFailure(e: Exception): Unit =
				promise.failure(e)
		})

	promise.future
}
```

외부 시스템의 API를 사용해야 하는 경우, 해당 콜백(Callback)의 결과값을 가져오고 싶을때 Promise를 사용할 수 있습니다. 먼저 빈 promise를 하나 생성합니다. 그 다음 성공시 호출되는 콜백에는 `promise.success`에 원하는 값을 넣어주고, 실패시 호출되는 콜백에는 `promise.failure`에 에러값을 넣어줍니다. 이 함수의 반환값은 `promise.future` 인데 이는 `promise.success`나 `promise.failure`의 값이 계산되면 해당 값을 꺼내서 사용할 수 있습니다.

#### **2. flatMap**
flatMap은 자바의 Stream이나 Rx Observable을 다뤄보신 분이라면 쉽게 이해할 수 있는 연산자입니다. flatMap 연산자의 정의는 다음과 같습니다.

```
def flatMap[B](f: (A) => M[B]): M[B]
```


#### **3. for comprehension**
flatMap은 Javascript에서 `Promise.then` 체이닝과 같은 방식으로 Future를 반환하는 함수를 여러개로 묶어서 사용할 수 있습니다.

```java
def getUser(userId: UserId): Future[User] = {
	userTable.getUser(userId).checkExists flatMap { user =>
		companyTable.getCompany(user.companyId).checkExists flatMap { company =>
			jobTable.getJob(user.jobId).checkExists map { job =>
				val companyInfo = CompanyInfo(company.name, company.isVerified)
				val jobInfo = JobInfo(job.jobId, job.category, job.name, job.isVerified)
				User(userId, user.name, user.image, companyInfo, jobInfo, user.memo)
			}
		}
	}
}
```

하지만 이를 반복적으로 사용할 경우, 우리가 흔히 알고 있는 콜백 헬(Callback hell)이라는 안티 패턴(Anti pattern)이 발생할 수 있습니다.

![callback_hell](/images/2017/10/09/callback_hell.gif "callback_hell"){: .center-image }

스칼라는 이와 같은 문제를 flatMap과 map을 합성한 기능인 **fro comprehension** 을 제공하여 멋지게 해결합니다. 이를 사용하면 콜백 헬에서 벗어나 가독성 높은 코드를 만들 수 있습니다.

```java
def getUser(userId: UserId): Future[User] = {
	for {
		user <- userTable.getUser(userId).checkExists
		company <- companyTable.getCompany(user.companyId).checkExists
		job <- jobTable.getJob(user.jobId).checkExists
	} yield {
		val companyInfo = CompanyInfo(company.name, company.isVerified)
		val jobInfo = JobInfo(job.jobId, job.category, job.name, job.isVerified)
		User(userId, user.name, user.image, companyInfo, jobInfo, user.memo)
	}
}
```

#### **4. Seq[Future]를 Future[Seq]로**
데이터베이스에서 하나의 키 값으로 데이터를 조회하는 경우 그 타입은 `Future`이지만, 여러 개의 키 값으로 데이터를 조회하는 경우에는 `Seq[Future]`일 것입니다. `Seq[Future]`는 여러 개의 Future로 이루어진 Sequence를 말합니다. userId의 리스트인 userIds를 가지고 유저 데이터를 조회하는 경우를 예로 살펴보겠습니다.

```java
val userFutures: Seq[Future[Option[UserEntity]]] = userIds map { userId =>
	userTable.getUser(userId)
}
```

이와 같은 여러개의 Future는 아래와 같이 `Await.result()`를 사용하거나 `Future.sequence`를 사용해서 하나의 Future로 만들 수 있습니다. 다만, `Await.result()`는 스칼라의 Awaitable 인스턴스를 Blocking I/O로 다루는 것이니 사용시에 참고하시기 바랍니다.

```java
// Blocking I/O를 활용해서 값 얻어내기
val userOpts: Seq[Option[UserEntity]] = userFutures map { userFuture =>
	Await.result(userFuture, duration)
}

// 다수의 Future를 멋지게 핸들링하기
val usersOptFuture: Future[Seq[Option[UserEntity]]] =
	Future.sequence(userFutures)
```

위에서 작성한 `usersOptFuture`는 계산이 완료된 후 `Seq[Option[UserEntity]]`를 가지게 되는데, 이 Sequence 안에는 userId에 해당하는 유저가 있을 경우 `Some(user)`이고, 없으면 `None` 값을 가지게 됩니다. 만약 `Seq[Option[X]]`가 아닌 `Seq[X]`로 변형하고 싶다면 `flatten`을 이용하면 됩니다.

```java
val usersFuture: Future[Seq[UserEntity]] =
	Future.sequence(userFutures) map { _.flatten }
```

`Future.seqneuce`는 `.traverse`의 심플 버전인데 이를 사용할 때 유의할 점을 Future가 실행되는 시점에서 보면, 모든 Future는 동시에 실행되되면서 하나의 Future로 감싸지기 때문에 순차적으로(in serial) 실행되는 것이 아닌 **병렬로(parallel)** 실행된다는 것입니다. 만약 Seq 안에 있는 Future가 조회(SELECT)가 아닌 삽입(INSERT)에 대한 결과인 경우, 같은 키 값에 대해 동시 실행되기 때문에 *insert duplicate key* 에러가 발생할 수 있습니다. 동시 실행이 아닌 순차적으로 실행하고 싶다면 Future의 실행 흐름을 flatMap으로 풀어서 사용해야 합니다.

---

# 예외 처리
순수 함수형 언어에는 예외가 없습니다. 예외는 타입 시스템과 함수형 프로그래밍의 순수성(purity)을 약화시키는 사이드 이펙트입니다. 수학 시간에 계산을 하다가 예외가 발생한 경우가 없듯이(0으로 나누는 것과는 다른 얘기), 함수형 프로그래밍에서도 오류나 부적절한 조건은 어떤 특정한 값으로 명시되어야 합니다.

#### Option Type
데이터베이스에서 특정 키 값으로 조회를 하였는데 해당하는 값이 없습니다. 그렇다면 `Throw Exception`을 해야하나요? 위에서 말했듯이, 함수형 프로그래밍에서는 예외를 추구하지 않기 때문에 이를 해결할 방법 중 하나로 **Option Type** 을 지원합니다. 스칼라가 가지고 있는 타입 시스템은 굉장히 강력하기 때문에 많은 것들을 컴파일러가 추론할 수 있게끔 설계되어 있습니다. 자바 8의 Optional, Kotlin, Swift에도 있는 이 타입은 **Some** 과 **None** 두 값을 가지게 됩니다.

유저의 정보를 업데이트하고 싶은 경우, 먼저 userId에 해당하는 사용자가 데이터베이스에 존재하는지 확인해야 합니다. 이때 해당 유저가 있으면 `Some(user)`이고, 없으면 `None`이 되고, 각 분기에 맞게 업데이트를 하거나 Future의 결과를 반환합니다.

```java
def updateUserProfile(userId: UserId, nameOpt: Option[String]): Future[Unit] =
		userTable.getUser(userId) flatMap {
			case Some(_) =>
				userTable.update(userId, nameOpt, None, None, None, None)
			case None =>
				Future.successful({})
		}
```

#### Either Type
Option은 원하는 액션에 대한 성공과 실패를 Some과 None으로 잘 구분지어 주지만, 때때로 실패에 대한 정보가 더 필요할 때가 있습니다. 스칼라는 이와 같은 상황에서 **Left** 와 **Right** 로 값을 구분지어 사용할 수 있게끔 **Either type** 을 지원합니다. Either 타입의 정의는 다음과 같습니다.

```
sealed abstract class Either[+A, +B] extends AnyRef
```

Either의 Left와 Right에 들어갈 값의 타입은 서로 달라고 됩니다. 따라서 이 Either는 액션에 대한 성공 시에는 그 결과값을 저장하고, 실패하면 실패 이유를 저장하는데 사용할 수 있습니다. Either를 사용할 때 보통은 *Right* 에 성공한 값을 넣고(right라서 Right라는...), *Left* 에 에러를 넣습니다.

```java
def getFirebaseInfo(userId: UserId): Future[Either[Errors.Error, FirebaseInfo]] = {
	createCustomToken(userId) {
		case customToken: String =>
			Right(FirebaseInfo(customToken))
		case _ =>
			Left(Errors.Forbidden)
	}
}
```

#### Try
**Try[T]** 는 Either와 유사하게 **Success[T]** 와 **Failure[T]** 두 가지 값을 가질 수 있습니다. 언뜻 보기에 굉장히 비슷해 보이는데 Try의 *Failure* 는 오직 *Throwable* 타입만 될 수 있습니다. 따라서 굳이 Try를 안쓰고 try/catch 문을 사용해서 에러를 처리해도 됩니다.

```java
// 실패하면 NumberFormatException이 Throw 된다.
def parseIntException(value: String): Int = value.toInt

// 실패하면 exception을 포함한 Failure가 리턴되고,
// 성공하면 파싱된 integer 값이 Success에 리턴된다.
def parseInt(value: String): Try[Int] = Try(value.toInt)
```

이처럼 Try는 어떤 에러가 발생했으나 함수 내에서 이를 처리할 수 없을 때 유용합니다.

#### Exceptions
스칼라는 JVM 위에서 동작하기 때문에 exception이 발생한 경우 저수준의 에러(low-level error) 핸들링이 가능합니다. 자바의 try, catch, finally와 비슷한 문법을 가지고 있습니다.

```java
try {
  dangerousCode()
} catch {
  case e: Exception => println("Error!")
} finally {
  cleanup
}
```

스칼라에서 try, catch 문을 사용할 때 주의해야 할 점은, 다음과 같이 작성할 경우 모든 Throwables를 에러로 인식하기 때문에 *OutOfMemoryError* 와 같은 치명적인 시스템 에러가 발생할 수 있습니다. 따라서 다음과 같이 작성해서는 안됩니다.

```java
try {
  dangerousCode()
} catch {
  case _ => println("Error! Also caught OutOfMemoryError here!")
}
```

---

# 마치며
\'느님에게 서버는 어떻게 하면 잘 만드는 것입니까\'라는 어리석은 질문을 한 것이 생각납니다. 그 때 대답은 아주 간단하지만 정답이라고 생각되는, \"일단 잘 돌아가야 한다. 잘 돌아가려면 발생할 수 있는 사이드 이펙트 최대한 줄여야 하는데, 이 때 함수형 프로그래밍이 빛을 발한다. 공유 자원은 줄이고, 데이터는 이뮤터블하게, 함수는 순수하게 작성하면 된다.\" 저에게는 코드를 작성할 때 좀 더 순수하게 작성할 수 없을까 한번 더 생각하게 해주는 명언입니다.

지난 1년을 되돌아보며 기억을 더듬어보니 빠른 프로토타이핑이라는 요구 사항에 맞추기 위해 공부하면서 개발하고 밤샜던 기억이 났습니다. 당시 느낀 점이 있다면 확실히 스칼라는 다른 언어에 비해 문법이 어렵습니다. 다른 언어에는 없는 implicit 키워드를 이해하는 것, Java Stream, RX Observable과 같은 개념도 모르는 상태에서 함수형 프로그래밍의 Monad와 같은 개념을 이해하지 않고 Future를 다루려 했던것... 등등 시간 압박과 함께 고생을 좀 했던것 같네요. 하지만 모든 기술들이 그렇듯 어느 계단을 올라서면 빛을 바라는 것 같습니다. 아직 개발해야 할 부분은 많이 남았지만, 동시성과 비동기 프로그래밍을 멋지게 구현할 수 있는 스칼라에 굉장히 만족하고 있습니다.

긴 글 읽어주셔서 감사합니다.

---

# Reference
- [Seven Languages in Seven Weeks - Scala](https://sungjk.github.io/2017/09/14/seven-languages-scala.html)
- [스칼라 - 퓨처와 동시성](https://sungjk.github.io/2017/08/09/scala-future.html)
- [Monad Programming with Scala Future](http://tech.kakao.com/2016/03/03/monad-programming-with-scala-future/)
- [Monad-in-java](https://gist.github.com/jooyunghan/e14f426839454063d98454581b204452)
- [Scala-logo](https://d120jmftguczr4.cloudfront.net/img/why-scala/scala-logo.png)
- [Netty-logo](https://logz.io/wp-content/uploads/2016/02/netty.png)
- [callback-hell](http://icompile.eladkarako.com/wp-content/uploads/2016/01/icompile.eladkarako.com_callback_hell.gif)
