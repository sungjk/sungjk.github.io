---
layout: entry
title: JavaScript ES6+. var, let, or const?
author: 김성중
author-email: ajax0615@gmail.com
description: ㅁㄴㅇㄹ
publish: true
---

Eric Elliott님의 [JavaScript ES6+: var, let, or const?](https://medium.com/javascript-scene/javascript-es6-var-let-or-const-ba58b8dcde75#.igl7uvbta)를 번역한 글입니다.

## JavaScript ES6+: var, let, or const?
더 나은 개발자가 되기 위해 배울 수 있는 가장 중요한 것은 간결함을 유지하는 것입니다. 식별자(identifier) 문맥에서, **하나의 식별자는 하나의 대상을 표현하기 위해서만 사용해야 한다** 는 것을 의미한다.

때때로 어떤 데이터를 나타내기 위해 식별자를 생성하는 것은 매력적이며, 이 식별자를 사용하여 하나의 표현에서 다른 것으로 바꿀 때 값을 임시로 저장할 수 있다.

예를 들어, 쿼리 문자열 매개 변수 값을 입력하고, 전체 URL을 저장한 다음, 쿼리 문자열을 저장하고, 다음 값을 입력할 수도 있다. 이러한 관행은 피해야 한다.

이는 URL에 대해 하나의 식별자를 사용하고, 쿼리 문자열에 대해 다른 하나의 식별자를 사용하고, 마지막으로 매개 변수 값을 다른 식별자에 저장하는 것이 이해하기에 더 쉽다.

이것이 내가 ES6에 있는 'let'보다 'const'를 선호하는 이유이다. 자바스크립트에서 'const'는 식별자를 재할당할 수 없음을 의미한다. (불변하는 값 *immutable values* 과 혼동해서는 안된다. 'const'는 수정된 속성을 가질 수 있다.)

만약 재할당이 필요하지 않다면, 'let'보다 **'const'가 나의 초기 선택(default choice)이다.** 코드에서 가능한한 투명하게 사용할 수 있기 때문이다.

변수를 재할당할 필요가 있을 때 'let'을 사용한다. 나는 **하나의 변수는 한가지만 표현하기 위해 사용** 하기 때문이다. 예를 들어, 'let'은 루프나 수학적 알고리즘에 사용되는 경향이 있다.

나는 ES6에서 'var'를 사용하지 않는다. 루프의 블록 스코프에 변수가 있더라도, 나는 'let'보다 'var'를 선호해야 하는 상황을 떠올릴 수 없다.

**'const'** 는 **식별자가 재할당되지 않는다** 는 시그널이다.

**'let'** 은 알고리즘에서 값을 교체(value swap)하거나 반복문의 카운터와 같이 **변수가 재할당될 수 있다** 는 시그널이다. 또한 이는 포함된 함수 전체가 아닌, 이것이 **정의된 블록 내에서만** 사용될 것이라는 말이다.

**'var'** 는 이제 자바스크립트에서 변수를 정의할 때 **사용할 수 있는 가장 약한 시그널** 이다. 이 변수는 재할당될 수도 있고, 그렇지 아닐 수도 있다. 그리고 함수 전체에서 사용될 수도 있고, 그렇지 않을 수도 있다. 또한 블록이나 반복문의 용도로만 사용될 수도 있다.

#### 주의
ES6에서 'let'과 'const'를 함께 사용한다면, 'typeof'를 사용하여 식별자의 존재 여부를 확인하는 것은 더 이상 안전하지 않다.

```javascript
function foo() {
    typeof bar;
    let bar = 'baz';
}

foo();  // 참조에러: 초기화하기 전에 렉시컬 선언 'bar'에 접근할 수 없다.
```

하지만 당신은 ["Programming JavaScript Applications"](https://ericelliottjs.com/product/programming-javascript-applications-paper-ebook-bundle/)로부터 내 조언을 받아 볼 수 있을 것이고, 항상 식별자를 사용하기 전에 그것을 초기화하라.
