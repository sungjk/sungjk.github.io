---
layout: entry
post-category: refactoring
title: 리팩터링 2 - Refactoring 2
author: 김성중
author-email: ajax0615@gmail.com
description: 마틴 파울러의 리팩터링 2판(코드 구조를 체계적으로 개선하여 효율적인 리팩터링 구현하기)
keywords: 리팩터링, 리팩토링, refactoring
thumbnail-image: /images/profile/refactoring.png
next_url: /2021/04/17/refactoring-03.html
publish: true
---

# 6. 기본적인 리팩터링
함수 구성과 이름 짓기는 가장 기본적인 저수준 리팩터링이다. 그런데 일단 함수를 만들고 나면 다시 고수준 모듈로 묶어야 한다.

### 6.1 함수 추출하기(Extract Function)
```javascript
// Before
function printOwing(invoice) {
  printBanner();
  let outstanding  = calculateOutstanding();

  //print details
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);  
}

// After
function printOwing(invoice) {
  printBanner();
  let outstanding  = calculateOutstanding();
  printDetails(outstanding);

  function printDetails(outstanding) {
    console.log(`name: ${invoice.customer}`);
    console.log(`amount: ${outstanding}`);
  }
}
```
- 코드를 언제 독립된 함수로 묶어야 할지에 관한 의견은 수없이 많다. 길이를 기준으로 삼을 수 있다. 재사용성을 기준으로 할 수도 있다. \'목적과 구현을 분리\'하는 방식이 가장 합리적인 기준으로 보인다.
- 함수가 짧으면 캐싱하기가 더 쉽기 때문에 컴파일러가 최적화하는데 유리할 때가 많다. 성능 최적화에 대해서는 항상 일반적인 지침을 따르자.
- 이름이 떠오르지 않는다면 함수로 추출하면 안 된다는 신호다.
- 만약 변수가 초기화되는 지점과 실제로 사용되는 지점이 떨어져 있다면 문장 슬라이드하기를 활용하여 변수 조작을 모두 한곳에 처리하도록 모아두면 편하다.

### 6.2 함수 인라인하기(Inline Function)
```javascript
// Before
function getRating(driver) {
  return moreThanFiveLateDeliveries(driver) ? 2 : 1;
}

function moreThanFiveLateDeliveries(driver) {
  return driver.numberOfLateDeliveries > 5;
}

// After
function getRating(driver) {
  return (driver.numberOfLateDeliveries > 5) ? 2 : 1;
}
```
- 때로는 함수 본문이 이름만큼 명확한 경우도 있다.
- 간접 호출을 너무 과하게 쓰는 코드도 흔한 인라인 대상이다.
- 실수하지 않으려면 한 번에 한 문장씩 옮기는 것이 좋다.
- 여기서 핵심은 항상 단계를 잘게 나눠서 처리하는 데 있다.

### 6.3 변수 추출하기(Extract Variable)
```javascript
// Before
return order.quantity * order.itemPrice -
  Math.max(0, order.quantity - 500) * order.itemPrice * 0.05 +
  Math.min(order.quantity * order.itemPrice * 0.1, 100);

// After
const basePrice = order.quantity * order.itemPrice;
const quantityDiscount = Math.max(0, order.quantity - 500) * order.itemPrice * 0.05;
const shipping = Math.min(basePrice * 0.1, 100);
return basePrice - quantityDiscount + shipping;
```
- 지역 변수를 활용하면 표현식을 쪼개 관리하기 더 쉽게 만들 수 있다.
- 현재 함수 안에서만 의미가 있다면 변수로 추출하는 것이 좋다. 그러나 함수를 벗어난 넓은 문맥에서까지 의미가 된다면 그 넓은 범위에서 통용되는 이름을 생각해야 한다.
- 클래스 전체에 영향을 줄 때는 변수가 아닌 메서드로 추출하는 편이다.
- 객체는 특정 로직과 데이터를 외부와 공유하려 할 떄 공유할 정보를 설명해주는 적당한 크기의 문맥이 되어준다.

### 6.4 변수 인라인하기(Inline Variable)
```javascript
// Before
let basePrice = anOrder.basePrice;
return (basePrice > 1000);

// After
return anOrder.basePrice > 1000;
```
- 변수가 주변 코드를 리팩터링하는 데 방해가 되면 인라인하는 것이 좋다.

### 6.5 함수 선언 바꾸기(Change Function Declaration)
```javascript
// Before
function circum(radius) {...}

// After
function circumference(radius) {...}
```
- 이름이 좋으면 함수의 구현 코드를 살펴볼 필요 없이 호출문만 보고도 무슨 일을 하는지 파악할 수 있다.
- 먼저 변경 사항을 살펴보고 함수 선언과 호출문들을 단번에 고칠 수 있을지 가늠해본다.
- 매개변수를 제거하려거든 먼저 함수 본문에서 제거 대상 매개변수를 참조하는 곳은 없는지 확인한다.
- 이름 변경과 매개변수 추가를 모두 하고 싶다면 각각을 독립적으로 처리하자.
- 상속 구조 속에 있는 클래스의 메서드를 변경할 때는 다형 관계인 다른 클래스에도 변경이 반영되어야 한다.
- 원하는 형태의 메서드를 새로 만들어서 원래 함수를 호출하는 전달(forward) 메서드로 활용하는 것이다.
- 함수가 주(state) 식별 코드를 매개변수로 받도록 리팩터링할 것이다. 그러면 의존성이 제거되어 더 넓은 문맥에 활용할 수 있다.

### 6.6 변수 캡슐화하기(Encapsulate Variable)
```javascript
// Before
let defaultOwner = {firstName: "Martin", lastName: "Fowler"};

// After
let defaultOwnerData = {firstName: "Martin", lastName: "Fowler"};
export function defaultOwner()       {return defaultOwnerData;}
export function setDefaultOwner(arg) {defaultOwnerData = arg;}
```
- 함수는 데이터보다 다루기가 수월하다.
- 접근할 수 있는 범위가 넓은 데이터를 옮길 때는 먼저 그 데이터로의 접근을 독점하는 함수를 만드는 식으로 캡슐화하는 것이 가장 좋은 방법일 때가 많다.
- 데이터의 유효범위가 넓을수록 캡슐화해야 한다. 레거시 코드를 다룰 때는 이런 변수를 참조하는 코드를 추가하거나 변경할 때마다 최대한 캡슐화한다. 그래야 자주 사용하는 데이터에 대한 결합도가 높아지는 일을 막을 수 있다.
- 불변 데이터는 가변 데이터보다 캡슐화할 이유가 적다. 데이터가 변경될 일이 없어서 갱신 전 검증 같은 추가 로직이 자리할 공간을 마련할 필요가 없기 때문이다.
- 링크가 필요 없다면 데이터를 복제해 저장하여 나중에 원본이 변경돼서 발생하는 사고를 방지할 수 있다.

### 6.7 변수 이름 바꾸기(Rename Variable)
```javascript
// Before
let a = height * width;

// After
let area = height * width;
```
- 함수 호출 한 번으로 끝나지 않고 값이 영속되는 필드라면 이름에 더 신경 써야 한다.

### 6.8 매개변수 객체 만들기(Introduce Parameter Object)
```javascript
// Before
function amountInvoiced(startDate, endDate) {...}
function amountReceived(startDate, endDate) {...}
function amountOverdue(startDate, endDate) {...}

// After
function amountInvoiced(aDateRange) {...}
function amountReceived(aDateRange) {...}
function amountOverdue(aDateRange) {...}
```
- 데이터 뭉치를 데이터 구조로 묶으면 데이터 사이의 관계가 명확해진다는 이점을 얻는다.
- 같은 데이터 구조를 사용하는 모든 함수가 원소를 참조할 때 항상 똑같은 이름을 사용하기 때문에 일관성도 높여준다.

### 6.9 여러 함수를 클래스로 묶기(Combine Functions into Class)
```javascript
// Before
function base(aReading) {...}
function taxableCharge(aReading) {...}
function calculateBaseCharge(aReading) {...}

// After
class Reading {
  base() {...}
  taxableCharge() {...}
  calculateBaseCharge() {...}
}
```
- 클래스로 묶으면 이 함수들이 공유하는 공통 환경을 더 명확하게 표현할 수 있고, 각 함수에 전달되는 인수를 줄여서 객체 안에서의 함수 호출을 간결하게 만들 수 있다. 또한 이런 객체를 시스템의 다른 부분에 전달하기 위한 참조를 제공할 수 있다.
- 프로그램의 다른 부분에서 데이터를 갱신할 가능성이 꽤 있을 때는 클래스로 묶어두면 큰 도움이 된다.

### 6.10 여러 함수를 변환 함수로 묶기(Combine Functions into Transform)
```javascript
// Before
function base(aReading) {...}
function taxableCharge(aReading) {...}

// After
function enrichReading(argReading) {
  const aReading = _.cloneDeep(argReading);
  aReading.baseCharge = base(aReading);
  aReading.taxableCharge = taxableCharge(aReading);
  return aReading;
}
```
- 모아두면 검색과 갱신을 일관된 장소에서 처리할 수 있고 로직 중복도 막을 수 있다.
- 변환 함수는 원본 데이터를 입력받아서 필요한 정보를 모두 도출한 뒤, 각각을 출력 데이터의 필드에 넣어 반환한다.
- 원본 데이터가 코드 안에서 갱신될 때는 클래스로 묶는 편이 훨씬 낫다. 변환 함수로 묶으면 가공한 데이터를 새로운 레코드에 저장하므로, 원본 데이터가 수정되면 일관성이 깨질 수 있기 떄문이다.

### 6.11 단계 쪼개기(Split Phase)
```javascript
// Before
const orderData = orderString.split(/\s+/);
const productPrice = priceList[orderData[0].split("-")[1]];
const orderPrice = parseInt(orderData[1]) * productPrice;

// After
const orderRecord = parseOrder(order);
const orderPrice = price(orderRecord, priceList);

function parseOrder(aString) {
  const values =  aString.split(/\s+/);
  return ({
    productID: values[0].split("-")[1],
    quantity: parseInt(values[1]),
  });
}
function price(order, priceList) {
  return order.quantity * priceList[order.productID];
}
```
- 코드를 수정해야 할 때 두 대상을 동시에 생각할 필요 없이 하나에만 집중하기 위해서다.
- 모듈이 잘 분리되어 있다면 다른 모듈의 상세 내용은 전혀 기억하지 못해도 원하는 대로 수정을 끝마칠 수도 있다.
- 각 단계는 자신만의 문제에 집중하기 때문에 나머지 관계에 대해서는 자세히 몰라도 이해할 수 있다.
- 다른 단계로 볼 수 있는 코드 영역들이 마침 서로 다른 데이터와 함수를 사용한다면 단계 쪼개기에 적합하다는 뜻이다.
- 핵심은 어디까지나 단계를 명확히 분리하는 데 있다.

---

# 7. 캡슐화
클래스는 본래 정보를 숨기는 용도로 설계되었다.

### 7.1 레코드 캡슐화하기(Encapsulate Record)
```javascript
// Before
organization = {name: "Acme Gooseberries", country: "GB"};

// After
class Organization {
  constructor(data) {
    this._name = data.name;
    this._country = data.country;
  }
  get name()    {return this._name;}
  set name(arg) {this._name = arg;}
  get country()    {return this._country;}
  set country(arg) {this._country = arg;}
}
```
- 객체를 사용하면 어떻게 저장했는지를 숨긴 채 세 가지 값을 각각의 메서드로 제공할 수 있다. 사용자는 무엇이 저장된 값이고 무엇이 계산된 값인지 알 필요가 없다.
- 캡슐화에서는 값을 수정하는 부분을 명확하게 드러내고 한 곳에 모아두는 일이 중요하다. 데이터를 깊은 복사(deep copy)하여 반환하는 방법, 데이터 구조의 읽기전용 프락시를 반환하는 방법이 있다.
- 눈에 띄는 문제는 데이터 구조가 클수록 복제 비용이 커져서 성능이 느려질 수 있다는 것이다.
- 읽기전용 프락시를 제공하거나 복제본을 동결시켜서 데이터를 수정하려 할 때 에러를 던지도록 만들 수 있다.
- 레코드 캡슐화를 재귀적으로 하는 것으로, 할 일은 늘어나지만 가장 확실하게 제거할 수 있다.

### 7.2 컬렉션 캡슐화하기(Encapsulate Collection)
```javascript
// Before
class Person {              
  get courses() {return this._courses;}
  set courses(aList) {this._courses = aList;}
  ...
}

// After
class Person {
  get courses() {return this._courses.slice();}
  addCourse(aCourse)    { ... }
  removeCourse(aCourse) { ... }
  ...
}
```
- 가변 데이터를 모두 캡슐화하는 편이다. 그러면 데이터 구조가 언제 어떻게 수정되는지 파악하기 쉬워서 필요한 시점에 데이터 구조를 변경하기도 쉬워지기 때문이다.
- 컬렉션 Getter를 제공하되 내부 컬렉션의 복제본을 반환하는 방법이 있다.
- 컬렉션에 대해서는 어느 정도 강박증을 갖고 불필요한 복제본을 만드는 편이, 예상치 못한 수정이 촉발한 오류를 디버깅하는 것보다 낫다.
- 컬렉션 관리를 책임지는 클래스라면 항상 복제본을 제공해야 한다. 그리고 나는 컬렉션을 변경할 가능성이 있는 작업을 할 때도 습관적으로 복제본을 만든다.

### 7.3 기본형을 객체로 바꾸기(Replace Primitive with Object)
```javascript
// Before
orders.filter(o => "high" === o.priority || "rush" === o.priority);

// After
orders.filter(o => o.priority.higherThan(new Priority("normal")))
```
- 단순한 출력 이상의 기능이 필요해지는 순간 그 데이터를 표현하는 전용 클래스를 정의한다.
- 목적은 어디까지나 클래스를 새로운 동작을 담는 장소로 활용하기 위해서다. 새로운 동작이란 새로 구현한 것일 수도, 다른 곳에서 옮겨온 것일 수도 있다.

### 7.4 임시 변수를 질의함수로 바꾸기(Replace Temp with Query)
```javascript
// Before
const basePrice = this._quantity * this._itemPrice;
if (basePrice > 1000)
  return basePrice * 0.95;
else
  return basePrice * 0.98;

// After
get basePrice() {this._quantity * this._itemPrice;}

...

if (this.basePrice > 1000)
  return this.basePrice * 0.95;
else
  return this.basePrice * 0.98;
```
- 임시 변수를 사용하면 값을 계산하는 코드가 반복되는 걸 줄이고 (변수 이름을 통해) 값의 의미를 설명할 수도 있어서 유용하다. 그런데 한 걸음 더 나아가 아예 함수로 만들어 사용하는 편이 나을 때가 많다.
- 긴 함수를 한 부분을 별도 함수로 추출하고자 할 때 먼저 변수들을 각각의 함수로 만들면 일이 수월해진다.
- 변수 대신 함수로 만들어두면 비슷한 계산을 수행하는 다른 함수에서도 사용할 수 있어 코드 중복이 줄어든다.
- 가장 단순한 예로, 변수에 값을 한 번 대입한 뒤 더 복잡한 코드 덩어리에서 여러 차례 다시 대입하는 경우는 모두 질의 함수로 추출해야 한다.

### 7.5 클래스 추출하기(Extract Class)
```javascript
// Before
class Person {
  get officeAreaCode() {return this._officeAreaCode;}
  get officeNumber()   {return this._officeNumber;}
  ...
}

// After
class Person {
  get officeAreaCode() {return this._telephoneNumber.areaCode;}
  get officeNumber()   {return this._telephoneNumber.number;}
}
class TelephoneNumber {
  get areaCode() {return this._areaCode;}
  get number()   {return this._number;}
}
```
- 메서드와 데이터가 너무 많은 클래스는 이해하기가 쉽지 않으니 잘 살펴보고 적절히 분리하는 것이 좋다.
- 데이터와 메서드를 따로 묶을 수 있다면 어서 분리하라는 신호다.
- 함께 변경되는 일이 많거나 서로 의존하는 데이터들도 분리한다.
- 저수준 메서드, 즉 다른 메서드를 호출하기보다 호출을 당하는 일이 많은 메서드부터 옮긴다.

### 7.6 클래스 인라인하기(Inline Class)
```javascript
// Before
class Person {
  get officeAreaCode() {return this._telephoneNumber.areaCode;}
  get officeNumber()   {return this._telephoneNumber.number;}
}
class TelephoneNumber {
  get areaCode() {return this._areaCode;}
  get number()   {return this._number;}
}

// After
class Person {
  get officeAreaCode() {return this._officeAreaCode;}
  get officeNumber()   {return this._officeNumber;}
}
```
- 더 이상 제 역할을 못 해서 그대로 두면 안 되는 클래스는 인라인한다.
- 두 클래스의 기능을 지금과 다르게 배분하고 싶을 떄도 클래스를 인라인한다.

### 7.7 위임 숨기기(Hide Delegate)
```javascript
// Before
manager = aPerson.department.manager;

// After
manager = aPerson.manager;

class Person {
  get manager() {return this.department.manager;}
}
```
- 캡슐화는 모듈들이 시스템의 다른 부분에 알아야 할 내용을 줄여준다. 캡슐화가 잘 되어 있다면 무언가를 변경해야 할 때 함께 고려해야 할 모듈 수가 적어져서 코드를 변경하기가 훨씬 쉬워진다.
- 서버 자체에 위임 메서드를 만들어서 위임 객체의 존재를 숨기면 된다.
- 클라이언트는 부서 클래스의 작동 방식, 다시 말해 부서 클래스가 관리자 정보를 제공한다는 사실을 알아야 한다. 이러한 의존성을 줄이려면 클라이언트가 부서 클래스를 볼 수 없게 숨기고, 대신 사람 클래스에 간단한 위임 메서드를 만들면 된다.

### 7.8 중개자 제거하기(Remove Middle Man)
```javascript
// Before
manager = aPerson.manager;

class Person {
  get manager() {return this.department.manager;}
}

// After
manager = aPerson.department.manager;
```
- 클라이언트가 위임 객체의 또 다른 기능을 사용하고 싶을 때마다 서버에 위임 메서드를 추가해야 하는데, 이렇게 기능을 추가하다 보면 단순히 전달만 하는 위임 메서드들이 점점 성가셔진다.
- 그러면 서버 클래스는 그저 중개자(middle man) 역할로 전락하여, 차라리 클라이언트가 위임 객체를 직접 호출하는게 나을 수 있다.
- 위임 숨기기나 중개자 제거하기를 적당히 섞어도 된다.

### 7.9 알고리즘 교체하기(Substitute Algorithm)
```javascript
// Before
function foundPerson(people) {
  for(let i = 0; i < people.length; i++) {
    if (people[i] === "Don") {
      return "Don";
    }
    if (people[i] === "John") {
      return "John";
    }
    if (people[i] === "Kent") {
      return "Kent";
    }
  }
  return "";
}

// After
function foundPerson(people) {
  const candidates = ["Don", "John", "Kent"];
  return people.find(p => candidates.includes(p)) || '';
}
```
- 더 간명한 방법을 찾아내면 복잡한 기존 코드를 간명한 방식으로 고친다.
- 반드시 메서드를 가능한 한 잘게 나눴는지 확인해야 한다.

---

### Reference
- [리팩터링 2판: 코드 구조를 체계적으로 개선하여 효율적인 리팩터링 구현하기](http://www.yes24.com/Product/Goods/89649360)
- [refactoring.com](https://refactoring.com)
