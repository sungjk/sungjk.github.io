---
layout: entry
title: ECMAScript 6 Features Overview & Comparison
author: 김성중
author-email: ajax0615@gmail.com
description: ECMAScript 6에서 지원하는 새로운 Feature에 대한 비교 설명입니다.
publish: false
---

#### Constants
변수가 새로운 내용으로 재할당 될 수 없도록 하는 상수("불변값"이라 불리는)를 지원한다.
주의할 점: 할당된 내용이 아닌 변수 자체를 변경 불가능하게 만든다(예를 들어, 대상이 객체일 경우, 객체의 내용은 여전히 바뀔 수 있음을 의미한다).

```javascript
// ES6
const PI = 3.141593
// 결과: PI > 3.0

// ES5에서는 블록 스코프가 아닌 글로벌 컨텍스트의 객체 프로퍼티를 통해서만 가능하다.
Object.defineProperty(typeof global === "object" ? global : window, "PI", {
    value:        3.141593,
    enumerable:   true,
    writable:     false,
    configurable: false
});
// 결과: PI > 3.0;
```

---

#### Block-Scoped Variables
호이스팅 없이 블록 스코프 변수(상수)를 지원한다.

```javascript
// ES6
for (let i = 0; i < a.length; i++) {
    let x = a[i]
    ...
}
for (let i = 0; i < b.length; i++) {
    let y = b[i]
    ...
}

let callbacks = []
for (let i = 0; i <= 2; i++) {
    callbacks[i] = function () { return i * 2 }
}
callbacks[0]() === 0
callbacks[1]() === 2
callbacks[2]() === 4

// ES5
var i, x, y;
for (i = 0; i < a.length; i++) {
    x = a[i];
    ...
}
for (i = 0; i < b.length; i++) {
    y = b[i];
    ...
}

var callbacks = [];
for (var i = 0; i <= 2; i++) {
    (function (i) {
        callbacks[i] = function() { return i * 2; };
    })(i);
}
callbacks[0]() === 0;
callbacks[1]() === 2;
callbacks[2]() === 4;
```
