---
layout: entry
post-category: refactoring
title: 리팩터링 4 - Refactoring 4
author: 김성중
author-email: ajax0615@gmail.com
description: 마틴 파울러의 리팩터링 2판(코드 구조를 체계적으로 개선하여 효율적인 리팩터링 구현하기)
keywords: 리팩터링, 리팩토링, refactoring
thumbnail-image: /images/profile/refactoring.png
publish: true
---

# 10. 조건부 로직 간소화

### 10.1 조건문 분해하기(Decompose Conditional)
```javascript
// Before
if (!aDate.isBefore(plan.summerStart) && !aDate.isAfter(plan.summerEnd))
  charge = quantity * plan.summerRate;
else
  charge = quantity * plan.regularRate + plan.regularServiceCharge;

// After
if (summer())
  charge = summerCharge();
else
  charge = regularCharge();
```
- 조건을 검사하고 그 결과에 따른 동작을 표현한 코드는 무슨 일이 일어나는지는 이야기해주지만 \'왜\' 일어나는지는 제대로 말해주지 않을 때가 많은 것이 문제다.
- 각 덩어리의 의도를 살린 이름의 함수 호출로 바꿔주자.

### 10.2 조건식 통합하기(Consolidate Conditional Expression)
```javascript
// Before
if (anEmployee.seniority < 2) return 0;
if (anEmployee.monthsDisabled > 12) return 0;
if (anEmployee.isPartTime) return 0;

// After
if (isNotEligableForDisability()) return 0;

function isNotEligableForDisability() {
  return ((anEmployee.seniority < 2)
          || (anEmployee.monthsDisabled > 12)
          || (anEmployee.isPartTime));
}
```
- 여러 조각으로 나뉜 조건들을 하나로 통합함으로써 내가 하려는 일이 더 명확해진다.
- 이 작업이 함수 추출하기까지 이어질 가능성이 높다.
- 순차적인 경우엔 or 연산자를 이용한다.
- if문이 중첩되어 나오면 and를 사용해야 한다.


### 10.3 중첩 조건문을 보호 구문으로 바꾸기(Replace Nested Conditional with Guard Clauses)
```javascript
// Before
function getPayAmount() {
  let result;
  if (isDead)
    result = deadAmount();
  else {
    if (isSeparated)
      result = separatedAmount();
    else {
      if (isRetired)
        result = retiredAmount();
      else
        result = normalPayAmount();
    }
  }
  return result;
}

// After
function getPayAmount() {
  if (isDead) return deadAmount();
  if (isSeparated) return separatedAmount();
  if (isRetired) return retiredAmount();
  return normalPayAmount();
}
```
- 함수의 진입점과 반환점이 하나여야 한다고 배운 프로그래머와 함께 일하다 보면 이 리팩터링을 자주 사용하게 된다.
- 반환점이 하나여야 한다는 규칙은 정말이지 유용하지 않다.
- 반환점이 하나일 때 함수의 로직이 더 명백하다면 그렇게 하자. 그렇지 않다면 하지 말자.
- 가변 변수를 제거하면 자다가도 떡이 생긴다는 사실을 기억하자.

### 10.4 조건부 로직을 다형성으로 바꾸기(Replace Conditional with Polymorphism)
```javascript
// Before
switch (bird.type) {
  case 'EuropeanSwallow':
    return "average";
  case 'AfricanSwallow':
    return (bird.numberOfCoconuts > 2) ? "tired" : "average";
  case 'NorwegianBlueParrot':
    return (bird.voltage > 100) ? "scorched" : "beautiful";
  default:
    return "unknown";
}

// After
class EuropeanSwallow {
  get plumage() {
    return "average";
  }
}
class AfricanSwallow {
  get plumage() {
     return (this.numberOfCoconuts > 2) ? "tired" : "average";
  }
}
class NorwegianBlueParrot {
  get plumage() {
     return (this.voltage > 100) ? "scorched" : "beautiful";
  }
}
```
- 조건부 로직을 직관적으로 구조화할 방법을 항상 고민한다.
- 클래스와 다형성을 이용하면 더 확실하게 분리할 수도 있다.
- 타입을 여러 개 만들고 각 타입이 조건부 로직을 자신만의 방식을 처리하도록 구성하는 방법이 있다.
- 개선할 수 있는 복잡한 조건부 로직을 발견하면 다형성이 막강한 도구임을 깨닫게 된다.
- 서브클래스에서 슈퍼클래스의 조건부 로직 메서드를 오버라이드하기.
- 자바스크립트에서는 타입 계층 구조 없이도 다형성을 표현할 수 있다. 객체가 적절한 이름의 메서드만 구현하고 있다면 아무 문제없이 같은 타입으로 취급하기 때문이다(Duck typing).
- 특수한 상황을 다루는 로직들을 기본 동작에서 분리하기 위해 상속과 다형성을 이용할 것이다.
- 메서드 이름의 \"And\"는 이 메서드가 두 가지 독립된 일을 수행한다고 소리친다.

### 10.5 특이 케이스 추가하기(Introduce Special Case)
```javascript
// Before
if (aCustomer === "unknown") customerName = "occupant";

// After
class UnknownCustomer {
    get name() {return "occupant";}
}
```
- 코드베이스에서 특정 값에 대해 똑같이 반응하는 코드가 여러 곳이라면 그 반응들을 한 데로 모으는 게 효율적이다.
- 특이 케이스 객체에서 단순히 데이터를 읽기만 한다면 반환할 값들을 담은 리터럴 객체 형태로 준비하면 된다. 그 이상의 어떤 동작을 수행해야 한다면 필요한 메서드를 담은 객체를 생성하면 된다.
- 여러 곳에서 똑같이 수정해야만 하는 코드를 별도 함수로 추출하여 한데로 모으기.
- 각 클라이언트에서 수행하는 특이 케이스 검사를 일반적으로 기본값으로 대체할 수 있다면 이 검사 코드에 여러 함수를 클래스로 묶기를 적용할 수 있다.
- 모든 클라이언트의 코드를 이 다형적 행위(타입에 따라 동작이 달라지는)로 대체할 수 있는지를 살펴본다.
- 데이터 구조를 읽기만 한다면 클래스 대신 리터럴 객체를 사용해도 된다.

### 10.6 어서션 추가하기(Introduce Assertion)
```javascript
// Before
if (this.discountRate)
  base = base - (this.discountRate * base);

// After
assert(this.discountRate >= 0);
if (this.discountRate)
  base = base - (this.discountRate * base);
```
- 어서션 실패는 시스템의 다른 부분에서는 절대 검사하지 않아야 하며, 어서션이 있고 없고가 프로그램 기능의 정상 동작에 아무런 영향을 주지 않도록 작성돼야 한다.
- 데이터를 외부에서 읽어 온다면 그 값을 검사하는 작업은 (어서션의 대상인) 가정이 아니라 (예외 처리로 대응해야 하는) 프로그램 로직의 일부로 다뤄야 한다. 외부 데이터 출처를 전적으로 신뢰할 수 있는 상황이 아니라면 말이다.

### 10.7 제어 플래그를 탈출문으로 바꾸기(Replace Control Flag with Break)
```javascript
// Before
for (const p of people) {
  if (! found) {
    if ( p === "Don") {
      sendAlert();
      found = true;
    }
  }
}

// After
for (const p of people) {
  if ( p === "Don") {
    sendAlert();
    break;
  }
}
```
- 제어 플래그란 코드의 동작을 변경하는 데 사용되는 변수를 말하며, 어딘가에서 값을 계산해 제어 플래그에 설정한 후 다른 어딘가의 조건문에서 검사하는 형태로 쓰인다. 나는 이런 코드를 항상 악취로 본다.

---

# 11. API 리팩터링
좋은 API는 데이터를 갱신하는 함수와 그저 조회만 하는 함수를 명확히 구분한다.

### 11.1 질의 함수와 변경 함수 분리하기(Separate Query from Modifier)
```javascript
// Before
function getTotalOutstandingAndSendBill() {
  const result = customer.invoices.reduce((total, each) => each.amount + total, 0);
  sendBill();
  return result;
}

// After
function totalOutstanding() {
  return customer.invoices.reduce((total, each) => each.amount + total, 0);  
}
function sendBill() {
  emailGateway.send(formatBill(customer));
}
```
- 외부에서 관찰할 수 있는 겉보기 부수효과(observable side effect)가 전혀 없이 값을 반환해주는 함수를 추구해야 한다.
- 질의 함수(읽기 함수)는 모두 부수효과가 없어야 한다. 명령-질의 분리(command-query separation)

### 11.2 함수 매개변수화하기(Parameterize Function)
```javascript
// Before
function tenPercentRaise(aPerson) {
  aPerson.salary = aPerson.salary.multiply(1.1);
}
function fivePercentRaise(aPerson) {
  aPerson.salary = aPerson.salary.multiply(1.05);
}

// After
function raise(aPerson, factor) {
  aPerson.salary = aPerson.salary.multiply(1 + factor);
}
```
- 두 함수의 로직이 아주 비슷하고 단지 리터럴 값만 다르다면, 그 다른 값만 매개변수로 받아 처리하는 함수 하나로 합쳐서 중복을 없앨 수 있다.

### 11.3 플래스 인수 제거하기(Remove Flag Argument)
```javascript
// Before
function setDimension(name, value) {
  if (name === "height") {
    this._height = value;
    return;
  }
  if (name === "width") {
    this._width = value;
    return;
  }
}

// After
function setHeight(value) {this._height = value;}
function setWidth (value) {this._width = value;}
```
- 플래그 인수(flag argument)란 호출되는 함수가 실행할 로직을 호출하는 쪽에서 선택하기 위해 전달하는 인수다.
- 플래그 인수는 호출할 수 있는 함수들이 무엇이고 어떻게 호출해야 하는지를 이해하기 어렵게 만든다.
- 플래그 인수가 있으면 함수들의 기능 차이가 잘 드러나지 않는다.
- 호출하는 쪽에서 이 불리언 리터럴 값을 이용해서 어느 쪽 코드를 실행할지를 정하기.

### 11.4 객체 통째로 넘기기(Preserve Whole Object)
```javascript
// Before
const low = aRoom.daysTempRange.low;
const high = aRoom.daysTempRange.high;
if (aPlan.withinRange(low, high))

// After
  if (aPlan.withinRange(aRoom.daysTempRange))
```
- 레코드를 통째로 넘기면 변화에 대응하기 쉽다. 예컨대 그 함수가 더 다양한 데이터를 사용하도록 바뀌어도 매개변수 목록은 수정할 필요가 없다.
- 하지만 함수가 레코드 자체에 의존하기를 원치 않을 때는 이 리팩터링을 수행하지 않는데, 레코드와 함수가 서로 다른 모듈에 속한 상황이면 특이 더 그렇다.

### 11.5 매개변수를 질의 함수로 바꾸기(Replace Parameter with Query)
```javascript
// Before
availableVacation(anEmployee, anEmployee.grade);

function availableVacation(anEmployee, grade) {
  // calculate vacation...
}

// After
availableVacation(anEmployee)

function availableVacation(anEmployee) {
  const grade = anEmployee.grade;
  // calculate vacation...
}
```
- 매개변수 목록은 함수의 변동 요인을 모아놓은 곳이다. 즉, 함수의 동작에 변화를 줄 수 있는 일차적인 수단이다. 다른 코드와 마찬가지로 이 목록에서도 중복은 피하는게 좋으며 짧을수록 이해하기 쉽다.
- 매개변수를 제거하면 값을 결정하는 책임 주체가 달라진다. 매개변수가 있다면 결정 주체가 호출자가 되고, 매개변수가 없다면 피호출 함수가 된다.
- 호출하는 쪽을 간소하게 만든다. 즉, 책임 소재를 피호출 함수로 옮긴다는 뜻이다.
- 대상 함수가 참조 투명(referential transparency)해야 한다. 참조 투명이란 \'함수에 똑같은 값을 건네 호출하면 항상 똑같이 동작한다\'는 뜻이다.

### 11.6 질의 함수를 매개변수로 바꾸기(Replace Query with Parameter)
```javascript
// Before
targetTemperature(aPlan)

function targetTemperature(aPlan) {
  currentTemperature = thermostat.currentTemperature;
  // rest of function...
}

// After
targetTemperature(aPlan, thermostat.currentTemperature)

function targetTemperature(aPlan, currentTemperature) {
  // rest of function...
}
```
- 똑같은 값을 건네면 매번 똑같은 결과를 내는 함수는 다루기 쉽다.
- 질의 함수를 매개변수로 바꾸면 어떤 값을 제공할지를 호출자가 알아내야 한다. 결국 호출자가 복잡해지는데, 이왕이면 호출자의 삶이 단순해지도록 설계하자는 내 평소 지론과 배치된다.
- \'의존성 모듈 바깥으로 밀어낸다\' 함은 그 의존성을 처리하는 책임을 호출자에게 지운다는 뜻이다.

### 11.7 세터 제거하기(Remove Setting Method)
```javascript
// Before
class Person {
  get name() {...}
  set name(aString) {...}
}

// After
class Person {
  get name() {...}
}
```
- 객체 생성 후에는 수정되지 않길 원하는 필드라면 세터를 제공하지 않았을 것이다.
- 필드는 오직 생성자에서만 설정되며, 수정하지 않겠다는 의도가 명명백백해지고, 변경될 가능성이 봉쇄된다.

### 11.8 생성자를 팩터리 함수로 바꾸기(Replace Constructor with Factory Function)
```javascript
// Before
leadEngineer = new Employee(document.leadEngineer, 'E');

// After
leadEngineer = createEngineer(document.leadEngineer);
```
- 생성자의 이름은 고정되어 있어서 더 적절한 이름이 있어도 사용할 수 없다.
- 팩터리 함수의 이름에 유형을 녹이는 방식을 권한다.

### 11.9 함수를 명령으로 바꾸기(Replace Function with Command)
```javascript
// Before
function score(candidate, medicalExam, scoringGuide) {
  let result = 0;
  let healthLevel = 0;
  // long body code
}

// After
class Scorer {
  constructor(candidate, medicalExam, scoringGuide) {
    this._candidate = candidate;
    this._medicalExam = medicalExam;
    this._scoringGuide = scoringGuide;
  }

  execute() {
    this._result = 0;
    this._healthLevel = 0;
    // long body code
  }
}
```
- 함수를 그 함수만을 위한 객체 안으로 캡슐화하면 더 유용해지는 상황이 있다. 이런 객체를 가리켜 명령(command)이라 한다.
- 명령 객체 대부분은 메서드 하나로 구성되며, 이 메서드를 요청해 실행하는 것이 이 객체의 목적이다.
- 복잡한 함수를 잘게 쪼개서 이해하거나 수정하기 쉽게 만들고자 할 때 사용한다.
- 복잡한 함수를 잘게 나누기.

### 11.10 명령을 함수로 바꾸기(Replace Command with Function)
```javascript
// Before
class ChargeCalculator {
  constructor (customer, usage){
    this._customer = customer;
    this._usage = usage;
  }
  execute() {
    return this._customer.rate * this._usage;
  }
}

// After
function charge(customer, usage) {
  return customer.rate * usage;
}
```
- 명령은 그저 함수를 하나 호출해 정해진 일을 수행하는 용도로 주로 쓰인다. 이런 상황이고 로직이 크게 복잡하지 않다면 명령 객체는 장점보다 단점이 크니 평범한 함수로 바꿔주는게 낫다.

### 11. 11 수정된 값 반환하기(Return Modified Value)
```javascript
// Before
let totalAscent = 0;
calculateAscent();

function calculateAscent() {
  for (let i = 1; i < points.length; i++) {
    const verticalChange = points[i].elevation - points[i-1].elevation;
    totalAscent += (verticalChange > 0) ? verticalChange : 0;
  }
}

// After
const totalAscent = calculateAscent();

function calculateAscent() {
  let result = 0;
  for (let i = 1; i < points.length; i++) {
    const verticalChange = points[i].elevation - points[i-1].elevation;
    result += (verticalChange > 0) ? verticalChange : 0;
  }
  return result;
}
```
- 변수를 갱신하는 함수라면 수정된 값을 반환하여 호출자가 그 값을 변수에 담아두도록 하는 것이다.
- 값 하나를 계산한다는 분명한 목적이 있는 함수들에 가장 효과적이고, 반대로 값 여러 개를 갱신하는 함수에는 효과적이지 않다.

### 11.12 오류 코드를 예외로 바꾸기(Replace Error Code with Exception)
```javascript
// Before
if (data)
  return new ShippingRules(data);
else
  return -23;

// After
if (data)
  return new ShippingRules(data);
else
  throw new OrderProcessingError(-23);
```
- 예외를 사용하면 오류 코드를 일일이 검사하거나 오류를 식별해 콜스택 위로 던지는 일을 신경쓰지 않아도 된다.
- 예외를 클래스 기반으로 처리하는 프로그래밍 언어가 많은데, 이런 경우라면 서브클래스를 만드는게 가장 자연스럽다.

### 11.13 예외를 사전확인으로 바꾸기(Replace Exception with Precheck)
```javascript
// Before
double getValueForPeriod (int periodNumber) {
  try {
    return values[periodNumber];
  } catch (ArrayIndexOutOfBoundsException e) {
    return 0;
  }
}

// After
double getValueForPeriod (int periodNumber) {
  return (periodNumber >= values.length) ? 0 : values[periodNumber];
}
```
- 함수 수행 시 문제가 될 수 있는 조건을 함수 호출 전에 검사할 수 있다면, 예외를 던지는 대신 호출하는 곳에서 조건을 검사하도록 해야 한다.

---

### Reference
- [리팩터링 2판: 코드 구조를 체계적으로 개선하여 효율적인 리팩터링 구현하기](http://www.yes24.com/Product/Goods/89649360)
- [refactoring.com](https://refactoring.com)
