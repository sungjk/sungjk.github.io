---
layout: entry
title: ThreadPoolTaskExecutor의 waitForTasksToCompleteOnShutdown 속성 알아보기
author-email: ajax0615@gmail.com
description: 스프링 애플리케이션에서 ThreadPoolTaskExecutor 사용시 graceful shutdown을 위한 waitForTasksToCompleteOnShutdown 속성에 대해서 알아봅니다.
keywords: spring boot, graceful shutdown, ThreadPoolTaskExecutor, waitForTasksToCompleteOnShutdown, awaitTerminationSeconds
publish: true
---

어느 날, 회사에서 새로운 기능을 추가한 후 테스트를 하는 과정에서 비동기로 실행되는 작업이 제대로 동작하지 않는걸 확인했다. 

![interrupted-io-exception](/images/2023/05/22/interrupted-io-exception.png "interrupted-io-exception"){: .center-image }

에러 내용을 보면 ExecutorService를 통해 비동기적으로 2가지 작업이 실행되는데, 하나는 OkHttpClient를 이용한 작업이고 나머지 하나는 Redis를 이용한 작업이다. 에러가 발생하기 바로 전에는 ThreadPoolTaskExecutor에서 shutdown 메서드가 호출되었다. 

좀 더 구체적으로 이 기능은 Spring Batch Application을 통해서 실행되었고 Job은 Tasklets을 이용해 구현되었다. 그리고 Tasklet 실행을 위해 별도의 TaskExecutor는 지정되어 있지 않았다. 문제가 발생했던 비동기 처리는 Tasklet 안에 작성된 비즈니스 로직 중 하나였다. 대충 수도 코드(Pseudocode)로 표현하면 아래와 같다.

```kotlin
@Bean
fun testJob(testStep: Step): Job {
  return jobBuilderFactory.get("testJob")
    .preventRestart()
    .start(testStep)
    .build()
}

@Bean
@JobScope
fun testStep(commonAsyncExecutor: TaskExecutor, eventAsyncExecutor: TaskExecutor): Step {
  return stepBuilderFactory["testStep"]
    .tasklet { _, _ ->
      // 동기로 메인 로직 처리
      commonAsyncExecutor.execute {
        // 비동기로 공통 부분 처리
      }
      eventAsyncExecutor.execute {
        // 비동기로 이벤트 처리
      }
      RepeatStatus.FINISHED
    }.build()
}

@Bean
fun commonAsyncExecutor(): TaskExecutor {
  val executor = ThreadPoolTaskExecutor()
  executor.corePoolSize = 5
  executor.maxPoolSize = 10
  executor.setQueueCapacity(100)
  executor.setThreadGroupName("CommonAsyncExecutor")
  executor.setThreadFactory(ThreadFactoryBuilder().setNameFormat("common-async-%d").build())
  executor.setRejectedExecutionHandler(ThreadPoolExecutor.CallerRunsPolicy())
  executor.initialize()
  return executor
}

@Bean
fun eventAsyncExecutor(): TaskExecutor {
  val executor = ThreadPoolTaskExecutor()
  executor.corePoolSize = 5
  executor.maxPoolSize = 10
  executor.setQueueCapacity(100)
  executor.setThreadGroupName("EventAsyncExecutor")
  executor.setThreadFactory(ThreadFactoryBuilder().setNameFormat("event-async-%d").build())
  executor.setRejectedExecutionHandler(ThreadPoolExecutor.CallerRunsPolicy())
  executor.initialize()
  return executor
}
```

동료들과 현상에 대해서 살펴보다가 SpringBatchApplication이 실행될 때 메인 스레드에서 실행을 마치고 나면 TaskExecutor에서 실행되고 있는 작업들까지 기다려주지 않고 바로 종료가 되는건 아닌가 하는 의문이 생겼다. 이 가설이 맞는지 확인이 필요했는데, 그 전에, 아주 간단하게는 배치 앱에서 비동기 작업을 수행하지 않고 전부다 동기로 실행되도록 바꾸면 쉽게 해결할 수 있을것 같았다. 그런데 수도코드에는 아주 간단하게 표현되어 있는데, 실제로 이 프로젝트에서는 아키텍처 특성상 TaskExecutor 설정들 뿐만 아니라 비즈니스 로직과 비동기 처리되는 부분들도 별도의 모듈에서 재사용 가능하게끔 설계가 되어 있다보니, 똑같은 기능을 A 앱에서는 실행시 비동기로 실행하고 B 앱에서는 어떤 이유 때문에 동기로 실행하는 등 설명이 필요한 코드를 만들고 싶지 않았다. 그래서 좀 더 정확한 원인도 찾아보면서 다른 해결 방법은 없나 찾아보게 되었다.

---

### shutdown
그러던 중 에러가 발생하기 전 호출된 `shutdown` 메서드 내부를 살펴보았다. 
[ThreadPoolTaskExecutor](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/scheduling/concurrent/ThreadPoolTaskExecutor.html) 클래스는 설정값이나 Lifecycle 관리를 위해 [ExecutorConfigurationSupport](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/scheduling/concurrent/ExecutorConfigurationSupport.html) 추상 클래스를 상속 받고 있는데, 스프링 앱 종료 명령이 떨어지면 ThreadPoolTaskExecutor 클래스도 종료를 위해 ExecutorConfigurationSupport 클래스에 정의된 [shutdown](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/scheduling/concurrent/ExecutorConfigurationSupport.html#shutdown()) 메서드가 호출된다.

> 좀 더 정확하게는, ExecutorConfigurationSupport 추상 클래스가 Bean LifeCycle Callback 중 하나인 DisposableBean을 구현하고 있고 [destroy()](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/scheduling/concurrent/ExecutorConfigurationSupport.html#destroy()) 메서드가 호출되면서, destory 메서드 안에 있는 shutdown 메서드가 호출되는 구조

![shutdown](/images/2023/05/22/shutdown.png "shutdown"){: .center-image }
<center>ExecutorConfigurationSupport에 정의된 shutdown 메서드</center>

그리고 shutdown 메서드에서는 아래 흐름에 따라 남은 Task를 처리한다.

1. `waitForTasksToCompleteOnShutdown=true`이면 ExecutorService에 정의된 shutdown 메서드 실행
2. `waitForTasksToCompleteOnShutdown=false`이면 ExecutorService에 정의된 shutdownNow 메서드를 실행하고, 남은 Task들을 전부다 취소
3. `awaitTerminationIfNecessary` 메서드 실행

처음 보는 키워드(waitForTasksToCompleteOnShutdown)를 통해 실행 흐름이 달라지면서 서로 다른 동작을 하는 shutdown()과 shutdownNow() 메서드가 호출된다.

![executor-service-shutdown](/images/2023/05/22/executor-service-shutdown.png "executor-service-shutdown"){: .center-image }
<center>ExecutorService 인터페이스에 정의된 shutdown 메서드</center>

![executor-service-shutdownNow](/images/2023/05/22/executor-service-shutdownNow.png "executor-service-shutdownNow"){: .center-image }
<center>ExecutorService 인터페이스에 정의된 shutdownNow 메서드</center>

shutdown 메서드와 shutdownNow 메서드는 이름에서도 차이가 약간 보이는거 같은데, shutdownNow는 현재 실행중/대기중인 모든 작업의 처리를 중지하고 대기중이던 작업 리스트를 반환한다. 반면에 shutdown 메서드는 이전에 submit된 작업은 실행된다. 하지만, 빨간 네모 박스에 써있는 것처럼 **shutdown, shutdownNow 메서드 둘 다 현재 처리중인 작업에 대한 종료를 기다려주지 않는다.** 즉 shutdown 메서드의 경우, 현재 실행중인 작업이 있다면 그대로 실행은 되지만 처리가 완료되는걸 보장해주지 않는다. 문서(주석)에 따르면 submit된 작업의 완료를 기다리게 하려면 [awaitTermination](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html#awaitTermination-long-java.util.concurrent.TimeUnit-)을 사용하면 된다고 한다.

![executor-service-awaitTermination](/images/2023/05/22/executor-service-awaitTermination.png "executor-service-awaitTermination"){: .center-image }
<center>ExecutorService 인터페이스에 정의된 awaitTermination 메서드</center>

shutdown, shutdownNot 메서드의 주석에서 알려준 awaitTermination 메서드는 shutdown 실행시 모든 처리중인 Task들이 완료될 때까지 블락하는(기다림) 기능이다. 그리고 이 메서드는 위에서 살펴본 ExecutorConfigurationSupport.shutdown() 메서드의 마지막 동작인 awaitTerminationIfNecessary 메서드 안에서 사용되는걸 확인할 수 있다.

![awaitTerminationIfNecessary](/images/2023/05/22/awaitTerminationIfNecessary.png "awaitTerminationIfNecessary"){: .center-image }
<center>ExecutorConfigurationSupport에 정의된 awaitTerminationIfNecessary 메서드</center>

awaitTerminationIfNecessary 메서드가 안에서는 `awaitTerminationMillis` 값이 0 이상이면 ExecutorService의 awaitTermination 메서드를 실행한다. 그리고 ExecutorConfigurationSupport 클래스에 선언된 변수인 awaitTerminationMillis의 초기값은 0이라서, 별도 값 설정이 없다면 awaitTerminationIfNecessary 메서드 안에서는 아무런 동작도 하지 않게 구현되어 있다.

---

### WaitForTasksToCompleteOnShutdown

shutdown 처리에 영향을 주는 ExecutorConfigurationSupport.shutdown, ExecutorConfigurationSupport.awaitTerminationIfNecessary, ExecutorService.shutdown, ExecutorService.shutdownNow 메서드들의 동작을 살펴봤으니, 이제 이 실행 흐름을 제어하는 `waitForTasksToCompleteOnShutdown` 속성을 살펴보자.

![setWaitForTasksToCompleteOnShutdown](/images/2023/05/22/setWaitForTasksToCompleteOnShutdown.png "setWaitForTasksToCompleteOnShutdown"){: .center-image }
<center>ExecutorConfigurationSupport에 정의된 setWaitForTasksToCompleteOnShutdown 메서드</center>

주석에 설명이 아주 잘 되어 있다. `WaitForTasksToCompleteOnShutdown` 속성은 shutdown 명령을 받으면 현재 실행 중인 작업을 중단하지 않고 작업이 완료될 때까지 기다리도록 만들고 싶을 때 사용된다. 그리고 위에서 awaitTerminationIfNecessary 메서드에서도 봤듯이 `awaitTerminationMillis` 값도 함께 설정해줘야 작업이 종료되기까지 제대로 블로킹이 된다.

![setAwaitTerminationSeconds](/images/2023/05/22/setAwaitTerminationSeconds.png "setAwaitTerminationSeconds"){: .center-image }
<center>ExecutorConfigurationSupport에 정의된 setAwaitTerminationSeconds 메서드</center>

`awaitTerminationMillis` 값을 설정하기 위해서는 setAwaitTerminationSeconds 또는 setAwaitTerminationMillis 메서드를 사용하면 된다. 이 메서드의 주석에도 잘 표현이 되어 있는데, 기본적으로 Executor는 작업이 완료되기를 기다리지 않기 때문에 `waitForTasksToCompleteOnShutdown` 속성을 true로 설정하고 적당한 시간도 함께 설정해주면 된다. 

---

### 적용 결과

문서에서 가이드한 대로 ThreadPoolTaskExecutor를 생성할 때 아래와 같이 `WaitForTasksToCompleteOnShutdown`와 `awaitTerminationMillis` 값을 설정하고 SpringBatchApplication을 다시 실행해 보았다.

```kotlin
@Bean
fun commonAsyncExecutor(): TaskExecutor {
  val executor = ThreadPoolTaskExecutor()
  executor.corePoolSize = 5
  executor.maxPoolSize = 10
  executor.setQueueCapacity(100)
  executor.setThreadGroupName("CommonAsyncExecutor")
  executor.setThreadFactory(ThreadFactoryBuilder().setNameFormat("common-async-%d").build())
  executor.setRejectedExecutionHandler(ThreadPoolExecutor.CallerRunsPolicy())
  // `WaitForTasksToCompleteOnShutdown`, `awaitTerminationMillis` 속성 추가
  executor.setWaitForTasksToCompleteOnShutdown(true)
  executor.setAwaitTerminationSeconds(30)
  executor.initialize()
  return executor
}

@Bean
fun eventAsyncExecutor(): TaskExecutor {
  val executor = ThreadPoolTaskExecutor()
  executor.corePoolSize = 5
  executor.maxPoolSize = 10
  executor.setQueueCapacity(100)
  executor.setThreadGroupName("EventAsyncExecutor")
  executor.setThreadFactory(ThreadFactoryBuilder().setNameFormat("event-async-%d").build())
  executor.setRejectedExecutionHandler(ThreadPoolExecutor.CallerRunsPolicy())
  // `WaitForTasksToCompleteOnShutdown`, `awaitTerminationMillis` 속성 추가
  executor.setWaitForTasksToCompleteOnShutdown(true)
  executor.setAwaitTerminationSeconds(30)
  executor.initialize()
  return executor
}
```

![success](/images/2023/05/22/success.png "success"){: .center-image }

정말 간단하게 적용해 볼 수 있는 옵션이다. 이제 shutdown 명령이 실행되더라도 TaskExecutor에 의해 비동기적으로 실행되는 구문들도 앱이 종료되기 전에 정상적으로 실행된다. TaskExecutor를 사용하면서 아주 기초적인 내용인 것 같은데 이걸 알아가는 과정이 재미도 있었는데 매우 많은 것들을 배울 수 있었다.

---

### Gracefully Shut Down

```shell
[root@localhost ~]# kill -l  
 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL       5) SIGTRAP
 6) SIGABRT      7) SIGBUS       8) SIGFPE       9) SIGKILL     10) SIGUSR1
11) SIGSEGV     12) SIGUSR2     13) SIGPIPE     14) SIGALRM     15) SIGTERM
16) SIGSTKFLT   17) SIGCHLD     18) SIGCONT     19) SIGSTOP     20) SIGTSTP
21) SIGTTIN     22) SIGTTOU     23) SIGURG      24) SIGXCPU     25) SIGXFSZ
26) SIGVTALRM   27) SIGPROF     28) SIGWINCH    29) SIGIO       30) SIGPWR
31) SIGSYS      34) SIGRTMIN    35) SIGRTMIN+1  36) SIGRTMIN+2  37) SIGRTMIN+3
38) SIGRTMIN+4  39) SIGRTMIN+5  40) SIGRTMIN+6  41) SIGRTMIN+7  42) SIGRTMIN+8
43) SIGRTMIN+9  44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12 47) SIGRTMIN+13
48) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14 51) SIGRTMAX-13 52) SIGRTMAX-12
53) SIGRTMAX-11 54) SIGRTMAX-10 55) SIGRTMAX-9  56) SIGRTMAX-8  57) SIGRTMAX-7
58) SIGRTMAX-6  59) SIGRTMAX-5  60) SIGRTMAX-4  61) SIGRTMAX-3  62) SIGRTMAX-2
63) SIGRTMAX-1  64) SIGRTMAX
```

번외로, 스프링 애플리케이션도 하나의 프로세스인데, 프로세스를 종료시키거나 시그널을 보내기 위해 사용하는 `kill` 커맨드에는 매우 많은 signal이 있다. 로컬 환경에서 개발하다 보면 좀비 프로세스가 포트를 점유하고 있을 때가 있어서 `$ kill -9 12345` 형태의 명령어는 굉장히 많이 쓰는 것 같다. 그리고 15(SIGTERM)도 마찬가지로 프로세스를 종료하는 역할을 한다. 그런데 SIGKILL(9)과 SIGTERM(15)은 위에서 알아본 내용과 비슷한 차이가 있다. SIGKILL은 OS가 커널 수준에서 프로세스를 강제로 종료하는 것이고, SIGTERM은 애플리케이션에 shutdown 명령어를 보내는 역할을 한다. 터미널에서 jvm program을 실행하다가 Ctrl+c를 누르면 프로그램이 서서히 종료되는걸 볼 수 있다(정확하진 않지만 IntelliJ와 같은 IDE에서 실행 중인 앱을 종료할 때도 비슷할 것 같다). 이때 애플리케이션에 shutdown 명령어를 보내는 게 15번 시그널(SIGTERM)이다. SIGKILL(9)은 시스템 다운타임이나 전원을 아예 꺼버리는 것과 마찬가지라 볼 수 있다.

이처럼 프로세스를 종료할 때 SIGKILL과 SIGTERM은 **정상적으로 프로세스를 종료(gracefully shut down)** 시킴에 있어 차이가 있다. 데이터베이스는 트랜잭션의 ACID을 통해 비정상적인 데이터가 없도록 하고, 메시지 큐는 ACK 메커니즘과 replication 등을 통해 graceful downtime에 대비하고 있다고 생각한다. 이처럼 우리가 실행하고 있는 스프링 애플리케이션도 안정적으로 종료시키기 위해서는 이와 같은 graceful downtime에 대비한 전략을 취할 필요가 있고, ThreadPoolTaskExecutor 생성 시 `WaitForTasksToCompleteOnShutdown`, `AwaitTerminationSeconds` 속성은 사용자 입장에서 아주 쉽게 적용해볼 수 있는 도구라고 생각한다.
