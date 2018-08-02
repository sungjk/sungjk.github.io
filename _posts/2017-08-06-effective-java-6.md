---
layout: entry
post-category: java
title: Effective Java(6)
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java의 7장(메서드)을 정리한 글입니다.
next_url: /2017/08/06/effective-java-7.html
publish: true
---

# 규칙 38. 인자의 유효성을 검사하라
메서드에 잘못된(invalid) 인자가 전달되어도, 메서드 앞부분에서 인자 유효성을 검사하도록 하면 적절한 예외를 통해 깔끔하고 신속하게 오류를 검출 할 수 있으나, 인자 유효성을 검사하지 않으면 몇 가지 문제가 생길 수 있다. 첫 번째는 처리 도중에 이상한 예외를 내면서 죽어버리는 것이고, 두 번쨰는 실행이 제대로 되는 것 같기는 한데 잘못된 결과가 나오는 것이다. 최고로 심각한 유형의 문제는, 메서드가 정상적으로 반환값을 내기는 하지만 어떤 객체의 상태가 비정상적으로 바뀌는 경우다.

public이 아닌 메서드는 일반적으로 인자 유효성을 검사할 때 확증문(assertion)을 이용한다.

```java
// 재귀적으로 정렬하는 private 도움 함수
private static void sort(long a[], int offset, int length) {
  assert a != null;
  assert offset >= 0 && offset <= a.length;
  assert length >= 0 && length <= a.length - offset;
  ...
}
```

통상적인 유효성 검사와 달리, 확증문은 확증 조건이 만족되지 않으면 AssertionError를 낸다.

호출된 메서드에서 바로 이용하진 않지만 나중을 위해 보관되는 인자의 유효성을 검사하는 것은 특히 중요하다.

생성자(constructor)는 나중을 위해 보관될 인자의 유효성을 반드시 검사해야 한다는 원칙의 특별한 경우에 해당한다. 클래스 불변식(invariant)을 위반하는 객체가 만들어지는 것을 막으려면, 생성자에 전달되는 인자의 유효성을 반드시 검사해야 한다.

메서드가 실제 계산을 수행하기 전에 그 인자를 반드시 검사해야 한다는 원칙에도 예외는 있다. 유효성 검사를 실행하는 오버헤드가 너무 크거나 비현실적이고, 계산 과정에서 유효성 검사가 자연스럽게 이루어지는 경우다. Colections.sort(List)처럼 객체 리스트를 정렬 전에 모든 객체가 서로 비교 가능한지 검사하는 것은 의미가 없다. 하지만 주의할 것은, 이런 형태의 암묵적인 유효성 검사 방법에 지나치게 기대다 보면, 실패 원자성(failure atomicity)을 잃게 된다는 점이다(규칙 64).

메서드는 가능하면 일반적으로 적용될 수 있도록 설계해야 한다. 메서드가 받을 수 있는 인자에 제약이 적으면 적을수록 더 좋다. 인자로 받을 수 있는 모든 값에 대해서 뭔가 적절한 동작을 수행할 수 있다면 말이다.

### 요약
메서드나 생성자를 구현할 때는 받을 수 있는 인자에 제한이 있는지 따져봐야 한다. 제한이 있다면 그 사실을 문서에 남기고, 메서드 앞부분에서 검사하도록 해야 한다.

---

# 규칙 39. 필요하다면 방어적 복사본을 만들라
**클래스의 클라이언트가 불변식(invariant)을 망가뜨리기 위해 최선을 다할 것이라는 가정하에, 방어적으로 프로그래밍해야 한다.**

어떤 객체의 내부 상태를 그 객체의 도움 없이 변경하는 것은 불가능하다. 하지만 외부 클래스가 객체 상태를 마음대로 변경할 수 있는 실수를 저지르는 것도 놀랄 만큼 쉽다. 예를 들어, 아래의 클래스는 기간(time period)을 나타내는 객체에 대한 변경 불가능 클래스다.

```java
// 변경 불가능이 보장되지 않는 변경 불가능 클래스(!)
public final class Period {
  private final Date start;
  private final Date end;

  public Period(Date start, Date end) {
    if (start.compareTo(end) > 0)
      throw new IllegalArgumentExceptiuon(start + " after " + end);
    this.start = start;
    this.end = end;
  }

  public Date start() {
    return start;
  }

  public Date end() {
    return end;
  }

  ...
}
```

얼핏 변경이 불가능한 것으로 보이고, 기간 시작점이 기간 끝점 이후일 수 없다는 불변식도 만족되는 것처럼 보인다. 하지만 Date가 변경 가능 클래스라는 점은 이용하면 불변식을 깨뜨릴 수 있다.

```java
// Period 객체의 내부 구조를 공격
Date start = new Date();
Date end = new Date();
Period p = new Period(start, end);
end.setYear(78);  // p 의 내부를 변경
```

따라서 Period 객체의 내부를 보호하려면 **생성자로 전달되는 변경 가능 객체를 반드시 방어적으로 복사**해서 그 복사본을 Period 객체의 컴포넌트로 이용해야 한다.

```java
// 수정된 생성자 - 인자를 방어적으로 복사함
public Period(Date start, Date end) {
  this.start = new Date(start.getTime());
  this.end = new Date(end.getTime());

  if (this.start.compareTo(this.end) > 0)
    throw new IllegalArgumentExceptiuon(this.start + " after " + this.end);
}
```

이 생성자를 쓰면 앞서 살펴본 공격법은 먹히지 않게 된다. **인자의 유효성을 검사하기 전에(규칙 38) 방어적 복사본을 만들었다는 것에 유의하자. 유효성 검사는 복사본에 대해서 시행한다.**

방어적 복사본을 만들 때 Date의 clone 메서드를 이용하지 않았다는 것도 주의하자. Date 클래스는 final 클래스가 아니므로, clone 메서드가 반드시 java.util.Date 객체를 반환할 거라는 보장이 없다. 공격을 위해 특별히 설계된 하위 클래스 객체가 반환될 수 있다는 것. 그런 하위 클래스는 새로 만들어진 객체에 대한 참조를 private static 리스트에 안에 넣어서 공격자가 참조할 수 있게 할 수도 있다. 이런 공격을 막으려면 **인자로 전달된 객체의 자료형이 제3자가 계승할 수 있는 자료형일 경우, 방어적 복사본을 만들 때 clone을 사용하지 않도록 해야 한다.**

그런데 위의 생성자를 사용하면 생성자 이자를 통한 공격은 막을 수 있으나 접근자를 통한 공격은 막을 수 없다. 접근자를 호출하여 얻은 객체를 통해 Period 객체 내부를 변경할 수 있기 때문.

```java
// Period 객체 내부를 노린 두 번째 공격 형태
Date start = new Date();
Date end = new Date();
Period p = new Period(start, end);
p.end().setYear(78);	// p의 내부를 변경
```

이런 공격을 막으려면 **변경 가능 내부 필드에 대한 방어적 복사본을 반환하도록** 접근자를 수정해야 한다.

```java
// 수정된 접근자 - 내부 필드의 방어적 복사본 생성
public Date start() {
  return new Date(start.getTime());
}

public Date end()  {
  return new Date(end.getTime());
}
```

생성자와 접근자를 이렇게 수정하고 나면 Period는 진정한 변경 불가능 클래스가 된다. Period 이외의 클래스가 Period 객체 내부의 변경 가능 필드에 접근할 수 없기 때문. 객체 안에 확실히 캡슐화된 필드가 된 것이다.

방어적 복사는 변경 불가능 클래스에만 쓰이는 기법이 아니다. 클라이언트가 제공한 객체를 내부 자료 구조에 반영하는 생성자가 메서드에 사용 가능하다.

클라이언트에게 내부 컴포넌를 반환(return)하기 위해 방어적 복사본을 만드는 경우에도 같은 원칙이 적용되나. 이제 만드는 클래스가 변경 가능이건 불가능이건 간에, 변경 가능한 내부 컴포넌트에 대한 참조를 반환하기 전에는 한 번 더 생각해야 한다.

객체의 컴포넌트로는 가능하다면 변경 불가능 객체를 사용해야 한다는 것이다. 그래야 방어적 복사본에 대해서는 신경 쓸 필요가 없었기 때문이다.

### 요약
- 컴포넌트로부터 구했거나 클라이언트를 반드시 방어적으로 복사해야 한다. 해당 클래스는 그 컴포넌트를 반드시 방어적으로 복사해야 한다. 복사 오버헤드가 너무 크고 클래스가 그 내부 컴포넌트를 반드시 방어적으로 복사해야 한다.

---

# 규칙 40. 메서드 시그니처는 신중하게 설계하라
**메서드 이름은 신중하게 고르라.** 최우선 목표는 이해하기 쉬우면서도 같은 패키지 안의 다른 이름들과 일관성이 유지되는 이름을 고르는 것이다. 두 번째 목표는, 좀 더 널리 합의된 사항에도 부합하는 이름을 고르는 것이다.

**편의 메서드(convenience method)를 제공하는 데 너무 열 올리지 마라.** 모든 메서드는 \"맡은 일이 명확하고 거기 충실해야(pull its weight)\" 한다. 클래스에 메서드가 너무 많으면 학습, 사용, 테스트, 유지보수 등의 모든 측면에서 어렵다. 인터페이스의 경우에는 메서드가 많으면 문제가 두 배는 더 심각하다. 클래스나 인터페이스가 수행해야 하는 동작 각각에 대해서 기능적으로 완전한 메서드를 제공하라. \"단축(shorthand)\" 메서드는 자주 쓰일 때만 추가하라. **그럴지 잘 모르겠다면, 빼버려라.**

**인자 리스트(parameter list)를 길게 만들지 마라.** 4개 이하가 되도록 애쓰라. **자료형이 같은 인자들이 길게 연결된 인자 리스트는 특히 더 위험하다.** 사용자가 인자 순서를 착각할 수 있을 뿐더러, 실수로 인자 순서를 바꾸더라도 프로그램은 여전히 컴파일되고 실행될 것이기 때문이다.

긴 인자 리스트를 짧게 줄이는 방법은 세 가지다. 하나는 여러 메서드로 나누는 것이다. 예를 들어, java.util.List 인터페이스의 경우, 부분 리스트(sublist)의 시작 첨자와 끝 첨자를 알아내는 메서드는 제공하지 않는다. 그런 메서드는 세 개의 인자를 요구할 것이다. 대신 List 인터페이스는 subList라는 메서드를 제공하는데, 두 개의 인자를 받아서 부분 리스트의 뷰(view)를 반환한다. 이 메서드를 indexOf()나 lastIndexOf 메서드와 함꼐 사용하면 원하는 기능을 구현할 수 있다.

두 번째 방법은 도움 클래스(helper class)를 만들어 인자들을 그룹별로 나누는 것이다. 보통 이 도움 클래스들은 static 멤버 클래스다(규칙 22). 이 기법은 자주 등장하는 일련의 인자들이 어떤 별도 개체(entity)를 나타낼 때 쓰면 좋다. 예를 들어 카드 게임 기능을 클래스로 구현할 때, 카드의 숫자(rank)와 모양(suit)을 인자로 받는 메서드를 만든다고 하자. 한 장의 카드를 나타내는 도움 클래스를 만들어서 그 클래스를 메서드의 인자 자료형으로 사용하면 API 뿐만 아니라 클래스 내부 구조도 좋아질 것이다.

세 번째 방법은 앞 두 방법을 결합한 것으로, 빌더 패턴(builder pattern)을 고쳐서 객체 생성 대신 메서드 호출에 적용하는 것이다(규칙 2). 많은 인자가 필요한 메서드를 만들어야 한다면, 그리고 그 인자들 가운데 상당수는 옵션이라면, 모든 인자를 표현하는 객체 하나를 정의하고 그 객체의 \"수정자(setter)\" 메서드를 클라이언트가 여러 번 호출할 수 있도록 하면 좋다. 일단 원하는 대로 인자가 설정되고 나면 클라이언트는 해당 객체의 \"execute\" 메서드를 호출하여 최종적인 유효성 검사를 실행한 뒤 실제 계산을 진행한다.

**인자의 자료형으로는 클래스보다 인터페이스가 좋다**(규칙 52). 인자를 정의하기에 적합한 인터페이스가 있다면, 인터페이스를 구현하는 클래스 대신에 그 인터페이슬르 인자 자료형으로 쓰자. 예를 들어, HashMap을 인자 자료형으로 사용하는 메서드를 만들 이유는 없다는 것이다. Map을 사용하면 된다. 그렇게 하면 해당 메서드는 Hashtable을 인자로 받을 수도 있고, HashMap이나 TreeMap, TreeMap의 하위 자료형, 그리고 심지어는 아직 만들어지지도 않은 모든 Map 하위 클래스 객체를 인자로 받을 수 있게 된다. 인터페이스 대신에 클래스를 사용하면 클라이언트는 특정한 구현에 종속된다.

**인자 자료형으로 boolean을 쓰는 것보다는, 원소가 2개인 enum 자료형을 쓰는 것이 낫다.** 예를 들어, Thermometer 자료형 아래 enum 자료형의 값을 인자로 취하는 정적 팩터리 메서드가 있다고 하자. 이 enum 상수 각각은 온도 단위다.

```java
publid enum TemperatureScale { FAHRENHEIT, CELSIUS }
```

Thermometer.newInstance(TemperatureScale.CELSIUS) 쪽이 Thermometer.newInstance(true)보다는 무슨 뜻인지 알기 쉽다. 게다가, 나중에 Thermometer 클래스에 새로운 정적 팩터리 메서드를 추가하지 않고도 KELVIN이라는 새로운 온도 단위를 TemperatureScale에 추가할 수 있다. 게다가, 각각의 단위에 고유한 로직은 enum 상수의 메서드에 리팩터링해 넣을 수도 있다(규칙 30).

---

# 규칙 41. 오버로딩할 때는 주의하라
아래 프로그램의 목적은 컬렉션을 종류별로 분류하는 것이다.

```java
// 잘못된 프로그램
public class CollectionClassifier {
  public static String classify(Set<?> s) {
    return "Set";
  }

  public static String classify(List<?> lst) {
    return "List"''
  }

  public static void main(String[] args) {
    Collection<?>[] collections = {
      new HashSet<String>(),
      new ArrayList<BigInteger>(),
      new HashMap<String, String>().values()
    };

    for (Collection<?> c : collections)
      System.out.println(classify(c));
  }
}
```

이 프로그램은 Set, List, Unknown Collection을 순서대로 출력하지 않는다. Unknown Collection을 세 번 출력할 뿐이다. 왜일까? classify 메서드가 *오버로딩*되어 있으며, **오버로딩된 메서드 가운데 어떤 것이 호출될지는 컴파일 시점에 결정되기 때문이다.** 루프가 세 번 도는 동안, 인자의 컴파일 시점 자료형(compile-time type)은 전부 Collection\<?\>으로 동일하다. 각 인자의 실행시점 자료형(runtime type)은 전부 다르지만, 선택 과정에는 영향을 끼치지 못한다. 인자의 컴파일 시점 자료형이 Collection\<?\>이므로, 호출되는 것은 항상 classify\<Collection\<?\>\> 메서드다.

**오버로딩된 메서드는 정적(static)으로 선택되지만, 재정의된 메서드는 동적(dynamic)으로 선택되기 때문이다.** *재정의된*(overriden) 메서드의 경우, 선택 기준은 메서드 호출 대상 객체의 자료형이다. 객체 자료형에 따라 실행 도중에 결정되는 것이다. 그렇다면 재정의된 메서드란 무엇인가? 상위 클래스에 선언된 메서드와 같은 시그니처를 갖는 하위클래스 메서드가 재정의된 메서드다.

```java
class Wine {
  String name() { return "wine"; }
}

class SparklingWine extends Wine {
  @Override String name() { return "sparking wine"; }
}

class Champagne extends SparklingWine {
  @Override String name() { return "champagne"; }
}

public class Overriding {
  public static void main(String[] args) {
    Wine[] wines = {
      new Wine(), new SparklingWine(), new Champagne()
    };
    for (Wine wine : wines)
      System.out.println(wine.name());
  }
}
```

위 프로그램은 wine, sparking wine, champagne을 순서대로 출력한다. 재정의 메서드 가운데 하나를 선택할 때 객체의 컴파일 시점 자료형은 영향을 주지 못한다. 오버로딩에서는 반대로 실행시점 자료형이 아무 영향도 주지 못한다. 실행될 메서드는 컴파일 시에, 인자의 컴파일 시점 자료형만을 근거로 결정된다.

재정의(Overriding)가 일반적 규범(norm)이라면 오버로딩은 예외에 해당하므로, 메서드 재정의는 메서드 호출이 어떻게 처리되어야 한다는 예측에 부합한다. 오버로딩된 메서드 가운데 어떤 것이 주어진 인자들을 처리할지 알기 어려운 API라면, API 사용 과정에서 오류가 생길 가능성은 높다. 따라서 **오버로딩을 사용할 때는 혼란스럽지 않게 사용할 수 있도록 주의해야 한다.**

그렇다면 \"오버로딩이 혼란스러운 상황\"은 정확히 어떤 것인가? **혼란을 피하는 안전하고 보수적인 전략은, 같은 수의 인자를 갖는 두 개의 오버로딩 메서드를 API에 포함시키지 않는 것이다.**

예를 들어, ObjectOutputStream 클래스에는 모든 기본 자료형들을 비롯, 몇 가지 참조 자료형에 대한 write 메서드들이 정의되어 있다. 그런데 이 메서드들은 write 메서드를 재정의하는 대신 writeBoolean(boolean), writeInt(int), writeLong(long) 같이 정의되어 있다. 이런 작명 패턴을 따르면 오버로딩에 비해, 각 메서드에 대응되는 read 메서드를 정의할 수 있게 된다(readBoolean(), readInt(), readLong()).

하지만 생성자에는 다른 이름을 사용할 수 없다. 생성자가 많다면, 그 생성자들은 *항상* 오버로딩된다. 그게 문제라면 생성자 대신 정적 팩터리 메서드를 사용하는 옵션을 사용할 수도 있다(규칙 1). 또한 생성자의 경우라면 오버로딩과 재정의 메커니즘의 상호작용에 관해서는 신경 쓸 필요가 없는데, 생성자는 재정의될 수 없기 때문이다.

같은 수의 인자를 받는 오버로딩 메서드가 많더라도, 어떤 오버로딩 메서드가 주어진 인자 집합을 처리할 것인지가 분명히 결정된다면 프로그래머는 혼란을 겪지 않을 것이다. 그 조건은, 두 개의 오버로딩 메서드를 비교했을 때 그 형식 인자 가운데 적어도 하나가 \"확실히 다르다(radically different)\"면 만족된다. 그렇다면 \"확실히 다르다\"는 것은 무엇인가? 두 자료형을 서로 형변환(cast) 할 수 없다면 확실히 다른 것이다. 이 조건이 충족되면 주어진 인자 집합에 오버로딩을 적용했을 때 인자의 실행시점 자료형에 따라 오버로딩 메서드가 결정될 수 있으며 컴파일 시점 자료형에 구애되지 않으므로, 혼란을 빚는 주요한 원인이 사라지게 된다.

### 요약
- 메서드를 오버로딩할 수 있다고 해서 반드시 그래야 하는 것은 아니다.
- 인자 개수가 같은 오버로딩 메서드를 추가하는 것은 일반적으로 피해야 한다(생성자는 예외).

---

# 규칙 42. varargs는 신중히 사용하라
자바 1.5부터는 공식적으로 *가변 인자 메서드*(variable arity method)라고 부르는 varargs 메서드가 추가되었다. 클라이언트에서 전달한 인자 수에 맞는 배열이 자동 생성되고, 모든 인자가 해당 배열에 대입된다. 그리고 마지막으로 해당 배열이 메서드에 인자로 전달된다.

예를 들어, int 인자들을 받아서 그 합을 반환하는 varargs 메서드다. sum(1, 2, 3)을 호출하면 6이 반환되고, sum()을 호출하면 0이 반환된다.

```java
// varargs의 간단한 사용 예
static int sum(int... args) {
  int sum = 0;
  for (int arg : args)
    sum += arg;
  return sum;
}
```

그런데 때로는 0 이상이 아니라, 하나 이상의 인자가 필요할 때가 있다. 예를 들어, 주어진 int 인자 가운데 최소치를 구해야 한다면, 실행시점에 배열 길이를 검사해야만 한다.

```java
// 하나 이상의 인자를 받아야 하는 varargs 메서드를 잘못 구현한 사례
static int min(int... args) {
  if (args.length == 0)
    throw new IllegalArgumentExceptiuon("Two few arguments");
  int min = args[0];
  for (int i = 1; i < args.length; i++)
    if (args[i] < min)
      min = args[i];
  return min;
}
```

이 방법은 클라이언트가 인자 없이 메서드를 호출하는 것이 가능할 뿐만 아니라, 컴파일 시점이 아닌 실행 도중에 오류가 난다는 것이다.

이보다 더 좋은 방법은 메서드가 인자를 두 개 받도록 선언하는 것이다. 하나는 지정된 자료형을 갖는 일반 인자고, 다른 하나는 같은 자료형의 varargs 인자다.

```java
// 하나 이상의 인자를 받는 varargs 메서드를 제대로 구현한 사례
static int min(int firstArgs, int... remainingArgs) {
  int min = firstArgs;
  for (int arg : remainingArgs)
    if (arg < min)
      min = arg;
  return min;
}
```

이 예제로 알 수 있듯, varargs는 임의 개수의 인자를 처리하는 메서드를 만들어야 할 때 효과적이다.

**마지막 인자가 배열이라고 해서 무조건 뜯어고칠 생각은 버려라. varargs는 정말로 임의 개수의 인자를 처리할 수 있는 메서드를 만들어야 할 때만 사용하라.**

성능이 중요한 환경이라면 varargs 사용에 더욱 신중해야 한다. varargs 메서드를 호출할 때마다 배열이 만들어지고 초기화되기 때문.

### 요약
- varargs 메서드는 인자 개수가 가변적인 메서드를 정의할 때 편리하지만, 남용되면 곤란하다.

---

# 규칙 43. null 대신 빈 배열이나 컬렉션을 반환하라
아래와 같은 메서드는 어렵지 않게 만날 수 있다.

```java
private final List<Cheese> cheesesInStock = ...;

public Cheese[] getCheese() {
  if (cheesesInStock.size() == 0)
    return null;
  ...
}
```

클라이언트 입장에서는 아래와 같이 null이 반환될 때를 대비한 코드를 만들어야 한다.

```java
Cheese[] cheese = shop.getCheese();
if (cheese != null &&
    Arrays.asList(cheese).contains(Cheese.STILTON))
  System.out.println("Jolly good, just the thing.");
```

null이 반환되지 않는다면 아래와 같이 할 수 있다.

```java
if (Arrays.asList(shop.getCheese()).contains(Cheese.STILTON))
  System.out.println("Jolly good, just the thing.")
```

빈 배열이나 컬렉션을 반환하는 대신 null을 반환하는 메서드는 오류를 쉽게 유발한다. 클라이언트가 null 처리를 잊어버릴 수 있기 때문.

배열 할당 비용을 피할 수 있으니 null을 반환해야 바람직한 것 아니냐는 주장도 있을 수 있으나, 이 주장은 두 가지 측면에서 틀렸다. 프로파일링(profiling) 결과로 해당 메서드가 성능 저하의 주범이라는 것이 밝혀지지 않는 한, 그런 수준까지 성능 걱정을 하는 것은 바람직하지 않다(규칙 55). 두 번째는 길이가 0인 배열은 변경이 불가능(immutable)하므로 아무 제약없이 재사용할 수 있다(규칙 15).

```java
// 컬렉션에서 배열을 만들어 반환하는 올바른 방법
private final List<Cheese> cheesesInStock = ...;

private static final Cheese[] EMPTY_CHEESE_ARRAY = new Cheese[0];

public Cheese[] getCheese() {
  return cheesesInStock.toArray(EMPTY_CHEESE_ARRAY);
}
```

보통 toArray는 반환되는 원소가 담길 배열을 스스로 할당하는데, 컬렉션이 비어 있는 경우에는 인자로 주어진 빈 배열을 쓴다. 그리고 Collection.toArray(T\[\])의 명세를 보면, 인자로 주어진 배열이 컬렉션의 모든 원소를 담을 정도로 큰 경우에는 해당 배열을 반환값으로 사용한다고 되어 있다. 따라서 위의 숙어대로 하면 빈 배열은 절대로 자동 할당되지 않는다.

마찬가지로 컬렉션을 반환하는 메서드도 빈 컬렉션을 반환해야 할 때마다 동일한 변경 불가능 빈 컬렉션 객체를 반환하도록 구현할 수 있다. Collections.emptySet, emptyList, emptyMap 메서드가 그런 용도로 사용된다.

```java
// 컬렉션 복사본을 반환하는 올바른 방법
public List<Cheese> getCheeseList() {
  if (cheesesInStock.isEmpty())
    return Collections.emptyList(); // 언제나 같은 리스트 반환
  else
    return new ArrayList<Cheese>(cheesesInStock);
}
```

### 요약
**null 대신 빈 배열이나 빈 컬렉션을 반환하라.**

---

# 규칙 44. 모든 API 요소에 문서화 주석을 달라
**좋은 API 문서를 만들려면 API에 포함된 모든 클래스, 인터페이스, 생성자, 메서드, 그리고 필드 선언에 문서화 주석을 달아야 한다.** 직렬화(serialization)가 가능한 클래스라면 직렬화 형식도 밝혀야 한다(규칙 75). 유지보수가 쉬운 코드를 만들려면 API가 아닌 클래스나 인터페이스, 생성자, 메서드, 필드에 대해서도 문서화 주석을 남겨야 한다.

메서드에 대한 문서화 주석은 메서드와 클라이언트 사이의 규약(contract)을 간명하게 설명해야 한다. 계승을 위해 설계된 메서드가 아니라면(규칙 17) 메서드가 *무엇을* 하는지를 설명해야지 메서드가 *어떻게* 그 일을 하는지를 설명해서는 안 된다. 그리고 해당 메서드의 모든 *선행조건*(precondition)과 *후행조건*(postcondition)을 나열해야 한다.

선행조건과 후행조건 외에도, 메서드는 부작용(side effect)에 대해서도 문서화 해야 한다. 부작용은, 후행조건을 만족하기 위해 필요한 것이 아닌, 시스템의 관측 가능한 상태 변화를 일컫는다. 마지막으로 규칙 70에 설명한 대로, 클래스나 메서드의 스레드 안전성(thread safety)에 대해서도 문서에 남겨야 한다.

모든 문서화 주석의 첫 번째 \"문장\"은, 해당 주석에 담긴 내용을 *요약*한 것이다(summary description). 엄밀히 따지자면 문서화 주석의 요약문은 첫 번째 \"문장(sentence)\"일 필요는 없다. 완벽한 문장일 필요가 없다는 것이다. 메서드나 생성자의 경우, 요약문은 메서드가 무슨 일을 하는지 기술하는 (객체를 포함하는) 완전한 동사구(verb phrase)여야 한다. 다음은 자바 플랫폼 메서드들의 요약문이다.

- ArrayList(int initialCapacity): Constructs an empty list with the specified initial capacity.
- Collection.size(): Returns the number of elements in this collection.

클래스와 인터페이스의 요약문은 해당 클래스나 인터페이스로 만들어진 객체가 무엇을 나타내는지를 표현하는 명사구여야 한다. 필드의 요약문은 필드가 나타내는 것이 무엇인지를 설명하는 명사구여야 한다.

- TimerTask: A task that can be scheduled for one-time or repeated execution by a Timer.
- Math.PI: The double value that is closer than any other to pi, the ratio of the circumference of circle to its diameter.

제네릭, enum 그리고 어노테이션의 세 가지 기능에 대해서는 문서화 주석을 만들 때 특별히 주의해야 한다. **제네릭 자료형이나 메서드에 주석을 달 때는 모든 자료형 인자들을 설명해야 한다.**

```java
/**
 * An object that maps keys to values. A map cannot contain
 * duplicate keys; each key can map to at most one value.
 * ...
 * @param <K> the type of keys maintained by this map
 * @param <V> the type of mapped values
 */
public interface Map<K, V> {
  ...
}
```

**enum 자료형에 주석을 달 때는** 자료형이나 public 메서드뿐 아니라 **상수 각각에도 주석을 달아 주어야 한다.**

```java
/**
 * 교향악단에서 쓰이는 악기 종류.
 */
public enum OrchestraSection {
  /** 플루트, 클라리넷, 오보에 같은 목관악기. **/
  WOODWIND,

  /** 프렌치 혼이나 트럼펫 같은 금관악기. **/
  BRASS,

  /** 팀파니나 심벌즈 같은 타악기. **/
  PERCUSSION,

  /** 바이올린이나 첼로 같은 현악기. **/
  STRING;
}
```

**어노테이션 자료형에 주석을 달 때는** 자료형뿐 아니라 **모든 멤버에도 주석을 달아야 한다.** 멤버에는 마치 필드인 것처럼 명사구 주석을 달라. 자료형 요약문에는 동사구를 써서, 언제 이 자료형을 어노테이션으로 붙여야 하는지 설명하라.

```java
/**
 * 지정된 예외를 반드시 발생시켜야 하는 테스트 메서드임을 명시.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface ExceptionTest {
  /**
    * 어노테이션이 붙은 테스트 메서드가 테스트를 통과하기 위해
    * 반드시 발생시켜야 하는 예외. (이 Class 객체가 나타내는 자료형의
    * 하위 자료형이기만 하면 어떤 예외든 상관없다.)
    */
  Class<? extends Throwable> value();
}
```

문서화 주석에 관해서, 마지막으로 한 가지 주의사항만 더 살펴보자. 모든 공개 API 요소에는 문서화 주을 달 필요가 있지만, 항상 그 정도면 충분하진 않다. 관련된 클래스가 많아서 복잡한 API의 경우, API의 전반적인 구조를 설명하는 별도 문서(external document)가 필요한 경우가 많다.

### 요약
- 문서화 주석은 API 문서를 만드는 가장 효과적인 방법이다.

---

# Reference
- [Effective Java 2/E](http://www.insightbook.co.kr/%EB%8F%84%EC%84%9C-%EB%AA%A9%EB%A1%9D/programming-insight/%EC%9D%B4%ED%8E%99%ED%8B%B0%EB%B8%8C-%EC%9E%90%EB%B0%94effective-java-2e)
