---
layout: entry
title: Gradle Build Cache에 S3 활용하기
author-email: ajax0615@gmail.com
description: Gradle Build 속도 개선을 위한 S3 기반의 캐시 메커니즘에 대해서 알아봅니다.
keywords: gradle, build, cache, s3
publish: true
---

팀에서 Kotlin, Spring Boot 기반의 수십개의 마이크로서비스를 모노레포에 운영하고 있습니다. 멀티 레포 프로젝트에 비해 방대한 맥락과 코드가 한 곳에 모여있다보니 작성한 코드를 빌드하는 과정에서 병목이 생기기도 합니다. 그리고 CI 머신의 리소스를 여러 서비스가 공유하고 있다면 빌드 시간이 길어지는건, 다른 서비스의 빌드 시간에도 영향을 주는 구조가 됩니다. 결국 이 문제는 *사용자에게 더 빠르게 가치를 제공해야 한다*는 팀의 개발 철학과 멀어지는 결과를 야기한다.

이렇듯 빌드 속도가 제품 개발에 영향을 미치고 있다면, 간단한 설정만으로 빌드 결과물을 캐싱해놓고 재사용할 수 있는 Gradle Build Cache를 도입해보면 좋다. 이 플러그인은 Gradle Build Cache를 AWS S3에 저장해놓고 재사용함으로써 빌드 시간을 단축시킬 수 있게 도와줍니다. 적용 결과 적게는 2배, 많게는 10배 이상까지 빌드 시간이 단축되었습니다.

(CI를 Github Action에서 수행한다고 가정하고 작성하였습니다.)

### AwsS3BuildCache 적용하기

`settings.gradle.kts` 파일에 아래와 같이 Github Action에서 빌드 수행시 Remote(S3) 저장소로 빌드 결과물이 저장될 수 있도록 설정한다. Gradle Build Task 수행 단계에서 빌드 결과물을 자동으로 Local 또는 Remote로 저장할 수 있다.

```kotlin
plugins {
    id("com.github.burrunan.s3-build-cache") version "1.9.0"
}

// GITHUB ACTION 에서 수행되었으면 "true"
// https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#default-environment-variables
val isGithubAction = System.getenv("GITHUB_ACTIONS") == "true"

buildCache {
    // GITHUB ACTION 에서 수행된 경우가 아니면 Local Cache 사용
    local {
        isEnabled = isGithubAction.not()
    }

    // GITHUB ACTION 에서 수행되었으면 Remote Cache(S3) 사용
    if (isGithubAction) {
        remote<com.github.burrunan.s3cache.AwsS3BuildCache> {
            region = "your-aws-region"
            bucket = "your-aws-s3-bucket"
            prefix = "gradle/build/$YourProjectName/"
            isPush = true
            lookupDefaultAwsCredentials = true
        }
    }
}
```

Groovy를 사용중이라면 아래와 같이 적용하면 된다.

```groovy
plugins {
    id "com.github.burrunan.s3-build-cache" version "1.9.0"
}

def isGithubAction = System.getenv("GITHUB_ACTIONS") == "true"

buildCache {
    local {
        enabled = !isGithubAction
    }

    if (isGithubAction) {
        remote(com.github.burrunan.s3cache.AwsS3BuildCache) {
            region = "your-aws-region"
            bucket = "your-aws-s3-bucket"
            prefix = "gradle/build/$YourProjectName/"
            push = true
            lookupDefaultAwsCredentials = true
        }
    }
}
```

### (선택) Gradle Build Cache 옵션 활성화하기

Gradle 6.0 이상부터는 빌드시 Cache가 기본적으로 활성화되어 있는데, 하위 버전을 사용하고 있다면 빌드 커맨드에 `--build-cache` 옵션을 추가해서 `./gradlew build --build-cache` 로 실행하면 된다.

아니면 `gradle.properties` 파일에 아래 설정을 추가하면 Gradle의 캐시 사용을 명시적으로 표현할 수 있다.

```
org.gradle.caching=true
```

### (선택) 로컬 환경에서 Build Cache 활성화하기

만약 로컬 환경에서도 S3 Build Cache를 사용하고 싶다면, 관리와 비용 측면에서 Cache Push는 CI에서만 호도록 아래 설정처럼 사용하기를 권장합니다. 빈번한 캐시 업로드와 다운로드로 인해 S3 사용량 증가로 인해 트래픽과 과금에 영향을 줄 수 있습니다.

```kotlin
val isGithubAction = System.getenv("GITHUB_ACTIONS") == "true"

buildCache {
    local {
        // CI는 로컬 캐시 비활성화
        isEnabled = !isGithubAction
    }

    remote<com.github.burrunan.s3cache.AwsS3BuildCache> {
        region = "your-aws-region"
        bucket = "your-aws-s3-bucket"
        prefix = "gradle/build/$YourProjectName/"
        // 로컬은 pull-only, CI만 push 허용
        isPush = isGithubAction
        lookupDefaultAwsCredentials = true
    }
}
```

### References

- [burrunan/gradle-s3-build-cache](https://github.com/burrunan/gradle-s3-build-cache)
- [Configure the Build Cache](https://docs.gradle.org/current/userguide/build_cache.html#sec:build_cache_configure)
- [Store information in variables - GitHub Docs](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#default-environment-variables)
