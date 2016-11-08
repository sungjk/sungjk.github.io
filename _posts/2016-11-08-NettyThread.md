---
layout: entry
title: How Netty uses thread pools?
author: 김성중
author-email: ajax0615@gmail.com
description: Asynchronous event-driven 네트워크 애플리케이션 프레임워크인 Netty에서 Thread pool을 어떻게 사용하고 있는지 살펴봅니다.
publish: true
---

> Netty is a NIO client server framework which enables quick and easy development of network applications such as protocol servers and clients.

네티(Netty) 프로젝트의 공식 홈페이지에서는 Netty를 위와 같이 소개하고 있다. 네티는 비동기 이벤트 네트워크 애플리케이션 프레임워크다. 유지보수를 고려한 고성능 프로토콜 서버와 클라이언트를 안정적이고 빠르게 개발할 수 있다. 이를 반증이라도 하듯 고속 그리고 대용량 네트워크 데이터를 처리하는 트위터와 네이버 라인도 네티를 사용하고 있다. 동접자 수와 퍼포먼스 모두를 만족하는 네트워크 프로그램을 만들어야 한다면 네티를 강력 추천한다.

![Netty-components](/images/2016/11/08/netty-components.png "netty-components"){: .center-image }

## event-driven
일반적인 이벤트-드리븐 애플리케이션은 두가지 방식으로 동작한다. 첫 번째는 **이벤트 리스너와 이벤트 처리 스레드에 기반한 방법** 이다. 대부분의 UI 처리 프레임워크가 사용하는 방법으로써 이벤트를 처리하는 로직을 가진 이벤트 메서드를 대상 객체의 이벤트 리스너에 등록하고 객체에 이벤트가 발생했을 때 이벤트 처리 스레드에서 등록된 메서드를 수행한다. 이때 이벤트 메서드를 수행하는 스레드는 대부분 단일 스레드로 구현된다. 두 번째는 이벤트 큐에 이벤트를 등록하고 **이벤트 루프가 이벤트 큐에 접근하여 처리하는 방법** 이다. 첫 번째 방법에 비해 프레임워크의 구현이 복잡하지만 프레임워크의 사용자 입장에서는 더 간단하게 사용할 수 있다.

이벤트 루프가 다중 스레드일 때 이벤트 큐는 여러 개의 스레드에서 공유되며 가장 먼저 이벤트 큐에 접근한 스레드가 첫 번째 이벤트를 가져와서 이벤트를 수행한다. 이떄 이벤트 큐에 입력된 이벤트를 처리하고자 이벤트 루프 스레드를 사용한다.

![event_loop](/images/2016/11/08/event_loop.jpg "event_loop"){: .center-image }

위 그림은 객체(Event Emitters)에서 발생한 이벤트와 이벤트 루프의 연관 관계를 보여준다. 객체에서 발생한 이벤트는 이벤트 큐에 입력되고 이벤트 루프는 큐에 입력된 이벤트가 있을 때 해당 이벤트를 꺼내서 이벤트를 실행한다. 이것이 이벤트 루프의 기본 개념이다. 이 개념에 더해서 이벤트 루프가 지원하는 스레드 종류에 따라서 단일 스레드 이벤트 루프와 다중 스레드 이벤트 루프로 나뉘고, 이벤트 루프가 처리한 이벤트의 결과를 돌려주는 방식에 따라서 콜백 패턴과 퓨처 패턴으로 나뉜다. 네티는 이 두 가지 패턴을 모두 지원한다.

---

그렇다면 Netty는 스레드를 어떤식으로 사용하고 있을까? 네티는 단일 스레드 이벤트 루프와 다중 스레드 이벤트 루프를 모두 사용할 수 있다. 다중 스레드 이벤트 루프는 이벤트의 발생 순서와 실행 순서가 일치하지 않지만, 네티에서는 이벤트 루프의 종류에 상관없이 이벤트 발생 순서에 따른 실행 순서를 보장한다. 어떻게 처리 순서가 뒤바뀌는 현상을 처리할 수 있을까? 네티가 다중 스레드 이벤트 루프를 사용함에도 불구하고 이벤트 발생 순서와 실행 순서를 일치시킬 수 있는 이유는 아래의 세 가지 특징에 기반한다.

- 네티의 이벤트는 채널에서 발생한다.
- 이벤트 루프 객체는 이벤트 큐를 가지고 있다.
- 네티의 채널은 하나의 이벤트 루프에 등록된다.

![event-loop-thread](/images/2016/11/08/event-loop-thread.png "event-loop-thread"){: .center-image }

네티의 각 채널은 위와 같이 개별 이벤트 루프 스레드에 등록된다. 그러므로 채널에서 발생한 이벤트는 항상 동일한 이벤트 루프 스레드에서 처리하여 이벤트 발생 순서와 처리 순서가 일치된다. 기존의 이벤트 루프 스레드와의 차이점은 **이벤트 루프 스레드의 이벤트 큐 공유 여부** 이다. 즉 이벤트의 수행 순서가 일치하지 않는 근본적인 이유는 이벤트 루프들이 이벤트 큐를 공유하기 때문에 발생하는데, 네티는 이벤트 큐를 이벤트 루프 스레드의 내부에 둠으로써 수행 순서 불일치의 원인을 제거했다.

위 그림에서는 하나의 이벤트 루프 스레드에 하나의 채널만 등록되어 있지만, 실제로는 하나의 이벤트 루프 스레드에 여러 채널을 등록할 수 있다. 이와 같읕 구조는 다중 채널에 대한 효율적인 스레드 구조를 만들어낸다. 여러 채널이 이벤트 루프에 등록되었을 때에도 이벤트 처리는 항상 발생 순서와 일치한다. 즉, 처리를 위한 이벤트 루프 스레드가 하나이므로 이벤트 처리 순서는 이벤트 발생 순서와 같다.

---

Netty는 NIO를 바탕으로 NioServerSocketChannelFactory를 구현하였다. 여기에는 2가지 타입의 스레드가 있는데, 하나는 보스 스레드 *boss thread* 이고, 나머지 하나는 워커 스레드 *worker thread* 이다. 보스 스레드는 모든 리슨 소켓(listen socket)들을 관리하고, 워커 스레드는 연결된 소켓(accepted socket)을 관리한다고 보면 된다.

## Boss threads
ChannelHandlers는 포트 별로 접속을 허용해주는 보스 스레드를 가지고 있다. 예를 들어, 80번과 443번 서버 포트를 연다면, 보스 스레드를 2개 가지고 있는 셈이다. 일단 커넥션이 성공적으로 이루어지면 보스 스레드는 승인된(accepted) 채널을 하나의 워커 스레드로 전달한다.

## Worker threads
워커 스레드는 개발자가 명시한 갯수만큼 Worker Thread Pool을 유지한다(디폴트 개수는 코어수*2). 워커 스레드는 Non-blocking 모드에서 채널에 읽기와 쓰기 작업을 Non-blocking으로 처리할 수 있다.

보스 스레드와 워커 스레드는 코드 상에서 다음과 같이 활용할 수 있다. 개발자는 다음과 같은 템플릿을 유지하고, WebsocketHandler 핸들러에 요청을 처리할 로직을 작성하면 된다. 코드에 대한 상세 설명은 생략하도록 하겠다.


```
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

#### 참고
[How Netty uses thread pools?](http://stackoverflow.com/questions/5474372/how-netty-uses-thread-pools)
