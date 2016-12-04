---
layout: entry
title: Rest & Spread Operators in ES6
author: 김성중
author-email: ajax0615@gmail.com
description: ES6에서 지원하는 multiple arguments를 처리하기 위한 Rest operator와 Spread operator에 대한 설명입니다.
publish: true
---

JSX로 작성된 React 코드를 보면 이상하게 생긴 연산자를 쉽게 볼 수 있다. three dots(...)라고 하는 이 녀석은 ES6에서 Rest 연산자와 Spread 연산자를 표현하기 위해 사용되고 있다. 함수의 여러 인수(multiple arguments)를 편리하게 처리하고, 배열 리터럴의 일부를 반복 가능한 식(다른 배열 리터럴 등)에서 초기화하거나 여러 인수로 확장할 수 있는 등 간편한 syntax를 제공하는 Rest 연산자와 Spread 연산자가 무엇인지 알아보자.

## 1. Rest operator(...)
**Rest operater** 는 [비구조화 할당(destructuring assignment)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment)에 의해 선택되지 않은 남은 열거형 속성 키를 할당해준다. 즉, 반복 가능한 대상에서 선택되지 않은 나머지 원소들을 배열로 추출해준다. spread 연산자를 사용하면 함수 호출의 여러 인수(multiple arguments)를 배열로 전환할 수 있기 때문에, 인수를 개별적으로 지정해주지 않아도 된다.

```javascript
// Rest 연산자는 나머지 원소들을 모아주는 역할을 하므로,
// 배열과 같은 곳에서 사용한다면 무조건 마지막에 명시를 해주어야 한다.
const [x, ...y] = ['a', 'b', 'c'];  
// x == 'a'
// y == ['b', 'c']

// 아무런 원소도 발견하지 못한다면, 빈 배열(Empty array)를 반환한다.
// 즉, undefined나 null 값을 만들지 않는다.
const [x, y, ...z] = ['a'];
// x == 'a'
// y == undefined
// z == []

// 피연산자(operand)는 단일 변수일 필요가 없다.
const [x, ...[y, z]] = ['a', 'b', 'c'];
// x == 'a'
// y == 'b'
// z == 'c'
```

## 2. The Spread operator(...)
Rest 연산자와 Spread 연산자 모두 three dots(...)를 사용해서 겉보기에는 서로 같아 보이지만, 서로 정반대의 의미를 가지고 있다.

- **Spread operator**: 반복 가능한 원소들을 함소 호출의 인수(arguments)나 배열의 원소들로 변환시켜 준다.
- **Rest operator**: 반복 가능한 나머지 원소들을 배열에 모아주고, rest parameters와 destructuring을 위해 사용된다.

```javascript
// Spread 연산자는 하나의 단일 변수(single variable)을 여러 개로 확장할 수 있다.
const abc = ['a', 'b', 'c'];
const def = ['d', 'e', 'f'];
const alpha = [...abc, ...def]; // ['a', 'b', 'c', 'd', 'e', 'f']

// Rest 연산자는 함수의 나머지 인수들을 하나의 배열로 만들어준다.
function sum(first, ...others) {
    for (let i = 0; i < others.length; ++i) {
        first += others[i];
    }
    return first;
}

sum(1, 2, 3, 4); // 10
```

#### 2.1 Spreading into function and method calls
Math.max()는 메서드 호출 안에서 spread 연산자가 어떻게 동작하는지 설명하기에 아주 좋은 예시이다. Math.max(x1, x2, ...)는 주어진 인수들 중 가장 큰 값을 리턴한다. 이 메서드는 인수로 수(number)는 허용하지만, 배열은 허용하지 않는다. 이러한 상황에서 spread operator를 적용시킬 수 있다.

```javascript
Math.max(-1, 5, 11, 3);      // 11
Math.max(-1, 5, [11, 3]);    // NaN
Math.max(...[-1, 5, 11, 3]); // 11

// rest 연산자와 대조적으로,
// spread 연산자를 연속되는 부분 어디에서든 사용할 수 있다.
Math.max(-1, ...[-1, 5, 11], 3); // 11
```

다른 예로 자바스크립트에서 배열의 원소들을 다른 배열에 파괴적으로 추가(append)할 때, 배열은 spread operator를 활용해서 모든 인수를 추가해주는 push(x1, x2, ...) 메서드를 가지고 있다. 아래 코드는 arr1에 arr2의 원소를 어떻게 추가하는지 보여준다.

```javascript
const arr1 = ['a', 'b'];
const arr2 = ['c', 'd'];

arr1.push(...arr2);
// arr1 is now ['a', 'b', 'c', 'd']
```

#### 2.2 Spreading into constructors
함수나 메서드 호출에서 사용했던 것처럼, 생성자 호출에도 spread 연산자를 사용할 수 있다.

```javascript
new Date(...[2016, 12, 25]);
```

#### 2.3 Spreading into Arrays
배열에 Spread 연산자를 어떻게 사용하는지 코드를 통해 알아보자.

```javascript
// 배열 리터럴에도 spread 연산자를 사용할 수 있다.
[1, ...[2, 3], 4] // [1, 2, 3, 4]

// 배열들을 연결(concatenate)할 때 매우 편리하다.
const x = ['a', 'b'];
const y = ['c'];
const z = ['d', 'e'];

const arr = [...x, ...y, ...z]; // ["a", "b", "c", "d", "e"]
```

spread 연산자의 이점은 반복 가능한 어떠한 값이든 피연산자(operand)로 사용할 수 있다는 것이다(반복을 지원하지 않는 배열의 concat() 메소드와 대조적임).

#### 2.3.1 Converting iterable or Array-like objects to Arrays
다음과 같이 spread 연산자는 반복 가능한 값을 배열로 변환해준다.

```javascript
// Set을 배열로 변환
const set = new Set([11, -1, 6]);
const arr = [...set];   // [11, -1, 6]

// 반복 가능한 객체를 배열로 변환
const obj = {
    * [Symbol.iterator]() {
        yield 'a';
        yield 'b';
        yield 'c';
    }
};
const arr = [...obj];   // ['a', 'b', 'c']
```

주의! *for-of* 루프처럼, spread operator는 반복 가능한 값들에만 적용할 수 있다. 모든 빌트-인 된 자료구조(Array, Map, Set)는 반복 가능하다.

#### 2.4 Spreading into component props in React
React에서 부모의 속성을 자식에게 전달할 때 다음과 같이 spread 연산자를 사용할 수 있다.

```javascript
let props = {};
props.foo = x;
props.bar = y;

const component = <Component {...props} />;
```


## 참조
- [Destructuring](http://exploringjs.com/es6/ch_destructuring.html)

- [Parameter handling](http://exploringjs.com/es6/ch_parameter-handling.html#sec_spread-operator)
