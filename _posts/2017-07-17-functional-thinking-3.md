---
layout: entry
post-category: fp
title: 함수형 사고(3)
author: 김성중
author-email: ajax0615@gmail.com
description: 함수형 사고 - 객체지향 개발자에서 함수형 개발자로 거듭나기
publish: true
---

가비지 컬렉션 같은 저수준 세부사항의 조작을 런타임에 양도함으로써 찾아야 할 수많은 오류를 방지해주는 능력이야말로 함수형 사고의 가치라고 하겠다. 대다수의 개발자들은 메모리와 같은 기본 추상적 개념을 문제없이 무시하는 데 익숙하겠지만, 더 높은 단계에서 나타나는 추상화는 낯설어한다. 하지만 이런 고수준 추상 개념들도 기계장치의 지루한 일들을 처리해줌으로써 개발자가 자신의 문제에 고유한 측면을 연구할 시간을 제공한다는 측면에서 똑같은 역할을 수행한다.

# 3.1 반복 처리에서 고계처함수로
고계함수 내에서 어떤 연산을 할 것인지를 표현하기만 하면, 언어가 그것을 능률적으로 처리할 것이다.

# 3.2 클로저
모든 함수형 언어는 클로저를 포함한다. 하지만 이 언어 기능은 종종 신비에 싸인 것처럼 언급되곤 한다. **클로저(Closure)** 란 그 내부에서 참조되는 모든 인수에 대한 묵시적 바인딩을 지닌 함수를 칭한다. 다시 말하면 **이 함수(또는 메서드)는 자신이 참조하는 것들의 문맥(context)을 포함한다.**

예제 3-1. 그루비에서의 간단한 클로저 바인딩

```
class Employee {
  def name, salary
}

def paidMore(amount) {
  return { Employee e -> e.salary -> amount }
}

isHighPaid = paidMore(100000)
```

두 개의 필드가 있는 Employee 클래스가 정의된다. 그리고 amount 매개변수를 받는 paidMore 함수가 정의된다. 이 함수의 리턴 값은 **클로저** 라는 코드 블록이다. 이 코드 블록에 1000000을 매개변수로 주고 isHighPaid란 인수에 할당한다. 이렇게 하면 1000000의 값은 이 코드 블록에 영원히 **바인딩** 된다.

예제 3-2. 클로저 블록의 실행

```
def Smithers = new Employee(name:"Fred", salary:120000)
def Homer = new Employee(name:"Homer", salary:80000)
println isHighPaid(Smithers)
println isHighPaid(Homer)
// true, false
```

클로저가 생성될 때에, 이 코드 블록의 스코프에 포함된 인수들을 둘러싼 상자가 같이 만들어진다. 그래서 이름도 **클로저** 라 지어졌다.

예제 3-3. 또 다른 클로저 바인딩

```
isHighPaid = paidMore(200000)
println isHighPaid(Smithers)
println isHighPaid(Homer)
def Burns= new Employee(name:"Monty", salary:100000)
println isHighPaid(Burns)
```

다른 값을 바인딩해서 paidMore 클로저를 하나 더 만들 수 있다. 클로저는 **함수형 언어나 프레임워크에서 코드 블록을 다양한 상황에서 실행하게 해주는 메커니즘으로 많이 쓰인다.** 클로저를 map()과 같은 고계함수에 자료 변형 코드 블록으로 전달하는 것이 대표적인 예이다.

예제 3-4. 그루비에서 클로저의 작동 원리

```
def Closure makeCounter() {
  def local_variable = 0
  return { return local_variable += 1 }  // 이 함수의 리턴 값은 값이 아니라 코드 블록이다.
}

c1 = makeCounter()  // c1은 이 코드블로긔 인스턴스를 가리킨다.
c1()  // 내부 인수가 증가한다.
c1()
c1()

c2 = makeCounter() //새로운 인스턴스를 가리킨다.

println "c1 = ${c1()}, c2 = ${c2()}"
// c1 = 4, c2 = 1 // 각각의 인스턴스는 local_variable에 다른 내부 상태를 지니고 있다.
```

두 개의 코드 블록이 각각의 local_variable 값을 유지하는 것을 주의해서 보자. **클로저(Closure)** 란 단어의 어원이 **문맥을 포괄함(enclosing context)** 이란 점에서 이 작업의 내용을 추측할 수 있을 것이다. 이 지역 인수는 함수 내부에서 정의되어있지만, 코드 블록이 이 인수에 바인딩되어 있고, 따라서 코드 블록이 존재하는 동안에 이 인수 값은 유지되어야 한다.

예제 3-5. 자바로 구현한 makeCounter()

```
class Counter {
  public int varField;

  Counter(int var) {
      varField = var;
  }

  public static Counter makeCounter() {
     return new Counter(0);
  }

  public int execute() {
    return ++varField;
  }
}
```

여러 가지 변형된 Counter 클래스 (익명 클래스나 제네릭을 사용한) 구현이 가능하지만, 어떤 경우에나 개발자가 직접 내부 상태를 관리해야 한다. 왜 클로저의 사용이 함수적 사고를 예시하는지가 여기에서 분명해진다. **런타임에 내부 상태의 관리를 맡겨버리는 것이다.**

클로저는 **지연 실행(deferred execution)** 의 좋은 예이다. 클로저 블록에 코드를 바인딩함으로써 그 블록의 실행을 나중으로 연기할 수 있다.

명령형 언어는 상태로 프로그래밍 모델을 만든다. 그 좋은 예가 매개변수를 주고 받는 것이다. 클로저는 코드와 문맥을 한 구조로 캡슐화해서 행위의 모델을 만들 수 있게 해준다.

# 3.3 커링과 부분 적용
커링이나 부분 적용은 함수나 메서드의 인수의 개수를 조작할 수 있게 해준다. 주로 인수 일부에 기본값을 주는 방법을 사용한다.

#### **3.3.1 정의와 차이점**
- **커링(currying)**: 다인수(multiargument) 함수를 일인수(single-argument) 함수들의 체인으로 바꿔주는 방법이다. 이것은 그 변형 과정이지 변형된 함수를 실행하는 것을 지칭하는 것은 아니다. 함수의 호출자가 몇 개의 인수를 고정할지를 결졍하며 적은 수의 인수를 가지는 함수를 유도해낸다.
- **부분 적용(partial application)**: 주어진 다인수 함수를 생략될 인수의 값을 미리 정해서 더 적은 수의 인수를 받는 하나의 함수로 변형하는 방법이다. 이 방법은 이름이 의미하듯이 몇몇 인수에 값을 미리 적용하고 나머지 인수만 받는 함수를 리턴한다.

커링이나 부분 적용 모두 몇몇 인수의 값만 주면 인수가 몇 개 빠져도 호출할 수 있는 함수를 리턴해준다. 다만 **커링은 체인의 다음 함수를 리턴하는 반면에, 부분 적용은 주어진 값을 인수에 바인딩시켜 인수가 더 작은 하나의 함수를 만들어준다.**

예를 들자면 process(x, y, z)의 완전히 커링된 버전은 process(x)(y)(z)이다. 여기에서 process(x)와 process(x)(y)는 인수가 하나인 함수이다. 첫 인수만 커링을 하면 process(x)의 리턴 값은 인수가 하나인(여기서는 y) 또 하나의 함수이다. 이 함수의 리턴 값은 또 하나의 일인수 함수이다. 반면에 부분 적용을 사용하여 변환하면 인수 숫자가 적은 함수가 남는다. process(x, y, z)의 인수 하나를 부분 적용하면 인수 두 개짜리의 process(y, z)가 된다.

#### **스칼라**
스칼라는 제약이 있는 함수를 정의할 수 있는 트레이트와 함께 커링과 부분 적용을 모두 지원한다.

예제 3-10. 스칼라의 인수 커링

```
object CurryTest extends App {
  def filter(xs: List[Int], p: Int => Boolean): List[Int] =
    if (xs.isEmpty) xs
    else if (p(xs.head)) xs.head :: filter(xs.tail, p)
    else filter(xs.tail, p)

  def modN(n: Int)(x: Int) = ((x % n) == 0)

  val nums = List(1, 2, 3, 4, 5, 6, 7, 8)
  println(filter(nums, modN(2)))
  println(filter(nums, modN(3)))
}
```

filter() 함수는 재귀적으로 주어진 필터 조건을 적용한다. modN() 함수는 두 개의 인수 목록으로 정의된다. modN()을 filter()의 인수로 호출할 때에는 인수 하나를 전달한다. 여기서 filter() 함수는 두 번째 인수로 Int 인수를 받아 Boolean을 리턴하는 함수를 받는다. 이 함수의 시그니처는 여기서 전달된 커링된 함수의 시그니처와 같다.

예제 3-11. 스칼라에서의 부분 적용

```
def price(product: String) : Double =
  product match {
    case "apples" => 140
    case "oranges" => 223
}

def withTax(cost: Double, state: String) : Double =
  state match {
    case "NY" => cost * 2
    case "FL" => cost * 3
}

val locallyTaxed = withTax(_: Double, "NY")
val costOfApples = locallyTaxed(price("apples"))

asset(Math.round(costOfApples) == 280)
```

먼저 제품과 가격 사이의 매핑을 리턴하는 price() 함수를 만든다. 다음으로 그 비용과 판매 지역인 주(state)를 인수로 받는 withTax() 함수를 만든다. 여기서 필요 없는 인수(state)를 계속해서 끌고 다니지 않고, 그것을 부분 적용해서 고정한 함수를 리턴한다. 이 locallyTaxed() 함수는 비용(cost) 하나만을 인수로 받는다.

# 3.4 스트림과 작업 재정렬
명령형에서 함수형 스타일로 바꾸면 얻는 것 중의 하나가 런타임이 효율적인 결정을 할 수 있게 된다는 점이다.

```
public String cleanNames(List<String> names) {
  if (names == null) return "";
  return names
    .stream()    
    .map(e -> capitalize(e))
    .filter(n -> n.length() > 1)
    .collect(Collectors.joining(","));
}
```

여기서는 map()작업이 filter()보다 먼저 실행된다. 명령형 사고로는 당연히 필터 작업이 맵 작업보다 먼저 와야한다. 그래야 맵 작업의 양이 줄어든다. 하지만 함수형 언어에는 Stream이란 추상 개념이 정의되어 있다. Stream은 여러모로 컬렉션과 흡사하지만 바탕 값이 없다. 하지만 원천에서 목적지까지 값들이 흐르게끔 한다. 원천은 names 컬렉션이고 목적지는 collect() 함수이다. 이 두 작업 사이에서 map()과 filter()는 **게으른** 함수이다. 이들은 실행을 가능하면 미룬다. 이들은 목적지에서 요구하지 않으면 결과를 내려고 시도하지도 않는다.

런타임은 필터를 맵 작업 전에 실행하여 게으른 작업을 효율적으로 재정렬할 수도 있다. 런타임에 최적화를 맡기는 것이 양도의 중요한 예이다. 시시콜콜한 세부사항은 버리고 문제 도메인의 구현에 집중하게 되는 것이다.

# Reference
[함수형 사고](http://www.hanbit.co.kr/store/books/look.php?p_code=B6064588422)
