---
layout: entry
title: IntelliJ 안에서 gRPC 호출 테스트하기
author: 김성중
author-email: ajax0615@gmail.com
description: IntelliJ IDEA 안에서 gRPC 호출 테스트를 작성하는 방법을 살펴봅니다.
keywords: intellij, http, grpc, test
publish: true
---


평소 gRPC Client를 개발하다가 호출 테스트를 위해 [grpcurl](https://github.com/fullstorydev/grpcurl)을 주로 사용했다. gRPC Server가 Reflection Protocol을 지원하면 Stub 등을 만드는 프리 컴파일 과정이 필요없이 런타임에 gRPC 서비스의 정의와 메서드 목록, 메타데이터 등을 조회할 수 있다. 그래서 grpcurl을 이용하면 클라이언트는 서비스의 구체적인 stub 정보들을 알지 못하더라도 서버로부터 정보를 받아올 수 있다.

아래 proto에 정의한 Echo 서비스의 UnaryEcho RPC를 구현한 gRPC Server가 있다고 가정해보자(+ reflection).

```proto
syntax = "proto3";

package grpc.examples.echo;

message EchoRequest {
  string message = 1;
}

message EchoResponse {
  string message = 1;
}

service Echo {
  rpc UnaryEcho(EchoRequest) returns (EchoResponse) {}
  rpc ServerStreamingEcho(EchoRequest) returns (stream EchoResponse) {}
  rpc ClientStreamingEcho(stream EchoRequest) returns (EchoResponse) {}
  rpc BidirectionalStreamingEcho(stream EchoRequest) returns (stream EchoResponse) {}
}
```

이 gRPC Server에 grpcurl을 이용해서 UnaryEcho RPC를 호출하면 응답이 정상적으로 온 걸 확인할 수 있다.


```sh
# UnaryEcho RPC 호출
$ grpcurl --plaintext -d '{
    "message": "This is grpcurl test."
}' localhost:50051 grpc.examples.echo.Echo/UnaryEcho

# Response
{
  "message": "This is grpcurl test."
}
```

grpcurl은 사용하기에도 엄쳥 편리하고 Service Listing, Element Describing 등 단순 RPC 호출 뿐만 아니라 다양한 기능들을 제공한다.

```sh
# 모든 서비스 조회
$ grpcurl --plaintext localhost:50051 list
grpc.examples.echo.Echo
grpc.reflection.v1.ServerReflection
grpc.reflection.v1alpha.ServerReflection
helloworld.Greeter

# 특정 서비스의 메서드 조회
$ grpcurl --plaintext localhost:50051 list grpc.examples.echo.Echo
grpc.examples.echo.Echo.BidirectionalStreamingEcho
grpc.examples.echo.Echo.ClientStreamingEcho
grpc.examples.echo.Echo.ServerStreamingEcho
grpc.examples.echo.Echo.UnaryEcho

# 특정 서비스의 메서드 type symbol을 포함한 설명 조회
$ grpcurl --plaintext localhost:50051 describe grpc.examples.echo.Echo
grpc.examples.echo.Echo is a service:
service Echo {
  rpc BidirectionalStreamingEcho ( stream .grpc.examples.echo.EchoRequest ) returns ( stream .grpc.examples.echo.EchoResponse );
  rpc ClientStreamingEcho ( stream .grpc.examples.echo.EchoRequest ) returns ( .grpc.examples.echo.EchoResponse );
  rpc ServerStreamingEcho ( .grpc.examples.echo.EchoRequest ) returns ( stream .grpc.examples.echo.EchoResponse );
  rpc UnaryEcho ( .grpc.examples.echo.EchoRequest ) returns ( .grpc.examples.echo.EchoResponse );
}
```

그런데. 혼자 개발하면 큰 상관은 없는데 함께 일하는 환경에서 이런 스크립트들을 개인 로컬 피씨나 노트에 관리하면, 함께 일하는 사람들과 동기화가 잘 되지 않는 문제가 생길 수 있다. 물론 사용 방법을 문서나 어딘가에 잘 정리해서 관리하면 이런 문제를 어느정도 해결할 수는 있겠지만, 실제로 이런 스크립트를 사용할 애플리케이션이 있다면 애플리케이션 코드와 함께 모아두면 얼마나 좋을까?

IntellJ는 `.http` 파일에서 HTTP Test를 할 수 있는 기능을 제공해준다. 간단한 호출 테스트를 한다면 굳이 Postman 같은 툴을 사용할 필요가 없다. `http-client.env.json` 파일에 `.http` 파일에서 사용할 변수를 정의하고 호출 테스트가 필요한 `.http` 파일을 작성하면 된다.

![echo-http](/images/2023/07/01/echo-http.png "echo-http"){: .center-image }

API 호출 테스트가 필요하다면 문서를 찾아보거나 누군가에게 물어볼 필요 없이 `.http` 파일을 참조하면 된다. 관련된 정보를 한 곳에 모아두는건 응집도 측면에서 굉장한 도움이 된다고 생각한다. 그러니 프로젝트에서 API 호출 테스트가 필요하다면 `.http` 를 적극 사용해보자. 만약 API 테스팅에 Postman 같은 도구를 사용하고 있다면 Postman Collection들도 별도 문서로 정의할 필요 없이 프로젝트 코드에 포함시켜 관리하는게 유지보수 측면에도 도움이 된다.

### IntelliJ에서 gRPC 테스트하기

잠깐 HTTP Test에 대해서 이야기했는데, 최근에 IntelliJ의 `.http` 파일을 통해서 **gRPC 호출 테스트**도 가능한 점을 뒤늦게 알게 되었다. 이 기능은 [2021.3 EAP 빌드(2021년 10월)](https://blog.jetbrains.com/idea/2021/10/intellij-idea-2021-3-eap-6-enhanced-http-client-kotlin-support-for-cdi-and-more/)에 추가됐는데 무려 3년전... 

Unary 응답 뿐만 아니라 서버 사이드 Streaming 응답도 일반 HTTP 테스트하는 것처럼 JSON 형태로 확인할 수 있다. grpcurl에서 사용하던 것만큼 편하게 쓸 수 있다.

![gRPCCompletionFields](/images/2023/07/01/gRPCCompletionFields.gif "gRPCCompletionFields"){: .center-image }

![HTTPStreaming](/images/2023/07/01/HTTPStreaming.gif "HTTPStreaming"){: .center-image }

또 하나 편한 기능은, `.proto` 파일에서 gutter 아이콘을 클릭하면 gRPC 요청 테스트를 작성할 수 있는 `.http` 파일을 자동으로 생성해준다.

![HTTPClientGutter](/images/2023/07/01/HTTPClientGutter.gif "HTTPClientGutter"){: .center-image }

위에서 살펴본 UnaryEcho RPC를 구현한 gRPC Server를 구동시켜놓은 상태에서 grpcurl 호출 테스트를 한 것과 마찬가지로 IntelliJ IDEA 에서 정의한 GRPC 커맨드를 호출하니 아주 잘 동작한다.

`GRPC` 키워드를 시작으로 `Host`/`Proto Package`.`Service Naem`/`RPC Name` 형태를 입력하고 JSON 포맷으로 요청 message 포맷을 입력하면 된다.

- `Host`: localhost:50051
- `Proto Package`: grpc.examples.echo
- `Service Name`: Echo
- `RPC Name`: UnaryEcho

![echo-grpc](/images/2023/07/01/echo-grpc.png "echo-grpc"){: .center-image }

gRPC metadata도 함께 전송하고 싶다면 아래 구문처럼 `Metadata-key: Value` 형태를 포함시키면 된다.

```sh
GRPC localhost:8080
X-Myhostname: Example.org
```

### 마치며

프로젝트에 `_endpoint-test` 라는 디렉터리를 만들고, 테스트용으로 사용하기 위해 개인 노트에 적어두었던 grpcurl 스크립트를 전부다 이 디렉터리에 추가해두었다. gRPC 호출 테스트가 필요할 때 누군가를 찾거나 문서를 찾아볼 필요없이 프로젝트 안에서 모든걸 해결할 수 있기를 기대한다. 그리고 [IntelliJ > HTTP Client](https://www.jetbrains.com/help/idea/http-client-in-product-code-editor.html) 공식 문서를 보면 여기서 살펴본 HTTP와 gRPC 요청 뿐만 아니라, WebSocket, GraphQL 테스트도 지원하는데 적극 사용해봐야겠다👍👍 

---

# 참고
- [IntelliJ > HTTP Client](https://www.jetbrains.com/help/idea/http-client-in-product-code-editor.html)
- [GRPC Server Reflection Protocol](https://github.com/grpc/grpc/blob/master/doc/server-reflection.md)
- [IntelliJ IDEA 2021.3 EAP 6](https://blog.jetbrains.com/idea/2021/10/intellij-idea-2021-3-eap-6-enhanced-http-client-kotlin-support-for-cdi-and-more/)
