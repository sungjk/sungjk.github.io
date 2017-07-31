---
layout: entry
title: Effective Java(1)
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java의 2장(객체의 생성과 삭제)을 정리한 글입니다.
publish: true
---

# 규칙 1. 생성자 대신 정적 팩터리 메서드를 사용할 수 없는지 생각해 보라
클래스를 통해 객체를 만드는 방법은 public으로 선언된 생성자(constructor)를 이용하는 방법 말고, 클래스에 public으로 선언된 정적 팩터리 메서드(static factory method)를 추가하는 방법이 있다.

**첫 번째 장점은, 생성자와는 달리 정적 팩터리 메서드에는 이름(name)이 있다는 것이다.** 생성자에 전달되는 인자(parameter)들은 어떤 객체가 생성되는지를 설명하지 못하지만, 정적 팩터리 메서드는 이름을 잘 짓기만 하면 사용하기도 쉽고, 클라이언트 코드의 가독성(readability)도 높아진다.

**두 번째 장점은, 생성자와는 달리 호출할 때마다 새로운 객체를 생성할 필요는 없다는 것이다.** 변경 불가능한 클래스라면 이미 만들어 둔 객체를 활용할 수도 있고, 만든 객체를 캐시(cache) 해놓고 재사용하여 같은 객체가 불필요하게 거듭 생성되는 일을 피할 수도 있다. 동일한 객체가 요청되는 일이 잦고, 특히 객체를 만드는 비용이 클 때 적용하면 성능을 크게 개선할 수 있다.

**세 번째 장점은, 생성자와는 달리 반환값 자료형의 하위 자료형 객체를 반환할 수 있다는 것이다.** public으로 선언되지 않은 클래스의 객체를 반환하는 API를 만들 수 있다.

심지어 정적 팩터리 메서드가 반환하는 객체의 클래스는 정적 팩터리 메서드가 정의된 클래스의 코드가 작성되는 순간에 존재하지 않아도 무방하다.

**네 번째 장점은, 형인자 자료형(parameterized type) 객체를 만들 때 편하다는 점이다.**

```java
Map<String, List<String>> m = new HashMap<String, List<String>>();
```

이처럼 자료형 명세를 중복하면, 형인자가 늘어남에 따라 길고 복잡한 코드가 만들어진다. 하지만 정적 팩터리 메서드를 사용하면 컴파일러가 형인자를 스스로 알아내도록 할 수 있다. 이런 기법을 자료형 유추(type inference)라고 부른다.

```java
public static <K, V> HashMap<K, V> newInstance() {
  return new HashMap<K, V>();
}
```

이런 메서드가 있으면 다음과 같이 좀 더 간결하게 작성할 수 있다.

```java
Map<String, List<String>> m = HashMap.newInstance();
```

**정적 팩터리 메서드만 있는 클래스를 만들면 생기는 가장 큰 문제는, public이나 protected로 선언된 생성자가 없으므로 하위 클래스를 만들 수 없다는 것이다.**

**두 번째 단점은, 정적 팩터리 메서드가 다른 정적 메서드와 확연히 구분되지 않는다는 것이다.** 지금으로서는 클래스나 인터페이스 주석(comment)을 통해 정적 팩터리 메서드임을 널리 알리거나, 정적 팩터리 메서드 이름을 지을 때 조심하는 수밖에 없다. 보통 정적 팩터리 메서드 이름으로는 다음과 같은 것들을 사용한다.

- valueOf: 인자로 주어진 값과 같은 값을 갖는 객체를 반환한다는 뜻이다. 이런 정적 팩터리 메서드는 형변환(type-conversion) 메서드이다.
- of: valueOf를 더 간단하게 쓴 것이다.
- getInstance: 인자에 기술된 객체를 반환하지만, 인자와 같은 값을 갖지 않을 수도 있다. 싱글턴(singleton) 패턴을 따를 경우, 이 메서드는 인자 없이 항상 같은 객체를 반환한다.
- newInstance: getInstance와 같지만 호출할 때마다 다른 객체를 반환한다.
- getType: getInstance와 같지만, 반환될 객체의 클래스와 다른 클래스에 팩터리 메서드가 있을 때 사용한다.
- newType: newInstance와 같지만, 반환될 객체의 클래스와 다른 클래스에 팩터리 메서드가 있을 때 사용한다.

#### **요약**
정적 팩터리 메서드와 public 생성자는 용도가 서로 다르며, 그 차이와 장단점을 이해하는 것이 중요하다. 정적 팩터리 메서드를 고려해 보지도 않고 무조건 public 생성자를 만드는 것은 삼가기 바란다.

---

# 규칙 2. 생성자 인자가 많을 때는 Builder 패턴 적용을 고려하라
선택적 인자가 많은 상황에 보통 프로그래머들은 점층적 생성자 패턴(telescoping constructor pattern)을 적용한다. 필수 인자만 받는 생성자를 하나 정의하고, 선택적 인자를 하나 받는 생성자를 추가하고, 거기에 두 개의 선택적 인자를 받는 생성자를 추가하는 식으로, 생성자들을 쌓아 올리듯 추가하는 것이다.

```java
// 점층적 생성자 패턴 - 더 많은 인자 개수에 잘 적응하지 못한다.
public class NutritionFacts {
  private final int servingSize;  // (mL)             필수
  private final int servings;     // (per container)  필수
  private final int calories;     //                  선택
  private final int fat;          // (g)              선택
  private final int sodium;       // (mg)             선택
  private final int carbohydrate; // (g)              선택

  public NutritionFacts(int servingSize, int servings) {
    this(servingSize, servings, 0);
  }

  public NutritionFacts(int servingSize, int servings,
                        int calories) {
    this(servingSize, servings, calories, 0);
  }

  public NutritionFacts(int servingSize, int servings,
                        int calories, int fat) {
    this(servingSize, servings, calories, fat, 0);
  }

  public NutritionFacts(int servingSize, int servings,
                        int calories, int fat, int sodium) {
    this(servingSize, servings, calories, fat, sodium, 0);
  }

  public NutritionFacts(int servingSize, int servings,
                        int calories, int fat, int sodium,
                        int carbohydrate) {
    this.servingSize = servingSize;
    this.servings = servings;
    this.calories = calories;
    this.fat = fat;
    this.sodium = sodium;
    this.carbohydrate = carbohydrate;
  }
}
```

**위와 같은 점층적 생성자 패턴은 잘 동작하지만 인자 수가 늘어나면 클라이언트 코드를 작성하기가 어려워지고, 무엇보다 읽기 어려운 코드가 되고 만다.**

생성자에 전달되는 인자 수가 많을 때 적용 가능한 두 번째 대안은 자바빈(JavaBeans) 패턴이다. 인자 없는 생성자를 호출하여 객체부터 만든 다음, 설정 메서드(setter methods)들을 호출하여 필수 필드뿐 아니라 선택적 필드의 값들까지 채우는 것이다.

```java
// 자바빈 패턴 - 일관성 훼손이 가능하고, 항상 변경 가능하다.
public class NutritionFacts {
  // 필드는 기본값으로 초기화(기본값이 있는 경우만)
  private int servingSize = -1; // 필수: 기본값 없음
  private int servings = -1;    // 상동
  private int calories = 0;
  private int fat = 0;
  private int sodium = 0;
  private int carbohydrate = 0;

  public NutritionFacts() { }
  // 설정자(setter)
  public void setServingSize(int val) { servingSize = val; }
  public void setServings(int val) { servings = val; }
  public void setCalories(int val) { calories = val; }
  public void setFat(int val) { fat = val; }
  public void setSodium(int val) { sodium = val; }
  public void setCarbohydrate(int val) { carbohydrate = val; }
}

NutritionFacts cocaCola = new NutritionFacts();
cocaCola.setServingSize(240);
cocaCola.setServings(8);
cocaCola.setCalories(100);
cocaCola.setSodium(35);
cocaCola.setCarbohydrate(27);
```

자바빈 패턴은 객체 생성도 쉽고 읽기도 좋지만, **1회의 함수 호출로 객체 생성을 끝낼 수 없으므로, 객체 일관성(consistency)이 일시적으로 깨질 수 있다는 것이다.** 또한, **자바빈 패턴으로는 변경 불가능(immutable) 클래스를 만들 수 없다는 것이다.** 스레드 안전성(thread-safety)을 제공하기 위해 해야 할 일도 더 많아진다.

점층적 생성자 패턴의 안전성에 자바빈 패턴의 가독성을 결합한 세 번째 대안은 바로, 빌더(Builder) 패턴이다.

1. 필수 인자들을 생성자에(또는 정적 팩터리 메서드에) 전부 전달하여 빌더 객체(Builder object)를 만든다.
2. 빌더 객체에 정의된 설정 메서드들을 호출하여 선택적 인자들을 추가해 나간다.
3. 마지막으로 아무런 인자 없이 build 메서드를 호출하여 변경 불가능(immutable) 객체를 만드는 것이다.

```java
// 빌더 패턴
public class NutritionFacts {
  private final int servingSize;
  private final int servings;
  private final int calories;
  private final int fat;
  private final int sodium;
  private final int carbohydrate;

  public static class Builder {
    // 필수 인자
    private final int servingSize;
    private final int servings;
    // 선택적 인자 - 기본값으로 초기화
    private int calories = 0;
    private int fat = 0;
    private int sodium = 0;
    private int carbohydrate = 0;

    public Builder(int servingSize, int servings) {
      this.servingSize = servingSize;
      this.servings = servings;
    }

    public Builder calories(int val) {
      calories = val;
      return this;
    }

    public Builder fat(int val) {
      fat = val;
      return this;
    }

    public Builder sodium(int val) {
      sodium = val;
      return this;
    }

    public Builder carbohydrate(int val) {
      carbohydrate = val;
      return this;
    }

    public NutritionFacts build() {
      return new NutritionFacts(this);
    }
  }

  private NutritionFacts(Builder builder) {
    servingSize = builder.servingSize;
    servings = builder.servings;
    calories = builder.calories;
    fat = builder.fat;
    sodium = builder.sodium;
    carbohydrate = builder.carbohydrate;
  }
}

NutritionFacts cocaCola = new NutritionFacts.Builder(240, 8).
    calories(100).sodium(35).carbohydrate(27).build();
```

이 코드는 작성하기도 쉽고, 읽기 쉽다. **Ada나 Python 같은 언어는 선택적 인자에 이름을 붙일 수 있도록 허용하는데, 그것과 비슷한 코드를 작성할 수 있기 때문이다.**

생성자와 마찬가지로, 빌더 패턴을 사용하면 인자에 불변식(invariant)을 적용할 수 있다. build 메서드 안에서 해당 불변식이 위반되었는지 검사할 수 있는 것이다. 생성자와 비교했을 때 빌더 패턴의 또 한 가지 작은 장점은 빌더 객체는 여러 개의 varargs 인자를 받을 수 있다는 것이다. 또한 빌더 패턴은 유연하다. 하나의 빌더 객체로 여러 객체를 만들 수 있다.

빌더 패턴에도 단점은 있다. 객체를 생성하려면 우선 빌더 객체를 생성해야 하는데, 빌더 객체를 만드는 오버헤드가 문제가 될 소지는 없어 보이지만, 성능이 중요한 상황에선 그렇지 않을 수도 있다. 점층적 생성자 패턴보다 많은 코드를 요구하기 때문에 인자가 충분히 많은 상황(가령, 네 개 이상)에서 이용해야 한다.

#### **요약**
**빌더 패턴은 인자가 많은 생성자나 정적 팩터리가 필요한 클래스를 설계할 때, 특히 대부분의 인자가 선택적 인자인 상황에 유용하다.**

---

# 규칙 3. private 생성자나 enum 자료형은 싱글턴 패턴을 따르도록 설계하라
윈도우 매니저나 파일 시스템 같은 유일할 수밖에 없는 시스템 컴포넌트는 보통 싱글턴이다. **클래스를 싱글턴으로 만들면 클라이언트를 테스트하기가 어려워질 수가 있다.**

```java
// public final 필드를 이용한 싱글턴
public class Elvis {
  public static final Elvis INSTANCE = new Elvis();
  private Elvis() { ... }

  public void leaveTheBuilding() { ... }
}
```

private 생성자는 public static final 필드인 Elvis.INSTANCE를 초기화 할 때 한 번만 호출된다. 클라이언트가 주의해야 할 것은 AccessibleObject.setAccessible 메서드의 도움을 받아 리플렉션(reflection) 공격을 받을 수 있다. 이를 방어하고 싶다면, 두 번째 객체를 생성하라는 요청을 받으면 예외를 던지도록 생성자를 고쳐야 한다. 두 번째 방법은 public으로 선언된 정적 팩터리 메서드를 이용하는 것이다.

```java
// 정적 팩터리를 이용한 싱글턴
public class Elvis {
  private static final Elvis INSTANCE = new Elvis();
  private Elvis() { ... }
  public static Elvis getInstance() { return INSTANCE; }

  public void leaveTheBuilding() { ... }
}
```

Elvis.getInstance는 항상 같은 객체에 대한 참조를 반환한다. 이것 외의 Elvis 객체는 만들 수 없다. public 필드를 사용하면 클래스가 싱글턴인지는 선언만 보면 금방 알 수 있어서 좋다. public static final로 선언했으므로 항상 같은 객체를 참조하게 된다.

JDK 1.5부터는 싱글턴을 구현할 때 새로운 방법을 사용할 수 있다. 원소가 하나뿐인 enum 자료형을 정의하는 것이다.

```java
// Enum 싱글턴 - 이렇게 하는 쪽이 더 낫다
public enum Elvis {
  INSTANCE;

  public void leaveTheBuilding() { ... }
}
```

이 접근법은 기능적으로는 public 필드를 사용하는 구현법과 동등하지만, 좀 더 간결하다는 것과 직렬화가 자동으로 처리된다는 차이가 있다. 직렬화가 복잡하게 이루어져도 여러 객체가 생길 일이 없으며, 리플렉션을 통한 공격에도 안전하다. **원소가 하나뿐인 enum 자료형이야말로 싱글턴을 구현하는 가장 좋은 방법이다.**

---

# 규칙 4. 객체 생성을 막을 때는 private 생성자를 사용하라
정적 메서드나 필드만 모은 클래스를 만들고 싶을 때가 있다. java.lang.Math나 java.util.Arrays, java.utils.Collections 등이 그 좋은 예이다. 이런 유틸 클래스(utility class)들은 객체를 만들 목적의 클래스가 아니다. 생성자를 생략하면 컴파일러는 자동으로 인자 없는 public 기본 생성자(default constructor)를 만들어 버린다.

**객체를 만들 수 없도록 하려고 클래스를 abstract로 선언해 봤자 소용없다.** 기본 생성자는 클래스에 생성자가 없을 때 만들어지니까, **private 생성자를 클래스에 넣어서 객체 생성을 방지하자는 것이다.**

```java
// 객체를 만들 수 없는 유틸리티 클래스
public class UtilityClass {
  // 기본 생성자가 자동 생성되지 못하도록 하여 객체 생성 방지
  private UtilityClass {
    throws new AssertionError();
  }
  ... // 나머지는 생략
}
```

생성자를 명시적으로 정의했으나 호출할 수 없다는 사실이 썩 직관적이지는 않으니, 위에 보인 것처럼 주석을 달아 두는 것이 바람직하다.

또한, 이렇게 하면 하위 클래스도 만들 수 없다. 모든 생성자는 상위 클래스의 생성자를 명시적으로든 아니면 묵시적으로든 호출할 수 있어야 하는데, 호출 가능한 생성자가 상위 클래스에 없기 때문이다.

# 규칙 5. 불필요한 객체는 만들지 마라
기능적으로 동일한 객체는 필요할 때마다 만드는 것보다 재사용하는 편이 낫다.

```java
String s = new String("stringette");  // 이러면 곤란하다!
```

위의 문장은 실행될 때마다 String 객체를 만드는데, 쓸데없는 짓이다. String 생성자에 전달되는 \"stringette\"는 그 자체로 String 객체다. 생성자 호출로 만들어지는 모든 객체와 기능적으로 같다. 따라서 그냥 아래처럼 하는 것이 바람직하다.

```java
String s = "stringette";
```

생성자와 정적 팩터리 메서드를 함께 제공하는 변경 불가능 클래스의 경우, 생성자 대신 정적 팩터리 메서드를 이용하면 불필요한 객체 생성을 피할 수 있을 때가 많다. 예를 들어, Boolean(String)보다는 Boolean.valueOf(String) 쪽이 대체로 바람직하다. 생성자는 호출할 때마다 새 객체를 만들지만, 정적 팩터리 메서드는 그럴 필요도 없고 실제로 그러지도 않을 것이다.

```java
public class Person {
  private final Date birthDate;
  // 다른 필드와 메서드, 생성자는 생략

  // 이렇게 하면 안 된다!
  public boolean isBabyBoomer() {
    // 생성 비용이 높은 객체를 쓸데없이 생성한다
    Calendar gmtCal = Calendar.getInstance(TimeZone.getTimeZone("GMT"));
    gmtCal.set(1946, Calendar.JANUARY, 1, 0, 0, 0);
    Date boomStart = gmtCal.getTime();
    gmtCal.set(1965, Calendar.JANUARY, 1, 0, 0, 0);
    Date boomEnd = gmtCal.getTime();
    return birthDate.compareTo(boomStart) >= 0 && birthDate.compareTo(boomEnd) < 0;
  }
}
```

위에 보인 isBabyBoomer 메서드는 호출될 때마다 Calendar 객체 하나, TimeZone 객체 하나, 그리고 Date 객체 두 개를 쓸데없이 만들어 낸다. 이렇게 비효율적인 코드는 정적 초기화 블록(static initializer)를 통해 개선하는 것이 좋다.

```java
public class Person {
  private final Date birthDate;
  // 다른 필드와 메서드, 생성자는 생략

  /**
    * 베이비 붐 시대의 시작과 끝
    */
  private static final Date BOOM_START;
  private static final Date BOOM_END;

  static {
    Calendar gmtCal = Calendar.getInstance(TimeZone.getTimeZone("GMT"));
    gmtCal.set(1946, Calendar.JANUARY, 1, 0, 0, 0);
    BOOM_START = gmtCal.getTime();
    gmtCal.set(1965, Calendar.JANUARY, 1, 0, 0, 0);
    BOOM_END = gmtCal.getTime();
  }

  public boolean isBabyBoomer() {
    return birthDate.compareTo(BOOM_START) >= 0 && birthDate.compareTo(BOOM_END) < 0;
  }
}
```

이렇게 개선된 Person 클래스는 Calendar, TimeZone 그리고 Date 객체를 클래스가 초기화 될 때 한 번만 만든다. isBabyBoomer가 호출될 때마다 만들지 않는다. isBabyBoomer가 자주 호출되는 메서드였다면 성능은 크게 개선될 것이다. 만일 개선된 Person 클래스가 초기화된 다음에 isBabyBoomer 메서드가 한번도 호출되지 않는다면, BOOM_START와 BOOM_END 필드는 쓸데없이 초기화되었다고 봐야 할 것이다. 그런 상황은 초기화 지연(lazy initialization) 기법을 사용하면 피할 수 있다.

JDK 1.5부터는 쓸데없이 객체를 만들 새로운 방법이 더 생겼다. 자동 객체화(autoboxing)라는 것인데, 프로그래머들이 자바의 기본 자료형(primitive type)과 그 객체 표현형을 섞어 사용할 수 있도록 해 준다.

```java
// 무시무시할 정도로 느린 프로그램. 어디서 객체가 생성되는지 알겠는가?
public static void main(String[] args) {
  Long sum = 0L;
  for (long i = 0; i < Integer.MAX_VALUE; i++) {
    sum += i;
  }
  System.out.println(sum);
}
```

sum은 long이 아니라 Long으로 선언되어 있는데, 그 덕에 2^31개의 쓸데없는 객체가 만들어진다. 여기서 얻을 수 있는 명백한 교훈은, **객체 표현형 대신 기본 자료형을 사용하고, 생각지도 못한 자동 객체화가 발생하지 않도록 유의하라는 것이다.**

마찬가지로, 직접 관리하는 객체 풀(object pool)을 만들어 객체 생성을 피하는 기법은 객체 생성 비용이 극단적으로 높지 않다면 사용하지 않는 것이 좋다.

참고로 방어적 복사가 요구되는 상황에서 객체를 재사용하는 데 드는 비용은 쓸데없이 같읕 객체를 여러 벌 만드는 비용보다 훨씬 높다는 것에 유의하자.

# 규칙 6. 유효기간이 지난 객체 참조는 폐기하라

```java
// "메모리 누수(memory leak)"가 어디서 생기는지 보이는가?
public class Stack {
  private Object[] elements;
  private int size = 0;
  private static final int DEFAULT_INITIAL_CAPACITY = 16;

  public Stack() {
    elements = new Object[DEFAULT_INITIAL_CAPACITY];
  }

  public void push(Object e) {
    ensureCapacity();
    elements[size++] = e;
  }

  public Object pop() {
    if (size == 0)
      throw new EmptyStackException();
    return elements[--size];
  }

  /**
    * 적어도 하나 이상의 원소를 담을 공간을 보장한다.
    * 배열의 길이를 늘려야 할 때마다 대략 두 배씩 늘인다.
    */
  if (elements.length == size)
    elements = Arrays.copyOf(elements, 2 * size + 1);
}
```

메모리 누수는 스택이 커졌다가 줄어들면서 제거한 객체들을 쓰레드 수집기가 처리하지 못해서 생긴다. 스택을 사용하는 프로그램이 그 객체들을 더 이상 참조하지 않는데도 말이다. 스택이 그런 객체에 대한 만기 참조(obsolete reference)를 제거하지 않기 때문이다. 만기 참조란, 다시 이용되지 않을 참조(reference)를 말한다.

자동적으로 쓰레기 객체를 수집하는 언어에서 발생하는 메모리 누수 문제(널리 알려진 용어로는 의도치 않은 객체 보유(unintentional object retention라고 한다)는 찾아내기 어렵다. 실수로 객체 참조를 계속 유지하는 경우, 해당 객체만 쓰레기 수집에서 제외되는 것이 아니라 그 객체를 통해 참조되는 다른 객체들도 쓰레기 수집에서 제외된다.

이런 문제는 간단히 고칠 수 있다. 쓸 일 없는 객체 참조는 무조건 null로 만드는 것이다.

```java
public Object pop() {
  if (size == 0)
    throw new EmptyStackException();
  Object results = elements[--size];
  elements[size] = null;  // 만기  참조 제거
  return results;
}
```

만기 참조를 null로 만들면 나중에 실수로 그 참조를 사용하더라도 NullPointerException이 발생하기 때문에, 프로그램은 오작동하는 대신 바로 종료된다는 장점이 있다. **객체 참조를 null로 처리하는 것이 규범(norm)이라기보단 예외적인 조치가 되어야 한다.** 만기 참조를 제거하는 가장 좋은 방법은 해당 참조가 보관된 변수가 유효범위(scope)를 벗어나게 두는 것이다. 변수를 정의할 때 그 유효범위를 최대한 좁게 만들면 자연스럽게 해결된다.

일반적으로, **자체적으로 관리하는 메모리가 있는 클래스를 만들 때는 메모리 누수가 발생하지 않도록 주의해야 한다.** 더 이상 사용되지 않는 원소 안에 있는 객체 참조는 반드시 null로 바꿔 주어야 한다.

**캐시(cache)도 메모리 누수가 흔히 발생하는 장소다.** 객체 참조를 캐시 안에 넣어 놓고 잊어버리는 일이 많기 때문이다. 이를 해결하기 위해 첫 번째, WeakHashMap을 가지고 캐시를 구현하는 것이다. 캐시 바깥에서 키(key)를 참조하고 있을 때만 값(value)을 보관하면 될 때 쓸 수 있는 전략이다. 키에 대한 참조가 만기 참조가 되는 순간 캐시 안에 보관된 키-값 쌍은 자동으로 삭제되기 때문.

**메모리 누수가 흔히 발견되는 또 한 곳은 리스너(listener) 등의 역호출자(callback)다.** 쓰레기 수집기가 역호출자를 즉시 처리하도록 할 가장 좋은 방법은, 역호출자에 대한 약한 참조(weak reference)만 저장하는 것이다. WeakHashMap의 키로 저장하는 것이 그 예다.

# 규칙 7. 종료자 사용을 피하라
**종료자(finalizer)는 예측 불가능하며, 대체로 위험하고, 일반적으로 불필요하다.** 종료자의 한 가지 단점은, 즉시 실행되리라는 보장이 전혀 없다는 것이다. 어떤 객체에 대한 모든 참조가 사라지고 나서 종료자가 실행되기까지는 긴 시간이 걸릴 수도 있다. **따라서 긴급한(time-critical) 작업을 종료자 안에서 처리하면 안 된다.** 예를 들어, 종료자 안에서 파일을 닫도록 하면 치명적이다. 파일 기술자(file descriptor)는 유한한 자원이기 때문이다.

종료자의 더딘 실행(tardy finalization)은 단순히 이론적인 문제가 아니다. 클래스에 종료자를 붙여 넣으면, 드문 일이지만 객체 메모리 반환이 지연될 수도 있다.

지속성이 보장되어야 하는 **중요 상태 정보(critical persistent state)는 종료자로 갱신하면 안 된다.** 예를 들어 분산 시스템(distributed system) 전체를 먹통으로 만드는 가장 좋은 방법은, 데이터베이스 같은 공유 자원에 대한 지속성 락(persistent lock)을 종료자가 반환하게 구현하는 것이다.

그렇다면 파일이나 스레드 반환하거나 삭제해야 하는 자원을 포함하는 객체의 클래스는 어떻게 작성해야 하는 것일까? 그냥, **명시적인 종료 메서드(termination method)를 하나 정의** 하고, 더 이상 필요하지 않는 객체라면 클라이언트가 해당 메서드를 호출하도록 하라. 한 가지 명심할 것은, 종료 여부를 객체 안에 보관해야 한다는 것. 즉, 유효하지 않은 객체임을 표시하는 private 필드를 하나 두고, 모든 메서드 맨 앞에 해당 필드를 검사하는 코드를 두어, 이미 종료된 객체에 메서드를 호출하면 IllegalStateException이 던져지도록 해야 한다는 것이다.

**이런 명시적 종료 메서드는 보통 try-finally 문과 함께 쓰인다. 객체 종료를 보장하기 위해서다.** 명시적 종료 메서드를 finally 문 안에서 호출하도록 해놓으면 객체 사용 과정에서 예외가 던져져도 종료 메서드가 실행되도록 만들 수 있다.

```java
// try-finally 블록을 통해 종료 메서드 실행 보장
Foo foo = new Foo(...);
try {
  // foo로 해야 하는 작업 수행
  ...
} finally {
  foo.terminate();  // 명시적 종료 메서드 호출
}
```

종료자가 적합한 곳은 첫째, 명시적 종료 메서드 호출을 잊을 경우에 대비하는 안전망(safety net)으로서의 역할이다. 하지만 **종료자는 그런 자원을 발견하게 될 경우 반드시 경고 메시지를 로그(log)로 남겨야 한다.** 둘째, 네이티브 피어(native peer)와 연결된 객체를 다룰 때다. 네이티브 피어는 일반 자바 객체가 네이티브 메서드(native method)를 통해 기능 수행을 위임하는 네이티브 객체를 말한다.

#### **요약**
자원 반환에 대한 최종적 안전장치를 구현하거나, 그다지 중요하지 않은 네이티브 자원을 종료시키려는 것이 아니라면 종료자는 사용하지 말라. 굳이 종료자를 사용해야 하는 드문 상황에 처했다면 super.finalize 호출은 잊지 말자. 자원 반환 안전망을 구현하는 경우에는 종료자가 호출될 때마다 클라이언트 코드가 잘못 작성되었음을 알리는 메시지를 로그로 남기자. 마지막으로, 하위 클래스가 정의가 가능한 public 클래스에 종료자를 추가해야 하는 상황이라면, 하위 클래스에서 실수로 super.finalize 호출을 잊어도 종료 작업이 수행될 수 있도록 종료 보호자 패턴을 도입하면 좋을지 고려해보자.

# Reference
- [Effective Java 2/E](http://www.insightbook.co.kr/%EB%8F%84%EC%84%9C-%EB%AA%A9%EB%A1%9D/programming-insight/%EC%9D%B4%ED%8E%99%ED%8B%B0%EB%B8%8C-%EC%9E%90%EB%B0%94effective-java-2e)
