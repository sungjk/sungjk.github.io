---
layout: entry
title: Test Doubles - Stubbing
author: 김성중
author-email: ajax0615@gmail.com
description: 과하게 사용하면 위험한 Stub
keywords: test double, stubs
publish: true
---

Stub은 없는 행위를 테스트가 함수에 덧씌우는 방법이다. 테스트에서 실제 구현을 대체할 수 있는 쉽고 빠른 방법이다. 아래 코드는 Stub을 이용해서 신용카드 서버의 응답을 시뮬레이션하는 예이다.

```java
@Test
public void getTransactionCount() {
  transactionCounter = new TransactionCounter(mockCreditCardServer);
  // Stub을 이용해 트랜잭션 3개를 반환한다.
  when(mockCreditServer.getTransactions()).thenReturn(newList(TRANSACTION_1, TRANSACTION_2, TRANSACTION_3));
  assertThat(transactionCounter.getTransactionCount()).isEqualTo(3);
}
```

# Stub 과용의 위험성
Stub을 과하게 사용하면 테스트를 유지보수할 일이 늘어나서 오히려 생산성을 갉아먹곤 한다.

### 불명확해진다
Stub을 이용하려면 대상 함수에 행위를 덧씌우는 코드를 추가로 작성해야 한다. 이 추가 코드는 읽는 이의 눈을 어지럽혀서 테스트의 의도를 파악하기 어렵게 한다. 특히 대상 시스템이 어떻게 동작하는지 잘 모르는 사람에게는 이해하기 어려운 코드가 만들어질 것이다.

만약 특정 함수를 Stubbing한 이유를 이해하기 위해 실제 시스템의 코드를 살펴보는 일이 일어나고 있다면 Stub이 적합하지 않다는 결정적인 신호다.

### 깨지기 쉬워진다
**Stub을 이용하면 대상 시스템의 내부 구현 방식이 테스트에 드러난다.** 제품의 내부가 다르게 구현되면 테스트 코드도 함께 수정해야 한다는 뜻이다. 좋은 테스트라면 사용자에게 영향을 주는 공개 API가 아닌 한, 내부가 어떻게 달라지든 영향받지 않아야 한다.

### 테스트 효과가 감소한다
Stub으로 원래 행위를 뭉개버리면 해당 함수가 실제 구현과 똑같이 동작하는지 보장할 방법이 사라진다. 예를 들어 다음 코드는 add() 메서드가 지켜야 할 명세 일부를 하드코딩하여 1과 2를 건네면 무조건 3을 반환하게 했다.

```java
when(stubCalculator.add(1, 2)).thenReturn(3);
```

**실제 구현의 명세에 의존하는 시스템이라면 Stub을 사용하지 않는게 좋다.** 명세의 세부 사항을 Stub이 복제해야만 하는데, 그 명세가 올바른지는 보장할 방법이 없기 때문이다.

또한 Stub을 이용하면 상태를 저장할 방법이 사라져서 대상 시스템의 특성 일부를 테스트하기 어려울 수 있다. 예를 들어 실제 구현이나 가짜 객체를 이용한다면 database.save(item) 으로 저장한 상품 정보를 database.get(item.id())를 호출해 어렵지 않게 다시 꺼내올 수 있을 것이다. 실제 구현과 가짜 객체 모두 내부 상태를 관리하기 때문이다. 하지만 Stub에서는 불가능하다.

### Stub을 과하게 사용한 예

```java
@Test
public vodi creditCardIsCharged() {
  // mock framework로 생성한 Test Double을 건넨다.
  paymentProcessor = new PaymentProcessor(mockCreditCardServer, mockTransactionProcessor);
  // Test Double이 함수를 Stub하여 뭉갠다.
  when(mockCreditCardServer.isServerAvailable()).thenReturn(true);
  when(mockTransactionProcessor.beginTransaction()).thenReturn(transaction);
  when(mockCreditCardServer.initTransaction(transaction)).thenReturn(true);
  when(mockCreditCardServer.pay(transaction, creditCard, 500)).thenReturn(false);
  when(mockTransactionProcessor.endTransaction()).thenReturn(true);
  // 대상 시스템을 호출한다.
  paymentProcessor.processPayment(creditCard, Money.dollars(500));
  // pay() 메서드가 거래 내역을 실제로 전달했는지는 확인할 방법이 없다.
  // 검증할 수 있는 것은 그저 pay() 메서드가 호출되었다는 사실뿐이다.
  verify(mockCreditCardServer).pay(transaction, creditCard, 500);
}
```

같은 테스트를 Stub 없이 다시 작성하면 아래처럼 될 것이다. 테스트가 얼마나 간결해졌는지 비교해보라. 트랜잭션이 처리되는 자세한 과정도 테스트 코드에서 사라졌다. 처리 방법은 신용카드 서버가 알고 있으니 특별히 설정할 게 없다.

```java
@Test
public vodi creditCardIsCharged() {
  paymentProcessor = new PaymentProcessor(creditCardServer, transactionProcessor);
  // 대상 시스템을 호출한다.
  paymentProcessor.processPayment(creditCard, Money.dollars(500));
  // 신용카드 서버의 상태를 조회하여 지불 결과가 잘 반영됐는지 확인한다.
  assertThat(creditCardServer.getMostRecentCharge(creditCard)).isEqualTo(500);
}
```

물론 테스트가 외부의 신용카드 서버와 실제로 통신하는 건 원치 않을 테니 신용카드 서버는 가짜 객체로 대체하는게 좋다. 가짜 객체를 이용할 수 없는 상황이라면, 대안으로 실제 구현이 테스트용으로 밀폐시킨 신용카드 서버와 통신하게 할 수 있다. 물론 가짜 객체보다는 테스트 속도가 느려질 것이다.

### Stub이 적합한 경우
Stub은 실제 구현을 포괄적으로 대체하기 보다는 **특정 함수가 특정 값을 반환하도록 하여 대상 시스템을 원하는 상태로 변경하려 할 때 제격이다.** 맨 처음 코드에서는 대상 시스템이 빈 거래 목록을 반환하지 않아야 했다. 실제 구현이나 가짜 객체로는 원하는 반환값을 얻거나 특정 오류를 일으키기가 불가능할 수 있다. 하지만 Stub으로는 함수의 동작을 테스트 코드에서 정의할 수 있으므로, 이럴 때 쉽게 원하는 결과를 얻을 수 있다.

**목적이 분명하게 드러나게 하려면 Stub된 함수 하나하나가 assert문들과 직접적인 연관이 있어야 한다.** 그래서 테스트들은 대체로 적은 수의 함수만 Stub으로 대체한다. Stub된 함수가 많을수록 테스트의 의도는 희미해질 것이다. Stub이 많이 눈에 띄는 것만으로도 Stub을 과하게 사용했다는 신호일 수 있다. 혹은 대상 시스템이 너무 복잡하니 리팩터링하라는 신호일 수도 있다.

Stub을 활용하기 괜찮은 상황일수록 되도록 실제 구현이나 가짜 객체를 이용하라고 권한다. 이 둘은 시시콜콜한 구현 방식까지는 노출하지 않으며, 코드가 훨씬 간결해지기 때문에 테스트 자체에 오류가 숨어들 가능성이 적다. 하지만 테스트가 지나치게 복잡해지지 않을 정도로 제한적으로만 사용한다면 Stub도 충분히 활용할 수 있는 기술이다.

---

### 참고
- [Software Engineering at Google > Stubbing](https://abseil.io/resources/swe-book/html/ch13.html#stubbing-id00091)
- [Software Engineering at Google > stubs and mocks are bad.](https://news.ycombinator.com/item?id=27882652)
- [Stubs and mocks make bad tests](https://swizec.com/blog/what-i-learned-from-software-engineering-at-google/#stubs-and-mocks-make-bad-tests)