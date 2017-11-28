---
layout: entry
post-category: fp
title: 함수형 사고(4)
author: 김성중
author-email: ajax0615@gmail.com
description: 함수형 사고 - 객체지향 개발자에서 함수형 개발자로 거듭나기
publish: true
---

# 4.1 메모이제이션
메모이제이션은 다음과 같은 상황에서 유용하다. 시간이 많이 걸리는 연산을 반복적으로 사용해야 한다고 가정해보자. 보편적인 해결 방법은 내장 캐시를 설정하는 것이다. **주어진 매개변수를 사용하여 연산을 할 때마다 그 값을 매개변수를 키 값으로 하는 캐시에 저장한다.** 후에 이 함수가 같은 매개변수로 호출되면 다시 연산하는 대신에 캐시의 값을 리턴한다.

캐싱 방법이 제대로 작동하려면 함수가 **순수** 해야 한다. **순수함수** 란 부수 효과가 없는 함수를 말한다. 불변 클래스 필드를 참고하지도 않고, 리턴 값 외에는 아무 값도 쓰지 않아야 하며, 주어진 매개변수에만 의존해야 한다. java.lang.Math의 모든 메서드가 순수함수의 좋은 예이다. 물론, 주어진 매개변수에 대해 항상 같은 값을 리턴하는 함수에 한해서만 캐시된 값을 재사용할 수 있다.

#### **4.1.1 캐싱**
**1. 메서드 레벨에서의 캐싱**<br/>
다음의 코드에서 Classifier 클래스는 자연수를 분류한다. 분류를 위해 같은 수를 이 클래스의 여러 메서드에 주는 일이 다반사이다.

```java
if (Classifier.isPerfect(n)) print "!"
else if (Classifier.isAbundant(n)) print "+"
else if (Classifier.isDeficient(n)) print "-"
```

이렇게 구현한 경우, 모든 분류 메서드를 호출할 때마다 매개변수의 합을 계산해야 한다. 이것이 **클래스 내부 캐싱(intraclass caching)** 의 예이다. 이 경우 sumOfFactors()가 각각의 수에 대해 여러번 호출된다. 이렇게 자주 사용된다면 이는 상당히 비효율적인 접근 방법이다.

**2. 합산 결과를 캐시하기**<br/>
이미 수행된 결과를 재사용하는 것이 코드를 효율적으로 만드는 한 방법이다. 매개변수의 합을 구하는 것이 어렵기 때문에 각 수마다 한 번만 계산하고자 한다.

예제 4-1. 합을 캐시하기(그루비)

```
package com.nealford.ft.memoization

class ClassifierCachedSum {
    private sumCache = [:]

    def sumOfFactors(number) {
        if (! sumCache.containsKey(number)) {
            sumCache[number] = factorsOf(number).sum()
        }
        return sumCache[number]
    }
}
```

클래스를 초기화할 때 sumCache란 해시를 만든다. sumOfFactors() 메서드 내부에서는 캐시에 매개변수의 합이 들어 있으면 그 값을 바로 리턴한다. 값이 없으면 힘든 계산을 수행하고 리턴 값을 캐시에 넣은 후에 리턴한다.

최적화하지 않은 버전과 캐시된 버전의 첫 번째 시도에서의 시간 차이는 무시할 수 있을 정도로 작지만, 두 번째 시도에서는 그 차이가 엄청나다. 이것이 **외부 캐싱** 의 예이다. 캐시된 결과는 호출하는 모든 코드가 사용하게 되며, 그래서 두 번째 시도는 무척 빨라진다.

**3. 전부 다 캐시하기**<br/>
합을 캐싱해서 코드가 많이 빨라졌으니, 모든 중간 결과를 캐시하면 어떤 결과가 나올까?

예제 4-2. 전부 다 캐시하기

```
class ClassifierCached {
    private sumCache = [:], factorCache = [:]

    def sumOfFactors(number) {
        if (! sumCache.containsKey(number))
        sumCache[number] = factorsOf(number).sum()
        sumCache[number]
    }

    def isFactor(number, potential) {
        number % potential == 0;
    }

    def factorsOf(number) {
        if (! factorCache.containsKey(number))
        factorCache[number] = (1..number).findAll {isFactor(number, it)}
        factorCache[number]
    }

    def isPerfect(number) {
        sumOfFactors(number) == 2 * number
    }

    def isAbundant(number) {
        sumOfFactors(number) > 2 * number
    }

    def isDeficient(number) {
        sumOfFactors(number) < 2 * number
    }
}
```

ClassifierCached 클래서에서는 매개변수의 합과 자연수 매개변수들에 대한 캐시를 더했다. 전부 다 캐시한 버전(새로운 인스턴스 변수를 가지고 있는 새로운 클래스)은 첫 시도에서 411ms가 걸렸고, 캐시가 꽉 찬 후의 둘째 시도에서는 빠른 38ms가 걸렸다. 결과는 매우 좋지만 이 방법은 규모를 늘리기가 어렵다. 다음에 보이는 것처럼 8,000까지 테스트를 해보면 그 결과는 비참하다.

> java.lang.OutOfMemoryError: Java heap space

이 결과에서 볼 수 있듯이, 캐싱 코드를 작성하는 개발자는 정확함과 함께 실행 조건도 신경써야 한다. 이것이 '움직이는 부분'의 적절한 예이다. 코드 내의 상태와 그 의미를 개발자가 항상 관리해야만 한다. 수많은 언어가 이미 **메모이제이션** 과 같은 메커니즘을 사용하여 이러한 제약을 극복해냈다.

#### **4.1.2 메모이제이션의 첨가**
함수형 프로그래밍은 런타임에 재사용 가능한 메커니즘을 만들어서 움직이는 부분을 최소화하는 데 주력한다. **메모이제이션은 프로그래밍 언어에 내장되어 반복되는 함수의 리턴 값을 자동으로 캐싱해주는 기능** 이다.

그루비에서 함수를 메모아이즈하기 위해서는 함수를 클로저로 정의하고, 리턴 값이 캐시되는 함수를 리턴하는 memoize() 메서드를 실행해야 한다. 함수를 메모아이즈하는 것을 **메타함수** 를 적용하는 것이라고 할 수 있다. 즉 리턴 값이 아니라 함수에 어떤 것을 적용하는 것이다. 3장에서 거론했던 커링도 하나의 메타함수 기법이다. 그루비는 Closure 클래스에 메모이제이션을 내장했고 다른 언어들은 각기 다른 방법으로 이것을 구현한다.

메모아이즈하는 대상의 불변성(immutability)에 대해 다시 한번 강조해야겠다. 메모아이즈된 함수의 결과가 매개변수 이외의 어떤 것에라도 의존하면 기대하는 결과를 항상 얻을 수는 없다. 메모아이즈된 함수에 부수효과가 있다면 캐시된 값이 리턴되어도 그 코드를 믿을 수 없기 때문이다.

메모아이즈된 함수는<br/>
    - 부수 효과가 없어야 하고,<br/>
    - 외부 정보에 절대로 의존하지 말아야 한다.

런타임이 갈수록 정교해지고, 사용할 수 있는 기계 자원이 풍부해지면서, 모든 주류 언어에 메모이제이션과 같은 고급 기능들이 일반화되고 있다. 일례로 자바 8은 내장된 메모이제이션이 없지만 새로 도입된 람다 기능을 사용하면 쉽게 구현할 수 있다.

# 4.2 게으름
표현의 평가를 가능한 최대로 늦추는 기법인 게으른 평가는 함수형 프로그래밍 언어에서 많이 볼 수 있는 기능이다. 게으른 컬렉션은 그 요소들을 한꺼번에 미리 연산하는 것이 아니라, 필요에 따라 하나씩 전달해준다. 이렇게 하면 몇 가지 이점이 있다. 우선 시간이 많이 걸리는 연산을 반드시 필요할 때까지 미룰 수 있게 된다. 둘째로, 요청이 계속되는 한 요소를 계속 전달하는 무한 컬렉션을 만들 수 있다. 셋째로, 맵이나 필터 같은 함수형 개념을 게으르게 사용하면 효율이 높은 코드를 만들 수 있다.

# Reference
[함수형 사고](http://www.hanbit.co.kr/store/books/look.php?p_code=B6064588422)
