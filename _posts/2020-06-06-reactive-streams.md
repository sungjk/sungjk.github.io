---
layout: entry
title: Reactive Streams 훑어보기
author: 김성중
author-email: ajax0615@gmail.com
description: Back pressure를 기반으로 비동기 스트림 처리의 표준을 제공하는 Reactive Streams를 알아봅니다.
keywords: reactive, streams, reactive streams, webflux
publish: true
---

# Reactive Streams 정의하기
Reactive Streams은 Netflix, Lightbend, Pivotal의 엔지니어들에 의해 2013년 말에 시작되었다. Reactive Streams은 차단되지 않는 Back pressure를 갖는 비동기 스트림 처리의 표준을 제공하는 것이 목적이다.

Reactive Programming의 비동기 특성은 동시에 여러 작업을 수행하여 더 큰 확장성을 얻게 해준다. Back pressure는 데이터를 소비하는 Consumer가 처리할 수 있는 만큼으로 전달 데이터를 제한함으로써 지나치게 빠른 데이터 소스로부터의 데이터 전달 폭주를 피할 수 있는 수단이다.

> 자바 스트림은 대개 동기화되어 있고 한정된 데이터로 작업을 수행한다. Reactive Streams은 무한 데이터셋을 비롯해서 어떤 크기의 데이터셋이건 비동기 처리를 지원한다. 그리고 실시간으로 데이터를 처리하며, Back pressure를 사용해서 데이터 전달 폭주를 막는다.

Reactive Streams은 4개의 인터페이스인 Publisher, Subscriber, Subscription, Processor로 요약할 수 있다. Publisher는 하나의 Subscription당 하나의 Subscriber에 발행하는 데이터를 생성한다. Publisher 인터페이스에는 Subscriber가 Publisher를 구독 신청할 수 있는 subscribe() 메서드 한 개가 선언되어 있다.

```java
public interface Publisher<T> {
  void subscribe(Subscriber<? super T> subscriber);
}
```

그리고 Subscriber가 구독 신청되면 Publisher로부터 이벤트를 수신할 수 있다. 이 이벤트들은 Subscriber 인터페이스의 메서드를 통해 전송된다.

```java
public interface Subscriber<T> {
  void onSubscribe(Subscription sub);
  void onNext(T item);
  void onError(Throwable ex);
  void onComplete();
}
```

Subscriber가 수신할 첫 번째 이벤트는 onSubscribe()의 호출을 통해 이루어진다. Publisher가 onSubscribe()를 호출할 때 이 메서드의 인자로 Subscription 객체를 Subscriber에 전달한다. Subscriber는 Subscription 객체를 통해서 구독을 관리할 수 있다.

```java
public interface Subscription {
  void request(long n);
  void cancel();
}
```

Subscriber는 request()를 호출하여 전송되는 데이터를 요청하거나, 또는 더 이상 데이터를 수신하지 않고 구독을 취소한다는 것을 나타내기 위해 cancel()을 호출할 수 있다. request()를 호출할 때 Subscriber는 받고자 하는 데이터 항목 수를 나타내는 long 타입의 값을 인자로 전달한다. 이것이 Back pressure이며, Subscriber가 처리할 수 있는 것보다 더 많은 데이터를 Publisher가 전송하는 것을 막아준다. 요청된 수의 데이터를 Publisher가 전송한 후에 Subscriber는 다시 request()를 호출하여 더 많은 요청을 할 수 있다.

Subscriber의 데이터 요청이 완료되면 데이터가 스트림을 통해 전달되기 시작한다. 이때 onNext() 메서드가 호출되어 Publisher가 전송하는 데이터가 Subscriber에게 전달되며, 만일 에러가 생길 때는 onError()가 호출된다. 그리고 Publisher에서 전송할 데이터가 없고 더 이상의 데이터를 생성하지 않는다면 Publisher가 onComplete()를 호출하여 작업이 끝났다고 Subscriber에게 알려준다.

Processor 인터페이스는 다음과 같이 Subscriber 인터페이스와 Publisher 인터페이스를 결합한 것이다.

```java
public interface Processor<T, R> extends Subscriber<T>, Publisher<R> {}
```

Subscriber 역할로 Processor는 데이터를 수신하고 처리한다. 그다음에 역할을 바꾸어 Publisher 역할로 처리 결과를 자신의 Subscriber들에게 발행한다. Reactive Streams은 꽤 직관적이라서 데이터 처리 파이프라인을 개발하는 방법을 쉽게 알 수 있다. 즉, Publisher로부터 시작해서 0 또는 그 이상의 Processor를 통해 데이터를 끌어온 다음 최종 결과를 Subscriber에 전달한다.

그러나 Reactive Streams 인터페이스는 스트림을 구성하는 기능이 없다. 이에 따라 프로젝트 리액터에서는 리액티브 스트림을 구성하는 API를 제공하여 Reactive Streams 인터페이스를 구현하였다.

---

### 참고
- [Reactive Streams](https://www.reactive-streams.org/)
- [스프링 인 액션](http://www.yes24.com/Product/Goods/6229706)
