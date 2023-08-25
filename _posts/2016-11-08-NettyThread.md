---
layout: entry
title: How Netty uses thread pools?
author-email: ajax0615@gmail.com
description: Asynchronous event-driven 네트워크 애플리케이션 프레임워크인 Netty에서 Thread pool을 어떻게 사용하고 있는지 살펴봅니다.
keywords: Netty, Channel, ChannelPipeline, ChannelHandler
publish: true
---

> Netty is a NIO client server framework which enables quick and easy development of network applications such as protocol servers and clients.

네티(Netty) 프로젝트의 공식 홈페이지에서는 Netty를 위와 같이 소개하고 있다. 네티는 비동기 이벤트 네트워크 애플리케이션 프레임워크다. 유지보수를 고려한 고성능 프로토콜 서버와 클라이언트를 안정적이고 빠르게 개발할 수 있다. 이를 반증이라도 하듯 고속 그리고 대용량 네트워크 데이터를 처리하는 트위터와 네이버 라인도 네티를 사용하고 있다. 동접자 수와 퍼포먼스 모두를 만족하는 네트워크 프로그램을 만들어야 한다면 네티를 강력 추천한다.

![Netty-components](/images/2016/11/08/netty-components.png "netty-components"){: .center-image }

Netty framework를 사용하다보면 Channel, EventLoop 같은 용어들을 자주 마주하게 된다. Spring Webflux에 대해 조금 알고 있다면 EventLoop가 조금은 친숙할 것이다. 크게 Thread 기반 요청 처리와 EventLoop 기반 요청 처리를 나눠볼 때 여기서 말하는 EventLoop가 Netty의 EventLoop와 같다고 볼 수 있다. 그럼 좀 더 자세하게 Netty framework에서 제공하는 주요 인터페이스들을 살펴보면서 내부적으로 어떻게 동작하는지 알아보자.

Channel이 무엇이고 어떻게 활용되는지 개념적인걸 알아보고, 좀 더 상위 레벨에서 Netty의 요청 흐름을 파악하기 위해 ChannelPipeline 인터페이스를 살펴보겠다. 각 개념들을 살펴보다보면 중간중간 새로운 용어들이 나오는데 일단 이런게 있구나 하며 읽고 넘어가면 아래에서 또 설명할테니 마음 편하게 살펴봅시다.

---

## Channel

Read, Write, Connect, Bind 와 같은 I/O 작업을 할 수 있는 네트워크 소켓이나 컴포넌트를 나타내는 개념이고, 아래와 같은 인터페이스를 제공한다.

- 채널의 현재 상태 - OPEN 상태인지, CONNECTED 상태인지 등
- 채널의 다양한 설정 파라미터들 - 송신 버퍼 사이즈, 수신 버퍼 사이즈 등
- 다양한 I/O Operations - Read, Write, Connect, Bind 등
- 모든 I/O 이벤트를 처리할 ChannelPipeline

채널의 모든 I/O 작업들은 비동기로 동작해서, 완료 여부와 상관없이 호출 즉시 리턴되고, ChannelFuture를 통해 I/O 작업이 성공인지 실패인지 취소되었는지를 알려준다. 그리고 채널은 각 용도에 맞게 다양한 하위 인터페이스([DuplexChannel](https://netty.io/4.1/api/io/netty/channel/socket/DuplexChannel.html), [Http2StreamChannel](https://netty.io/4.1/api/io/netty/handler/codec/http2/Http2StreamChannel.html), [ServerChannel](https://netty.io/4.1/api/io/netty/channel/ServerChannel.html),  [ServerSocketChannel](https://netty.io/4.1/api/io/netty/channel/socket/ServerSocketChannel.html), [SocketChannel](https://netty.io/4.1/api/io/netty/channel/socket/SocketChannel.html), [UdtChannel](https://netty.io/4.1/api/io/netty/channel/udt/UdtChannel.html), [UdtServerChannel](https://netty.io/4.1/api/io/netty/channel/udt/UdtServerChannel.html) 등)를 제공하고 그 구현체들도 제공하고 있다.

![channel](/images/2016/11/08/channel.png "channel"){: .center-image }

<center>jboss netty v3.8의 Channel 인터페이스. 지금은 훨씬 더 많은 하위 인터페이스가 존재한다.</center>

Channel을 보다 보면 Socket 인 것 같기도 하고 모호한 부분이 있는데 Socket이라고 표현하기엔 제공하는 기능과 범주가 너무 달라서, **네트워크 연결에 대한 추상화된 표현**이라고 이야기하는게 맞을것 같다. 그래서 딱 뭐라고 명확하게 표현하기도 어려운 것 같다.

---

## ChannelPipeline

Netty의 가장 핵심이자 기본적인 개념인 Channel은 생성되고 나면 ChannelPipeline이라는걸 구성하게 된다. Netty는 기본적으로 데이터를 받기 위한 Input Stream을 Inbound 라고 표현하고, 무언가 데이터를 내보내기 위한 Output Stream을 Outbound 라고 표현한다. 그리고 아래 그림에 표현된 것처럼, ChannelPipeline은 Inbound 이벤트와 Outbound 이벤트들을 처리하거나 가로채서 무언가를 실행할 수 있는 ChannelHandler의 조합을 나타낸다. [Core J2EE에 소개된 Intercepting Filter 패턴](https://www.oracle.com/java/technologies/intercepting-filter.html)을 기반으로 구현되어 있어서, 개발자가 핸들러를 자유롭게 추가할 수 있고 핸들러들이 서로 상호작용할 수 있도록 제어할 수도 있다. 그리고 각 Channel에는 고유한 파이프라인이 존재하고, 새로운 Channel이 만들어질 때마다 자동으로 ChannelPipeline도 생성된다.

- 그림 왼쪽 하단에 표현된 Inbound 이벤트 처리 과정을 보면, Inbound 이벤트는 Inbound Handler에 의해 처리된다. Inbound Handler는 I/O Thread에 의해 생성된 Inbound data를 처리하는데, Inbound data는 `SocketChannel.read(ByteBuffer)` 같은 input operation을 이용해서 remote peer 로부터 읽어서 생성된다.
- 마찬가지로 그림 오른쪽 상단에 표현된 Outbound 이벤트 처리 과정을 보면, Outbound 이벤트는 Outbound Handler에 의해 처리된다. Outbound Handler는 Write 요청과 같은 외부로 내보낼 트래픽을 생성하거나 변환하는데, Outbound Handler를 모두 거치고 나면 I/O Thread에서 `SocketChannel.write(ByteBuffer)` 같은 output operation을 이용해서 처리된다.

![channel-pipeline](/images/2016/11/08/channel-pipeline.png "channel-pipeline"){: .center-image }

- 그림 왼쪽 하단에 표현된 Inbound 이벤트 처리 과정을 보면, Inbound 이벤트는 Inbound Handler에 의해 처리된다. Inbound Handler는 I/O Thread에 의해 생성된 Inbound data를 처리하는데, Inbound data는 `SocketChannel.read(ByteBuffer)` 같은 input operation을 이용해서 remote peer 로부터 읽어서 생성된다.
- 마찬가지로 그림 오른쪽 상단에 표현된 Outbound 이벤트 처리 과정을 보면, Outbound 이벤트는 Outbound Handler에 의해 처리된다. Outbound Handler는 Write 요청과 같은 외부로 내보낼 트래픽을 생성하거나 변환하는데, Outbound Handler를 모두 거치고 나면 I/O Thread에서 `SocketChannel.write(ByteBuffer)` 같은 output operation을 이용해서 처리된다.

```kotlin
val p: ChannelPipeline = ...
p.addLast("1", InboundHandlerA())
p.addLast("2", InboundHandlerB())
p.addLast("3", OutboundHandlerA())
p.addLast("4", OutboundHandlerB())
p.addLast("5", InboundOutboundHandler())
```

위 예시에서 Inbound는 Inbound Handler를 의미하고 Outbound는 Outbound Handler를 의미하는데, 위 설정대로라면 Inbound 이벤트가 발생했을때 핸들러 적용은 1, 2, 3, 4, 5 순서대로 된다. 반면에 Outbound 이벤트가 발생하면 5, 4, 3, 2, 1 순서로 적용된다. 그런데 항상 이렇게 적용되지는 않고, 핸들러 스택의 깊이를 줄이기 위해 특정 핸들러 평가를 건너뛰는 규칙이 있다.

- 3, 4는 ChannelInboundHandler 인터페이스를 구현하지 않았기 때문에, Inbound 이벤트는 3, 4는 건너 뛰고 1, 2, 5 순서로 적용된다.
- 1, 2는 ChannelOutboundHandler 인터페이스를 구현하지 않았기 때문에, Outbound 이벤트는 1, 2는 건너뛰고 5, 4, 3 순서로 적용된다.
- 5는 ChannelInboundHandler, ChannelOutboundHandler 인터페이스를 모두 구현했기 때문에, Inbound 이벤트와 Outbound 이벤트 모두에 적용되어서 1, 2, 5 그리고 5, 4, 3 순서에 모두 적용된다.

이렇듯 다양한 ChannelHandler를 만들고 조합해서 Inbound(Read), Outbound(Write) 이벤트를 처리하기 위한 Pipeline을 구성할 수 있다. 예를 들어, 아래처럼 몇가지 프로토콜과 비즈니스 로직을 수행하는 서버가 있다고 가정해보자.

1. Protocol Decoder - ByteBuf 같은 Binary data를 Java object로 변환
2. Protocol Encoder - Java object를 Binary data로 변환
3. Business Logic Handler - 데이터베이스 접근과 같은 비즈니스 로직 실행

```kotlin
val group: EventExecutorGroup = new DefaultEventExecutorGroup(16)
...
val pipeline: ChannelPipeline = ch.pipeline()
pipeline.addLast("decoder", MyProtocolDecoder())
pipeline.addLast("encoder", MyProtocolEncoder())

// I/O 스레드 말고 다른 스레드에서 MyBusinessLogicHandler를 적용
pipeline.addLast(group, "handler", MyBusinessLogicHandler())
```

위에서 I/O Thread가 블로킹되는걸 막고 싶다면(by a time-consuming task) MyBusinessLogicHandler 이벤트를 I/O 스레드가 아닌 다른 별도의 스레드에서 실행하게 할 수 있다. 비즈니스 로직이 비동기로 수행되거나 매우 빨리 끝나는 작업이라면 그룹 지정을 따로 할 필요는 없다.

그리고 ChannelPipeline을 구성할 때 여러 ChannelHandler가 서로 상호작용하는데, 이 때 Thread safe 함을 보장해준다. 파이프라인에서 처리중인 데이터를 암호화하거나 복호화하는 핸들러를 각각 추가하더라도 스레드 경합으로 인해 문제가 발생하지 않는다.

---

## ChannelHandler

위에서 ChannelHandler는 파이프라인 안에서 조합을 통해 실행된다. ChannelHandler는 I/O Event와 I/O Operation을 처리하거나 파이프라인 내에서 다음 핸들러를 실행하는 역할을 한다. 그리고 Inbound, Outbound에 따라 하위 타입을 제공한다.

- [ChannelInboundHandler](https://netty.io/4.1/api/io/netty/channel/ChannelInboundHandler.html): Inbound I/O Event를 다루는 핸들러
- [ChannelOutboundHandler](https://netty.io/4.1/api/io/netty/channel/ChannelOutboundHandler.html): Outbound I/O Operation을 다루는 핸들러

ChannelInboundHandler, ChannelOutboundHandler 모두 순수한 인터페이스라서 개발자가 이걸 직접 구현해서 사용해야하는데, 편의를 위해 ChannelHandlerAdapter 추상클래스를 구현한 어댑터 클래스도 제공하고 있다.

- ChannelInboundHandlerAdapter: Inbound I/O Event 어댑터 구현체
- ChannelOutboundHandlerAdapter: Outbound I/O Operation 어댑터 구현체
- ChannelDuplexHandler: Inbound, Outbound Event 처리용 어댑터 구현체

---

## ChannelHandlerContext

ChannelPipeline 안에서는 여러 ChannelHandler가 서로 상호작용을 한다고 했다. 이건 어떻게 동작하는걸까? ChannelHandlerContext라는 context 객체가 ChannelPipeline 안에서 핸들러간 서로 상호작용할 수 있게 도와준다. Context 객체를 통해서 핸들러는 upstream과 downstream으로 이벤트를 전달하고, 파이프라인을 동적으로 변경시킬 수도 있고, 정보를 저장할 수도 있다(AttributeKeys 사용). 좀 더 구체적으로는 ChannelHandlerContext에 있는 이벤트 전파 메서드(event propagation methods)를 호출해서 다음 핸들러로 이벤트를 전달한다.

```kotlin
// Inbound event propagation methods:
ChannelHandlerContext.fireChannelRegistered()
ChannelHandlerContext.fireChannelActive()
ChannelHandlerContext.fireChannelRead(Object)
ChannelHandlerContext.fireChannelReadComplete()
ChannelHandlerContext.fireExceptionCaught(Throwable)
ChannelHandlerContext.fireUserEventTriggered(Object)
ChannelHandlerContext.fireChannelWritabilityChanged()
ChannelHandlerContext.fireChannelInactive()
ChannelHandlerContext.fireChannelUnregistered()

// Outbound event propagation methods:
ChannelOutboundInvoker.bind(SocketAddress, ChannelPromise)
ChannelOutboundInvoker.connect(SocketAddress, SocketAddress, ChannelPromise)
ChannelOutboundInvoker.write(Object, ChannelPromise)
ChannelHandlerContext.flush()
ChannelHandlerContext.read()
ChannelOutboundInvoker.disconnect(ChannelPromise)
ChannelOutboundInvoker.close(ChannelPromise)
ChannelOutboundInvoker.deregister(ChannelPromise)

// Inbound, Outbound event propagation Examples:
class MyInboundHandler : ChannelInboundHandlerAdapter() {
    override fun channelActive(ctx: ChannelHandlerContext) {
        println("Connected!")
        ctx.fireChannelActive()
    }
 }
 class MyOutboundHandler : ChannelOutboundHandlerAdapter() {
    override fun close(ctx: ChannelHandlerContext, promise: ChannelPromise) {
        println("Closing...")
        ctx.close(promise)
    }
 }
```

### 상태 관리(State Management)

ChannelHandler 안에서 간단하게는 아래 코드처럼 멤버 변수를 이용해서 상태를 관리할 수 있다.

```kotlin
class DataServerHandler : SimpleChannelInboundHandler<Message>() {
    private lateinit var loggedIn: Boolean

    override fun channelRead0(ctx: ChannelHandlerContext, message: Message) {
        if (message is LoginMessage) {
            authenticate(message)
            loggedIn = true
        } else (message is GetDataMessage) {
            if (loggedIn) {
                ctx.writeAndFlush(fetchSecret(message))
            } else {
                    fail()
            }
        }
    }
}
```

그런데 ChannelHandler 인스턴스 하나를 여러 채널에 사용하게 되면 인증되지 않은 클라이언트가 정보를 조회할 수 있는 상황이 발생할 수 있다. 따라서 이런 상황을 막으려면 매 번 새로운 채널을 만들때마다 새로운 핸들러를 생성해줘야 한다(ChannelHandler 인스턴스를 하나의 Connection에 할당).

```kotlin
class DataServerInitializer : ChannelInitializer<Channel>() {
    override fun initChannel(channel: Channel) {
        // 채널 생성할 때마다 새로운 핸들러 생성
        channel.pipeline().addLast("handler", DataServerHandler())
    }
}
```

매 번 이렇게 핸들러 인스턴스를 생성하고 싶지 않다면 ChannelHandlerContext에서 제공하는 AttributeKeys를 사용하면 된다.

```kotlin
@Sharable
class DataServerHandler : SimpleChannelInboundHandler<Message>() {
    private val auth: AttributeKey<Boolean> = AttributeKey.valueOf("auth")

    override fun channelRead0(ctx: ChannelHandlerContext, message: Message) {
        val atrr = ctx.attr(auth)
        if (message is LoginMessage) {
            authenticate(message)
            atrr.set(true)
        } else (message is GetDataMessage) {
            if (Boolean.TRUE.equals(attr.get()) {
                ctx.writeAndFlush(fetchSecret(message))
            } else {
                fail()
            }
        }
    }
}
```

이제 핸들러의 상태가 ChannelHandlerContext에 연결되어 있으므로, 동일한 핸들러 인스턴스를 서로 다른 파이프라인에 추가할 수 있다.

```kotlin
class DataServerInitializer : ChannelInitializer<Channel>() {
    private val SHARED = DataServerHandler()

    override fun initChannel(channel: Channel) {
        // 채널 생성할 때마다 동일한 핸들러 추가
        channel.pipeline().addLast("handler", SHARED)
    }
}
```

위 예제에서처럼 AttributeKey를 사용했다면 `@Sharable` annotation을 달아줘야 한다. ChannelHandler에 `@Sharable` annotation이 붙어 있으면, 핸들러 인스턴스를 한 번만 생성하고 Race Condition 없이 하나 이상의 채널 파이프라인에 여러 번 등록될 수 있음을 의미한다. 그런데 만약 이 annotation이 붙어있지 않으면 멤버 변수를 사용했을 때처럼 공유되지 않은 상태가 되기 때문에, 파이프라인에 추가할 때마다 새로운 핸들러 인스턴스를 만들어줘야 한다.

---

## EventLoop

EventLoop를 이해한다는건 Netty의 Threading model을 이해하는 것과 마찬가지다. Thread는 기본적으로 매 작업마다 생성하고 소멸시키는 것보다 Thread Pool을 사용해서 재사용 하는게 효과적이다. 그런데 Thread 수가 증가하면 Context switching 비용도 마찬가지로 증가하고 부하가 심할 경우에는 문제가 발생할 수도 있, Multithreading은 애플리케이션에 복잡성을 가져다 주고 이로 인한 동시성 문제까지 이어질 수 있다. 그래서 EventLoop에 대해 알아볼 때, Netty가 이런 문제를 어떻게 단순화했는지 살펴보는게 중요하다.

Network framework 들은 기본적으로 네트워크 연결(Connection)과 관련된 Life Cycle 관리를 위해 발생하는 이벤트를 처리하는 작업들을 하는데, Netty에서도 이런 인터페이스를 EventLoop라는 이름으로 제공한다.

Netty의 EventLoop는 동시성(Concurrency)과 네트워킹(Networking)이라는 가장 기본적인 2가지 API를 기반으로 구성되어 있다. `io.netty.util.concurrent` 패키지는 JDK 패키지 `java.util.concurrent`를 빌드하여 스레드 실행기를 제공하고, `io.netty.channel` 패키지의 클래스는 Channel 이벤트와 인터페이스하기 위한 역할을 한다.

![event-executor](/images/2016/11/08/event-executor.png "event-executor"){: .center-image }

일반적인 이벤트-드리븐 애플리케이션은 두가지 방식으로 동작한다. 첫 번째는 **이벤트 리스너와 이벤트 처리 스레드에 기반한 방법**이다. 대부분의 UI 처리 프레임워크가 사용하는 방법으로써 이벤트를 처리하는 로직을 가진 이벤트 메서드를 대상 객체의 이벤트 리스너에 등록하고 객체에 이벤트가 발생했을 때 이벤트 처리 스레드에서 등록된 메서드를 수행한다. 이때 이벤트 메서드를 수행하는 스레드는 대부분 단일 스레드로 구현된다. 두 번째는 이벤트 큐에 이벤트를 등록하고 **이벤트 루프가 이벤트 큐에 접근하여 처리하는 방법** 이다. 첫 번째 방법에 비해 프레임워크의 구현이 복잡하지만 프레임워크의 사용자 입장에서는 더 간단하게 사용할 수 있다.

이벤트 루프가 다중 스레드일 때 이벤트 큐는 여러 개의 스레드에서 공유되며 가장 먼저 이벤트 큐에 접근한 스레드가 첫 번째 이벤트를 가져와서 이벤트를 수행한다. 이 때 이벤트 큐에 입력된 이벤트를 처리하고자 이벤트 루프 스레드를 사용한다.

![event_loop](/images/2016/11/08/event_loop.jpg "event_loop"){: .center-image }

위 그림은 객체(Event Emitters)에서 발생한 이벤트와 이벤트 루프의 연관 관계를 보여준다. 객체에서 발생한 이벤트는 이벤트 큐에 입력되고 이벤트 루프는 큐에 입력된 이벤트가 있을 때 해당 이벤트를 꺼내서 이벤트를 실행한다. 이것이 이벤트 루프의 기본 개념이다. 이 개념에 더해서 이벤트 루프가 지원하는 스레드 종류에 따라서 단일 스레드 이벤트 루프와 다중 스레드 이벤트 루프로 나뉘고, 이벤트 루프가 처리한 이벤트의 결과를 돌려주는 방식에 따라서 콜백 패턴과 퓨처 패턴으로 나뉜다. 네티는 이 두 가지 패턴을 모두 지원한다.

그렇다면 Netty는 스레드를 어떤식으로 사용하고 있을까? 네티는 단일 스레드 이벤트 루프와 다중 스레드 이벤트 루프를 모두 사용할 수 있다. 일반적인 다중 스레드 이벤트 루프를 사용하는 프레임워크에서 다중 스레드 이벤트 루프는 이벤트의 발생 순서와 실행 순서가 일치하지 않지만, 네티에서는 이벤트 루프의 종류에 상관없이 이벤트 발생 순서에 따른 실행 순서를 보장한다. 어떻게 처리 순서가 뒤바뀌는 현상을 처리할 수 있을까? 네티가 다중 스레드 이벤트 루프를 사용함에도 불구하고 이벤트 발생 순서와 실행 순서를 일치시킬 수 있는 이유는 아래의 세 가지 특징에 기반한다.

- 네티의 이벤트는 채널에서 발생한다.
- 이벤트 루프 객체는 이벤트 큐를 가지고 있다.
- 네티의 채널은 하나의 이벤트 루프에 등록된다.

![event-loop-thread](/images/2016/11/08/event-loop-thread.png "event-loop-thread"){: .center-image }

네티의 각 채널은 위와 같이 개별 이벤트 루프 스레드에 등록된다. 그러므로 채널에서 발생한 이벤트는 항상 동일한 이벤트 루프 스레드에서 처리하여 이벤트 발생 순서와 처리 순서가 일치된다. 기존의 이벤트 루프 스레드와의 차이점은 **이벤트 루프 스레드의 이벤트 큐 공유 여부** 이다. 즉 이벤트의 수행 순서가 일치하지 않는 근본적인 이유는 이벤트 루프들이 이벤트 큐를 공유하기 때문에 발생하는데, 네티는 이벤트 큐를 이벤트 루프 스레드의 내부에 둠으로써 수행 순서 불일치의 원인을 제거했다.

위 그림에서는 하나의 이벤트 루프 스레드에 하나의 채널만 등록되어 있지만, 실제로는 하나의 이벤트 루프 스레드에 여러 채널을 등록할 수 있다. 이와 같읕 구조는 다중 채널에 대한 효율적인 스레드 구조를 만들어낸다. 여러 채널이 이벤트 루프에 등록되었을 때에도 이벤트 처리는 항상 발생 순서와 일치한다. 즉, 처리를 위한 이벤트 루프 스레드가 하나이므로 이벤트 처리 순서는 이벤트 발생 순서와 같다.

Netty는 NIO를 바탕으로 NioServerSocketChannelFactory를 구현하였다. 여기에는 2가지 타입의 스레드가 있는데, 하나는 보스 스레드 *boss thread* 이고, 나머지 하나는 워커 스레드 *worker thread* 이다. 보스 스레드는 모든 리슨 소켓(listen socket)들을 관리하고, 워커 스레드는 연결된 소켓(accepted socket)을 관리한다고 보면 된다.

### Boss threads
ChannelHandlers는 포트 별로 접속을 허용해주는 보스 스레드를 가지고 있다. 예를 들어, 80번과 443번 서버 포트를 연다면, 보스 스레드를 2개 가지고 있는 셈이다. 일단 커넥션이 성공적으로 이루어지면 보스 스레드는 승인된(accepted) 채널을 하나의 워커 스레드로 전달한다.

### Worker threads
워커 스레드는 개발자가 명시한 갯수만큼 Worker Thread Pool을 유지한다(디폴트 개수는 코어수*2). 워커 스레드는 Non-blocking 모드에서 채널에 읽기와 쓰기 작업을 Non-blocking으로 처리할 수 있다.

보스 스레드와 워커 스레드는 코드 상에서 다음과 같이 활용할 수 있다. 개발자는 다음과 같은 템플릿을 유지하고, WebsocketHandler 핸들러에 요청을 처리할 로직을 작성하면 된다. 코드에 대한 상세 설명은 생략하도록 하겠다.

```scala
import ...

class WebsocketHandler(queue: Queue[Request]) extends ChannelInboundHandlerAdapter {
    override def channelRead(ctx: ChannelHandlerContext, msg: Object): Unit = {
        println(s"from message: ${msg.getClass()}")
        msg match {
            case frame: TextWebSocketFrame =>
                println(frame.text())
                ctx.channel().writeAndFlush(new TextWEbSocketFrame(frame.text()))   // echo 역할
            case frame =>
                println(frame)
        }
    }
}

object Main {
    val websocketPath = "/ws"

    val queue = new LinkedBlockingQueue[Request]

    trait Configure {
        val portNumber: Int
        val workerCount: Int
    }

    def start(configure: Configure): Unit = {
        val bossGroup = new NioEventLoopGroup()
        val workerGroup = new NioEventLoopGroup()
        try {
            val b = new ServerBootstrap()
            b.group(bossGroup, workerGroup)
                .channel(classOf[NioServerSocketChannel])
                .childHandler(new ChannelInitializer[SocketChannel]() {
                    override def initChannel(ch: SocketChannel): Unit = {
                        val pipeline = ch.pipeline()
                        pipeline.addLast(new HttpServerCodec())
                        pipeline.addLast(new HttpObjectAggregator(65536))
                        pipeline.addLast(new WebSocketServerCompressionHandler())
                        pipeline.addLast(new WebSocketServerProtocolHandler(websocketPath, null, true))
                        pipeline.addLast(new HttpRequestHandler(websocketPath))
                        pipeline.addLast(new WebsocketHandler(queue))
                    }
                })
                .option[java.lang.Integer](ChannelOption.SO_BACKLOG, 128)
                .childOption[java.lang.Boolean](ChannelOption.SO_KEEPALIVE, true)

            val f = b.bind(configure.portNumber).sync()

            println(s"Now listeing to port ${configure.portNumber}")
            f.channel().closeFuture().sync()
        } finally {
            workerGroup.shutdownGracefully()
            bossGroup.shutdownGracefully()
        }
    }

    def main(args: Array[String]): Unit = {
        val configure = new Configure {
            val portNumber = 8000
            val workerCount = 200
        }
        start(configure)
    }
}
```

---

## References

- [Channel](https://netty.io/4.1/api/io/netty/channel/Channel.html)
- [ChannelHandlerContext](https://netty.io/4.1/api/io/netty/channel/ChannelHandlerContext.html)
- [Attribute](https://netty.io/4.1/api/io/netty/util/Attribute.html)
- [AttributeKey](https://netty.io/4.1/api/io/netty/util/AttributeKey.html)
- [ChannelPipeline](https://netty.io/4.1/api/io/netty/channel/ChannelPipeline.htm)
- [ChannelHandler](https://netty.io/4.1/api/io/netty/channel/ChannelHandler.html)
- [EventLoop](https://netty.io/4.1/api/io/netty/channel/EventLoop.html)
- [EventLoopGroup](https://netty.io/4.1/api/io/netty/channel/EventLoopGroup.html)
- [EventExecutorGroup](https://netty.io/4.1/api/io/netty/util/concurrent/EventExecutorGroup.html)
