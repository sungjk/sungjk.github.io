---
layout: entry
title: M1 맥북에서 gRPC osx-aarch_64 바이너리 받아오기
author: 김성중
author-email: ajax0615@gmail.com
description: M1 맥북에서 gRPC osx-aarch_64 바이너리 받아오는 방법
keywords: m1, grpc, osx-aarch_64, amd, arm
publish: true
---

Apple M1 맥북을 지급받고 개발 환경을 셋팅했는데, grpc를 사용중인 프로젝트에서 gradle build 스크립트가 실패했다.

![aarch-64](/images/2022/01/22/proto-aarch-64.png "aarch-64"){: .center-image }

이유는 별다른 옵션을 주지 않으면 grpc 패키지를 받아올때 환경에 따라서 x86_64 또는 aarch_64 바이너리를 받아오는데, 아직 grpc 패키지에 ARM64용 바이너리(aarch-64)가 릴리즈되지 않았기 때문이다. 그래서 M1 환경의 장비에서도 ARM64용 바이너리가 아닌 AMD64용 바이너리를 받아올 수 있도록 별도의 설정이 필요하다. 프로젝트가 M1 맥북과 Intel 맥북에서 모두 동작하려면 M1 환경의 맥북에 이를 구분할 수 있는 값(osx-x86_64)을 추가하는걸 권장한다.

### gradle.properties 설정값 추가하기
Gradle global 속성값을 저장하는 곳인 `~/.gradle/gradle.properties` 안에 `osx-x86_64` 값을 추가한다. 이건 M1 장비에만 추가하면 되는 설정값이다. Intel 맥북에는 따로 설정하지 않아도 `osx-x86_64` 바이너리를 받아온다.

```
protoc_platform=osx-x86_64
```

### build.gradle 수정하기
M1 환경인 경우에도 AMD64용 grpc 바이너리를 받아올 수 있도록 protobuf task에 `protoc_platform` 속성값이 존재하는지 검사하는 조건문을 추가한다. 

```
protobuf {
    protoc {
        if (project.hasProperty('protoc_platform')) {
            artifact = "com.google.protobuf:protoc:${protobufVersion}:${protoc_platform}"
        } else {
            artifact = "com.google.protobuf:protoc:${protobufVersion}"
        }
    }
    plugins {
        grpc {
            if (project.hasProperty('protoc_platform')) {
                artifact = "io.grpc:protoc-gen-grpc-java:${grpcVersion}:${protoc_platform}"
            } else {
                artifact = "io.grpc:protoc-gen-grpc-java:${grpcVersion}"
            }
        }
    }
}
```

---

### 참고
- [grpc-java#7690](https://github.com/grpc/grpc-java/issues/7690)
