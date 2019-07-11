---
layout: entry
title: Effective Java 3 - 클래스와 인터페이스
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java 3판의 4장(클래스와 인터페이스)을 정리한 글입니다.
keywords: Java, 자바
publish: true
---

# 15. 클래스와 멤버의 접근 권한을 최소화하라
어설프게 설계된 컴포넌트와 잘 설계된 컴포넌트의 가장 큰 차이는 클래스 내부 데이터와 내부 구현 정보를 외부 컴포넌트로부터 얼마나 잘 숨겼느냐다. 정보 은닉의 장점은 다음과 같다.

- 시스템 개발 속도를 높인다. 여러 컴포넌트를 병렬로 개발할 수 있기 때문이다.
- 시스템 관리 비용을 낮춘다. 각 컴포넌트를 더 빨리 파악하여 디버깅할 수 있고, 다른 컴포넌트로 교체하는 부담도 적기 때문이다.
- 정보 은닉 자체가 성능을 높여주지는 않지만, 성능 최적화에 도움을 준다. 완성된 시스템을 프로파일링해 최적화할 컴포넌트를 정한 다음(아이템 67), 다른 컴포넌트에 영향을 주지 않고 해당 컴포넌트만 최적화할 수 있기 때문이다.
- 소프트웨어 재사용성을 높인다. 외부에 거의 의존하지 않고 독자적으로 동작할 수 있는 컴포넌트라면 그 컴포넌트와 함께 개발하지 않은 낯선 환경에서도 유용하게 쓰일 가능성이 크기 때문이다.
- 큰 시스템을 제작하는 난이도를 낮춘다. 시스템 자체가 아직 완성되지 않은 상태에서도 개별 컴포넌트의 동작을 검증할 수 있기 때문이다.

정보 은닉의 기본 원칙은 **모든 클래스와 멤버의 접근성을 가능한 좁히는 것이다.** 톱레벨 클래스와 인터페이스에 부여할 수 있는 접근 수준은 package-private과 public 두 가지다. 톱레벨 클래스나 인터페이스를 public으로 선언하면 공개 API가 되며, package-private으로 선언하면 해당 패키지 안에서만 이용할 수 있다. 패키지 외부에서 쓸 이유가 없다면 package-private으로 선언하자.

한 클래스에서만 사용하는 package-private 톱레벨 클래스나 인터페이스는 이를 사용하는 클래스 안에 private static으로 중첩시켜보자. 톱레벨로 두면 같은 패키지의 모든 클래스가 접근할 수 있지만, private static으로 중첩시키면 바깥 클래스 하나에서만 접근할 수 있다. public일 필요가 없는 클래스의 접근 수준을 package-private 톱레벨 클래스로 좁혀야 한다.

멤버(필드, 메서드, 중첩 클래스, 중첩 인터페이스)에 부여할 수 있는 접근 수준은 네 가지다.

- private: 멤버를 선언한 톱레벨 클래스에서만 접근할 수 있다.
- package-private: 멤버가 소속된 패키지 안의 모든 클래스에서 접근할 수 있다.
- protected: package-private의 접근 범위를 포함하며, 이 멤버를 선언한 클래스의 하위 클래스에서도 접근할 수 있다.
- public: 모든 곳에서 접근할 수 있다.

public 클래스에서는 멤버의 접근 수준을 package-private에서 protected로 바꾸는 순간 그 멤버에 접근할 수 있는 대상 범위가 엄청나게 넓어진다. public 클래스의 protected 멤버는 공개 API이므로 영원히 지원돼야 한다. 또한 내부 동작 방식을 API 문서에 적어 사용자에게 공개해야 할 수도 있다. 따라서 protected 멤버의 수는 적을수록 ㅗㅈㅎ다.

**public 클래스의 인스턴스 필드는 되도록 public이 아니어야 한다.** 필드가 가변 객체를 참조하거나, final이 아닌 인스턴스 필드를 public으로 선언하면 그 필드에 담을 수 있는 값을 제한할 힘을 잃게 된다. 그 필드와 관련된 모든 것은 불변식을 보장할 수 없게 된다는 뜻이다. 필드가 수정될 때 (락 획득 같은) 다른 작업을 할 수 없게 되므로 **public 가변 필드를 갖는 클래스는 일반적으로 스레드 안전하지 않다.**

해당 클래스가 표현하는 추상 개념을 완성하는 데 꼭 필요한 구성요소로써의 상수라면 public static final 필드로 공개해도 좋다. 관례상 이런 상수의 이름은 대문자 알파벳으로 쓰며, 각 단어 사이에 밑줄(\_)을 넣는다. 이런 필드는 반드시 기본 타입 값이나 불변 객체를 참조해야 한다.

길이가 0이 아닌 배열은 모두 변경 가능하지 주의하자. 따라서 **클래스에서 public static final 배열 필드를 두거나 이 필드를 반환하는 접근자 메서드를 제공해서는 안 된다.**

```java
// 보안 허점
public static final Thing[] VALUES = { ... };

// 방법 1. private으로 만들고 public 불변 리스트를 추가
private static final Thing[] PRIVATE_VALUES = { ... };
public static final List<Thing> VALUES =
  Collections.unmodifiableList(Arrays.asList(PRIVATE_VALUES));

// 방법 2. private으로 만들고 복사본을 반환하는 public 메서드 추가(방어적 복사)
private static final Thing[] PRIVATE_VALUES = { ... };
public static final Thing[] values() {
  return PRIVATE_VALUES.clone();
}
```

---

# Reference
- [Effective Java 3/E](http://www.kyobobook.co.kr/product/detailViewKor.laf?ejkGb=KOR&mallGb=KOR&barcode=9788966262281&orderClick=LAG&Kc=)
