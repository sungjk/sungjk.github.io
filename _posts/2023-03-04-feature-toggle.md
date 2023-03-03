---
layout: entry
title: Feature Toggle 150% 활용하기
author: 김성중
author-email: ajax0615@gmail.com
description: 안전하고 효율적인 배포를 위해 피쳐 플래그를 다양한 용도로 활용한 이야기
keywords: Feature Toggle, Feature Flag
publish: true
---

지난 포스팅에서 [우리 팀에 맞는 Git Branch 전략 선택하기](https://sungjk.github.io/2023/02/20/branch-strategy.html)라는 주제로 Github Flow를 적용한 이야기를 기록했었다. 글로 표현하려니.. 모든걸 다 담아내기엔 어려움이 적지 않았다. 실제로는 더 많은 고민과 이야기가 있었는데. 이번엔 효율적이고 안정적인 배포를 위해 고민했던 것 중 하나인 Feature Toggle(Feature Flag)에 대한 이야기를 적어보려고 한다.(Feature Toggle, Feature Flag 둘 다 같은 용어라서 섞어 사용할게요)

### 이거 배포에 포함됐는데 괜찮나요?

- FEATURE-100 티켓이 이번 릴리즈에 포함됐는데 괜찮나요?
- FEATURE-123 티켓은 1주일 뒤에 배포되어야 합니다.
- A 서버는 B 서버의 API를 사용하고 있어서 B 서버가 배포된 이후에 A 서버가 배포되어야 합니다.

내가 작업한 코드를 Mainline에 추가한 다음 개발 환경에서 테스트를 하고 있었다. 그런데 다른 동료들이 작업한 코드를 릴리즈에 포함시킨다고 하면 Mainline에 있는 모든 코드들이 포함될텐데, 내 코드는 아직 확인중에 있고 사용자에게 노출되면 안된다. 이런 상황에서 어떡하면 좋을까? 내가 테스트를 완료할 때까지 동료들이 기다려주거나 내 코드를 Mainline에서 Revert하면 된다.

![git-revert](/images/2023/03/04/git-revert.png "git-revert"){: .center-image }

<center><a href="https://webdevstudios.com/2017/07/20/fixing-things-git-reset-vs-revert/" target="\_blank">Fixing Things: Git Reset vs. Revert</a></center>

여러 동료와 같은 프로젝트를 함께 작업하다 보면 의도치 않게 작업한 코드가 사용자에게 노출될 때가 있다. Git 브랜치 전략에 Git Flow를 사용하든, Github Flow를 사용하든. 어떤 브랜치 전략을 사용하든 발생할 수 있는 문제다. 테스트를 완료할 때까지 동료들이 기다리거나 코드를 Revert 하지 않고 해결 할 수 있는 방법은 없을까?



## Feature Toggles(aka Feature Flags)

이런 문제 상황을 해결하기 위한 방법 중 하나가 Feature Toggle 이다. Feature Toggle은 코드를 수정하지 않고 시스템의 동작을 바꿀 수 있는 기술이다. 사용자에게 새로운 기능을 빠르고 안전하게 제공하는데 도움을 주는 패턴이기도 하다. 그리고 이 Feature Toggle은 Feature Flags, Feature Bits 또는 Feature Flippers 라고도 불리운다. 업계에서는 주로 Feature Flag 라는 용어를 많이 사용하고 있는듯하다. 원래도 개념에 대해서는 알고는 있었는데 Martin Fowler가 작성한 [Feature Toggles (aka Feature Flags)](https://sungjk.github.io/2022/10/15/feature-toggles.html) 아티클을 공부하고 나서 그동안 겉핥기 식으로 알고 있었다는걸 깨달았고, 이 패턴에 대한 생각이 확장됨과 동시에 프로젝트에 적용해 볼 수 있는 아이디어가 많이 떠올랐다.

![feature-flagging](/images/2023/03/04/feature-flagging.png "feature-flagging"){: .center-image }

<center><a href="https://www.atlassian.com/continuous-delivery/principles/feature-flags/" target="\_blank">Continuous delivery principles - Feature flags</a></center>

아래 코드는 좀 억지 같기도 한데. 잘 몰랐을 때에는 이렇게도 사용했던거 같다. Boolean 값을 하드코딩하거나 Spring Boot YAML 파일에 useNewCoolFeature에 대한 값(true or false)을 설정해두고 로직의 큰 변화 없이 간단한 코드 수정만으로 새로운 피쳐를 적용할 수 있다.

```kotlin
// YAML에 true 설정 후 배포하면 새로운 피쳐 적용
val useNewCoolFeature = false // true
if (useNewCoolFeature) {
    return applyNewCoolFeature()
} else {
    return applyOldFeature()
}
```

아니면 이렇게도 많이 사용했다. [Spring Boot의 profiles 속성](https://docs.spring.io/spring-boot/docs/1.2.0.M1/reference/html/boot-features-profiles.html)을 활용해서 Production 환경에서만 기존 피쳐를 활성화하는 방식. 새로운 피쳐가 사용자에게 노출되지 않으니 이것도 안전하게 코드를 관리할 수 있는 방법이다.

```kotlin
@Configuration
@Profile("production")
class Feature {
    ...
}

@Configuration
@Profile("!production")
class NewCoolFeature() {
    ...
}
```

이렇게만 해도 위에서 이야기한 문제를 어느정도 해결할 수 있다. 그런데 좀 불편해 보이는 점이 있다. NewCoolFeature를 Production 환경에 적용하려면 YAML 파일의 설정값이나 Profile을 교체해서 릴리즈를 생성하고 코드를 배포해야 한다. 배포에 적지 않은 시간이 소요된다면 이 문제도 해결할 수 없을지 진지하게 고민이 필요해 보인다. 이 문제에 대한 해답도 Martin Fowler가 작성한 [Feature Toggles (aka Feature Flags)](https://sungjk.github.io/2022/10/15/feature-toggles.html) 아티클에 나와 있으니 Feature Flag에 관심있는 사람이라면 Martin Fowler가 작성한 아티클을 무조건! 읽어보길 추천한다.

## Feature Toggle 설계하기

Martin Fowler의 Feature Toggles 아티클을 살펴보면 Feature Flag의 탄생부터 코드 배포 없이 동적으로 적용하는 방법과 Feature Toggle을 효율적으로 관리하는 방법까지 잘 소개가 되어 있는데, 스터디를 마친 후 회사 프로젝트에 적용해보기 위해 나름대로 Feature Toggle 설계 원칙을 정리해보았다.

1. **토글이 켜져 있을 때에는 새로운 피쳐를 활성화하고 꺼져 있을 때에는 기존/레거시 피쳐를 활성화한다.**
2. **토글 포인트(Toggle Point)를 토글 라우터(Toggle Router)에서 분리한다.**
3. **토글 설정(Toggle Configuration)은 특정 저장소에 의존하지 않는다.**
4. **토글 설정(Toggle Configuration)을 코드 배포 없이 동적으로 설정할 수 있다.**
5. **사용하지 않는 토글은 바로 제거한다.**

1번은 Feature Flag의 기본 동작이라서 당연한 이야기이고, 2번부터 5번까지는 Feature Toggle을 효율적으로 관리하기 위한 방법들이다. 각 원칙에 대해 알아보기 전에, 토글 포인트, 토글 라우터 등의 용어들은 모두 위에 소개한 [아티클](https://sungjk.github.io/2022/10/15/feature-toggles.html)에서 등장하는 것들인데 하나씩 어떤 의미인지 살펴보자.

**토글 포인트(Toggle Point)**란, 새로운 피쳐와 기존 피쳐를 구분하는 코드 지점을 의미한다. 예를 들어, if-else 구문으로 새로운 피쳐를 구분해두었다면 if-else 구문이 토글 포인트가 된다.

```kotlin
val useNewCoolFeature = false
// 토글 포인트(Toggle Point)
if (useNewCoolFeature) { 
    return applyNewCoolFeature()
} else {
    return applyOldFeature()
}
```

**토글 라우터(Toggle Router)**란, 새로운 피쳐와 기존 피쳐를 구분하기 위한 방법 또는 라우팅을 결정하는 객체나 수단을 의미한다. 예를 들어, isFeatureEnabled 함수를 통해 새로운 피쳐를 구분하고 있다면 이 함수가 토글 라우터가 된다.

```kotlin
// 토글 라우터(Toggle Router)
fun isFeatureEnabled(feature: String): Boolean {
    return featureConfig.contains(feature)
}
```

**토글 설정(Toggle Configuration)**이란, 단순하게는 Feature Flag의 ON/OFF 속성을 담은 설정값이라고 볼 수 있다. Feature가 현재 어떤 상태인지를 나타내는 기준이 되고, 위에서 살펴본 토글 라우터(Toggle Router)는 토글 설정(Toggle Configuration)을 바탕으로 새로운 피쳐인지 아닌지 결정을 내릴 수 있다.

Feature Flag를 사용한다면 심플하게 1번만 있어도 충분할거 같은데 2번부터 5번까지는 왜 필요할까? 피쳐 플래그를 사용하다보면 코드 이곳 저곳에 토글 포인트가 생기고 한 눈 팔고 있는 순간 코드 베이스 전체에 확산될 수 있다. if-else, if-else, if-else… 피쳐 플래그를 사용하는 코드가 얼마 없다면 상관없는데, 사용중인 곳이 많거나 토글의 수명이 엄청 길다면 이런 코드들은 [깨진 유리창](https://en.wikipedia.org/wiki/Broken_windows_theory)의 원인이 될 수 있다. 뿐만 아니라, 위에서 잠깐 살펴봤던 것처럼 새로운 피쳐 적용을 위해 새로운 코드를 배포해야 하는 불편함도 없애기 위해 설정을 배포 없이 동적으로 바꿀 수 있어야 한다. 개발이 완료되고 나서 피쳐 관리를 위한 비용을 최소화해야 한다.

---

## Feature Toggle 구현하기
처음엔 [Proxy Pattern](https://refactoring.guru/design-patterns/proxy)을 기반으로 피쳐 토글링을 위한 인터페이스와 프록시들을 직접 구현했다(대충 아래 코드인데 비슷한 내용은 [reflectoring.io](https://reflectoring.io/spring-boot-feature-flags/) 코드 참고). 이 방식도 괜찮긴 했는데 익숙해지고 나면 피쳐 토글링을 위해 매번 토글 라우터(아래 코드에서는 FeatureToggledService 클래스)를 새로 만들어줘야 하는 귀찮음이 있었다. 사용자 입장에서 더 명시적이고 편하게 쓸 수 있는 방법은 없을까?

```kotlin
class FeatureToggleFactoryBean<T> : FactoryBean<T> {
    ...
    override fun getObject(): T {
        val invocationHandler = InvocationHandler { proxy, method, args ->
            if (isEnabled) {
                method.invoke(newFeature, args)
            } else {
                method.invoke(oldFeature, args)
            }
        }
        val proxy = Proxy.newProxyInstance(targetClass, invocationHandler)
        return proxy as T
    }
    ...
}

// Toggle Router
@Component
class FeatureToggledService(featureToggleConfig: FeatureToggleConfig) : FeatureToggleFactoryBean<FeatureProcessor>(
    FeatureProcessor::class.java,
    featureToggleConfig::isEnabled,
    NewFeatureProcessor(),
    OldFeatureProcessor(),
)
```

이런 고민을 하고 있을 당시에 개인적으로 Resilience4j 오픈소스를 둘러보고 있었다. Resilience4j에서는 CircuitBreaker, Bulkhead 등 fault tolerance 기능들을 제공하는데, Spring Boot 기반의 애플리케이션에서 손쉽게 사용할 수 있도록 Starter를 제공한다. 이 의존성을 추가하기만 하면 AOP,Aspect가 자동으로 추가되고(Auto-Configured) 사용자 입장에서는 Annotation 기반으로 CircuitBreaker, Bulkhead 등의 다양한 기능을 쉽게 사용할 수 있다.

```java
// Codes
@CircuitBreaker(name = BACKEND, fallbackMethod = "fallback")
@RateLimiter(name = BACKEND)
@Bulkhead(name = BACKEND, fallbackMethod = "fallback")
@Retry(name = BACKEND)
@TimeLimiter(name = BACKEND)
public Mono<String> method(String param1) {
    return Mono.error(new NumberFormatException());
}

private Mono<String> fallback(String param1, CallNotPermittedException e) {
    return Mono.just("Handled the exception when the CircuitBreaker is open");
}

private Mono<String> fallback(String param1, BulkheadFullException e) {
    return Mono.just("Handled the exception when the Bulkhead is full");
}

private Mono<String> fallback(String param1, NumberFormatException e) {
    return Mono.just("Handled the NumberFormatException");
}

private Mono<String> fallback(String param1, Exception e) {
    return Mono.just("Handled any other exception");
}

// Properties
resilience4j.circuitbreaker:
    configs:
        default:
            slidingWindowSize: 100
            permittedNumberOfCallsInHalfOpenState: 10
            waitDurationInOpenState: 10000
            failureRateThreshold: 60
            eventConsumerBufferSize: 10
            registerHealthIndicator: true
        someShared:
            slidingWindowSize: 50
            permittedNumberOfCallsInHalfOpenState: 10
    instances:
        backendA:
            baseConfig: default
            waitDurationInOpenState: 5000
        backendB:
            baseConfig: someShared
```

그런데.. 어떻게 동작하는지 모르면 나도 모르게 흑마법이 일어난다고 느껴져서 개인적으로 Annotation 사용을 꺼려했다. 동작 방식도 숨겨져 있고 사용 가이드도 잘 알고 있어야 한다는 점도. 스프링을 처음 접했을때 Annotation이 너무 많아서 이게 뭐지 했던 기억이.. 아무튼 그전까지는 단점만 생각하고 있었던거 같은데, 막상 사용해보면 엄-청 편하다. 의존성 추가하고 필요한 곳에 Annotation 달아주고 property 추가 좀 해주고. 인터페이스라는건 사용자가 구체적인 동작을 몰라도 잘 마련된 가이드에 따라 쉽게 쓸 수 있도록 디자인하는게 중요한데, Resilience4j의 CircuitBreaker Annotation이 그러했다. 사용자 입장에서는 이게 내부적으로 어떻게 구현되어있는지 알고 있을 필요가 없고 단지 내가 원하는 방식대로 옵션과 Fallback에 대한 설정만 해주면 된다.

이런 편리함을 겪어보니 충분히 Annotation 기반으로 토글 라우터를 구현해도 좋겠다는 생각이 들었고, 위에서 정의한 4가지 설계 원칙에 따라서 Resilience4j의 CircuitBreaker 코어 모듈을 참고해서 구현해보았다.

- [CircuitBreaker Annotation](https://github.com/resilience4j/resilience4j/blob/master/resilience4j-annotations/src/main/java/io/github/resilience4j/circuitbreaker/annotation/CircuitBreaker.java)
- [CircuitBreaker FallbackExecutor](https://github.com/resilience4j/resilience4j/blob/master/resilience4j-spring/src/main/java/io/github/resilience4j/fallback/FallbackExecutor.java)
- [CircuitBreaker Aspect](https://github.com/resilience4j/resilience4j/blob/master/resilience4j-spring/src/main/java/io/github/resilience4j/circuitbreaker/configure/CircuitBreakerAspect.java)

### 1. 토글이 켜져 있을 때에는 새로운 피쳐를 활성화하고 꺼져 있을 때에는 기존/레거시 피쳐를 활성화한다.

isEnabled 메서드의 동작에 따라 토글이 켜져 있으면 신규 피쳐 실행을 위해 `proceedingJoinPoint.proceed()` 을 호출하고, 토글이 꺼져 있으면 기존 피쳐 실행을 위해 `fallbackExecutor.execute()` 을 호출한다.

```kotlin
@Aspect
@Component
class FeatureToggleAspect(private val featureToggleProvider: FeatureToggleProvider) {
	...
    @Around(value = "matchAnnotatedClassOrMethod(featureToggleAnnotation)", argNames = "proceedingJoinPoint, featureToggleAnnotation")
    fun featureToggleAroundAdvice(proceedingJoinPoint: ProceedingJoinPoint, featureToggleAnnotation: FeatureToggle): Any {
        ...
        // 피쳐 플래그가 켜져 있는 경우, 새로운 동작 실행
        if (featureToggleProvider.isEnabled(key)) {
            return proceedingJoinPoint.proceed()
        }
        // 피쳐 플래그가 꺼져 있는 경우, 기존 피쳐 실행
        return fallbackExecutor.execute(proceedingJoinPoint, key, fallbackMethod)
    }
}
```

### 2. 토글 포인트(Toggle Point)를 토글 라우터(Toggle Router)에서 분리한다.

위에서 토글 포인트(Toggle Point)는 New/Old를 구분하는 코드 지점을 의미하고, 토글 라우터(Toggle Router)는 New/Old 를 구분하기 위한 객체나 수단이라고 했다. if-else 구문에서 피쳐가 New 인지 Old 인지 결정되는 것처럼, 결정 로직은 토글 포인트의 일부다. 이런 토글 포인트와 New/Old를 구분하기 위한 수단(객체 또는 함수), 즉 토글 라우터가 한 곳에 모여 있으면 나중에 결정 로직을 변경하려고 할 때 토글 포인트가 포함된 코드베이스 전체를 변경해야 하는 현상이 발생할 수 있다. 그래서 토글 포인트 지점을 제공하는 FeatureToggleAspect에서는 토글 라우터 역할을 하는 FeatureToggleProvider 인터페이스를 주입 받고, 토글 결정 지점과 실제로 New인지 Old인지 구분하는 `isEnabled()`를 서로 다른 환경에서 관리할 수 있도록 분리했다. 토글 포인트 입장에서는 어떤 로직을 통해 토글링이 된건지 관심사가 아니기 때문에.

그리고 토글 포인트를 품고 있는 Aspect에서는 토글링에 따른 신규 로직과 기존 로직을 실행하기 위해 미리 정의한 Annotation을 참조한다. 새로운 피쳐 타겟 함수에 적용할 `@FeatureToggle`과 기존 피쳐(Fallback) 함수에 적용할 `@FeatureToggleFallback` 을 추가했다. 

```kotlin
// 신규 로직에 적용할 Annotation
@Target(AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class FeatureToggle(
    val key: String,
    val fallbackMethod: String = "",
)

// 기존 로직에 적용할 Annotation
@Target(AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class FeatureToggleFallback

// FeatureToggle, FeatureToggleFallback Annotation을 처리할 Aspect
@Aspect
@Component
class FeatureToggleAspect(private val featureToggleProvider: FeatureToggleProvider) {
    private val fallbackExecutor = FeatureToggleFallbackExecutor()

    @Pointcut(value = "@within(featureToggle) || @annotation(featureToggle)", argNames = "featureToggle")
    fun matchAnnotatedClassOrMethod(featureToggle: FeatureToggle) {
    }

    @Around(value = "matchAnnotatedClassOrMethod(featureToggleAnnotation)", argNames = "proceedingJoinPoint, featureToggleAnnotation")
    fun featureToggleAroundAdvice(proceedingJoinPoint: ProceedingJoinPoint, featureToggleAnnotation: FeatureToggle): Any {
        ...
        // Toggle Point
        if (featureToggleProvider.isEnabled(key)) {
            return proceedingJoinPoint.proceed()
        }
        return fallbackExecutor.execute(proceedingJoinPoint, key, fallbackMethod)
    }
}
```

### 3. 토글 설정(Toggle Configuration)은 특정 저장소에 의존하지 않는다.

토글 설정값(Toggle Configuration)은 `FeatureToggleProvider` 인터페이스를 통해 주입 받도록 만들어서, 데이터베이스 뿐만 아니라 Zookeeper, Cental Dogma 등 Key, Value 저장소를 통해서도 관리할 수 있도록 만들었다. 처음에 개발할 당시에는 팀에서 Cental Dogma를 사용하지 않고 있어서 데이터베이스에 Key, Value 형태로 피쳐를 관리했는데, 지금은 Cental Dogma 셋업이 완료되었다. 조만간 피쳐 관리에 Central Dogma를 도입할 예정인데, 토글 설정을 옮겨 저장하고 데이터를 패치하는 코드만 수정하면 되어서 비교적 쉽게 적용할 수 있을듯 하다.

```kotlin
interface FeatureToggleProvider {
    fun isEnabled(key: String): Boolean
}
```

### 4. 토글 설정(Toggle Configuration)을 코드 배포 없이 동적으로 설정할 수 있다.

토글 설정값(Toggle Configuration)을 주입하는 `FeatureToggleProvider` 구현체에서 `@Scheduled` 애너테이션을 사용해서 설정값을 주기적으로 폴링하는 방법으로 간단하게 구현했다. 지금은 데이터베이스에 저장된 토글 설정값을 주기적으로 폴링하고 있어서 서버 배포 없이 설정값만 바꿔주면 동적으로 동기화되고 있다.

```kotlin
class FeatureToggleProviderImpl(private val repository: ToggleRepository) : FeatureToggleProvider {
    // <ToggleKey, ToggleConfiguration>
    private val toggleConfigMap: AtomicReference<Map<String, ToggleConfiguration>> = AtomicReference(emptyMap())

    @Scheduled(fixedDelay = 5000)
    fun syncToggleConfiguration() {
        // Sync toggle configuration to toggleConfigMap
        val newToggleConfigMap = repository.findAll()
            .associateBy({ it.key }, { this.parseConfig(it) })
        toggleConfigMap.set(newToggleConfigMap)
    }
    ...
}
```

### 5. 사용하지 않는 토글은 바로 제거한다.
지난 포스팅에서 Feature Branch에도 수명이 있는 것과 비슷하게 Feature Toggle에도 수명이 있다. 아래에서 토글의 다양한 종류에 대해서 간략하게 살펴볼텐데, 그 전에 Toggle은 얼마나 동적인지(Dynamism)와 수명이 얼마나 긴지(Longevity)에 따라서 토글의 유형을 분류할 수 있다. 이건 토글이 어떤 용도로 사용되는지에 따라 정해지는데, 피쳐의 ON/OFF 용도로 토글을 사용하다가 토글을 OFF 상태로 변경할 일이 없어지면 해당 토글은 더이상 관리할 필요가 없어진다. 사용하지 않는 토글을 계속해서 유지하는건 관리 측면에서 좋을게 하나도 없기 때문에 우리는 사용하지 않는 토글을 바로 제거하기로 약속했다. 반면에, 아래에서 살펴보겠지만 권한 토글(Permissioning Toggle)의 경우에는 1년 넘게 아니면 평생 유지되는 것도 존재할 수 있다.

![long-lived-transient-toggles](/images/2023/03/04/long-lived-transient-toggles.png "long-lived-transient-toggles"){: .center-image }

---

## FeatureToggle 사용하기
`NEW_COOL_FEATURE` 피쳐가 활성화된 경우에 실행할 함수에 `@FeatureToggle` Annotation을 추가하고, 비활성화된 경우에 실행할 함수에는 `@FeatureToggleFallback` Annotation을 추가한다. 런타임에 호출자 입장에서는 newCoolFeature 함수를 호출하는데 위에서 정의한 토글 포인트(FeatureToggleAspect)를 통해 피쳐가 활성화 되어 있는지 판단한 후 newCoolFeature 함수를 실행하거나 currentFeature 함수를 실행하게 된다.

```kotlin
class MyFeatureProcessor {
    // `NEW_COOL_FEATURE=ON`인 경우 실행
    @FeatureToggle(key = "NEW_COOL_FEATURE", fallbackMethod = "oldFeature")
    fun newCoolFeature(): String {
        return "NewCoolFeature"
    }

    // `NEW_COOL_FEATURE=OFF`인 경우 실행
    @FeatureToggleFallback
    fun oldFeature(): String {
        return "OldFeature"
    }
}
```

---

## FeatureToggle 160% 활용하기
다시 Martin Fowler가 작성한 [Feature Toggles (aka Feature Flags)](https://sungjk.github.io/2022/10/15/feature-toggles.html) 아티클을 언급해야겠다. 우리는 위에서 신규 동작을 실행할건지 구버전 피쳐를 실행할건지 판단하는 기본적인 기능만 살펴보았다. 하나의 배포 단위(릴리즈 버전) 내에서 취할 수 있는 서로 다른 CodePath(FeatureToggle or FeatureToggleFallback)를 제공하고, 런타임에 토글 설정에 따라 하나를 선택할 수 있었다. 마틴옹은 이 기본적인 동작을 활용해서 다양한 방식으로 사용될 수 있음을 알려주었다. Canary 배포, 실험(+ A/B) 뿐만 아니라 Circuit Breaker와 같은 피쳐 관리용으로도 활용할 수 있다. 

처음엔 key: FeatureName, value: Boolean(true or false) 형태로만 관리했는데, 단순히 ON/OFF 기능만 사용하는걸 넘어서 안전하고 효율적인 배포를 위해 토글 설정을 좀 더 고민해보았다. key 값은 그대로 FeatureName으로 유지하고, value에는 다양한 설정을 담을 수 있도록 JSON 타입의 데이터를 저장했다. 그래서 지금은 아래와 같이 피쳐별로 JSON 포맷의 토글 설정들을 관리하고 있다. 아티클에 나온 모든 기능들이 필요한건 아니라서 Permissioning, Canary 기능만 취해서 사용하고 있다.

```
{
    "enabled": false,     // 전체 적용 여부
    "debug": false,       // 전체 적용 디버깅 로그 출력
    "permission": {
        "enabled": false, // 권한 있는 유저에게 적용 여부
        "debug": false,   // 권한 있는 유저에게 적용 디버깅 로그 출력
        "user_ids": []    // 권한 있는 유저 목록
    },
    "canary": {
        "enabled": false, // 카나리 그룹에 적용 여부
        "debug": false,   // 카나리 그룹에 적용 디버깅 로그 출력
        "percentage": 0   // 카나리 그룹 퍼센트
    }
}

```

### 권한 토글(Permissioning Toggles)
Permission Toggle은 특정 사용자에게만 기능을 오픈하고 싶을때 사용한다. 나 혹은 팀원이 먼저 기능 테스트를 하고 싶거나, 어떤 피쳐를 특정 유저에게 계속해서 유지하고 싶을때 주로 사용하고 있다. 샴페인 마시기처럼([개밥 먹기는 샴페인 마시기에서 유래했다고](https://www.mindmeister.com/blog/drinking-our-own-champagne/)).

위 JSON 포맷에서 `permission` 필드의 `enabled` 필드를 활성화하고(true), `user_ids` 리스트에 사용자 ID를 입력하면 특정 유저에게만 해당 피쳐가 적용된다. 그리고`user_ids` 목록에 포함되지 않은 사용자라면 기존 피쳐가 적용된다. 예를 들어, 새로운 기능 배포 전에 나에게만 해당 피쳐를 적용하고 싶을때 내 UserId를 입력하거나, 팀원 전체에 적용하고 싶을때 팀원 모두의 UserId를 입력하면 된다.

![permissioning-toggles](/images/2023/03/04/permissioning-toggles.png "permissioning-toggles"){: .center-image }

### 카나리 토글(Canary Toggle)
인프라에서 전체 배포를 하기 전에 소수의 사용자에게만 변경 사항을 적용하기 위해 롤아웃을 조절하는걸 카나리 릴리즈라고 한다. 인프라에서의 카나리 릴리즈와 마찬가지로 피쳐 토글에도 카나리를 적용할 수 있다. 카나리 릴리즈는 기본적으로 요청 단위로 비율을 정하는데, 피쳐 토글을 사용하는 단일 노드 입장에서는 전체 노드에 들어오는 요청을 파악할 수 없기 때문에 요청을 한 사용자나 특정 구분자를 이용해서 비율을 정할 수 있다. 예를 들어, 요청 Header에 사용자ID가 포함되어 있다면 그 값을 modulo 연산을 한 결과를 가지고 canary 그룹에 속하는지 판단할 수 있다.

사용자 그룹에 카나리 토글을 적용하려면 위 JSON 포맷에서 `canary` 필드의 `enabled` 필드를 활성화하고(true), `percentage` 필드에 카나리 그룹 비율을 추가해주면 된다. 예를 들어, 카나리 그룹 비율(percentage)이 20으로 설정되어 있고 사용자 ID를 modulo 연산한 결과에 따라서 그룹에 속하는지 판단할 수 있다.

- 사용자ID가 123456인 경우, 123456%100=56>percentage → false
- 사용자ID가 654321인 경우, 654321%100=21>percentage → true

### 활용 사례
FeatureToggleProvider 인터페이스는 토글 설정값(Toggle Configuration)을 패치하고 피쳐가 활성화되어 있는지 확인하는 토글 라우터 역할을 한다. 그런데 토글 설정에 단순히 ON/OFF만 있지 않고 다른 속성들도 포함되어 있다보니 처리하는 순서가 중요했다. `toggleConfig.enabled`는 사용자 구분 없이 전체 적용을 의미하는데, 권한 토글이나 카나리 토글을 검사하기 전에 먼저 확인한다면 권한 토글이나 카나리 토글이 아무 의미가 없어진다. 그리고 Permissioning Toggle이 활성화된 경우에는 Canary와 상관없이 항상 적용되어야 하기 때문에 카나리 토글 검사보다 권한 토글을 먼저 확인한다. 그리고 마지막에 전체 적용 여부를 확인한다.

```kotlin
class FeatureToggleProviderImpl(private val repository: ToggleRepository) : FeatureToggleProvider {
    // <ToggleKey, ToggleConfiguration>
    private val toggleConfigMap: AtomicReference<Map<String, ToggleConfiguration>> = AtomicReference(emptyMap())

    ...

    override fun isEnabled(key: String, userId: Long?): Boolean {
        return runCatching {
            val toggleConfig = this.toggleConfigMap[key]
            // Permissioning Toggle; 권한이 있는 사용자에게 Feature 적용
            if (toggleConfig.isPermittedUser(key, userId)) {
                return true
            }
            // Canary Toggle; Canary 그룹에 포함된 사용자에게 Feature 적용
            if (toggleConfig.isCanaryGroupedUser(key, userId)) {
                return true
            }
            if (toggleConfig.debug) {
                logger.info("[FeatureToggleProvider] Feature Toggle - key($key), userId($userId), enabled(${toggleConfig.enabled})")
            }
            // 전체 사용자에게 Feature 적용
            return toggleConfig.enabled
        }.getOrDefault(false)
    }

    ...
}
```

---

## 마무리
피쳐 토글의 기본 ON/OFF 동작도 잘 활용했지만 Permissioning Toggle, Canary Toggle은 더 값지게 사용하고 있다. 커피를 주문하는데 임직원에게는 사이즈업 비용을 받지 않는다고 하면 사이즈업 금액 계산 모델에 Permissioning Toggle을 적용해두고 Free 값을 리턴하도록 설정할 수도 있고, 새로운 프로모션 오픈을 하기 전에 사내 구성원에게만 노출하고 싶을때에도 버튼 노출 여부에 Permissioning Toggle을 적용해두고 `user_ids` 필드를 이용해서 동적으로 관리할 수도 있다. 그리고 인프라에 Canary Release 구축 여부와 상관없이 서비스 자체적으로 카나리 그룹 설정이 가능해졌다. 최근에 프로젝트 아키텍처를 전환하는 작업도 진행했는데, 동일한 기능이 리팩터링 후에도 잘 동작하는지 권한 토글을 이용해서 먼저 확인해보고, 문제가 없다면 카나리 토글을 통해서 사용자에게도 점진적으로 적용할 수 있었다.

매번 코드를 작성하고 제거할 때마다 Feature Toggle을 사용하지는 않는다. 반면에 정말 인지하기 어려운 사이드이펙트가 발생할 것 같은 부분이나, 마이크로서비스간 배포 독립성(B 서버를 배포한 다음에 A 서버 배포) 또는 특정 시점에 피쳐 오픈이 필요한 경우에는 항상 사용하고 있다. 

![jeremy](/images/2023/03/04/0.png "jeremy"){: .center-image }

벌써 1년 전이구나. 페이스북에서 우연히 맘시터 개발블로그에 올라온 피쳐플래그 기반의 배포 환경을 보고 엄청 궁금했었는데 이제는 당연한 환경이 되어버렸다. 피쳐 플래그를 사용하지 않던 시절에도 핵심 모듈을 리팩터링하거나 기능을 추가하기 전에 테스트를 꼼꼼히 해서 부담감을 많이 덜려고 노력했었는데, 이제는 안전 장치가 하나 더 생겨서 마음이 훨씬 더 편안해졌다. 게다가 지난 글에 적어놨듯이 매일 배포하는 환경에 피쳐 플래그가 70% 이상은 일조하고 있다고 생각한다. 기본 동작에 더해서 다양한 용도로 잘 활용하고 있다고 생각해서 150%라는 표현을 사용했는데, 앞으로 운영용(Ops Toggle)이나 실험용(Experiment Toggle) 등 활용할 수 있는 곳을 더 늘려서 200%까지 더 끌어 올려보고 싶다.

---

### 참고
- [Feature Toggles (aka Feature Flags)](https://martinfowler.com/articles/feature-toggles.html)
