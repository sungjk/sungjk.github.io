---
layout: entry
post-category: java
title: Effective Java(2)
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java의 3장(모든 객체의 공통 메서드)을 정리한 글입니다.
publish: true
---

Object는 객체 생성이 가능한 클래스(concrete class)이긴 하지만 기본적으로는 계승해서 사용하도록 설계된 클래스이다. Object에 정의된 비-final 메서드(equals, hashCode, toString, clone 그리고 finalize)에는 명시적인 일반 규약(general contract)이 있다. 재정의(override)하도록 설계된 메서드들이기 때문. 이 메서드들을 재정의하는 클래스는 그 일반 규약을 따라야 한다. 그렇지 않은 클래스를 HashMap이나 HashSet처럼 해당 규약에 의존하는 클래스와 함께 사용하면 문제가 생긴다.

# 규칙 8. equals를 재정의할 때는 일반 규약을 따르라
equals 메서드는 아래의 조건 가운데 하나라도 만족되면 재정의하지 않아도 된다.

- **각각의 객체가 고유하다.** 값(value) 대신 활성 개체(active entity)를 나타내는 Thread 같은 클래스가 이 조건에 부합한다.
- **클래스에 \"논리적 동일성(logical equality)\" 검사 방법이 있건 없건 상관없다.** 일례로 java.util.Random 클래스는 두 Random 객체가 같은 난수열(sequence of random numbers)을 만드는지 검사하는 equals 메서드를 재정의할 필요는 없다.
- **상위 클래스에서 재정의한 equals가 하위 클래스에서 사용하기에도 적당하다.**
- **클래스가 private 또는 package-private로 선언되었고, equals 메서드를 호출할 일이 없다.**

다음과 같은 경우에 Object.equals를 재정의하는 것이 바람직하다.

- 객체 동일성(object equality)이 아닌 논리적 동일성(logical equality)의 개념을 지원하는 클래스일 때
- 상위 클래스의 equals가 하위 클래스의 필요를 충족하지 못할 때

equals 메서드는 동치 관계(equivalence relation)를 구현하는데, 이를 정의할 때 준수해야 하는 일반 규약(general contract)은 다음과 같다.

- **반사성**(reflexive): null이 아닌 참조 x가 있을 때, x.equals(x)는 true를 반환한다. 모든 객체는 자기 자신과 같아야 한다.
- **대칭성**(symmetric): null 아닌 참조 x와 y가 있을 때, x.equals(y)는 y.equals(x)가 true일 때만 true를 반환한다. 두 객체에게 서로 같은지 물으면 같은 답이 나와야 한다.
- **추이성**(transitive): null 아닌 참조 x, y, z가 있을 때, x.equals(y)가 true이고 y.equals(z)가 true이면 x.equals(z)도 true이다. 첫번째 객체가 두 번째 객체와 같고, 두번째 객체가 세번째 객체와 같다면, 첫번째 객체와 세번째 객체도 같아야 한다.
- **일관성**(consistent): null 아닌 참조 x와 y가 있을 때, equals를 통해 비교되는 정보에 아무 변화가 없다면, x.equals(y) 호출 결과는 호출 횟수에 상관없이 항상 같아야 한다. 일단 같다고 판정된 객체들은 추후 변경되지 않는 한 계속 같아야 한다. 그리고 변경 가능 여부에 상관없이, **신뢰성이 보장되지 않는 자원(unreliable resource)들을 비교하는 equals를 구현하는 것은 삼가라.**
- **널(Null)에 대한 비 동치성(Non-nullity)**: null 아닌 참조 x에 대해서, x.equals(null)은 항상 false이다. 모든 객체는 null과 동치 관계에 있지 아니한다.

다음은 훌륭한 equals 메서드를 구현하기 위해 따라야 할 지침들이다.

1. **== 연산자를 사용하여 equals의 인자가 자기 자신임을 검사하라.**
2. **instanceof 연산자를 사용하여 인자의 자료형이 정확한지 검사하라.**
3. **equals의 인자를 정확한 자료형으로 변환하라.**
4. **\"중요\" 필드 각각이 인자로 주어진 객체의 해당 필드와 일치하는지 검사한다.**
5. **equals 메서드 구현을 끝냈다면, 대칭성, 추이성, 일관성의 세 속성이 만족되는지 검토하라.**

그리고 equals를 구현할 때는 주의해야 할 사항이 몇 가지 더 있다.

- **equals를 구현할 때는 hashCode도 재정의하라.**(규칙 9)
- **너무 머리 쓰지 마라.** 앨리어싱(aliasing)까지 고려한 동치성 검사는 바람직하지 않다.
- **equals 메서드의 인자 형을 Object에서 다른 것으로 바꾸지 마라.**

---

# 규칙 9. equals를 재정의할 때는 반드시 hashCode도 재정의하라
Object 클래스 명세에서 복사해 온 일반 규약은 다음과 같다.

- 응용프로그램 실행 중에 같은 객체의 hashCode를 여러 번 호출하는 경우, equals가 사용하는 정보들이 변경되지 않았다면, 언제나 동일한 정수(integer)가 반환되어야 한다.
- equals(Object) 메서드가 같다고 판정한 두 객체의 hashCode 값은 같아야 한다.
- equals(Object) 메서드가 다르다고 판정한 두 객체의 hashCode 값은 꼭 다를 필요는 없다.

**hashCode를 재정의하지 않으면 두번째 핵심 규약을 위반한다. 같은 객체는 같은 해시 코드 값을 가져야 한다는 규약이 위반되는 것이다.**

```java
Map<PhoneNumber, String> m = new HashMap<PhoneNumber, String>();
m.put(new PhoneNumber(707, 867, 5309), "Jenny");
```

equals 메서드만 재정의한 PhoneNumber 클래스에 m.get(new PhoneNumber(707, 867, 5309))를 호출하면 "Jenny"가 반환될 거라 기대하겠지만 정작 반환되는 것은 null이다. 두 개의 PhoneNumber 객체가 사용되었음에 유의하자. PhoneNumber 클래스에 hashCode 메서드를 재정의하지 않았으므로 이 두 객체는 서로 다른 해시 코드를 갖는다. hashCode 규약을 위반한 것이다.

좋은 해시 함수는 다른 객체에는 다른 해시 코드를 반환하는 경향이 있다. 이상적인 해시 함수는 서로 다른 객체들을 모든 가능한 해시 값에 균등하게 분배해야 한다.

해시 코드 계산 비용이 높은 변경 불가능 클래스를 만들 때는, 필요할 때마다 해시 코드를 재계산하는 대신 객체 안에 캐시해 두어야 할 수 있다.

```java
// 초기화 지연 기법을 사용해 해시 코드 캐싱
private volatile int hashCode;

@Override public int hashCode() {
    int result = hashCode;
    if (result == 0) {
        result = 17;
        result = 31 * result + areaCode;
        result = 31 * result + prefix;
        result = 31 * result + lineNumber;
        hashCode = result;
    }
    return result;
}
```

**주의할 것은, 성능을 개선하려고 객체의 중요 부분을 해시 코드 계산 과정에서 생략하면 안 된다는 것이다.**

String, Integer, Date처럼 자바 플랫폼 라이브러리에 포함된 많은 클래스들의 명세를 보면, 객체의 값에 따라 어떤 해시 코드가 반환되는지가 명확하게 기술되어 있다. 일반적으로는 이렇게 하면 해시 함수를 개선하기 어려워지므로 좋지 않다. 해시 함수의 세부적인 계산 과정은 문서에 생략하고, 문제점이 발견되거나 더 좋은 해시 함수를 찾았을 때는 다음번 릴리스에 반영하도록 하면, 어떤 클라이언트도 해시 함수가 반환하는 값에 의존하지 않을 것이다.

---

# 규칙 10. toString은 항상 재정의하라
toString의 일반 규약을 보면, toString이 반환하는 문자열은 \"사람이 읽기 쉽도록 간략하지만 유용한 정보를 제공해야 한다\"고 되어 있다. 또한 이런 구절도 있다. \"모든 하위 클래스는 이 메서드를 재정의함이 바람직하다.\"

**toString을 잘 만들어 놓으면 클래스를 좀 더 쾌적하게 사용할 수 있다.** toString 메서드는 println이나 printf 같은 함수, 문자열 연결 연산자(string concatenation operator), assert, 디버거(debugger) 등에 객체가 전달되면 자동으로 호출된다.

```java
System.out.println("Failed to connect: " + phoneNumber);
```

toString 메서드를 재정의하면 해당 객체만 혜택을 보는 것이 아니라 해당 객체에 대한 참조를 유지하는 객체들, 특히 컬렉션까지 혜택을 본다. 맵을 출력했을 때 \"{Jenny=PhoneNumber@163b91}\"처럼 출력되는 것이 좋겠는가? 아니면 \"{Jenny=(707)867-5309}\"로 출력되는 것이 좋겠는가?

**가능하다면 toString 메서드는 객체 내의 중요 정보를 전부 담아 반환해야 한다.** 예를 들어 PhoneNumber 클래스는 지역 번호, 국번, 회선 번호 등의 정보를 가져올 수 있는 접근자(accessor) 메서드를 포함해야 한다. 그렇지 않으면 프로그래머들은 toString 문자열을 파싱하려 할 것이다.

---

# 규칙 11. clone을 재정의할 때는 신중하라
Cloneable은 어떤 객체가 복제(clone)을 허용한다는 사실을 알리는 데 쓰려고 고안된 믹스인(mixin) 인터페이스다. 이 인터페이스에는 clone 메서드가 없으며, Object의 clone 메서드는 protected로 선언되어 있다는 것이다.

실질적으로 Cloneable 인터페이스를 구현하는 클래스는 제대로 동작하는 public clone 메서드를 제공해야 한다. 해당 클래스의 모든 상위 클래스가 제대로 된 public 또는 protected clone 메서드를 제공하지 않으면 일반적으로는 불가능한 일이다.

PhoneNumber 클래스의 clone을 구현할 때는 그저 Cloneable 인터페이스를 구현한다고 선언하고, Object 클래스의 protected clone 메서드를 접근할 수 있도록 하는 public 메서드를 구현해 넣기만 하면 된다.

```java
@Override public PhoneNumber clone() {
    try {
        return (PhoneNumber) super.clone();
    } catch (CloneNotSupportedException e) {
        throw new AssertionError(); // 수행될리 없음.
    }
}
```

위의 clone 메서드는 Object가 아니라 PhoneNumber를 반환한다. 제네릭의 일부로 공변 반환형(covariant return type)이 도입되었기 때문에 이렇게 하는 것이 바람직하다. 다시 말해서, 재정의 메서드(overriding method)의 반환값 자료형은 재정의되는 메서드의 반환값 자료형의 하위 클래스가 될 수 있다.

clone 메서드가 위처럼 단순히 super.clone()이 반환하는 객체를 그대로 반환하도록 구현한다면, 필드에 참조가 있을 경우 문제가 생길 수 있다. **clone 메서드는 또 다른 형태의 생성사다. 원래 객체를 손상시키는 일이 없도록 해야 하고, 복사본의 불변식(invariant)도 제대로 만족시켜야 한다. Stack의 clone 메서드가 제대로 동작하도록 하려면 스택의 내부 구조도 복사해야 한다.**

```java
@Override public Stack clone() {
    try {
        Stack result = (Stack) super.clone();
        result.elements = elements.clone();
        return result;
    } catch (CloneNotSupportedException e) {
        throw new AssertionError();
    }
}
```

clone 메서드를 구현하는 것은 복잡한 과정이다. clone 메서드를 구현해야만 하는 것이 아니라면, **객체를 복사할 대안을 제공하거나, 아예 복제 기능을 제공하지 않는 것이 낫다.** 예를 들어, 변경 불가능 클래스는 객체 복제를 허용하지 않는 것이 맞다. 복사본은 원래 객체와 논리적으로 구별이 불가능할 것이기 때문이다.

**객체 복제를 지원하는 좋은 방법은, 복사 생성자(copy constructor)나 복사 팩터리(copy factory)를 제공하는 것이다.** 복사 생성자와 복사 팩터리 메서드 접근법은 Cloneable/clone보다 좋은 점이 많다. 위험해 보이는 언어 외적(extralinguistic) 객체 생성 수단에 의존하지 않으며, 제대로 문서화되지 않고 강제하기도 어려운 규약에 충실할 것을 요구하지도 않으며, final 필드 용법과 충돌하지 않으며, 불필요한 예외를 검사하도록 요구하지도 않으며, 형 변환도 필요 없다.

#### 요약
Cloneable을 계승하는 인터페이스는 만들지 말아야 하며, 계승 목적으로 설계하는 클래스는 Cloneable을 구현하지 말아야 한다.

---

# 규칙 12. Comparable 구현을 고려하라
Comparable 인터페이스를 구현하는 클래스의 객체들은 자연적 순서(natural ordering)을 갖게 된다. Comparable을 구현한 클래스는 다양한 제네릭 알고리즘 및 Comparable 인터페이스를 이용하도록 작성된 컬렉션 구현체와도 전부 연동할 수 있다. 알파벳 순서나 값의 크기, 또는 시간적 선후관계처럼 명확한 자연적 순서를 따르는 값 클래스를 구현할 때는 Comparable 인터페이스를 구현할 것을 반드시 고려해 봐야 한다.

compareTo 메서드의 일반 규약을 종합해 보면, compareTo 메서드를 사용한 동치성 검사도 equals 규약과 같은 사항, 즉 반사성, 대칭성, 추이성을 만족해야 함을 알게 된다. 따라서 compareTo 규약을 만족하면서 클래스를 계승하여 새로운 값 컴포넌트를 추가할 방법은 없다.

compareTo 메서드를 구현하는 것은 equals 메서드를 구현하는 것과 비슷하지만 몇 가지 중요한 차이가 있다. Comparable 인터페이스가 자료형을 인자로 받는 제네릭 인터페이스이므로 compareTo 메서드의 인자 자료형은 컴파일 시간에 정적으로 결정된다는 사실이다. 따라서 인자로 받은 객체의 자료형을 검사하거나 형 변환할 필요가 없다.

# Reference
- [Effective Java 2/E](http://www.insightbook.co.kr/%EB%8F%84%EC%84%9C-%EB%AA%A9%EB%A1%9D/programming-insight/%EC%9D%B4%ED%8E%99%ED%8B%B0%EB%B8%8C-%EC%9E%90%EB%B0%94effective-java-2e)
