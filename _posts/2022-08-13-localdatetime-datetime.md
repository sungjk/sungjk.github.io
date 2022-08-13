---
layout: entry
title: Java LocalDateTime과 MySQL DATETIME
author: 김성중
author-email: ajax0615@gmail.com
description: Java에서 날짜/시간을 다룰때 MySQL의 DATETIME 타입과의 관계를 알아봅니다.
keywords: java, localdatetime, mysql, datetime
publish: true
---

Java 에서 날짜, 시간 데이터를 다루기 위해 제공하는 타입인 LocalDateTime과 MySQL에서 날짜, 시간 데이터를 다루기 위해 제공하는 타입인 DATETIME의 관계에 대해서 알아보겠습니다.

### MySQL의 날짜/시간 관련 타입

| 타입 | 데이터 | 형식 |
| :---: | :---: | :---: |
| DATE | 날짜만 포함 | YYYY-MM-DD |
| DATETIME | 날짜, 시간 모두 포함 | YYYY-MM-DD hh:mm:ss[.fraction] |
| TIME | 시간만 포함 | hh:mm:ss[.fraction] |
| TIMESTAMP | 날짜, 시간 모두 포함 | YYYY-MM-DD hh:mm:ss[.fraction] |

### [.fraction]

MySQL 5.6 이전 버전에서는 시간을 초단위까지만 표현할 수 있었는데, MySQL 5.6.4 버전부터는 시간을 초 아래 6자리(microseconds)까지 표현이 가능해졌고, 이를 fractional seconds라고 부르고 있어요.

MySQL에서 현재 시간을 출력하는 NOW라는 함수를 사용할 때에도 인자로 **fsp**(*fractional seconds part*)를 입력할 수 있어요. 3을 주면 초아래 3자리까지, 6을 주면 초아래 6자리까지 표현할 수 있어요.

![mysql_now](/images/2022/08/13/mysql_now.png "mysql_now"){: .center-image }

DATETIME 타입도 마찬가지로, 초 아래 몇자리까지 표현할 건지 fsp를 지정할 수 있어요. 3을 주면 초 아래 3자리까지, 6을 주면 초아래 6자리까지 표현할 수 있어요. 6자리까지 표현할 수 있는데, 3자리까지만 값이 주어진 경우 빈자리에는 자동으로 0을 채워줍니다.

![mysql_datetime](/images/2022/08/13/mysql_datetime.png "mysql_datetime"){: .center-image }

`DATETIME(6)` 타입을 DATETIME의 디폴트로 가져가면 동시에 들어오는 많은 요청들을 초 아래 6자리까지 구분할 수 있다보니 `DATETIME` 타입을 사용하는 것보다 얻을 수 있는 장점이 많아져요.

### java.time
MySQL에서는 fractional seconds를 통해서 초 아래의 값들을 관리하고 있는데, Java에서는 어떻게 다룰 수 있을까요?  

Java 8 버전부터 java.time 패키지가 추가되었어요. 이 패키지가 추가되기 전에는 java.util.Date, java.util.Calendar 같은 유틸 클래스들도 있었는데, [JSR 310](https://jcp.org/en/jsr/detail?id=310)(앞의 2개의 클래스를 대체하는 것을 목표로 제안된 자바의 표준 날짜/시간 관련 API)이 제안되면서 java.time 패키지가 추가되었어요.

그리고 java.time 은 시간을 nanoseconds 까지 표현할 수 있는데, 이는 milliseconds 까지만 다루던 구버전 API(java.util.Date, java.util.Calender)와 Joda-Time 보다 더 세밀한 시간값을 표현하도록 도와줘요.

![java_time](/images/2022/08/13/java_time.png "java_time"){: .center-image }

그리고 JVM 환경에서 개발을 할 때 흔히 사용하는 LocalDateTime, ZonedDateTime, Instant 같은 클래스들도 java.time 패키지 안에서 제공되는 API라서 마찬가지로 초 아래 9자리(nanoseconds)까지 다룰 수 있어요.

![java_time_package](/images/2022/08/13/java_time_package.png "java_time_package"){: .center-image }

특정 날짜, 특정 시간값으로 nanoseconds 까지 다룰 수 있는 LocalDateTime 객체를 생성하는 팩터리 메서드도 제공하고 있습니다.

![localdatetime_of](/images/2022/08/13/localdatetime_of.png "localdatetime_of"){: .center-image }

nanoseconds, microseconds 값은 getLong 함수를 이용해서 추출할 수 있습니다.

![localdatetime_getlong](/images/2022/08/13/localdatetime_getlong.png "localdatetime_getlong"){: .center-image }

그렇다면 `DATETIME(6)`로 저장된 값을 Java의 LocalDateTime으로 읽어올 때 아무 문제가 없겠죠? LocalDateTime은 6자리(microseconds)보다 더 높은 9자리(nanoseconds)까지 다룰 수 있으니까요.

그렇지 않고, `DATETIME(6)`로 저장된 값을 java.util.Date, java.util.Calendar 같은 클래스로 다룬다면 초 아래 3자리는 버림 처리됩니다. 개발할 때 주의할 필요가 있어요.

### 참고
- [https://dev.mysql.com/doc/refman/8.0/en/fractional-seconds.html](https://dev.mysql.com/doc/refman/8.0/en/fractional-seconds.html)
- [https://stackoverflow.com/a/35213339](https://stackoverflow.com/a/35213339)
- [https://docs.oracle.com/javase/8/docs/api/java/time/package-summary.html](https://docs.oracle.com/javase/8/docs/api/java/time/package-summary.html)
- [https://docs.oracle.com/javase/8/docs/api/java/time/LocalDateTime.html#of-int-java.time.Month-int-int-int-int-int-](https://docs.oracle.com/javase/8/docs/api/java/time/LocalDateTime.html#of-int-java.time.Month-int-int-int-int-int-)
