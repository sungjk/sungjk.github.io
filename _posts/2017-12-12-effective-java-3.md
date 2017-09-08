---
layout: entry
title: Effective Java(3)
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java의 4장(클래스와 인터페이스)을 정리한 글입니다.
publish: false
---

# 규칙 13. 클래스와 멤버의 접근 권한은 최소화하라
잘 설계된 모듈과 그렇지 못한 모듈을 구별 짓는 가장 중요한 속성 하나는 모듈 내부의 데이터를 비롯한 구현 세부사항을 다른 모듈에 잘 감추느냐의 여부다. 이 개념은 *정보 은닉(information hiding)* 또는 *캡슐화(encapsulation)* 라는 용어로 알려져 있다.

정보 은닉은 여러 가지 이유로 중요한데, 그 대부분은 정보 은닉이 시스템을 구성하는 모듈 사이의 *의존성을 낮춰서*(decouple), 각자 개별적으로 개발하고, 시험하고, 최적화하고, 이해하고, 변경할 수 있도록 한다는 사실에 기초한다. 그렇게 되면 시스템 개발 속도가 올라가는데, 각각의 모듈을 병렬적으로 개발할 수 있기 때문이다.

정보 은닉의 원칙은 단순하다. **각 클래스와 멤버는 가능한 한 접근 불가능하도록 만들라는 것.**

최상위 레벨 클래스나 인터페이스는 가능한 package-private로 선언해야 한다. package-private로 선언하면 API의 일부가 아니라 구현 세부사항에 속하게 되므로, 다음번 릴리스에 클라이언트 코드를 깨뜨릴 걱정 없이 자유로이 변경하거나 삭제하거나, 대체할 수 있게 된다. public으로 선언하게 되면 호환성을 보장하기 위해 해당 개체를 계속 지원해야 한다.

필드나 메서드, 중첩 클래스(nested class), 중첩 인터페이스(nested interface) 같은 멤버의 접근 권한은 네 개 중 하나로 설정할 수 있다. 접근 권한이 증가하는 순서로 나열했다.

- **private** - 이렇게 선언된 멤버는 선언된 최상위 레벨 클래스 내부에서만 접근 가능하다.
- **package-private** - 이렇게 선언된 멤버는 같은 패키지 내의 아무 클래스나 사용할 수 있다.
- **protected** - 이렇게 선언된 멤버는 선언된 클래스 및 그 하위 클래스만 사용할 수 있다.
- **public** - 이렇게 선언된 멤버는 어디서도 사용이 가능하다.

**객체 필드(instance field)는 절대로 public으로 선언하면 안 된다**(규칙 14). 비-final 필드나 변경 가능 객체에 대한 final 참조 필드를 public으로 선언하면, 필드에 저장될 값을 제한할 수 없게 된다. 따라서 그 필드에 관계된 불변식(invariant)을 강제할 수 없다. 필드가 변경될 때 특정한 동작이 실행되도록 할 수 없으므로, **변경 가능 public 필드를 가진 클래스는 다중 스레드에 안전하지 않다.** 변경 불가능 객체를 참조하는 final 필드라 해도 public으로 선언하면 클래스의 내부 데이터 표현 형태를 유연하게 바꿀 수 없게 된다.

길이가 0이 아닌 배열은 언제나 변경 가능하므로, **public static final 배열 필드를 두거나, 배열 필드를 반환하는 접근자(accessor)를 정의하면 안 된다.**

```java
// 보안 문제를 초래할 수 있는 코드
public static final Thing[] VALUES = { ... };
```

이 문제를 고치는 방법은 두 가지다. public으로 선언되었던 배열은 private로 바꾸고, 변경 불가능한 public 리스트(list)를 하나 만드는 것이다.

```java
private static final Thing[] PRIVATE_VALUES = { ... };
public static final List<Thing> VALUES =
    Collections.unmodifiableList(Array.asList(PRIVATE_VALUES));
```

두번째 방법은 배열은 private로 선언하고, 해당 배열을 복사해서 반환하는 public 메서드를 하나 추가하는 것이다.

```java
private static final Thing[] PRIVATE_VALUES = { ... };
public static final Thing[] values() {
    return PRIVATE_VALUES.clone();
}
```

#### 요약
- 접근 권한은 가능한 낮추라.
- 최소한의 public API를 설계한 다음, 다른 모든 클래스, 인터페이스, 멤버는 API에서 제외하라.
- public static final 필드를 제외한 어떤 필드도 public 필드로 선언하지 마라.
- public static final 필드가 참조하는 객체는 변경 불가능 객체로 만들라.

---

# 규칙 14. public 클래스 안에는 public 필드를 두지 말고 접근자 메서드를 사용하라

```java
// 이런 저급한 클래스는 절대로 public으로 선언하지 말 것
class Point {
    public double x;
    public double y;
}
```

이런 클래스는 데이터 필드를 직접 조작할 수 있어서 *캡슐화* 의 이점을 누릴 수가 없다(규칙 13). API를 변경하지 않고서는 내부 표현을 변경할 수 없고, 불변식(invariant)도 강제할 수 없고, 필드를 사용하는 순간에 어떤 동작이 실행되도록 만들 수도 없다.

```java
// 접근자 메서드와 수정자를 이용한 데이터 캡슐화
class Point {
    private double x;
    private double y;

    public Point(double x, double y) {
        this.x = x;
        this.y = y;
    }

    public double getX() { return x; }
    public double getY() { return y; }

    public void setX(double x) { this.x = x; }
    public void setY(double y) { this.y = y; }
}
```

**선언된 패키지 밖에서도 사용 가능한 클래스에는 접근자 메서드를 제공하라.** 하지만 package-private나 private로 선언된 중첩 클래스의 필드는 그 변경 가능 여부와는 상관없이 외부로 공개하는 것이 바람직할 때도 있다.

---

# 규칙 15. 변경 가능성을 최소화하라
변경 불가능(immutable) 클래스는 그 객체를 수정할 수 없는 클래스다. 객체 내부의 정보는 객체가 생성될 때 주어진 것이며, 객체가 살아 있는 동안 그대로 보존된다. 변경 불가능 클래스를 만들 때는 아래의 다섯 규칙을 따르면 된다.

1. **객체 상태를 변경하는 메서드(수정자 mutator 메서드 등)를 제공하지 않는다.**
2. **계승할 수 없도록 한다.**
3. **모든 필드를 final로 선언한다.**
4. **모든 필드를 private로 선언한다.** 클라이언트가 필드가 참조하는 변경 가능 객체를 직접 수정하는 일을 막을 수 있다.
5. **변경 가능 컴포넌트에 대한 독점적 접근권을 보장한다.** 클래스에 포함된 변경 가능 객체에 대한 참조를 클라이언트는 획득할 수 없어야 한다.

대부분의 변경 불가능 클래스가 따르는 패턴은 *함수형* 접근법(functional approach)으로도 알려져 있는데, 피연산자를 변경하는 대신, 연산을 적용한 결과를 새롭게 만들어 반환하기 떄문이다. *절차적*(procedural) 또는 *명령형*(imperative) 접근법은 피연산자에 일정한 절차를 적용하여 그 상태를 바꾼다.

**변경 불가능 객체는 단순하다.** 생성될 때 부여된 한 가지 상태만 갖는다. 따라서 생성자가 불변식(invariant)을 확실히 따른다면, 해당 객체는 불변식을 절대로 어기지 않게 된다.

**또한 변경 불가능 객체는 스레드에 안전(thread-safe)할 수 밖에 없다. 어떤 동기화도 필요 없으며,** 여러 스레드가 동시에 사용해도 상태가 훼손될 일이 없다. 스레드 안전성을 보장하는 가장 쉬운 방법이다. 따라서 **변경 불가능한 객체는 자유롭게 공유할 수 있다.**

변경 불가능 객체를 자유롭게 공유할 수 있다는 것은 *방어적 복사본*(규칙 39)을 만들 필요가 없단 뜻이기도 하다. 따라서 변경 불가능 객체에 clone 메서드나 복사 생성자(규칙 11)는 만들 필요도 없고, 만들어서도 안 된다.

**변경 불가능 객체는 그 내부도 공유할 수 있다.**

**변경 불가능 객체는 다른 객체의 구성요소로도 훌륭하다.** 구성요소들의 상태가 변경되지 않는 객체는 설사 복잡하다 해도 훨씬 쉽게 불변식을 준수할 수 있다. 그 특별한 사례로, 맵(map)과 집합(set)을 들 수 있다. 변경 불가능 객체는 맵의 키나 집합의 원소로 활용하기 좋다. 한번 집어넣고 나면 그 값이 변경되어 맵이나 집합의 불변식이 깨질 걱정은 하지 않아도 된다.

**변경 불가능 객체의 유일한 단점은 값마다 별도의 객체를 만들어야 한다는 점이다.** 따라서 객체 생성 비용이 높을 가능성이 있다. 이러한 경우 몇 가지 대안적 설계법이 있는데, 변경 불가능성을 보장하기 위해서는 하위 클래스 정의가 불가능하도록 해야 하는데, 보통은 클래스를 final로 선언하면 되지만, 그보다 더 유연한 방법이 있다. 모든 생성자를 private나 package-private로 선언하고 public 생성자 대신 public *정적 팩터리* 를 제공하는 것이다.

```java
// 생성자 대신 정적 팩터리 메서드를 제공하는 변경 불가능 클래스
public class Complex {
    private final double re;
    private final double im;

    private Complex(double re, double im) {
        this.re = re;
        this.im = im;
    }

    public static Complex valueOf(double re, double im) {
        return new Complex(re, im);
    }
}
```

#### 요약
- **변경 가능한 클래스로 만들 타당한 이유가 없다면, 반드시 변경 불가능 클래스로 만들어야 한다.**
- **변경 불가능한 클래스로 만들 수 없다면, 변경 가능성을 최대한 제한하라.**
- **특별한 이유가 없다면 모든 필드는 final로 선언하라.**
- 특별한 이유가 없다면, 생성자 이외의 public 초기화 메서드나 정적 팩터리 메서드를 제공하지 마라.

---

# 규칙 16. 계승하는 대신 구성하라
계승은 상위 클래스와 하위 클래스 구현을 같은 프로그래머가 통제하는 단일 패키지 안에서 사용하면 안전하다.

**메서드 호출과 달리, 계승은 캡슐화(encapsulation) 원칙을 위반한다.** 하위 클래스가 정상 동작하기 위해서는 상위 클래스의 구현에 의존할 수 밖에 없다.

```java
// 계승을 잘못 사용한 사례!
public class InstrumentedHashSet<E> extends HashSet<E> {
    // 요소를 삽입하려 한 횟수
    private int addCount = 0;

    public InstrumentedHashSet() {
    }

    public InstrumentedHashSet(int initCap, float loadFactor) {
        super(initCap, loadFactor);
    }

    @Override public boolean add(E e) {
        addCount++;
        return super.add(e);
    }

    @Override public boolean addAll(Collection<? extends E> c) {
        addCount += c.size();
        return super.addAll(c);
    }

    public int getAddCount() {
        return addCount;
    }
}
```

이 클래스로 객체를 만들어 addAll 메서드를 통해 세 개 원소를 집어넣는다고 해 보자.

```java
InstrumentedHashSet<String> s = new InstrumentedHashSet<String>();
s.addAll(Arrays.asList("Snap", "Crackle", "Pop"));
```

getAddCount 메서드가 3을 반환할 것이라 기대하겠지만, 실제로는 6을 반환한다. HashSet의 addAll 메서드는 add 메서드를 통해 구현되어 있기 때문이다. InstrumentedHashSet에 정의된 addAll 메서드는 addCount에 3을 더하고 상위 클래스인 HashSet의 addAll 메서드를 super.addAll과 같이 호출하는데, 이 메서드는 InstrumentedHashSet에서 재정의한 add 메서드를 삽입할 원소마다 호출하게 된다.

하위 클래스에서 재정의한 addAll 메서드를 삭제하면 이 문제를 \"교정(fix)\"할 수 있는데, 이 클래스가 정상 동작한다는 것은 HashSet의 addAll 메서드가 add 위에서 구현되었다는 사실에 의존한다.

하위 클래스 구현을 망가뜨릴 수 있는 또 한 가지 요인은, 다음 릴리스에는 상위 클래스에 새로운 메서드가 추가될 수 있다는 것이다.

지금껏 설명한 모든 문제를 피할 방법이 있다. 기존 클래스를 계승하는 대신, 새로운 클래스에 기존 클래스를 참조하는 private 필드를 하나 두는 것이다. 이런 설계 기법을 *구성*(composition)이라고 부르는데, 기존 클래스가 새 클래스의 일부(component)가 되기 때문이다. 새로운 클래스에 포함된 각각의 메서드는 기존 클래스에 있는 메서드 가운데 필요한 것을 호출해서 그 결과를 반환하면 된다. 이런 구현 기법을 *전달*(forwarding)이라고 하고, 전달 기법을 사용해 구현된 메서드를 *전달 메서드*(forwarding method)라고 부른다. 기존 클래스의 구현 세부사항에 종속되지 않기 때문에, 기존 클래스에 또 다른 메서드가 추가되더라도 새로 만든 클래스에는 영향이 없을 것이다.

```java
// 계승 대신 구성을 사용하는 포장(wrapper) 클래스
public class InstrumentedSet<E> extends ForwardingSet<E> {
    private int addCount = 0;

    public InstrumentedSet(Set<E> s) {
        super(s);
    }

    @Override public boolean add(E e) {
        addCount++;
        return super.add(e);
    }

    @Override public boolean addAll(Collection<? extends E> c) {
        addCount += c.size();
        return super.addAll(c);
    }

    public int getAddCount() {
        return addCount;
    }
}
```

InstrumentedSet과 같은 클래스를 포장 클래스(wrapper class)라고 부르는데, 다른 Set 객체를 포장하고(감싸고) 있기 때문이다. 또한 이런 구현 기법은 *장식자*(decorator) 패턴이라고 부르는데, 기존 Set 객체에 기능을 덧붙여 장식하는 구실을 하기 때문이다.

계승은 하위 클래스가 상위 클래스의 *하위 자료형*(subtype)이 확실한 경우에만 바람직하다. 다시 말해서, 클래스 B는 클래스 A와 \"IS-A\" 관계가 성립할 때만 A를 계승해야 한다.

#### 요약
- 계승은 강력한 도구이지만 캡슐화 원칙을 침해하므로 문제를 발생시킬 소지가 있다.
- 계승은 상위 클래스와 하위 클래스 사이에 IS-A 관계가 있을 때만 사용하는 것이 좋다.
- 하위 클래스가 상위 클래스와 다른 패키지에 있거나 계승을 고려해 만들어진 상위 클래스가 아니라면, 하위 클래스는 깨지기 쉽다.
- 이런 문제를 피하려면 구성과 전달 기법을 사용하는 것이 좋다.
- 포장 클래스는 하위 클래스보다 견고할 뿐 아니라, 더 강력하다.

---

# 규칙 17. 계승을 위한 설계와 문서를 갖추거나, 그럴 수 없다면 계승을 금지하라



# Reference
- [Effective Java 2/E](http://www.insightbook.co.kr/%EB%8F%84%EC%84%9C-%EB%AA%A9%EB%A1%9D/programming-insight/%EC%9D%B4%ED%8E%99%ED%8B%B0%EB%B8%8C-%EC%9E%90%EB%B0%94effective-java-2e)
