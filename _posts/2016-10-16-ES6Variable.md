---
layout: entry
title: JavaScript ES6+. var, let, or const?
author: 김성중
author-email: ajax0615@gmail.com
description: ES6에서 블록 레벨과 함수 레벨을 모두 지원하면서 var, let, const의 사용에 대한 Eric Elliott님의 개인적인 의견입니다.
publish: true
---

Eric Elliott님의 [JavaScript ES6+: var, let, or const?](https://medium.com/javascript-scene/javascript-es6-var-let-or-const-ba58b8dcde75#.igl7uvbta)를 번역한 글입니다.

## JavaScript ES6+: var, let, or const?
더 나은 개발자가 되기 위해 배워야 하는 가장 중요한 것은 간결함을 유지하는 것이다. 식별자(identifier) 문맥을 예로 들면, **하나의 식별자는 하나의 대상을 표현하기 위해서만 사용해야 한다.**

어떤 데이터를 표현내기 위해 식별자를 만드는 것은 매력적이고, 이 식별자를 사용하여 하나의 표현에서 다른 것으로 바꿀 때 값을 임시로 저장할 수 있다.

예를 들어, 식별자에 쿼리 문자열 매개 변수 값을 입력하고, 전체 URL을 저장한 다음, 쿼리 문자열을 저장하고, 다음 값을 입력할 수도 있다. 하지만 이러한 관행은 피해야 한다.

위와 같은 방법보다 URL에 대해 하나의 식별자를 사용하고, 쿼리 문자열에 대해 다른 하나의 식별자를 사용하고, 매개 변수 값을 다른 식별자에 저장하는 것이 더 좋다.

위와 같은 이유로 나는 ES6에서 *let* 보다 *const* 를 선호한다. 자바스크립트에서, *const* 는 다시 할당할 수 없음을 나타낸다. (불변값 *immutable values* 과 혼동하지 말아야 한다. Immutable.js나 Mori같은 불변 데이터타입이 아닌, const 객체는 수정된 속성을 가질 수 있다.)

만약 식별자의 재할당이 필요하지 않다면, 나는 *let* 보다 ***const*** 를 선택할 것이다. 코드에서 명확한 용도로 사용될 수 있기 때문이다.

식별자를 재할당할 필요가 있을 때 *let* 을 사용한다. **하나의 식별자를 한 가지 표현에만 사용**하기 때문이다. 예를 들어, *let* 은 루프나 수학적 알고리즘에 사용되는 경향이 있다.

나는 ES6에서 *var* 를 사용하지 않는다. 루프의 블록 스코프에 식별자가 있더라도 *let* 보다 *var* 가 나은 경우를 생각하기 힘들다.

**const** 는 **식별자가 재할당되지 않음**을 의미한다.

**let** 은 알고리즘에서 값을 교체(value swap)하거나 반복문의 카운터와 같이 **식별자가 재할당될 수 있음** 을 의미한다. 또한 이는 포함된 함수 전체가 아닌, **정의된 블록 내에서만** 사용된다.

**var** 는 자바스크립트에서 식별자를 정의할 때 **사용할 수 있는 가장 약한 시그널** 이다. var로 할당된 변수는 재할당될 수도 있고 아닐 수도 있다. 그리고 함수 전체에서 사용될 수도 있고, 그렇지 않을 수도 있다. 또한 블록이나 반복문의 용도로 사용될 수도 있다.

#### 주의
ES6에서 let과 const를 함께 사용할 때, typeof로 식별자의 존재 여부를 확인하는 것은 더 이상 안전하지 않다.

```javascript
function foo() {
    typeof bar;
    let bar = 'baz';
}

foo();  // 참조에러: 초기화하기 전에 렉시컬 선언된 'bar'에 접근할 수 없다.
```

당신은 ["Programming JavaScript Applications"](https://ericelliottjs.com/product/programming-javascript-applications-paper-ebook-bundle/)에서 내 조언을 받을 수 있고, 위와 같은 상황에서는 항상 식별자를 사용하기 전에 그것을 초기화하라.
