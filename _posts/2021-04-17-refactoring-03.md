---
layout: entry
post-category: refactoring
title: 리팩터링 3 - Refactoring 3
author: 김성중
author-email: ajax0615@gmail.com
description: 마틴 파울러의 리팩터링 2판(코드 구조를 체계적으로 개선하여 효율적인 리팩터링 구현하기)
keywords: 리팩터링, 리팩토링, refactoring
thumbnail-image: /images/profile/refactoring.png
next_url: /2021/04/17/refactoring-04.html
publish: true
---

# 8. 기능 이동

### 8.1 함수 옮기기(Move Function)
```javascript
// Before
class Account {
  get overdraftCharge() {...}
}

// After
class AccountType {
  get overdraftCharge() {...}
}
```
- 좋은 소프트웨어 설계의 핵심은 모듈화가 얼마나 잘 되어 있느냐를 뜻하는 모듈성(modularity)이다. 모듈성이란 프로그램의 어딘가를 수정하려 할 때 해당 기능과 깊이 관련된 작은 일부만 이해해도 가능하게 해주는 능력이다.
- 모듈성을 높이려면 서로 연관된 요소들을 함께 묶고, 요소 사이의 연결 관계를 쉽게 찾고 이해할 수 있도록 해야 한다.
- 대상 함수를 호출하는 함수들은 무엇인지, 대상 함수가 호출하는 함수들은 또 무엇이 있는지, 대상 함수가 사용하는 데이터는 무엇인지를 살펴봐야 한다.
- 중첩 함수를 사용하다 보면 숨겨진 데이터까지 상호 의존하기가 아주 쉬우니 중첩 함수는 되도록 만들지 말자.

### 8.2 필드 옮기기(Move Field)
```javascript
// Before
class Customer {
  get plan() {return this._plan;}
  get discountRate() {return this._discountRate;}
}

// After
class Customer {
  get plan() {return this._plan;}
  get discountRate() {return this.plan.discountRate;}
}
```
- 경험과 도메인 주도 설계 같은 기술이 데이터 구조 잡기에 좋다.
- 프로젝트를 진행할수록 우리는 문제 도메인과 데이터 구조에 대해 더 많은 것을 배우게 된다.
- 현재 데이터 구조가 적절치 않음을 깨닫게 되면 곧바로 수정해야 한다.
- 한 레코드를 변경하려 할 때 다른 레코드의 필드까지 변경해야만 한다면 필드의 위치가 잘못되었다는 신호다.
- 클래스의 데이터들은 접근자 메서드들 뒤에 감춰져(캡슐화되어) 있으므로 클래스에 곁들여진 함수(메서드)들은 데이터를 이리저리 옮기는 작업을 쉽게 해준다.

### 8.3 문장을 함수로 옮기기(Move Statements into Function)
```javascript
// Before
result.push(`<p>title: ${person.photo.title}</p>`);
result.concat(photoData(person.photo));

function photoData(aPhoto) {
  return [
    `<p>location: ${aPhoto.location}</p>`,
    `<p>date: ${aPhoto.date.toDateString()}</p>`,
  ];
}

// After
result.concat(photoData(person.photo));

function photoData(aPhoto) {
  return [
    `<p>title: ${aPhoto.title}</p>`,
    `<p>location: ${aPhoto.location}</p>`,
    `<p>date: ${aPhoto.date.toDateString()}</p>`,
  ];
}
```
- 특정 함수를 호출하는 코드가 나올 때마다 그 앞이나 뒤에서 똑같은 코드가 추가로 실행되는 모습을 보면, 나는 그 반복되는 부분을 피호출 함수로 합치는 방법을 궁리한다.
- 문장들을 함수로 옮기려면 그 문장들이 피호출 함수의 일부라는 확신이 있어야 한다.
- 타겟 함수를 호출하는 곳이 한 곳뿐이면, 단순히 소스 위치에서 해당 코드를 잘라내어 피호출 함수로 복사하고 테스트한다.
- 호출자가 둘 이상이면 호출자 중 하나에서 \'타겟 함수 호출 부분과 그 함수로 옮기려는 문장들을 함께\' 다른 함수로 추출한다.

### 8.4 문장을 호출한 곳으로 옮기기(Move Statements into Callers)
```javascript
// Before
emitPhotoData(outStream, person.photo);

function emitPhotoData(outStream, photo) {
  outStream.write(`<p>title: ${photo.title}</p>\n`);
  outStream.write(`<p>location: ${photo.location}</p>\n`);
}

// After
emitPhotoData(outStream, person.photo);
outStream.write(`<p>location: ${person.photo.location}</p>\n`);

function emitPhotoData(outStream, photo) {
  outStream.write(`<p>title: ${photo.title}</p>\n`);
}
```
- 여러 곳에서 사용하던 기능이 일부 호출자에게는 다르게 동작하도록 바뀌어야 한다면 이런 일이 벌어진다.
- 달라진 동작을 함수에서 꺼내 해당 호출자로 옮겨야 한다.

### 8.5 인라인 코드를 함수 호출로 바꾸기(Replace Inline Code with Function Call)
```javascript
// Before
let appliesToMass = false;
for(const s of states) {
  if (s === "MA") appliesToMass = true;
}

// After
appliesToMass = states.includes("MA");
```
- 함수의 이름이 코드의 동작 방식보다는 목적을 말해주기 때문에 함수를 활용하면 코드를 이해하기 쉬워진다.
- 함수는 중복을 없애는 데도 효과적이다.
- 이미 존재하는 함수와 똑같은 일을 하는 인라인 코드를 발견하면 보통은 해당 코드를 함수 호출로 대체하길 원할 것이다.
- 예외가 있다면 기존 함수의 코드를 수정하더라도 인라인 코드의 동작은 바뀌지 않아야 할 때 뿐이다.

### 8.6 문장 슬라이드하기(Slide Statements)
```javascript
// Before
const pricingPlan = retrievePricingPlan();
const order = retreiveOrder();
let charge;
const chargePerUnit = pricingPlan.unit;

// After
const pricingPlan = retrievePricingPlan();
const chargePerUnit = pricingPlan.unit;
const order = retreiveOrder();
let charge;
```
- 하나의 데이터 구조를 이용하는 문장들은 (다른 데이터를 이용하는 코드 사이에 흩어져 있기보다는) 한데 모여 있어야 좋다.
- 모든 변수 선언을 함수 첫머리에 모아두는 것보다, 변수를 처음 사용할 때 선언하는 스타일을 선호한다.
- 요소를 선언하는 곳과 사용하는 곳을 가까이 두기를 좋아해서 선언 코드를 슬라이드하여 처음 사용하는 곳까지 끌어내리는 일을 자주 한다.
- 부수효과(side effect)가 있는 코드를 슬라이드하거나 부수효과가 있는 코드를 건너뛰어야 한다면 훨씬 신중해야 한다.
- 상태 갱신에 특히나 신경 써야 하기 때문에 상태를 갱신하는 코드 자체를 최대한 제거하는 게 좋다.
- 슬라이드 후 테스트가 실패했을 때 가장 좋은 대처는 더 작게 슬라이드해보는 것이다.
- 조건문 밖으로 슬라이드할 때는 중복 로직이 제거될 것이고, 조건문 안으로 슬라이드할 때는 반대로 중복 로직이 추가될 것이다.
- **항상 단계를 잘게 나눠 리팩터링한다.**

### 8.7 반복문 쪼개기(Split Loop)
```javascript
// Before
let averageAge = 0;
let totalSalary = 0;
for (const p of people) {
  averageAge += p.age;
  totalSalary += p.salary;
}
averageAge = averageAge / people.length;

// After
let totalSalary = 0;
for (const p of people) {
  totalSalary += p.salary;
}

let averageAge = 0;
for (const p of people) {
  averageAge += p.age;
}
averageAge = averageAge / people.length;
```
- 반복문 쪼개기는 서로 다른 일들이 한 함수에서 이뤄지고 있다는 신호일 수 있다.
- 리팩터링과 최적화를 구분하자.
- 긴 리스트를 반복하더라도 병목으로 이어지는 경우는 매우 드물다. 오히려 반복문 쪼개기가 다른 더 강력한 최적화를 적용할 수 있는 길을 열어주기도 한다.

### 8.8 반복문을 파이프라인으로 바꾸기(Replace Loop with Pipeline)
```javascript
// Before
const names = [];
for (const i of input) {
  if (i.job === "programmer")
    names.push(i.name);
}

// After
const names = input
  .filter(i => i.job === "programmer")
  .map(i => i.name);
```
- 컬렉션 파이프라인을 이용하면 처리 과정을 일련의 연산으로 표현할 수 있다.

### 8.9 죽은 코드 제거하기(Remove Dead Code)
```javascript
// Before
if(false) {
  doSomethingThatUsedToMatter();
}

// After
// deleted
```
- 코드가 더 이상 사용되지 않게 됐다면 지워야 한다.

---

# 9. 데이터 조직화

### 9.1 변수 쪼개기(Split Variable)
```javascript
// Before
let temp = 2 * (height + width);
console.log(temp);
temp = height * width;
console.log(temp);

// After
const perimeter = 2 * (height + width);
console.log(perimeter);
const area = height * width;
console.log(area);
```
- 변수에는 값을 단 한 번만 대입해야 한다. 대입이 두 번 이상 이뤄진다면 여러 가지 역할을 수행한다는 신호다.
- 역할이 둘 이상인 변수가 있다면 쪼개야 한다.

### 9.2 필드 이름 바꾸기(Rename Field)
```javascript
// Before
class Organization {
  get name() {...}
}

// After
class Organization {
  get title() {...}
}
```
- 모든 변경을 한 번에 수행하는 대신 작은 단계들로 나눠 독립적으로 수행할 수 있게 된다.
- **리팩터링 도중 테스트에 실패한다면 더 작은 단계로 나눠 진행해야 한다는 신호임을 잊지 말자.**

### 9.3 파생 변수를 질의 함수로 바꾸기(Replace Derived Variable with Query)
```javascript
// Before
get discountedTotal() {
  return this._discountedTotal;
}
set discount(aNumber) {
  const old = this._discount;
  this._discount = aNumber;
  this._discountedTotal += old - aNumber;
}

// After
get discountedTotal() {
  return this._baseTotal - this._discount;
}
set discount(aNumber) {
  this._discount = aNumber;
}
```
- 가변 데이터의 유효 범위를 가능한 한 좁혀야 한다.
- 값을 쉽게 계산해낼 수 있는 변수들을 모두 제거한다.

### 9.4 참조를 값으로 바꾸기(Change Reference to Value)
```javascript
// Before
class Product {
  applyDiscount(arg) {this._price.amount -= arg;}
}

// After
class Product {
  applyDiscount(arg) {
    this._price = new Money(this._price.amount - arg, this._price.currency);
  }
}
```
- 참조로 다루는 경우에는 내부 객체는 그대로 둔 채 그 객체의 속성만 갱신하며, 값으로 다루는 경우에는 새로운 속성을 담은 객체로 기존 내부 객체를 통째로 대체한다.
- 불변 데이터 값은 프로그램 외부로 건네줘도 나중에 그 값이 나 몰래 바뀌어서 내부에 영향을 줄까 염려하지 않아도 된다.
- 특정 객체를 여러 객체에서 공유하고자 한다면, 그래서 공유 객체의 값을 변경했을 때 이를 관련 객체 모두에 알려줘야 한다면 공유 객체를 참조로 다뤄야 한다.

### 9.5 값을 참조로 바꾸기(Change Value to Reference)
```javascript
// Before
let customer = new Customer(customerData);

// After
let customer = customerRepository.get(customerData.id);
```
- 복사본이 많이 생겨서 가끔은 메모리가 부족할 수도 있지만, 다른 성능 이슈와 마찬가지로 아주 드문 일이다.
- 모든 복제본을 찾아서 빠짐없이 갱신해야 하며, 하나라도 놓치면 데이터 일관성이 깨져버린다. 이런 상황이라면 복제된 데이터들을 모두 참조로 바꿔주는게 좋다.
- 같은 엔티티를 표현하는 객체가 여러 개 만들어지면 혼란이 생긴다.
- 항상 물리적으로 똑같은 고객 객체를 사용하고 싶다면 먼저 이 유일한 객체를 저장해둘 곳이 있어야 한다. 나는 저장소 객체(repository object)를 사용하는 편이다.

### 9.6 매직 리터럴 바꾸기(Replace Magic Literal)
```javascript
// Before
function potentialEnergy(mass, height) {
  return mass * 9.81 * height;
}

// After
const STANDARD_GRAVITY = 9.81;
function potentialEnergy(mass, height) {
  return mass * STANDARD_GRAVITY * height;
}
```
- 코드를 읽는 사람이 이 값의 의미를 모른다면 숫자 자체로는 의미를 명확히 알려주지 못하므로 매직 리터럴이라 할 수 있다.

---

### Reference
- [리팩터링 2판: 코드 구조를 체계적으로 개선하여 효율적인 리팩터링 구현하기](http://www.yes24.com/Product/Goods/89649360)
- [refactoring.com](https://refactoring.com)
