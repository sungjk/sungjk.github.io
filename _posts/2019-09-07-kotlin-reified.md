---
layout: entry
post-category: kotlin
title: 코틀린에서 reified는 왜 쓸까?
author: 김성중
author-email: ajax0615@gmail.com
description: 런타임에 Type erasure 없이 제네릭 타입을 보존시켜주는 reified 키워드에 대한 알아보았습니다.
keywords: Kotlin, 코틀린, reified, Type erasure
publish: true
---

# 왜 쓸까?

```java
fun <T> genericFunc(c: Class<T>)
```

일반적인 제네릭 함수 body에서 타입 T는 컴파일 타임에는 존재하지만 런타임에는 [Type erasure](https://docs.oracle.com/javase/tutorial/java/generics/erasure.html) 때문에 접근할 수 없다. 따라서 일반적인 클래스에 작성된 함수 body에서 제네릭 타입에 접근하고 싶다면 genericFunc 처럼 명시적으로 타입을 파라미터로 전달해주어야 한다.

하지만 **reified type parameter** 와 함께 inline 함수를 만들면 추가적으로 `Class<T>`를 파라미터로 넘겨줄 필요 없이 런타임에 타입 `T`에 접근할 수 있다. 따라서 `myVar is T` 처럼 변수가 `T`의 인스턴스인지 쉽게 검사할 수 있다.

```java
inline fun <reified T> genericFunc()
```

# 동작 방식
`reified`는 `inline` function과 조합해서만 사용할 수 있다. 이런 함수는 컴파일러가 함수의 바이트코드를 함수가 사용되는 모든 곳에 복사하도록 만든다. reified type과 함께 인라인 함수가 호출되면 컴파일러는 type argument로 사용된 실제 타입을 알고 만들어진 바이트코드를 직접 클래스에 대응되도록 바꿔준다. 그래서 `myVar is T`는 런타임과 바이트코드에서 `myVar is String` 이 될 수 있다.

# 예시
실제로 [kotlin jackson module](https://github.com/FasterXML/jackson-module-kotlin)을 다루는 프로젝트에서 쉽게 찾아볼 수 있다.

### 1. reified type 없이 접근하기

```java
// 컴파일 되지 않음
fun <T> String.toKotlinObject(): T {
  val mapper = jacksonObjectMapper()
  return mapper.readValue(this, T::class.java)
}
```

`readValue` 메서드는 `JsonObject`를 파싱하는데 사용하기 위해 타입 하나를 받는다. 타입 파라미터 `T`의 Class를 얻으려고 하면 컴파일 에러가 발생한다. **`"Cannot use 'T' as reified type parameter. Use a class instead."`**

### 2. 명시적으로 Class 파라미터를 전달하기

```java
fun <T : Any> String.toKotlinObject(c: KClass<T>): T {
  val mapper = jacksonObjectMapper()
  return mapper.readValue(this, c.java)
}
```

메서드 파라미터로 전달된 `T`의 `Class`는 `readValue`의 argument로 사용된다. 일반적인 제네릭 자바 코드와 같은 형태이고 올바르게 동작한다. 그리고 다음과 같이 사용할 수 있다.

```
data class Foo(val name: String)

val json = """{"name":"example"}"""
json.toKotlinObject(Foo::class)
```

### 3. `reified` 사용하기
`reified` 타입 파라미터 `T`와 함께 `inline` 함수를 사용하면 같은 기능을 다른 방식으로 구현할 수 있다.

```java
inline fun <reified T : Any> String.toKotlinObject(): T {
  val mapper = jacksonObjectMapper()
  return mapper.readValue(this, T::class.java)
}
```

위 코드에서는 추가적으로 `T`의 `Class`를 받을 필요도 없고, `T`는 일반적인 클래스로 사용될 수 있다. 그리고 다음과 같이 사용할 수 있다.

```java
json.toKotlinObject<Foo>()
```

# Note
`reified` 타입 파라미터로 작성된 인라인 함수는 **자바 코드에서 호출 할 수 없다.**
