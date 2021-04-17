---
layout: entry
post-category: refactoring
title: 리팩터링 5 - Refactoring 5
author: 김성중
author-email: ajax0615@gmail.com
description: 마틴 파울러의 리팩터링 2판(코드 구조를 체계적으로 개선하여 효율적인 리팩터링 구현하기)
keywords: 리팩터링, 리팩토링, refactoring
thumbnail-image: /images/profile/refactoring.png
publish: true
---

# 12. 상속 다루기

### 12.1 메서드 올리기(Pull Up Method)
```javascript
// Before
class Employee {...}

class Salesman extends Employee {
  get name() {...}
}

class Engineer extends Employee {
  get name() {...}
}

// After
class Employee {
  get name() {...}
}

class Salesman extends Employee {...}
class Engineer extends Employee {...}
```
- 무언가 중복되었다는 것은 한쪽의 변경이 다른 쪽에는 반영되지 않을 수 있다는 위험을 항상 수반한다.
- 나중에 다른 서브클래스가 더해질 수도 있으니 Party의 서브클래스가 monthlyCost()를 구현해야 한다는 사실을 알려주는게 좋을것이다.

### 12.2 필드 올리기(Pull Up Field)
```javascript
// Before
class Employee {...} // Java

class Salesman extends Employee {
  private String name;
}

class Engineer extends Employee {
  private String name;
}

// After
class Employee {
  protected String name;
}

class Salesman extends Employee {...}
class Engineer extends Employee {...}
```
- 필드들이 비슷한 방식으로 쓰인다고 판단되면 슈퍼클래스로 끌어올린다.

### 12.3 생성자 본문 올리기(Pull Up Constructor Body)
```javascript
// Before
class Party {...}

class Employee extends Party {
  constructor(name, id, monthlyCost) {
    super();
    this._id = id;
    this._name = name;
    this._monthlyCost = monthlyCost;
  }
}

// After
class Party {
  constructor(name){
    this._name = name;
  }
}

class Employee extends Party {
  constructor(name, id, monthlyCost) {
    super(name);
    this._id = id;
    this._monthlyCost = monthlyCost;
  }
}
```
- 서브클래스들에서 기능이 같은 메서드들을 발견하면 함수 추출하기와 메서드 올리기를 차례로 적용하여 말끔히 슈퍼클래스로 옮기곤 한다.
- 생성자는 할 수 있는 일과 호출 순서에 제약이 있기 때문에 조금 다른 식으로 접근해야 한다.
- 코드가 생성자의 인수인 name을 참조하므로 이 인수를 슈퍼클래스 생성자에게 매개변수로 건넨다.

### 12.4 메서드 내리기(Push Down Method)
```javascript
// Before
class Employee {
  get quota {...}
}

class Engineer extends Employee {...}
class Salesman extends Employee {...}

// After
class Employee {...}
class Engineer extends Employee {...}
class Salesman extends Employee {
  get quota {...}  
}
```
- 특정 서브클래스 하나(혹은 소수)와만 관련된 메서드는 슈퍼클래스에서 제거하고 해당 서브클래스(들)에 추가하는 편이 깔끔하다.

### 12.5 필드 내리기(Push Down Field)
```javascript
// Before
class Employee {        // Java
  private String quota;
}

class Engineer extends Employee {...}
class Salesman extends Employee {...}

// After
class Employee {...}
class Engineer extends Employee {...}

class Salesman extends Employee {
  protected String quota;
}
```
- 서브클래스 하나(혹은 소수)에서만 사용하는 필드는 해당 서브클래스(들)로 옮긴다.

### 12.6 타입 코드를 서브클래스로 바꾸기(Replace Type Code with Subclasses)
```javascript
// Before
function createEmployee(name, type) {
  return new Employee(name, type);
}

// After
function createEmployee(name, type) {
  switch (type) {
    case "engineer": return new Engineer(name);
    case "salesman": return new Salesman(name);
    case "manager":  return new Manager (name);
  }
}
```
- 타입 코드는 프로그래밍 언어에 따라 열거형이나 심볼, 문자열, 숫자 등으로 표현하며, 외부 서비스가 제공하는 데이터를 다루려 할 때 딸려오는 일이 흔하다.
- 서브클래스는 조건에 따라 다르게 동작하도록 해주는 다형성을 제공한다.
- 서브클래스는 특정 타입에서만 의미가 있는 값을 사용하는 필드나 메서드가 있을 때 발현된다.
- 생성자에 건네는 타입 코드 인수는 쓰이지 않으니 없애버린다.
- 다양한 서브 클래스 사이의 관계를 명확히 알려주는 클래스라면 그냥 두는 편이다.

### 12.7 서브클래스 제거하기(Remove Subclass)
```javascript
// Before
class Person {
  get genderCode() {return "X";}
}
class Male extends Person {
  get genderCode() {return "M";}
}
class Female extends Person {
  get genderCode() {return "F";}
}

// After
class Person {
  get genderCode() {return this._genderCode;}
}
```
- 서브클래싱은 원래 데이터 구조와는 다른 변종을 만들거나 종류에 따라 동작이 달라지게 할 수 있는 유용한 메커니즘이다.
- 서브클래스는 결국 한 번도 활용되지 않기도 하며, 때론 서브클래스를 필요로 하지 않는 방식으로 만들어진 기능에서만 쓰이기도 한다.
- 무언가의 표현 방법을 바꾸려 할 때면 먼저 현재의 표현을 캡슐화하여 이 변화가 클라이언트 코드에 주는 영향을 최소화한다.

### 12.8 슈퍼클래스 추출하기(Extract Superclass)
```javascript
// Before
class Department {
  get totalAnnualCost() {...}
  get name() {...}
  get headCount() {...}
}

class Employee {
  get annualCost() {...}
  get name() {...}
  get id() {...}
}

// After
class Party {
  get name() {...}
  get annualCost() {...}
}

class Department extends Party {
  get annualCost() {...}
  get headCount() {...}
}

class Employee extends Party {
  get annualCost() {...}
  get id() {...}
}
```
- 비슷한 일을 수행하는 두 클래스가 보이면 상속 메커니즘을 이용해서 비슷한 부분을 공통의 슈퍼클래스로 옮겨 담을 수 있다.
- 상속은 프로그램이 성장하면서 깨우쳐가게 되며, 슈퍼클래스로 끌어올리고 싶은 공통 요소를 찾았을 때 수행하는 사례가 잦았다.

### 12.9 계층 합치기(Colapse Hierarchy)
```javascript
// Before
class Employee {...}
class Salesman extends Employee {...}

// After
class Employee {...}
```
- 계층구조도 진화하면서 어떤 클래스와 그 부모가 너무 비슷해져서 더는 독립적으로 존재해야 할 이유가 사라지는 경우가 생기기도 한다. 바로 그 둘을 하나로 합쳐야 할 시점이다.

### 12.10 서브클래스를 위임으로 바꾸기(Replace Subclass with Delegate)
```javascript
// Before
class Order {
  get daysToShip() {
    return this._warehouse.daysToShip;
  }
}

class PriorityOrder extends Order {
  get daysToShip() {
    return this._priorityPlan.daysToShip;
  }
}

// After
class Order {
  get daysToShip() {
    return (this._priorityDelegate)
      ? this._priorityDelegate.daysToShip
      : this._warehouse.daysToShip;
  }
}

class PriorityOrderDelegate {
  get daysToShip() {
    return this._priorityPlan.daysToShip
  }
}
```
- 상속에는 단점이 있다. 무언가가 달라져야 하는 이유가 여러 개여도 상속에서는 그중 단 하나의 이유만 선택해 기준으로 삼을 수 밖에 없다.
- 상속은 클래스들의 관계를 아주 긴밀하게 결합한다. 부모를 수정하면 이미 존재하는 자식들의 기능을 해치기가 쉽기 때문에 각별히 주의해야 한다.
- 위임은 객체 사이의 일반적인 관계이므로 상호작용에 필요한 인터페이스를 명확히 정의할 수 있다. 즉, 상속보다 결합도가 훨씬 약하다. 그래서 서브클래싱(상속) 관련 문제에 직면하게 되면 흔히들 서브클래스를 위임으로 바꾸곤 한다.
- \"(클래스) 상속보다는 (객채) 컴포지션을 사용하라!\" 이 원칙은 상속을 쓰지 말라는 게 아니라, 과용하는 데 따른 반작용으로 나온 것이다.
- 일련의 큰 동작의 일부를 서브클래스에서 오버라이드하여 빈 곳으로 매꿔주도록 설계된 메서드가 여기 속한다. 슈퍼클래스를 수정할 때 굳이 서브클래스까지 고려할 필요가 없는게 보통이지만, 이 무지로 인해 서브클래스의 동작을 망가뜨리는 상황이 닥칠 수 있다. 하지만 이런 경우가 흔치 않다면 상속은 충분한 값어치를 한다.
- 처음부터 새로 만드는 방법을 사용할 수 없고, 대신 데이터 구조를 수정해야 할 때도 있다. 그런데 이 방식으로는 수많은 곳에서 참조되는 예약 인스턴스를 다른 것으로 교체하기 어렵다.
- 위임 클래스의 생성자는 서브클래스가 사용하던 매개변수와 예약 객체로의 참조(back-reference)를 매개변수로 받는다. 역참조가 필요한 이유는 서브클래스 메서드 중 슈퍼클래스에 저장된 데이터를 사용하는 경우가 있기 때문이다.
- 상속은 한 번만 쓸 수 있으니 야생과 사육을 기준으로 나누려면 종에 따른 분류를 포기해야 한다.
- 위임 클래스들은 종에 따라 달라지는 데이터와 메서드만을 담게 되고 종과 상관없는 공통 코드는 Bird 자체와 미래의 서브클래스들에 남는다.

### 12.11 슈퍼클래스를 위임으로 바꾸기(Replace Superclass with Delegate)
```javascript
// Before
class List {...}
class Stack extends List {...}

// After
class Stack {
  constructor() {
    this._storage = new List();
  }
}
class List {...}
```
- 슈퍼클래스의 기능들이 서브클래스에는 어울리지 않는다면 그 기능들을 상속을 통해 이용하면 안된다는 신호다.
- 제대로 된 상속이라면 서브클래스가 슈퍼클래스의 모든 기능을 사용함은 물론, 서브클래스의 인스턴스를 슈퍼클래스의 인스턴스로도 취급할 수 있어야 한다. 다시 말해, 슈퍼클래스가 사용되는 모든 곳에서 서브클래스의 인스턴스를 대신 사용해도 이상없이 동작해야 한다.

---

### Reference
- [리팩터링 2판: 코드 구조를 체계적으로 개선하여 효율적인 리팩터링 구현하기](http://www.yes24.com/Product/Goods/89649360)
- [refactoring.com](https://refactoring.com)
