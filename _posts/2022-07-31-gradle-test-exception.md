---
layout: entry
title: Gradle Test 실행시 Exception 포맷 지정하기
author: 김성중
author-email: ajax0615@gmail.com
description: Gradle Test Logging에서 Exception 포맷을 지정하는 방법
keywords: gradle, test, testLogging, exceptionFormat
publish: true
---

날짜, 시간과 관련된 테스트 코드를 작성하다 보면 로컬 환경에서는 잘 성공하는데, CI에서는 실패하는 현상을 종종 마주하게 된다. 대부분 Time Zone 설정이 로컬은 KST인데 CI는 UTC라서 발생하는 문제였다. 이번에도 마찬가지일거라 생각해서 UTC 기준으로 테스트 코드가 동작하도록 수정하고 다시 CI에서 돌려봤는데 또 실패했다.

![failed-test](/images/2022/07/31/failed-test.png "failed-test"){: .center-image }

왜 실패했는지 에러 메시지라도 출력해주면 좋으련만, 에러 메시지도 함께 출력하려면 아래와 같이 gradle test task에 별도의 설정을 추가해야 한다.

```groovy
test {
    testLogging.showStandardStreams = true
    testLogging.exceptionFormat = 'full'
}
```

Gradle test task에 testLogging 설정을 추가하고 나면 아래와 같이 테스트를 실패한 이유를 알려준다.

![failed-test-with-exception](/images/2022/07/31/failed-test-with-exception.png "failed-test-with-exception"){: .center-image }


### 참고
- [Gradle TestLogging](https://docs.gradle.org/current/dsl/org.gradle.api.tasks.testing.logging.TestLogging.html)
