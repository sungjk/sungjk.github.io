---
layout: entry
title: WebFlux의 DataBuffer 다루기
author: 김성중
author-email: ajax0615@gmail.com
description: Webflux에 정의된 DataBuffer에 대해 알아봅니다.
keywords: Webflux, DataBuffer, BodyInserters, BodyExtractors
publish: true
---

회사에서 파일 관련된 서비스를 Webflux 기반으로 만들다 보니 자연스레 DataBuffer에 대해 알아보게 되었다. DataBuffer는 언뜻보기에 [Netty의 ByteBuf](https://netty.io/4.1/api/io/netty/buffer/ByteBuf.html)와 유사한 형태를 가지고 있었다. 과거에 Netty 기반으로 서비스를 만들때 직접 ByteBuf를 다뤄야 할 일이 있었다. 버퍼A를 새로운 버퍼B로 write 해야 하는데, 레퍼런스 카운팅에 대해 무지했던 나는 Memory Leak을 잡는데 어려움을 겪었었다. Netty는 메모리에서 버퍼의 할당(allocation)과 해제(deallocation)의 성능을 개선하기 위해 [레퍼런스 카운트(reference count)](https://netty.io/wiki/reference-counted-objects.html)라는 개념을 사용하고 있다. 할당이 되면 레퍼런스 카운트가 1 증가하고, 해제되면 1 감소한다. 아주 간단한 원리였는데, 이번에 스프링의 DataBuffer는 좀 더 잘 알고 가자는 취지에서 공식 문서를 파헤쳐 보았다.

# Data Buffers and Codecs

자바 NIO에서 [ByteBuffer](https://docs.oracle.com/javase/8/docs/api/java/nio/ByteBuffer.html)를 제공함에도 불구하고, 많은 라이브러리들이 자체적으로 byte buffer API를 만들어서 사용한다. 버퍼를 재사용하거나, 직접 버퍼에 접근해서 네트워크 성능을 끌어올리기 위함이다. 예를 들어, Netty에는 ByteBuf 계층 구조가 있고, Undertow는 XNIO를 사용하고, Jetty는 pooled byte buffers를 사용한다. 그리고 spring-core 모듈은 다음과 같이 다양한 byte buffer API와 함께 쓸 수 있는 추상화를 제공한다.

- **DataBufferFactory**: 데이터 버퍼의 할당(allocation)과 랩핑(wrapping)을 제공하는 데이터 버퍼의 팩토리(인터페이스)
- **DataBuffer**: 데이터 버퍼에 대한 추상화
- **DataBufferUtils**: 데이터 버퍼를 위한 유틸리티 메서드

### DataBufferFactory
[DataBufferFactory](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/io/buffer/DataBufferFactory.html)은 데이터 버퍼를 생성하기 위한 방법이라고 했다. 그리고 아래와 같은 2가지 방법으로 데이터 버퍼를 생성할 수 있다.

1. [allocateBuffer](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/io/buffer/DataBufferFactory.html#allocateBuffer-int-) 메서드를 이용하여 새로운 데이터 버퍼를 할당한다. 사이즈(capacity)를 명시하지 않으면 동적으로(on-demand) 사이즈가 변경될 수 있는데, 생성 단계에서 사이즈를 지정해주는게 더 효율적이다.
2. [wrap](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/io/buffer/DataBufferFactory.html#wrap-byte:A-) 메서드를 이용하여 이미 존재하는 byte array나 ByteBuffer를 랩핑(Wrap)할 수 있다. 이 때 해당 데이터로 DataBuffer를 구현만 하고, 할당은 하지 않는다.

참고로, WebFlux 애플리케이션은 DataBufferFactory를 직접 생성하지 않고, 클라이언트 측의 ClientHttpRequest나 ServerHttpResponse를 통해 접근한다. 팩토리의 타입은 Reactor Netty의 NettyDataBufferFactory이나 DefaultDataBufferFactory처럼 클라이언트나 서버에 의존적이다.

### DataBuffer
[DataBuffer](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/io/buffer/DataBuffer.html) 인터페이스는 ByteBuffer와 유사한 연산을 제공하지만, Netty의 ByteBuf에서 영감을 얻은 몇 가지를 추가로 제공한다.

- 독립적인 위치에서 Read, Write가 가능하다. 즉, Read, Write를 번갈아 수행하기 위해 `flip()`을 호출할 필요가 없다.
- 자바의 StringBuilder 처럼 요청시 용량(capacity)이 확장되었다.
- PooledDataBuffer를 통한 레퍼런스 카운팅(reference counting)과 풀링된 버퍼(Pooled buffers)
- 버퍼를 ByteBuffer, InputStream 또는 OutputStream으로 바라본다.
- 주어진 바이트에 대한 index 또는 마지막 index를 결정한다.

### PooledDataBuffer
Javadoc에 설명 된대로 ByteBuffer는 Direct이거나 Non-direct 일 수 있다. Direct buffers는 자바 힙(Heap) 영역 외부에 존재하기 때문에 Native I/O 연산을 위해 복사할 필요가 없다. 그래서 Direct buffers는 소켓을 통해 데이터를 송/수신하는데 유용하지만, 버퍼를 생성하고 해제(release)하는 데에는 더 많은 비용이 든다. 그래서 버퍼를 풀링(pooling buffers)하는 아이디어가 등장하게 된다.

[PooledDataBuffer](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/io/buffer/PooledDataBuffer.html)는 byte buffer 풀링에 필수적인 레퍼런스 카운팅을 돕는 DataBuffer의 확장이다. 풀링은 어떻게 동작할까? 최초에 PooledDataBuffer가 할당되면 참조 횟수는 1이다. `retain()`을 호출하면 카운트가 증가하고, `release()`를 호출하면 카운트가 감소한다. 카운트가 0보다 크면, 버퍼가 해제되지 않는다. 카운트가 0으로 감소되면 풀링된 버퍼가 해제될 수 있고, 이는 실제로 버퍼에 예약된 메모리가 메모리 풀(memory pool)로 리턴됨을 의미할 수 있다.

참고로, PooledDataBuffer를 직접 사용하는 것보다, DataBufferUtils에서 PooledDataBuffer의 인스턴스인 경우에만 DataBuffer에 release나 retain을 적용하는 것이 좋다(편리함).

### DataBufferUtils
[DataBufferUtils](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/io/buffer/DataBufferUtils.html)는 데이터 버퍼에서 작동하는 많은 유틸리티 메소드를 제공한다.

- 데이터 버퍼 스트림을 복사본 없이(zero-copy) 단일 버퍼(single buffer)로 결합한다.
- InputStream 또는 [NIO Channel](https://docs.oracle.com/javase/8/docs/api/java/nio/channels/Channel.html)을 `Flux<DataBuffer>`로 바꾸고, 그 반대의 경우 `Publisher<DataBuffer>`를 OutputStream 또는 NIO Channel로 바꾼다.
- 버퍼가 PooledDataBuffer의 인스턴스인 경우, DataBuffer를 retain하거나 release하는 메서드를 제공한다.
- 특정 바이트 수까지 바이트 스트림(stream-of-bytes)을 건너뛰거나(skip) 가져올(take) 수 있다.

### Codecs
org.springframework.core.codec 패키지에는 코덱을 위해 아래와 같은 인터페이스를 제공한다.

- `Publisher<T>`를 데이터 버퍼 스트림으로 인코딩하는 [Encoder](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/codec/Encoder.html)를 제공한다.
- `Publisher<DataBuffer>`를 더 높은 수준의 객체 스트림으로 디코딩하는 [Decoder](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/codec/Decoder.html)를 제공한다.

spring-core 모듈은 byte array, ByteBuffer, DataBuffer, Resource 및 String 인코더와 디코더 구현체를 제공한다. spring-web 모듈에는 Jackson JSON, Jackson Smile, JAXB2, Protocol Buffers 등의 인코더와 디코더 구현체가 추가되었다.

### DataBuffer 관리하기
바이트 버퍼를 추상화해서 API를 제공하는 Netty의 Bytebuf 뿐만 아니라, Spring Webflux에 있는 DataBuffer에서도 가장 중요하게 다루어야 할 부분은 버퍼가 풀링될 수 있으므로 버퍼가 해제(release)되도록 주의해야 하는 것이다.

데이터 버퍼를 관리하기 위해 위에서 설명한 코덱(Encoder, Decoder)이 내부적으로 수행하는 작업을 짧게 살펴보겠다. Decoder는 상위 레벨의 객체를 생성하기 전에 input 데이터 버퍼를 읽는다. 그래서 버퍼를 [상황에 맞게 잘 해제](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#databuffers-using) 해줘야 한다. Encoder는 다른 곳에서 읽고 해제될 데이터 버퍼를 할당한다. 그래서 실제로 Encoder가 할 일은 별로 없지만, 버퍼를 데이터로 채우는 동안에 직렬화(Serialization) 오류가 발생하면 데이터 버퍼를 해제하도록 주의해줘야 한다. Encoder를 Consume하는 쪽에서는 수신한 데이터 버퍼를 해제할 책임을 가지고 있다. Webflux 애플리케이션에서 Encoder의 출력은 서버의 HTTP 응답 또는 클라이언트의 HTTP 요청에 write를 하는 용으로 사용된다. 그래서 이러한 경우에 데이터 버퍼를 해제할 책임은 서버 응답 또는 클라이언트 요청에 있다.

---

# Handling the DataBuffer
Webflux에는 [ReactiveHttpInputMessage](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/http/ReactiveHttpInputMessage.html)의 body에서 데이터를 추출하기 위한 방법으로 [BodyExtractors](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/reactive/function/BodyExtractors.html) 추상 클래스를 제공하고, [ReactiveHttpOutputMessage](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/http/ReactiveHttpOutputMessage.html)의 body에 데이터를 주입하기 위해 [BodyInserters](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/reactive/function/BodyInserters.html) 추상 클래스를 제공한다. 그래서 이 추상 클래스들이 제공하는 정적 팩터리 메서드를 이용하여 간단하게 데이터를 핸들링 할 수 있다. BodyInserters와 BodyExtractors에서 제공하는 모든 메서드를 살펴보지는 않겠지만, 데이터 버퍼를 다루기 위해 사용되는 몇가지 예제를 살펴보겠다.

### BodyExtractors.toDataBuffers
BodyExtractors에서 제공하는 정적 팩터리 메서드 중 [toDataBuffers](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/reactive/function/BodyExtractors.html#toDataBuffers--) 메서드는 raw DataBuffers를 추출하는 Extractor를 리턴한다. Webflux에서 서버 사이드 HTTP request는 [ServerRequest](https://docs.spring.io/spring-framework/docs/5.0.0.M3/javadoc-api/org/springframework/web/reactive/function/ServerRequest.html) 인터페이스로 표현되는데, 이 인터페이스의 body 메서드에 Extractor를 인자로 전달해서 데이터 버퍼를 추출하면 된다.

```kotlin
fun extractDataBuffers(request: ServerRequest): Flux<DataBuffer> {
  return request.body(BodyExtractors.toDataBuffers())
}
```

### BodyExtractors.toMultipartData
Webflux에서 multipart data 형태의 서버 사이드 HTTP request는 [toMultipartData](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/reactive/function/BodyExtractors.html#toMultipartData--) 메서드를 이용하여 핸들링할 수 있다. toMultipartData 메서드는 multipart data 를 읽어서 MultiValueMap\<String, Part\> 형태로 바꿔주는 Extractor를 리턴한다. 여기서 [Part](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/http/codec/multipart/Part.html)는 HTTP multipart/form-data 요청에서 part를 표현하기 위해 springframework에 정의된 인터페이스이다. 참고로, 각 파트가 [FormFieldPart](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/http/codec/multipart/FormFieldPart.html) 또는 [FilePart](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/http/codec/multipart/FilePart.html) 인 경우에는 브라우저의 폼 요청일 수 있다. 브라우저로부터 온 폼 요청에서 FilePart는 다음과 같이 추출할 수 있다.

```kotlin
val partKey = "file"

fun extractDataBuffers(request: ServerRequest): Flux<DataBuffer> {
  return request.body(BodyExtractors.toMultipartData())
    .flatMap { map ->
      val multipartMap = map.toSingleValueMap()
      val isNotEmpty = multipartMap.isNotEmpty() && multipartMap.containsKey(partKey)
      val isFilePart = multipartMap[partKey] is FilePart
      when (isNotEmpty && isFilePart) {
        false -> Mono.error(IllegalStateException())
        true -> Mono.just(multipartMap[partKey] as FilePart)
      }
    }
    .toFlux()
    .flatMap { it.content() }
}
```

### DefaultDataBufferFactory.wrap
위에서 살펴본 DataBufferFactory 인터페이스의 구현체이다. 다시 한 번 얘기하자면, DataBufferFactory는 데이터 버퍼의 할당과 랩핑을 제공하는 팩토리이고, allocateBuffer, wrap, join 메서드를 제공한다고 했다. 이미 메모리에 존재하는 ByteBuffer나 byte array는 [wrap](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/io/buffer/DataBufferFactory.html#wrap-byte:A-) 메서드를 이용해서 DataBuffer로 만들 수 있다. 여기서 특이한 점은 주어진 ByteBuffer나 byte array를 랩핑할 때, 할당(allocateBuffer)과 달리 새로 메모리를 사용하지 않는다는 점이다.

```kotlin
// multiplart/form-data 형태의 데이터 만들어보기
fun createDataBuffer(filename: String): DataBuffer {
  val data = "--12345\r\n" +
    "Content-Disposition: form-data; name=\"file\"; filename=\"$filename\"\r\n" +
    "--12345--\rn\n"
  return DefaultDataBufferFactory().wrap(data.toByteArray())
}
```

### BodyInserters.fromDataBuffers
[fromDataBuffers](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/reactive/function/BodyInserters.html#fromDataBuffers-T-) 메서드는 인자로 주어진 Publisher\<DataBuffer\>를 HTTP Request body에 쓰기(write)위한 Inserter를 리턴한다. Publisher가 무엇인지에 대한 설명은 다음 [링크](https://sungjk.github.io/2020/06/06/reactive-streams.html)를 참조하면 좋겠다.

```kotlin
val dataBuffers: Flux<DataBuffer> = Flux.just(createDataBuffer("foo.jpg"))

webClient.post()
  .uri(....)
  .body(BodyInserters.fromDataBuffers(dataBuffers))
  ....
```

---

### References
- [Data Buffers and Codecs](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#databuffers)
- [multipart/form-data](https://tools.ietf.org/html/rfc2388#:~:text=Definition%20of%20multipart%2Fform%2Ddata,-The%20media%2Dtype&text=In%20forms%2C%20there%20are%20a,contains%20a%20series%20of%20parts.)
