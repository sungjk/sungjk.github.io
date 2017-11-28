---
layout: entry
post-category: java
title: Effective Java(3)
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java의 4장(클래스와 인터페이스)을 정리한 글입니다.
publish: true
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
메서드를 재정의하면 무슨 일이 생기는지, **재정의 가능 메서드를 내부적으로 어떻게 사용하는지(self-use) 반드시 문서에 남기라는 것이다.**

문서만 제대로 썼다고 계승에 적합한 설계가 되지는 않는다. 너무 애쓰지 않고도 효율적인 하위 클래스를 작성할 수 있도록 하려면, **클래스 내부 동작에 개입할 수 있는 훅(hooks)을 신중하게 고른 protected 메서드 형태로 제공해야 한다.**

**계승을 위해 설계한 클래스를 테스트할 유일한 방법은 하위 클래스를 직접 만들어 보는 것이다.** 만일 중요한 멤버를 protected로 선언하는 것을 잊었다면, 그 사실은 하위 클래스를 만드는 과정에서 고통스러울 정도로 분명해질 것이다. 반대로, 하위 클래스를 몇 개 만들어 봐도 사용할 일이 없었던 protected 멤버는 다시 private로 선언해야 할 것이다.

널리 사용될 클래스를 계승에 맞게 설계할 때는, 문서에 명시한 내부 호출 패턴(self-use pattern)뿐 아니라 메서드와 필드를 protected로 선언하는 과정에 함축된 구현 관련 결정들을 영원히 고수해야 한다는 점을 기억해야 한다. 따라서 다음 릴리스에 성능이나 기능을 개선하기 어려워진다. 그러므로 **그런 클래스는 릴리스에 포함시키기 전에 반드시 하위 클래스를 만들어서 테스트해야 한다.**

계승을 허용하려면 반드시 따라야 할 제약사항(restriction)이 몇 가지 더 있다. 그 중 첫 번째는, **생성자는** 직접적이건 간접적이건 **재정의 가능 메서드를 호출해서는 안 된다는 것이다.** 상위 클래스 생성자는 하위 클래스 생성자보다 먼저 실행되므로, 하위 클래스에서 재정의한 메서드는 하위 클래스 생성자가 실행되기 전에 호출될 것이다. 재정의한 메서드가 하위 클래스 생성자가 초기화한 결과에 의존할 경우, 그 메서드는 원하는 대로 실행되지 않을 것이다.

계승을 위해 설계하는 클래스에서 Cloneable이나 Serializable을 구현하기로 결정했다면, clone이나 readObject 메서드도 생성자와 비슷하게 동작하므로, 비슷한 규칙을 따라야 한다는 것에 주의해야 한다. 즉, **clone이나 readObject 메서드 안에서 직접적이건 간접적이건 재정의 가능한 메서드를 호출하지 않도록 주의해야 한다는 것이다.** readObject 메서드 안에서 재정의 가능 메서드를 호출하게 되면, 하위 클래스 객체의 상태가 완전히 역직렬화(deserialize) 되기 전에 해당 메서드가 실행되어 버린다. clone 메서드의 경우라면, 하위 클래스의 clone 메서드가 복사본 객체의 상태를 미처 수정하기도 전에 해당 메서드가 실행되어 버릴 것이다.

마지막으로, Serializable 인터페이스를 구현하는 계승용 클래스에 readResolve와 writeReplace 메서드가 있다면, 이 두 메서드는 private가 아니라 protected로 선언해야만 한다. private로 선언해버리면 하위 클래스는 해당 메서드들을 조용히 무시한다. 이것은 계승을 허용하기 위해 구현 세부사항을 클래스 API의 일부로 포함시켜야 하는 사례 가운데 하나다.

**계승을 위해 클래스를 설계하면 클래스에 상당한 제약이 가해진다.** 가볍게 생각할 수 없는 결정이다. 인터페이스에 대한 골격 구현(skeletal implementation) 추상 클래스(abstract class)를 만드는 경우라면 올바른 결정일 것이다(규칙 18). 분명 잘못된 결정일 때도 있다. 변경 불가능 클래스라면 계승은 배제해야 한다(규칙 15).

일반적인 객체 생성 가능 클래스의 경우, **계승에 맞도록 설계하고 문서화하지 않은 클래스에 대한 하위 클래스는 만들지 않는 것이다.** 하위 클래스 생성을 금지하는 방법에는 두 가지가 있다. 가장 쉬운 방법은 클래스를 final로 선언하는 것이다. 그 대안은, 모든 생성자를 private나 package-private로 선언하고 생성자 대신 public 정적 팩터리 메서드를 추가하는 것이다.

---

# 규칙 18. 추상 클래스 대신 인터페이스를 사용하라
인터페이스와 추상 클래스(abstract class)의 분명한 차이는, 추상 클래스는 구현된 메서드를 포함할 수 있지만 인터페이스는 아니라는 것이다. 좀 더 중요한 차이는, 추상 클래스는 규정하는 자료형을 구현하기 위해서는 추상 클래스를 반드시 계승해야 한다는 것이다. 인터페이스의 경우에는 인터페이스에 포함된 모든 메서드를 정의하고 인터페이스가 규정하는 일반 규약(general contract)을 지키기만 하면 되며, 그렇게 만든 클래스는 클래스 계층(class hierarchy)에 속할 필요가 없다.

**이미 있는 클래스를 개조해서 새로운 인터페이스를 구현하도록 하는 것은 간단하다.** 해야 하는 일이라고는 필요한 메서드가 다 있는지 확인해서 없으면 추가한 다음 클래스 선언부에 implements 절을 넣는 것이 전부다.

**인터페이스는 믹스인(mixin)을 정의하는 데 이상적이다.** 간단히 말해서 믹스인은 클래스가 \"주 자료형(primary type)\" 이외에 추가로 구현할 수 있는 자료형으로, 어떤 선택적 기능을 제공한다는 사실을 선언하기 위해 쓰인다. 예를 들어 Comparable은 어떤 클래스가 자기 객체는 다른 객체와는 비교 결과에 따른 순서를 갖는다고 선언할 때 쓰는 믹스인 인터페이스다. 이런 인터페이스를 믹스인이라 부르는 것은, 자료형의 주된 기능에 선택적인 기능을 \"혼합(mix in)\"할 수 있도록 하기 때문이다. 추상 클래스는 믹스인 정의에는 사용할 수 없다. 클래스가 가질 수 있는 상위 클래스는 하나뿐이며, 클래스 계층에는 믹스인을 넣기 좋은 곳이 없다.

**인터페이스는 비 계층적인(nonhierarchical) 자료형 프레임워크(type framework)를 만들 수 있도록 한다.** 예를 들어, 가수를 표현하는 인터페이스와 작곡가를 표현하는 인터페이스가 있다고 해보자.

```java
public interface Singer {
    AudioClip sing(Song s);
}
public interface Songwriter {
    Song compose(boolean hit);
}
```

그런데 가수 가운데는 작곡가인 사람도 있다. 추상 클래스 대신 인터페이스를 사용해 자료형을 만들었으므로, 아무런 문법적 문제없이 Singer와 Songwriter를 동시에 구현하는 클래스를 만들 수 있다. 대신, Singer와 Songwriter를 확장한 또 다른 인터페이스를 추가할 수도 있다. 이 인터페이스에는 새로운 메서드를 추가할 수 있다.

```java
public interface SingerSongwriter extends Singer, Songwriter {
    AudioClip strum();
    void actSensitive();
}
```

**인터페이스를 사용하면 포장 클래스 숙어(wrapper class idiom)을 통해(규칙 16) 안전하면서도 강력한 기능 개선이 가능하다.** 추상 클래스를 사용해 자료형을 정의하면 프로그래머는 계승 이외의 수단을 사용할 수 없다. 그렇게 해서 만든 클래스는 포장 클래스보다 강력하지도 않고, 깨지기도 쉽다.

인터페이스 안에는 메서드 구현을 둘 수 없지만, 그렇다고 프로그래머가 사용할 수 있는 코드를 제공할 방법이 없는 것은 아니다. **추상 골격 구현(abstract skeletal implementation) 클래스를 중요 인터페이스마다 두면, 인터페이스의 장점과 추상 클래스의 장점을 결합할 수 있다.** 인터페이스로는 자료형을 정의하고, 구현하는 일은 골격 구현 클래스에 맡기면 된다.

관습적으로 골격 구현 클래스의 이름은 *AbstractInterface* 와 같이 정한다. *Interface* 는 해당 클래스가 구현하는 인터페이스의 이름이다. 예를 들어, 컬렉션 프레임워크(Collection Framework)에는 인터페이스별로 골격 구현 클래스들이 하나씩 제공된다. AbstractCollection, AbstractSet, AbstractList, AbstractMap 등이다.

골격 구현 클래스를 적절히 정의하기만 하면, 프로그래머는 쉽게 인터페이스를 구현할 수 있다. 예를 들어, 아래의 정적 팩터리 메서드는 기능적으로 완전한 List를 구현한다.

```
// 골격 구현 위에서 만들어진 완전한 List 구현
static List<Integer> intArrayAsList(final int[] a) {
    if (a == null)
        throw new NullPointerException();
    return new AbstractList<Integer>() {
        public Integer get(int i) {
            return a[i];    // 자동 객체화(규칙 5)
        }

        @Override public Integer set(int i, Integer val) {
            int oldVal = a[i];
            a[i] = val;     // 자동 비객체화
            return oldVal;  // 자동 객체화
        }

        public int size() {
            return a.length;
        }
    }
}
```

정적 팩터리 메서드를 통해 반환되는 객체의 클래스가 정적 팩터리 안에 숨겨진, 외부에서는 접근이 불가능한 익명 클래스(anonymous class)라는 점에 주의하기 바란다(규칙 22).

추상 클래스를 자료형 정의 수단으로 사용했을 때 만족해야 하는 심각한 제약사항들을 따르지 않아도 추상 클래스를 구현할 수 있도록 돕는다는 것이 골격 구현 클래스의 아름다움이다. 골격 구현 클래스가 있다면 해당 클래스를 사용해 인터페이스를 구현하는 것이 가장 분명한 프로그래밍 방법이다. 하지만 엄밀하게 말해서 그것도 선택사항일 뿐이다. 골격 구현 클래스를 상속하도록 기존 클래스를 변경할 수 없다면, 인터페이스를 직접 구현해도 된다. 그리고 그럴 때도 골격 구현 클래스를 사용하면 더 쉽게 구현할 수 있다. 골격 구현 클래스를 계승하는 private 내부 클래스(inner class)를 정의하고, 인터페이스 메서드에 대한 호출은 해당 중첩 클래스 객체로 전달(forwarding)하는 것이다.

다양한 구현을 허용하는 자료형을 추상 클래스로 정의하면 인터페이스보다 나은 점이 한 가지 있는데, **인터페이스보다는 추상 클래스가 발전시키기 쉽다** 는 것이다. 다음 릴리스에 새로운 메서드를 추가하고 싶다면, 적당한 기본 구현 코드를 담은 메서드를 언제든 추가할 수 있다. 해당 추상 클래스를 계승하는 모든 클래스는 그 즉시 새로운 메서드를 제공하게 될 것이다. 인터페이스로는 이런 작업을 할 수 없다.

일반적으로 보자면, public 인터페이스를 구현하는 기존 클래스를 깨뜨리지 않고 새로운 메서드를 인터페이스에 추가할 방법은 없다. 따라서 public 인터페이스는 신중하게 설계해야 한다. **인터페이스가 공개되고 널리 구현된 다음에는, 인터페이스 수정이 거의 불가능하기 때문이다.** 그러니 처음부터 제대로 설계해야 한다.

#### 요약
- 인터페이스는 다양한 구현이 가능한 자료형을 정의하는 일반적으로 가장 좋은 방법이다.
- 유연하고 강력한 API를 만드는 것보다 개선이 쉬운 API를 만드는 것이 중요한 경우에는 추상 클래스를 사용해야 하는데, 그 단점은 잘 이해하고 있어야 하며, 그 단점을 수용할 수 있는 경우로 한정해서 사용해야 한다.
- 중요한 인터페이스를 API에 포함시키는 경우에는 골격 구현 클래스를 함께 제공하면 어떨지 심각하게 고려해봐야 한다.
- public 인터페이스는 극도로 주의해서 설계해야 하며, 실제로 여러 구현을 만들어 보면서 광범위하게 테스트해야 한다.

---

# 규칙 19. 인터페이스는 자료형을 정의할 때만 사용하라
인터페이스를 구현하는 클래스를 만들게 되면, 그 인터페이스는 해당 클래스의 객체를 참조할 수 있는 자료형(type) 역할을 하게 된다. 인터페이스를 구현해 클래스를 만든다는 것은, 해당 클래스의 객체로 어떤 일을 할 수 있는지 클라이언트에게 알리는 행위다. 다른 목적으로 인터페이스를 정의하고 사용하는 것은 적절치 못하다.

이 기준에 미달하는 사례로는 소위 상수 인터페이스(constant interface)라는 것이 있다. 이런 인터페이스에는 메서드가 없고, static final 필드만 있다. 모든 필드는 상수 정의다. 이런 인터페이스를 구현하는 것은 대체로 상수 이름 앞에 클래스 이름을 붙이는 번거로움을 피하기 위해서다.

```
// 상수 인터페이스 안티패턴 - 사용하지 말 것!
public interface PhysicalConstants {
    // 아보가드로 수(1/mod)
    static final double AVOGADROS_NUMBER    = 6.02214199e23;

    // 볼쯔만 상수(J/K)
    static final double BOLTZMAN_CONSTANT   = 1.3806503e-23;

    // 전자 질량(kg)
    static final double ELECTRON_MASS       = 9.10938188e-31;
}
```

**상수 인터페이스 패턴은 인터페이스를 잘못 사용한 것이다.** 클래스가 어떤 상수를 어떻게 사용하느냐 하는 것은 구현 세부사항이다. 상수 정의를 인터페이스에 포함시키면 구현 세부사항이 클래스의 공개 API에 스며들게 된다. 클래스가 상수 인터페이스를 구현한다는 사실은 클래스 사용자에게 중요한 정보가 아니고, 혼동시킬 뿐이다.

상수를 API 일부로 공개하고 싶을 때는 더 좋은 방법이 있다. 해당 상수가 이미 존재하는 클래스나 인터페이스에 강하게 연결되어 있을 때는 해당 클래스나 인터페이스에 추가해야 한다. 예를 들어, 수를 표현하는 기본 자료형의 객체 표현형들(Integer나 Double)에는 MIN_VALUE나 MAX_VALUE 상수가 공개되어 있다. 이런 상수들이 enum 자료형의 멤버가 되어야 바람직할 때는 enum 자료형(규칙 30)과 함께 공개해야 한다. 그렇지 않을 때는 해당 상수들을 객체 생성이 불가능한 유틸리티 클래스(규칙 4)에 넣어서 공개해야 한다.

```
// 상수 유틸리티 클래스
package com.effectivejava.science;

public class PhysicalConstants {
    private PhysicalConstants() { } // 객체 생성을 막음

    public static final double AVOGADROS_NUMBER    = 6.02214199e23;
    public static final double BOLTZMAN_CONSTANT   = 1.3806503e-23;
    public static final double ELECTRON_MASS       = 9.10938188e-31;
}
```

#### 요약
- 인터페이스는 자료형을 정의할 때만 사용해야 한다.
- 특정 상수를 API의 일부로 공개할 목적으로는 적절치 않다.

---

# 규칙 20. 태그 달린 클래스 대신 클래스 계층을 활용하라
두 가지 이상의 기능을 가지고 있으며, 그 중 어떤 기능을 제공하는지 표시하는 태그(tag)가 달린 클래스를 만날 때가 있다.

```
// 태그 달린 클래스 - 클래스 계층을 만드는 쪽이 더 낫다!
class Figure {
    enum Shape { RECTANGLE, CIRCLE };

    // 어떤 모양인지 나타내는 태그 필드
    final Shape shape;

    // 태그가 RECTANGLE일 때만 사용되는 필드들
    double length;
    double width;

    // 태그가 CIRCLE일 때만 사용되는 필드들
    double radius;

    // 원을 만드는 생성자
    Figure(double radius) {
        shape = Shape.CIRCLE;
        this.radius = radius;
    }

    // 사각형을 만드는 생성자
    Figure(double length, double width) {
        shape = Shape.RECTANGLE;
        this.length = length;
        this.width = width;
    }

    double area() {
        switch(shape) {
            case RECTANGLE:
                return length * width;
            case CIRCLE:
                return MATH.PI * (radius * radius);
            default:
                throw new AssertionError();
        }
    }
}
```

태그 달린 클래스에는 다양한 문제가 있다. enum 선언, 태그 필드, switch 문 등의 상투적 코드가 반복되는 클래스가 만들어지며, 서로 다른 기능을 위한 코드가 한 클래스에 모여 있으니 가독성도 떨어진다. 객체를 만들 때마다 필요 없는 기능을 위한 필드도 함께 생성되므로, 메모리 요구량도 늘어난다. 간단히 말해서, **태그 기반 클래스(tagged class)는 너저분한데다 오류 발생 가능성이 높고, 효율적이지도 않다.**

이 때에는 하위 자료형 정의(subtyping)을 활용하면 된다. 태그 기반 클래스는 클래스 계층을 얼기설기 흉내 낸 것일 뿐이다.

태그 기반 클래스를 클래스 계층으로 변환하려면, 먼저 태그 값에 따라 달리 동작하는 메서드를 추상 메서드(abstract method)로 선언하는 추상 클래스를 정의해야 한다. 그 다음 할 일은 태그 기반 클래스가 제공하던 각각의 기능을 방금 만든 최상위 클래스의 객체 생성 가능 하위 클래스(concrete subclass)로 정의하는 것이다.

```
// 태그 기반 클래스를 클래스 계층으로 변환한 결과
abstract class Figure {
    abstract double area();
}

class Circle extends Figure {
    final double radius;

    Circle(double radius) { this.radius = radius; }

    double area() { return Math.PI * (radius * radius); }
}

class Rectangle extends Figure {
    final double length;
    final double width;

    Rectangle(double length, double width) {
        this.length = length;
        this.width = width;
    }

    double area() { return length * width; }
}
```

태그 기반 클래스의 단점들이 여기에는 없다. 단순하고 명료하며, 원래 클래스에 있던 난삽하던 상투적인(boilerplate) 코드도 없다. 각각의 기능을 별도 클래스로 구현되어 있고, 각 클래스 안에는 관련 없는 필드도 존재하지 않는다. 모든 필드는 final로 선언되어 있다. 컴파일러는 생성자가 모든 데이터필드를 적절히 초기화하도록 할 것이며, 모든 클래스는 최상위 클래스에 abstract로 선언된 메서드를 구현하고 있다. 기능마다 별도의 자료형이 있기 때문에, 변수가 가진 기능이 무엇인지 명시적으로 표현할 수 있으며, 특정한 기능을 갖춘 자료형의 객체만이 변수나 인자에 할당되도록 할 수 있다.

클래스 계층의 또 다른 장점은 자료형 간의 자연스러운 계층 관계를 반영할 수 있어서 유연성이 높아지고 컴파일 시에 형 검사(type checking)를 하기 용이하다.

#### 요약
- 태그 기반 클래스 사용은 피하고, 이보다는 클래스 계층을 통해 태그를 제거할 방법이 없는지 생각해 보자.
- 태그 필드가 있는 클래스를 만나게 된다면, 리팩터링(refactoring)을 통해 클래스 계층으로 변환할 방법은 없는지 고민해 보자.

---

# 규칙 21. 전략을 표현하고 싶을 때는 함수 객체를 사용하라
자바는 함수 포인터를 지원하지 않지만 객체 참조를 통해 비슷한 효과를 달성할 수 있다. 객체의 메서드는 보통 호출 대상 객체에 뭔가를 한다. 하지만 다른 객체에 작용하는 메서드, 그러니까 인자로 전달된 객체에 뭔가를 하는 메서드를 정의하는 것도 가능하다. 가지고 있는 메서드가 그런 메서드 하나뿐인 객체는 해당 메서드의 포인터 구실을 한다. 그런 객체를 함수 객체(function object)라고 부른다.

```
class StringLengthComparator {
    public int compare(String s1, String s2) {
        return s1.length() - s2.length();
    }
}
```

StringLengthComparator 객체는 문자열을 비교하는 데 사용될 수 있는, 실행 가능 전략(concrete strategy)이다. 이에 더해 전략 인터페이스(strategy interface)를 정의할 필요가 있다.

```
// 전략 인터페이스
public interface Comparator<T> {
    public int compare(T t1, T t2);
}
```

#### 요약
- 함수 객체의 주된 용도는 전략 패턴(Strategy pattern)을 구현하는 것이다.
- 자바로 이 패턴을 구현하기 위해서는 전략을 표현하는 인터페이스를 선언하고, 실행 가능 전략 클래스가 전부 해당 인터페이스를 구현하도록 해야 한다.

---

# 규칙 22. 멤버 클래스는 가능하면 static으로 선언하라
중첩 클래스(nested class)는 다른 클래스 안에 정의된 클래스다. 중첩 클래스는 해당 클래스가 속한 클래스 안에서만 사용된다. 그렇지 않으면 중첩 클래스로 만들면 안 된다. 정적 멤버 클래스(static member class), 비-정적 멤버 클래스(nonstatic member class), 익명 클래스(anonymous class), 그리고 지역 클래스(local class)가 이에 해당된다.

비-정적 멤버 클래스 객체는 바깥 클래스 객체와 자동적으로 연결된다. 비-정적 멤버 클래스 안에서는 바깐 클래스의 메서드를 호출할 수도 있고, this 한정(qualified this) 구문을 통해 바깐 객체에 대한 참조를 획득할 수도 있다. 중첩된 클래스의 객체가 바깥 클래스 객체와 독립적으로 존재할 수 있도록 하려면 중첩 클래스는 반드시 정적 멤버 클래스로 선언해야 한다. 비-정적 멤버 클래스의 객체는 바깥 클래스 객체 없이는 존재할 수 없다.

비-정적 멤버 클래스는 어댑터(Adapter)를 정의할 때 많이 쓰인다. 바깥 클래스 객체를 다른 클래스 객체인 것처럼 보이게 하는 용도다.

```
// 비-정적 멤버 클래스의 전형적 용례
public class MySet<E> extends AbstractSet<E> {
    ... // 생략

    public Iterator<E> iterator() {
        return new MyIterator();
    }

    private class MyIterator implements Iterator<E> {
        ...
    }
}
```

**바깥 클래스 객체에 접근할 필요가 없는 멤버 클래스를 정의할 때는 항상 선언문 앞에 static을 붙여서 비-정적 멤버 클래스 대신 정적 멤버 클래스로 만들자.** static을 생략하면 모든 객체는 내부적으로 바깥 객체에 대한 참조를 유지하게 된다. 그 덕분에 시간과 공간 요구량이 늘어나며, 바깥 객체에 대한 쓰레기 수집(garbage collection)이 힘들어진다(규칙 6).

익명 클래스는 비-정적 문맥(nonstatic context) 안에서 사용될 때만 바깥 객체를 갖는다. 그러나 정적 문맥(static context) 안에서 사용된다 해도 static 멤버를 가질 수는 없다. 익명 클래스는 함수 객체(규칙 21)를 정의할 때 널리 쓰인다.

지역 클래스(local class)는 지역 변수(local variable)가 선언될 수 있는 곳이라면 어디서든 선언할 수 있으며, 지역 변수와 동일한 유효범위 규칙(scoping rule)을 따른다. 멤버 클래스처럼 이름을 가지며, 반복적으로 사용될 수 있다. 익명 클래스처럼 비-정적 문맥에서 정의했을 때만 바깥 객체를 갖는다. 그리고 static 멤버는 가질 수 없다. 길어지면 가독성을 해치므로, 익명 클래스처럼 짧게 작성해야 한다.

#### 요약
- 중첩 클래스를 메서드 밖에서 사용할 수 있어야 하거나, 메서드 안에 놓기에 너무 길 경우에는 멤버 클래스로.
- 멤버 클래스의 객체 각각이 바깥 객체에 대한 참조를 가져야 하는 경우에는 비-정적 멤버 클래스로, 그렇지 않은 경우에는 정적 멤버 클래스로.
- 중첩 클래스가 특정한 메서드에 속해야 하고, 오직 한곳에서만 객체를 생성하며, 해당 중첩 클래스의 특성을 규정하는 자료형이 이미 있다면 익명 클래스로, 그렇지 않을 때는 지역 클래스로.

---

# Reference
- [Effective Java 2/E](http://www.insightbook.co.kr/%EB%8F%84%EC%84%9C-%EB%AA%A9%EB%A1%9D/programming-insight/%EC%9D%B4%ED%8E%99%ED%8B%B0%EB%B8%8C-%EC%9E%90%EB%B0%94effective-java-2e)
