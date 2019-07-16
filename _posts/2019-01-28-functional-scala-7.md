---
layout: entry
post-category: scala
title: Functional Programming in Scala 8
author: 김성중
author-email: ajax0615@gmail.com
description: Functional Programming in Scala의 8장(property-based testing)을 정리한 글입니다.
publish: false
---

# 1. 속성 기반 검사의 간략한 소개
스칼라용 속성 기반 검사(property-based testing) 라이브러리인 ScalaCheck에서 속성(property)은 다음과 같다.

```java
val intList = Gen.listOf(Gen.choose(0, 100))

val prop =
    forAll(intList)(ns => ns.reverse.reverse == ns) &&
    forAll(intList)(ns => ns.headOption == ns.reverse.lastOption)

val failingProp = forAll(intList)(ns => ns.reverse == ns)

// 속성들을 점검한 예
scala> prop.check
+ OK, passed 100 tests.

scala> failingProp.check
! Falsified after 6 passed tests.
> ARG_0: List(0, 1)
```

여기서 intList는 List\[Int\]가 아니라 Gen\[List\[Int\]\]이다. Gen[List[Int]]는 List[Int] 타입의 testing suite를 생성하는 방법을 아는 녀석이다. 이 생성기(Generator)는 샘플을 제공하는데, 구체적으로 0과 100사이의 난수들로 채워진 리스트를 리턴한다. 이 생성기를 가지고 테스트할 데이터에 대해 조합, 합성, 재사용 등을 할 수 있다.

함수 forAll은 Gen[A] 형식의 생성기와 A => Boolean 형식의 함수를 적용해서 하나의 **속성** 을 만들어낸다. 이 속성은 생성기가 생성한 모든 값이 조건(함수)를 만족해야함을 단언한다(assert). 속성 중 하나라도 **반증**(falsification)하는 것이 전혀 없을 때에만 참이다.

prop.check을 호출하면 ScalaCheck는 무작위로 List[Int] 값들을 생성해서, 주어진 조건에 실패하는 경우가 있는지 검사한다.

# 2. 자료 형식과 함수의 선택



# Reference
- [Functional Programming in Scala](https://www.manning.com/books/functional-programming-in-scala)
- [Scala's lazy arguments: How do they work?](https://code.i-harness.com/en/q/95ada1)
