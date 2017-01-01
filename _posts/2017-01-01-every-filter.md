---
layout: entry
title: Javascript native array method - every, filter
author: 김성중
author-email: ajax0615@gmail.com
description: 자바스크립트 배열의 네이티브 메서드인 every와 filter에 대한 설명입니다.
publish: true
---

2017년 첫 포스트입니다!

ECMAScript 5에서는 5개의 네이티브 순회 메서드 every(), filter(), map(), some(), forEach()를 제공한다. 각 메서드들은 두 개의 인수(각 항목에서 실행될 함수와 함수를 실행하기 위한 스코프 객체)를 허용한다.

## every()
every() 메서드는 항상 "true"나 "false"의 불리언 값을 리턴하는데, 이는 배열의 모든 항목에 대해 실행되는 함수에서 리턴되는 값이다. 모든 항목에 대한 함수의 리턴값이 "true"라면 every() 메서드는 "true"를 반환하고, 하나라도 "false"를 반하면 every() 메서드는 "false"를 반환한다. 예제를 통해 확인해보자.

```javascript
// 어떠한 값도 리턴하지 않으면 'null'을 리턴하는 것과 같다.
// null, undefined, NaN은 false로 치환될 수 있다.
let arr = [1, 2, 3, 4, 5, 6];
const res = arr.every(function(item, index, array) {
});
console.log(res); // false

// arr2의 모든 원소들은 true를 리턴한다.
let arr2 = [1, 2, 3, 4, 5, 6];
const res2 = arr2.every(function(item, index, array) {
    return item;
});
console.log(res2); // true

// arr3의 원소 중 null이 포함되어 있기 때문에, null에 해당하는 함수에서 false를 리턴한다.
let arr3 = [1, 2, 3, null, 4, 5, 6];
const res3 = arr3.every(function(item, index, array) {
    return item;
});
console.log(res3); // false

let arr4 = [1, 2, 3, 4, 5, 6];
const res4 = arr4.every(function(item, index, array) {
    return item > 0;
});
console.log(res4); // true

let arr5 = [1, 2, 3, 4, 5, 6];
const res5 = arr5.every(function(item, index, array) {
    return item > 1;
});
console.log(res5); // false

['a', 'b', 'c'].every(function(item, index, arr){
    console.log(this); // Window
});

['a', 'b', 'c'].every(function(item, index, arr){
    console.log(this); // String {0: "j", 1: "e", 2: "r", 3: "e", 4: "m", 5: "y"}
}, 'jeremy');


['a', 'b', 'c'].every(function(item, index, arr){
    console.log(this.name); // jeremy
}, {name: 'jeremy'});
```

## filter()
filter() 메서드는 제공된 함수의 테스트를 통과한 원소들로 채워진 새로운 배열을 생성한다. 이러한 특성 떄문에 filter 메서드는 주로 배열의 원소 중에서 공통된 특성을 가진 원소들을 구분하고 싶을 때 사용된다.

```javascript
let playersArr = [
    {name: 'Jason', footedness: 'left', position: 'forward'},
    {name: 'Blake', footedness: 'right', position: 'defense'},
    {name: 'Philip', footedness: 'right', position: 'goalie'},
    {name: 'Logan', footedness: 'left', position: 'defense'},
    {name: 'Will', footedness: 'right', position: 'forward'}
];
let leftFootArr = playersArr.filter(function(player){
    return player.footedness === 'left';
});

console.log(leftFootArr);
// [{name: 'Jason', footedness: 'left', position: 'forward'}, {name: 'Logan', footedness: 'left', position: 'defense'}]
```
