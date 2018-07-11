---
layout: entry
post-category: scala
title: Functional Programming in Scala 6
author: 김성중
author-email: ajax0615@gmail.com
description: Functional Programming in Scala의 7장(순수 함수적 병렬성)을 정리한 글입니다.
publish: true
---

# 1. 자료 형식과 함수의 선택
대체로 함수적 라이브러리를 설계할 때에는 그 라이브러리로 무엇을 하고자 하는지에 대한 전반적인 착안을 가지고 설계 과정을 시작하게 된다. 이번 예제 라이브러리에서 우리가 원하는 것은 \"병렬 계산을 생성할 수 있어야 한다\"는 것이다. 그럼 간단하고 병렬화할 수 있는 계산을 살펴보고, 이러한 착안을 구현이 가능한 어떤 것으로 바꿔 보자. 병렬화할 계산은 목록에 있는 정수들의 합을 구하는 것이다. 이를 통상적인 foldLeft로 수행하는 코드는 다음과 같다.

```
def sum(ints: Seq[Int]): Int =
  ints.foldLeft(0)((a, b) => a + b)
```

여기서 Seq는 표준 라이브러리에 있는 목록과 기타 순차열들의 상위 클래스이고, foldLeft 메서드가 있다는 점이다. 그런데 이를 순차적으로 접는 대신, 다음 처럼 분할정복(Divide-and-Conquer) 알고리즘을 적용할 수도 있다.

```
// IndexedSeq는 순차열을 특정 지점에서 두 부분으로 분할하는 효율적인 splitAt 메서드를 제공한다.
def sum(ints: IndexedSeq[Int]): Int =
// headOption은 스칼라의 모든 컬렉션에 정의된 메서드이다.
  if (ints.size <= 1) ints.headOption getOrElse 0 else {
    // splitAt 함수를 이용해서 순차열을 반으로 나눈다.
    val (l, r) = ints.splitAt(ints.length / 2);
    // 재귀적으로 두 절반을 각각 합하고 그 결과를 합친다.
    sum(l) + sum(r)
  }
```

이 코드는 순차열을 splitAt 함수를 이용해서 절반으로 분할하고, 재귀적으로 두 절반을 합해서 결과들을 합친다. foldLeft 기반 구현과는 달리 이 구현은 병렬화할 수 있다. 즉, 두 절반을 병렬로 합할 수 있는 것이다.

### 1.1 병렬 계산을 위한 자료 형식 하나
표현식 sum(l) + sum(r) 을 생각해 보자. 이 표현식은 두 절반에 대해 재귀적으로 sum을 호출한다. 병렬 계산을 나타내는 자료 형식이 **하나의 결과를 담을** 수 있어야 한다는 점을 알 수 있다. 새로 발견한 이 지식을 설계에 적용해 보자. 일단 지금은 결과를 담을 컨테이너 형식 Par\[A\](parallel의 줄임말)를 새로 만들자. 이 형식에 필요한 함수들은 다음과 같다.

```
// 평가되지 않은 A를 받고, 그것을 개별 스레드에서 평가할 수 있는 계산을 돌려준다.
// 함수의 이름이 unit인 것은, 이 함수가 하나의 값을 감싸는 병렬성의 한 단위(unit)을 생성하기 때문.
def unit[A](a: => A): Par[A]

// 병렬 계산에서 결과 값을 추출한다.
def get[A](a: Par[A]): A
```

그럼 이 함수들을 가지고 정수 합산 예제를 갱신해 보자.

```
def sum(ints: IndexedSeq[Int]): Int =
  if (ints.size <= 1) ints.headOption getOrElse 0 else {
    val (l, r) = ints.splitAt(ints.length / 2)
    val sumL: Par[Int] = Par.unit(sum(l)) // 왼쪽 절반을 병렬로 계산
    val sumR: Par[Int] = Par.unit(sum(r)) // 오른쪽 절반을 병렬로 계산
    Par.get(sumL) + Par.get(sumR) // 두 결과를 추출해서 합한다.
  }
```

이 버전은 두 재귀적 sum 호출을 unit으로 감싸고, 두 부분 계산의 결과들을 get을 이용해서 추출한다.

unit은 주어진 인수를 개별 스레드에서 즉시 평가할 수도 있고, 인수를 그냥 가지고 있다가 get이 호출되면 평가를 시작할 수도 있다. 그런데 지금 예제에서 병렬성의 이점을 취하기 위해서는 unit이 인수의 동시적 평가를 시작한 후 즉시 반환되어야 한다. 왜냐하면 스칼라에서 함수의 인수들은 왼쪽에서 오른쪽으로 엄격하게 평가되므로, 만일 unit이 get이 호출될 때까지 실행을 지연시킨다면, 첫 병렬 계산의 실행이 끝나야 두 번째 병렬 계산이 시작된다. 이는 결국 계산이 순차적으로 실행되는 것과 같다.

그런데 만일 unit이 인수들의 평가를 동시에 시작한다면 get 호출에서 참조 투명성이 깨질 수 있다. sumL과 sumR을 해당 정의로 치환해 보면 이 점이 명백해진다. 치환해도 같은 결과가 나오긴 하지만, 이제는 프로그램이 병렬로 실행되지 않는다.

```
Par.get(Par.unit(sum(l))) + Par.get(Par.unit(sum(r)))
```

unit이 자신의 인수를 즉시 평가하기 시작한다면, 그 다음으로 일어나는 일은 get이 그 평가의 완료를 기다리는 것이다. 따라서 sumL 변수와 sumR 변수를 그냥 단순히 나열하면 + 기호의 양변은 병렬로 실행되지 않는다. 이는 unit에 한정적인 부수 효과가 존재함을 의미한다. 단, 그 부수 효과는 get**에만 관련**된 것이다. 다른 말로 하면, 이 경우 unit은 그냥 비동기 계산을 나타내는 Par\[Int\]를 돌려준다. 그런데 Par를 get으로 넘겨주는 즉시, get의 완료까지 실행이 차단된다는 부수 효과가 드러난다. 따라서 get을 호출하지 않거나, 적어도 호출을 최대한 미루어야 한다. 즉, 비동기 계산들을 그 완료를 기다리지 않고도 조합할 수 있어야 한다.

### 1.2 병렬 계산의 조합
앞에서 말한 unit과 get 조합의 문제점을 어떻게 피할 수 있을까? get을 호출하지 않는다면 sum 함수는 반드시 Par\[Int\]를 돌려주어야 한다.

```
def sum(ints: IndexedSeq[Int]): Par[Int] =
  if (ints.size <= 1) Par.unit(ints.headOption getOrElse 0) else {
    val (l, r) = ints.splitAt(ints.length / 2)
    Par.map2(sum(l), sum(r))(_ + _)
  }

// 참고. Par.map2는 두 병렬 계산의 결과를 결합하는 고차 함수이다.
def map2[A, B, C](a: Par[A], b: Par[B])(f: (A, B) => C): Par[C]
```

이제는 재귀의 경우에 unit을 호출하지 않고, unit의 인수가 게으른 인수여야 하는지도 명확하지 않다. map2의 경우에는 계산의 양변에 동등한 실행 기회를 주어서 양변이 병렬로 계산되게 하는 것이 합당하다(map2 인수들의 순서는 별로 중요하지 않다. 결합되는 두 게산이 독립적이며, 병렬로 실행될 수 있음을 나타내는 것이 중요하다). 그러한 의미를 구현하려면 어떤 선택이 필요할까? map2의 두 인수가 엄격하게 평가된다고 할 때 sum(IndexedSeq(1, 2, 3, 4))의 평가가 어떻게 진행되는지 생각해 보자.

```
sum(IndexedSeq(1, 2, 3, 4))
map2(
  sum(IndexedSeq(1, 2)),
  sum(IndexedSeq(3, 4)))(_ + _)
map2(
  map2(
    sum(IndexedSeq(1)),
    sum(IndexedSeq(2)))(_ + _),
  sum(IndexedSeq(3, 4)))(_ + _)
map2(
  map2(
    unit(1),
    unit(2))(_ + _),
  map2(
    sum(IndexedSeq(3)),
    sum(IndexedSeq(4)))(_ + _))(_ + _)
...
```

여기서 sum(x)를 평가하려면 x를 sum의 정의에 대입해야 한다. map2는 엄격한 함수이므로 그 인수들을 왼쪽에서 오른쪽으로 평가한다. 따라서 map2(sum(x), sum(y))(_ + _)를 만날 때마다 sum(x) 등을 재귀적으로 평가해야 한다. 이는, 합산 트리의 왼쪽 절반 전체를 엄격하게 구축한 후에야 오른쪽 절반을 (엄격하게) 구축할 수 있다는 바람직하지 않은 결과로 이어진다. 예를 들어, sum(IndexedSeq(1, 2))가 완전히 전개된 후에야 sum(IndexedSeq(3, 4))의 평가가 시작된다. 만일 map2가 인수들을 병렬로 평가한다면, 이는 계산의 오른쪽 절반의 구축을 시작하기도 전에 계산의 왼쪽 절반이 실행되기 시작함을 의미한다.

map2를 엄격하게 유지하되 그 실행이 즉시 **시작되지는 않게** 하면 어떨까? 병렬로 계산해야 할 것의 서술을 구축한다는 의미의 Par가 있다고 생각해보자. Par가 **평가**(이를테면 get 같은 함수를 이용해서)하기 전까지는 아무 일도 일어나지 않는다. 문제는, 만일 그러한 서술을 엄격하게 구축한다면, 서술을 나타내는 객체가 상당히 무거운 객체가 될 것이라는 점이다. map2를 게으르게 만들고 양변을 병렬로 즉시 실행하는 것이 나아 보인다. 그러면 양변에 동등한 실행 기회를 부여하는 문제도 해결된다.

### 1.3. 명시적 분기
그런데 map2의 두 인수를 병렬로 평가하는 것이 **항상** 바람직할까? 아마도 아닐 것이다.

```
Par.map2(Par.unit(1), Par.unit(1))(_ + _)
```

이 예에서 결합하고자 하는 두 계산은 아주 빠르게 완료될 것이고, 따라서 굳이 개별적인 논리적 스레드를 띄울 필요가 없다. 그러나 현재 API에는 이런 정보를 제공할 수단이 갖추어져 있지 않다. 즉, 현재 API는 계산을 메인 스레드로부터 분기하는 시점에 관해 그리 **명료하지 않다.** 즉, 우리가 그러한 분기가 일어나는 시점을 구체적으로 지정할 수 없다. 분기를 명시적으로 만들기 위해 함수 `def fork[A](a: => Par[A]): Par[A]` 를 추가하자. 이 함수는 주어진 Par가 개별 논리적 스레드에서 실행되어야 함을 명시적으로 지정하는 용도로 쓰인다.

```
def sum(ints: IndexedSeq[Int]): Par[Int] =
  if (ints.length <= 1) Par.unit(ints.headOption getOrElse 0) else {
    val (l, r) = ints.splitAt(ints.length / 2);
    Par.map2(Par.fork(sum(l)), Par.fork(sum(r)))(_ + _)
  }
```

이 fork 덕분에 이제는 map2를 엄격한 함수로 만들고, 인수들을 감싸는 것은 프로그래머의 뜻에 맡길 수 있게 되었다. fork 같은 함수는 병렬 계산들을 엄격하게 인스턴스화하는 문제를 해결해 주지만, 좀 더 근본적으로는 **병렬성을 명시적으로 프로그래머의 통제하에 두는 역할**을 한다.

이제 unit이 엄격해야 하는지 게을러야 하는지의 문제로 돌아가자. fork가 있으니 이제는 unit을 엄격하게 만들어도 표현력이 전혀 감소하지 않는다. 이 함수의 비엄격 버전(lazyUnit)은 unit과 fork로 간단히 구현할 수 있다.

```
def unit[A](a: A): Par[A]
def lazyUnit[A](a: => A): Par[A] = fork(unit(a))
```

lazyUnit 함수는 unit 같은 **기본**(primitive) 조합기가 아니라 **파생된**(derived) 조합기의 간단한 예이다.

fork는 인수들을 개별 논리적 스레드에서 평가되게 하는 수단이다. 그런데 그러한 평가가 호출 **즉시** 일어나게 할 것인지, 아니면 get 같은 함수에 의해 계산이 **강제**될 때까지 개별 논리적 스레드에서의 평가를 미룰 것인지는 아직 결정하지 않았다. 다른 말로 하면, 평가가 fork의 책임인지, 아니면 get의 책임인지의 문제를 결정해야 한다. 평가를 적극적으로(eagerly) 수행할 것인지 게으르게 수행할 것인지를 선택한다는 의미이다.

만일 fork가 자신의 인수를 즉시 병렬로 평가하기 시작한다면, 그 구현은 스레드를 생성하는 방법이나 과제를 일종의 스레드 풀에 제출하는 방법을 직접적으로든 간접적으로든 알고 있어야 한다. 더 나아가서, 이는 스레드 풀이 반드시 접근 가능한(전역적으로) 자원이어야 하며, fork를 호출하는 시점에서 이미 적절히 초기화되어 있어야 함을 의미한다. 이런 조건을 만족하려면 프로그램의 여러 부분에서 쓰이는 병렬성 전략을 프로그래머가 임의로 제어할 수 있는 능력을 포기해야 한다. 병렬 과제들의 실행을 위해 전역 자원을 두는 것이 근본적으로 잘못된 일은 아니지만, 구현이 무엇을 언제 사용할 것인지를 프로그래머가 좀 더 세밀하게 제어할 수 있다면 더 좋을 것임은 분명하다. 따라서 스레드 생성과 실행의 책임을 get에 부여하는 것이 훨씬 적합하겠다.

만약 fork가 그냥 인수의 평가를 뒤로 미루게 한다면, fork는 병렬성 구현을 위한 메커니즘에 접근할 필요가 없다. 그냥 평가되지 않은 Par 인수를 받고 그 인수에 동시적 평가가 필요하다는 점을 \'표시\'만 해두면 된다. 이것이 바로 fork의 의미라고 가정하다. Par는 나중에 get 함수 같은 무언가에 의해 **해석** 될 병렬 계산에 관한 **서술** 에 가깝다. 이는 Par를 나중에 준비되었을 때 **조회**(get)할 어떤 값을 담은 **컨테이터** 라고 생각했던 것과는 다른 발상이다. 이제는 **실행**이 가능한 일급 프로그램에 좀 더 가까워졌으므로 get 함수의 이름을 run으로 바꾸고, 병렬성이 실제로 구현되는 지점이 바로 이 run 함수임을 정의한다.

```
def run[A](a: Par[A]): A
```

Par 이제 순수 자료구조이므로, run은 병렬성을 구현하는 어떤 수단을 갖추어야 한다. 새 스레드를 생성하거나 작업들을 스레드 풀에 위임할 수도 있고, 그 밖의 다른 어떤 메커니즘을 사용할 수도 있다.

---

# 2. 표현의 선택
이제 우리가 만든 Par를 위한 API 개요는 다음과 같다.

```
def unit[A](a: A): Par[A]
def map2[A, B, C](a: Par[A], b: Par[B])(f: (A, B) => C): Par[C]
def fork[A](a: => Par[A]): Par[A]
def lazyUnit[A](a: => A): Par[A] = fork(unit(A))
// 주어진 Par를 fork의 요청에 따라 병렬 계산들을 수행하고 그 결과 값을 추출함으로써 완전히 평가한다.
def run[A](a: Par[A]):A
```

- unit은 상수 값을 병렬 계산으로 승격한다.
- map2는 두 병렬 계산의 결과들을 이항 함수로 조합한다.
- fork는 주어진 인수가 동시적으로 평가될 계산임을 표시한다. 그 평가는 run에 강제되어야 실제로 실행된다.
- lazyUnit은 평가되지 않은 인수를 Par로 감싸고, 그것을 병렬 평가 대상으로 표시한다.
- run은 계산을 실제로 실행해서 Par로부터 값을 추출한다.

run이 비동기적 작업들을 실행하기 위해 Java 표준 라이브러리 java.util.concurrent.ExecutorService를 스칼라로 가져와보자.

```
class ExecutorService {
  def submit[A](a: Callable[A]): Future[A]
}

trait Callable[A] { def call: A }

trait Future[A] {
  def get: A
  def get(timeout: Long, unit: TimeUnit): A
  def cancel(evenIfRunning: Boolean): Boolean
  def isDone: Boolean
  def isCancelled: Boolean
}
```

ExecutorService의 submit 메서드는 주어진 Callable 값에 대응되는, 필요에 따라 개별 스레드에서 실행될 계산을 처리해 주는 Future 객체를 돌려준다. 계산의 결과는 Future의 get 메서드로 얻을수 있다. Future는 또한 계산의 추소를 위한 추가적인 기능도 제공한다.

그럼 run 함수가 ExecutorService에 접근할 수 있다고 가정하고, 이를 개선해보자.

```
def run[A](s: ExecutorService)(a: Par[A]): A
```

Par\[A\]의 표현으로 사용할 수 있는 가장 간단한 모형은 ExecutorService => A일 것이다. 이 표현을 선택한다면 run을 구현하기가 아주 간단하지만, 계산 완료까지의 대기 시간이나 취소 여부를 run의 호출자가 결정할 수 있게 하면 더욱 좋을 것이다. 이를 위해 Par\[A\]를 ExecutorService => Future\[A\]로 두고, run은 그냥 Future를 돌려주게 하자.

```
type Par[A] = ExecutorService => Future[A]
def run[A](s: ExecutorService)(a: Par[A]): Future[A] = a(s)
```

Par가 ExecutorService를 필요로 하는 **하나의 함수**로 표현되었기 때문에, Future의 생성은 이 ExecutorService가 제공되기 전까지는 일어나지 않음을 주목하기 바란다.

---

# 3. API 다듬기
Par의 기본적인 구현은 다음과 같다.

```
object Par {
  // unit은 UnitFuture를 돌려주는 함수로 표현된다. UnitFuture는 Future의 간단한 구현으로,
  // 그냥 상수 값을 감싸기만 할 뿐 ExecutorService는 전혀 사용하지 않는다.
  // UnitFuture는 항상 완료 가능하며, 취소는 불가능하다.
  def unit[A](a: A): Par[A] = (es: ExecutorService) => UnitFuture(a)

  private case class UnitFuture[A](get: A) extends Future[A] {
    def isDone = true
    def get(timeout: Long, units: TimeUnit) = get
    def isCancelled = false
    def cancel(evenIfRunning: Boolean): Boolean = false
  }

  // f 호출을 개별 논리적 스레드에서 평가하지 않는다.
  // f를 개별 스레드에서 평가하고 싶다면 fork(map2(a, b)(f))를 사용하면 된다.
  def map2[A, B, C](a: Par[A], b: Par[B])(f: (A, B) => C): Par[C] =
    (es: ExecutorService) => {
      val af = a(es)
      val bf = b(es)
      // ExecutorService를 두 Par 값에 전달하고, Future의 af와 bf의 결과들을 기다리고,
      // 그것들에 f를 적용하고, 적용 결과를 UnitFuture로 감싼다.
      UnitFuture(f(af.get, bf.get))
    }

  def fork[A](a: => Par[A]): Par[A] =
    es => es.submit(new Callable[A] {
      def call = a(es).get
    })
}
```

Future 메서드들이 부수 효과에 의존적이라서 순수 함수적이지 않지만, Par API 자체는 여전히 순수하다. 그리고 Future의 내부 동작 방식은 사용자가 run을 호출해서 구현이 ExecutorService를 받아야 드러난다. 따라서, 구현이 부수 효과들에 의존하긴 하지만, 사용자는 항상 순수한 인터페이스로 프로그램을 짤 수 있다.

예를 들어, 하나의 List\[Int\]를 만드는 병렬 계산 표현식 Par[List[Int]]를 정렬된 Par[List[Int]]로 변환한다고 하자.

```
def sortPar(parList: Par[List[Int]]): Par[List[Int]]
```

물론 Par에 run을 적용하고, 결과 목록을 정렬하고 정렬된 목록을 unit을 이용해서 다시 Par로 꾸릴 수도 있다. 하지만 우리는 run의 호출을 피하고 map2를 이용해서(unit 이외에 Par 값을 조작할 수 있는 조합기는 map2뿐) 목록을 정렬할 것이다.

```
def sortPar(parList: Par[List[Int]]): Par[List[Int]] =
  map2(parList, unit(()))((a, _) => a.sorted)
```

그리 어렵지 않게 문제를 해결했다. 이제 Par[List[Int]]에게 목록을 정렬하라고 알려 줄 수 있다. 그런데 이를 좀 더 일반화하는 것도 가능하다. A => B 형식의 임의의 함수를, Par[A]를 받고 Par[B]를 돌려주는 함수로 승급(lift)시킬 수 있다. 다음은 Par에 대해 임의의 함수를 맵핑하는 map의 정의이다.

```
def map[A, B](pa: Par[A])(f: A => B): Par[B] =
  map2(pa, unit(()))((a, _) => f(a))
```

이제 sortPar는 그냥 다음과 같이 정의하면 된다.

```
def sortPar(parList: Par[List[Int]]) = map(parList)(_.sorted)
```

map2가 둘째 인수를 그냥 무시하게 만들기 위해 둘째 인수에 무의미한 값 unit(()) 을 전달하는 것은 속임수가 아니다. map2를 이용해서 map을 구현할 있지만 그 반대로는 불가능하다는 사실은 map2가 map보다 더 강력함을 보여줄 뿐이다.

이 API로 하나의 리스트에 map을 병렬로 적용할 수 있을까? 그럼 map2처럼 두 개의 병렬 계산을 결합하는 것이 아니라 N개의 병렬 계산을 결합하는 함수 parMap을 만들어 보자.

```
def parMap[A, B](ps: List[A])(f: A => B): Par[List[B]]
```

여기서 Par[A]는 ExecutorService => Future[A]의 별칭일 뿐임을 기억하기 바란다.

parMap을 새로운 방법으로 구현할 수도 있지만, 기존의 API들로 표현할 수 있는 연산들을 살펴보고 이들의 관계를 파악하기 위해 기존 조합기들을 이용해서 구현해보겠다.

```
def parMap[A, B](ps: List[A])(f: A => B): Par[List[B]] = {
  val fbs: List[Par[B]] = ps.map(asyncF(f))
}

// 참고. 임의의 함수 A => B를 그 결과가 비동기적으로 평가되는 함수로 변환하는 함수
def asyncF[A, B](f: A => B): A => Par[B] = a => lazyUnit(f(a))
```

asyncF는 병렬 계산 하나를 분기(forking)해서 결과를 산출함으로써 A => B를 A => Par[B]로 변환한다. 이를 이용하면 N개의 병렬 계산을 수월하게 분기시킬 수 있다. 그런데 그 계산들의 결과를 취합할 방법이 필요하다. List[Par[B]]를 parMap의 반환 형식이 요구하는 Par[List[B]]로 변환하는 수단인 sequence라는 새로운 함수를 정의하고 parMap의 구현을 완성시켜 보자.

```
def sequence[A](as: List[Par[A]]): Par[List[A]]

def parMap[A, B](ps: List[A])(f: A => B): Par[List[B]] = fork {
  val fbs: List[Par[B]] = ps.map(asyncF(f))
  sequence(fbs)
}
```

구현을 fork 호출 하나로 감쌌다. 이 구현에서 parMap은 입력이 거대한 목록이라고 해도 즉시 반환된다. 이후에 run을 호출하면 하나의 비동기 계산이 분기되며, 그 계산은 N개의 병렬 계산을 띄우고 그 계산들이 끝나길 기다렸다가 결과들을 하나의 목록으로 취합한다.

---

# 4. API의 대수(algebra)
일단 원하는 연산의 서명만 작성 한 후 \"그 형식을 따라가다 보면\" 구현에 도달하는 경우가 많다. 이는 대수 방정식을 단순화할 때 하는 추론과 비슷한 자연스러운 추론 방식이다. API를 하나의 **대수**(algebra), 즉 **법칙** 이라고 간주하고 그 대수에 정의된 규칙에 따라 형식적으로 기호를 조작하면서 문제를 풀어나가면 된다.

설계상의 다른 선택들과 마찬가지로, 법칙의 선택에는 **결과**가 따른다. 법칙을 선택하면 연산에 부여할 수 있는 의미에 제약이 생기고, 선택 가능한 구현 방식이 결정되며 다른 속성들에도 영향이 미친다.

```
map(unit(1))(_ + 1) == unit(2)
```

이 테스트 코드는 unit(1)에 _ + 1 함수를 맵핑한 것이 어떤 의미로는 unit(2)와 같음을 의미한다. 어떤 의미에서 같을까? 일단 지금은 **임의의 유효한** ExecutorService에 대해 두 Par 객체의 Future 결과가 서로 같다면 그 두 Par 객체가 동등하다고 말하기로 하자.

어떤 ExecutorService에 대해 이 법칙이 성립하는지는 다음과 같은 함수로 점검할 수 있다.

```
def equal[A](e: ExecutorService)(p: Par[A], p2: Par[A]): Boolean =
  p(e).get == p2(e).get
```

법칙과 함수는 공통점이 아주 많다. 함수를 일반화할 수 있듯이, 법칙도 일반화할 수 있다. 앞의 법칙을 다음과 같이 일반화할 수 있다.

```
map(unit(x))(f) == unit(f(x))
```

이는 이 법칙이 1과 _ + 1 함수 뿐만 아니라 **임의의**(any) x와 f에 대해 성립함을 의미한다. 앞서 언급했듯 이는 구현에 제약을 가하는데, unit을 구현할 때 주어진 입력을 조사해서 그 값이 1이면 병렬 계산의 결과로 42를 산출하도록 구현할 수는 없다. unit은 자신이 받은 것을 넘겨주기만 해야 하고, ExecutorService도 마찬가지이다.

어떤 함수를 정의할 때 그보다 더 간단한 함수들, 즉 **한 가지 일만 하는 함수** 들을 이용해서 정의하려는 것과 아주 비슷하게, 어떤 법칙을 정의할 때에는 **한 가지 사실만 말하는** 더 간단한 법칙들을 이용해서 정의할 수 있다. 앞에서 이 법칙이 **임의의** x와 f에 대해 성립했으면 한다고 말했다. f를 항등 함수(identity function)로 치환하면 다음과 같이 훨씬 더 간단한 법칙이 나온다.

```
map(unit(x))(f) == unit(f(x))   // 초기 법칙
map(unit(x))(id) == unit(id(x)) // f를 항등 함수로 치환
map(unit(x))(id) == unit(x)     // 단순화
map(y)(id) == y                 // 양변에서 unit(x)를 y로 치환
```

돌이켜보면 unit을 사용한 것은 불필요했다. map은 단지 함수 f를 y의 결과에 적용할 뿐이다. 그리고 f가 id라면 y에 아무런 영향도 미치지 않는다(이를 두고 map이 **구조 보존적**(structure-preserving)이어야 한다고 말한다. 즉, map은 병렬 계산의 구조를 변경해서는 안되며, 오직 계산 내부의 값만 변경해야 한다.). 그리고 map(y)(id) == y 라고 할 때 반대 방향의 치환들을 통해서 원래의 좀 더 복잡한 법칙으로도 돌아갈 수 있다. 논리적으로, 이러한 자유도는 map이 주어진 함수에 따라 다른 방식으로 행동하지 않기 때문에 생긴 것이다. 즉, 만약 map(y)(id) == y 라면 반드시 map(unit(x))(f) == unit(f(x)) 도 참이어야 한다.

---

# 5. 조합기들을 가장 일반적인 형태로 다듬기
함수적 설계는 반복적인 과정이다. API의 명세를 만들고 적어도 하나의 원형(prototype) 구현을 작성했다면, 그것을 현실적인 시나리오들에 사용해봐야 한다. 그런데 필요한 조합기를 바로 구현하는 것보다는, 그 조합기를 **가장 일반적인 형태** 로 다듬을 수 있는지 살펴보는 것이 바람직하다. 그러면 새 조합기가 필요한 것이 아니라 좀 더 일반적인 조합기의 특별한 경우가 필요했다는 것을 깨달을 수 있기 때문이다.

그럼 이에 관한 예로, 두 분기 계산 중 하나를 초기 계산의 결과에 기초해서 선택하는 함수가 필요하다고 하자.

```
def choice[A](cond: Par[Boolean]])(t: Par[A], f: Par[A]): Par[A]
```

이 함수는 cond의 결과가 true이면 t를 사용해서 계산하고, cond의 결과가 false이면 f를 사용해서 계산한다. 이를, cond의 결과가 나올때까지 실행을 차단하고 그 결과를 이용해서 t나 f의 실행을 결정하는 식으로 구현할 수도 있다. 이는 다음과 같이 Blocking 방식으로 구현한 것이다.

```
def choice[A](cond: Par[Boolean]])(t: Par[A], f: Par[A]): Par[A] =
  es =>
    if (run(es)(cond).get) t(es) // cond의 결과가 나올 때까지 Blocking
    else f(es)
```

이 조합기는 cond를 실행하고, 결과가 나오면 t나 f 중 하나를 실행한다. 여기서 Boolean을 사용하는 것과, **두** 병렬 계산 t와 f 중 하나를 선택한다는 사실은 다소 자의적이다. 어떤 조건에 기초해서 두 병렬 계산 중 하나를 선택하는 것이 유용하다면, N개의 계산 중 하나를 선택하는 것도 당연히 유용할 것이다.

```
def choiceN[A](n: Par[Int])(choices: List[Par[A]]): Par[A] =
  es => {
    val ind = run(es)(n).get
    run(es)(choices(ind))
  }
```

이 choiceN은 n을 실행하고, 그 결과에 기초해서 choices의 병렬 계산 중 하나를 선택한다. 하지만 choiceN에도 여전히 자의적인 구석이 남아 있다. List를 사용하는 것은 필요 이상으로 구체적인것 같다. 이 조합기는 컨테이너의 구체적인 종류에 구애받을 필요가 없다. 예를 들어, 계산들의 목록 대신 계산들의 Map이 있다면 어떨까?

```
def choiceMap[K, V](key: Par[K])(choices: Map[K, Par[V]]): Par[V]
  es => {
    val k = run(es)(key).get
    run(es)(choices(k))
  }
```

List와 마찬가지로, 가능한 선택들의 집합을 이처럼 Map으로 표현하는 것도 필요 이상으로 구체적이다. choiceMap의 구현을 살펴보면 Map의 API는 그리 많이 사용하지 않음을 알 수 있다. Map[A, Par[B]]는 단지 A => Par[B] 형식의 함수를 제공하는 데 쓰일 뿐이다. 이 점을 염두에 두고 choice와 choiceN을 다시 보면, choice에서는 한 쌍의 인수들이 그냥 Boolean => Par[A] 형식의 함수로 쓰이고 choiceN에서는 목록이 Int => Par[A] 형식의 함수로 쓰일 뿐이다.

이를 모두 통합하는 일반적인 시그니처를 만든다면 다음과 같다.

```
def chooser[A, B](pa: Par[A])(choices: A => Par[B]): Par[B]
  es => {
    val k = run(es)(p).get
    run(es)(choices(k))
  }
```

함수들을 이런 식으로 일반화할 때에는, 일반화의 결과로 나온 함수를 비판적으로 살펴보기 바란다. chooser는 일단 실행되면 첫 계산을 실행하고 그 결과에 따라 둘째 계산을 결정하는 하나의 병렬 계산이다. 그런데 첫 계산의 결과가 준비되기 전에 둘째 계산이 반드시 존재해야 할 필요는 없다. List나 Map 같은 컨테이너에 저장해 둘 필요가 없는 것이다. 첫 계산의 결과를 이용해서 둘째 계산을 즉석에서 생성할 수도 있다. 함수적 라이브러리에 흔히 등장하는 그러한 함수를 흔히 bind나 flatMap이라고 부른다.

```
def flatMap[A,B](p: Par[A])(choices: A => Par[B]): Par[B] =
  es => {
    val k = run(es)(p).get
    run(es)(choices(k))
  }
```

flatMap이라는 이름은 이 연산을 두 단계를 분해할 수 있음을 암시한다. 첫 단계는 Par[A]에 f: A => Par[B]를 **mapping해서** Par[Par[B]]를 생성하는 것이고, 둘째 단계는 Par[Par[B]]를 **flattening해서** Par[B]를 만드는 것이다. **임의의** x에 대해 Par[Par[X]]를 Par[X]로 변환하는 **간단한** 조합기를 추가하기만 하면 된다는 점을 암시해 준다. 그런 조합기를 join이라고 부르자.

```
def join[A](a: Par[Par[A]]): Par[A] =
  es => run(es)(run(es)(a).get())
```

함수의 이름을 join이라고 한 것은, 개념적으로 이 함수는 일단 실행되면 내부 계산을 실행하고, 그 계산이 완료되길 기다리고(Thread.join과 비슷하게), 그 결과를 돌려주기 때문이다.

> **대수의 표현력과 한계 인식**
> 함수형 프로그래밍을 계속 연습하다 보면 **대수로부터 표현할 수 있는 함수**들과 그 대수의 한계들을 인식하는 능력이 생긴다. 한 예로, 앞의 예제에서 choice 같은 함수를 map과 map2, unit 만으로 순수하게 표현할 수는 없다는 점을 처음부터 명백하게 인식하지는 못했을 것이다. 또한 choice가 단지 flatMap의 특수 경우라는 점도 명백하지 않았을 것이다. 시간이 지나면 이런 부분을 좀 더 일찍 인식하게 될 것이고, 필요한 조합기를 표현할 수 있도록 대수를 수정하는 방법 역시 좀 빨리 찾아내게 될 것이다. 이러한 능력은 모든 API 설계 작업에 도움이 된다.<br/>
> 실무의 관점에서 볼 때, API를 최소한의 기본 함수들로 줄이는 능력은 대단히 유용하다. parMap을 기존의 조합기들을 이용해서 구현할 때 언급했듯이, 기본적인 조합기들은 다소 까다로운 논리를 캡슐화하고 있는 경우가 많으며, 그런 것들을 재사용하면 까다로운 논리를 되풀이해서 다룰 필요가 없다.

# Reference
- [Functional Programming in Scala](https://www.manning.com/books/functional-programming-in-scala)
- [Scala's lazy arguments: How do they work?](https://code.i-harness.com/en/q/95ada1)
