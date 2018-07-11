---
layout: entry
post-category: java
title: Effective Java(4-2)
author: 김성중
author-email: ajax0615@gmail.com
description: Effective Java의 5장(제네릭)을 정리한 글입니다.
next_url: /2017/08/06/effective-java-5.html
publish: true
---

# 규칙 25. 배열 대신 리스트를 써라
배열은 제네릭 자료형과 두 가지 중요한 차이점을 갖고 있다. 첫 번째는, 배열은 공변 자료형(covariant)이라는 것이다. Sub가 Super의 하위 자료형(subtype)이라면 Sub[]도 Super[]의 하위 자료형이라는 것이다. 반면 제네릭은 불변 자료형(invariant)이다. Type1과 Type2가 있을 때, List\<Type1\>은 List\<Type2\>의 상위 자료형이나 하위 자료형이 될 수 없다. 그렇다면 제네릭 쪽이 배열보다 취약한 것이 아니냐는 논쟁의 여지가 있지만, 취약한 것은 배열 쪽이다.

```
// 실행 중에 문제를 일으킴
Object[] objectArray = new Long[1];
objectArray[0] = "I don't fit in";  // ArrayStoreException 예외 발생

// 컴파일 되지 않는 코드
List<Object> ol = new ArrayList<Long>(); // 자료형 불일치
ol.add("I don't fit in");
```

둘 중 어떤 방법을 써도 Long 객체 컨테이너(container) 안에 String 객체를 넣을 수는 없다. 그러나 배열을 쓰면 실수를 저지른 사실을 프로그램 실행 중에나 알 수 있다. 반면 리스트(list)를 사용하면 컴파일할 때 알 수 있다.

배열과 제네릭의 두 번째 중요한 차이는, 배열은 실체화(reification) 되는 자료형이라는 것이다. 즉, 배열의 각 원소의 자료형은 실행시간(runtime)에 결정된다는 것이다. 위의 예제에서 보았듯이, String 객체를 Long 배열에 넣으려고 하면 ArrayStoreException이 발생한다. 반면 제네릭은 삭제(erasure) 과정을 통해 구현된다. 즉, 자료형에 관계된 조건들은 컴파일 시점에만 적용되고, 그 각 원소의 자료형 정보는 프로그램이 실행될 때는 삭제된다는 것이다. 자료형 삭제(erasure) 덕에, 제네릭 자료형은 제네릭을 사용하지 않고 작성된 오래된 코드와도 문제없이 연동한다(규칙 23).

이런 기본적인 차이점 때문에 배열과 제네릭은 섞어 쓰기 어렵다. 예를 들어, 제네릭 자료형이나 형인자 자료형, 또는 형인자의 배열을 생성하는 것은 문법적으로 허용되지 않는다. 즉, new List\<E\>[], new List\<String\>[], new E[]는 전부 컴파일되지 않는다.

제네릭 배열 생성은 왜 허용되지 않을까? 형 안전성(typesafe)이 보장되지 않기 때문이다.

```
// 제네릭 배열 생성이 허용되지 않는 이유 - 아래의 코드는 컴파일되지 않는다!
List<String>[] stringLists = new List<String>[1];   // (1)
List<Integer> intList = Arrays.asList(42);          // (2)
Object[] objects = stringLists;                     // (3)
objects[0] = intList;                               // (4)
String s = stringLists[0].get(0);                   // (5)
```

(1)이 문제없이 컴파일 된다고 가정하자. 그러면 제네릭 배열이 만들어질 것이다. (2)는 하나의 원소를 갖는 배열 List\<Integer\>를 초기화한다. (3)은 List\<String\> 배열을 Object 배열 변수에 대입한다. 배열은 공변 자료형이므로, 가능하다. (4)에서는 List\<Integer\>를 Object 배열에 있는 유일한 원소에 대입한다. 제네릭이 형 삭제(erasure)를 통해 구현되므로 여기에도 하자는 없다. List\<Integer\> 객체의 실행시점 자료형(runtime type)은 List이며, List\<String\>[]의 실행시점 자료형 또한 List[]이다. 따라서 이 대입문(assignment)은 ArrayStoreException을 발생시키지 않는다. 문제는 지금부터다. List\<String\> 객체만을 담는다고 선언한 배열에 List\<Integer\>를 저장한 것이다. (5)에서는 이 배열 안에 있는 유일한 원소를 꺼내는 작업을 하고 있는데, 컴파일러는 꺼낸 원소의 자료형을 자동적으로 String으로 변환할 것이다. 사실은 Integer인데 말이다. 그러니 프로그램 실행 도중에 ClassCastException이 발생하고 말 것이다. 이런 일이 생기는 것을 막으려면 (1)처럼 제네릭 배열을 만들려고 하면 컴파일 할 때 오류가 발생해야 한다.

제네릭 배열 생성 오류에 대한 가장 좋은 해결책은 보통 E[] 대신 List\<E\>를 쓰는 것이다. 성능이 저하되거나 코드가 길어질 수는 있겠으나, 형 안전성과 호환성은 좋아진다.

예를 들어, 동기화된 리스트가 하나 있고(Collections.synchronizedList가 반환하는 종류의 리스트) 리스트에 원소의 자료형과 같은 자료형의 값 두 개를 인자로 받는 함수가 있다고 하자. 이제 리스트에 해당 함수를 적용해서, 리스트를 \"줄이고(reduce)\" 싶다고 해 보자. 리스트에 정수들이 들어있고, 함수가 하는 일이 두 개의 정수를 더하는 일이라면, 그 함수를 사용해서 리스트 내의 모든 정수의 합을 구하는 reduce 메서드를 만들어 보자는 것이다. 따라서 reduce는 리스트와 함수 하나를 인자로 받아야 하고, reduce의 초기값, 그러니까 리스트가 비어있을 때 reduce가 반환해야 하는 값도 인자로 받아야 한다.

```
// 제네릭 없이 작성한 reduce 함수. 병행성(concurrency) 문제가 있다!
static Object reduce(List list, Function f, Object initVal) {
    synchronized(list) {
        Object result = initVal;
        for (Object o : list)
            result = f.apply(result, o);
        return result;
    }
}

interface Function {
    Object apply(Object arg1, Object arg2);
}
```

규칙 67에서 다루는 지침은 동기화(synchronized) 영역 안에서 \"불가해 메서드(alien method)\"를 호출하면 안 된다는 것이다. 그러니 락(lock)을 건 상태에서 리스트를 복사한 다음, 복사본에 작업하도록 reduce 메서드를 수정해야 한다. 그러니 락(lock)을 건 상태에서 리스트를 복사한 다음, 복사본에 작업하도록 reduce 메서드를 수정해야 한다.

```
// 제네릭 없이 작성한 reduce 함수. 병행성 문제는 없다.
static Object reduce(List list, Function f, Object initVal) {
    Object[] snapshot = list.toArray(); // 리스트에 내부적으로 락을 건다.
    Object result = initVal;
    for (Object o : sanpshot)
        result = f.apply(result, o);
    return result;
}
```

이런 작업을 제네릭으로 하면 앞서 설명한 문제들을 겪게 된다. 앞서 살펴본 Function 인터페이스를 제네릭 버전으로 바꿔보자.

```
interface Function<T> {
    T apply(T arg1, T arg2);
}
```

그리고 아래는 제네릭을 \'순진하게\' 적용한 reduce 메서드다. *제네릭 메서드*(규칙 27)로 선언되어 있는데, 선언문의 의미를 이해하지 못한다 해도 실망하지 말자. 지금으로서는 메서드 내부에만 집중하면 된다.

```
// reduce의 제네릭 버전 - 컴파일되지 않는다!
static <E> E reduce(List<E> list, Function<E> f, E initVal) {
    E[] snapshot = list.toArray();  // 리스트에 락을 건다.
    E result = initVal;
    for (E e : snapshot)
        result = f.apply(result, e);
    return result;
}

// 에러
Reduce.java: incompatible types

// 고치면 새로운 경고가 뜬다.
Reduce.java:12: warning: [unchecked] unchecked cast
```

컴파일러가 전하려는 메시지는, 실행 도중에 형변환이 안전하게 이루어질지 검사할 수 없다는 뜻이다. 실행 시에 E가 무슨 자료형이 될지 알 수 없기 때문이다. **원소의 자료형 정보는 프로그램이 실행될 때에는 제네릭에서 삭제된다(erased)는 것을 기억하기 바란다.** 배열 대신 리스트를 써서 컴파일해도 아무런 오류나 경고 메시지가 없도록 수정하자.

```
// 리스트를 사용하는 제네릭 버전 reduce
static <E> E reduce(List<E> list, Function<E> f, E initVal) {
    List<E> snapshot;
    synchronized(list) {
        snapshot = new ArrayList<E>(list);
    }
    E result = initVal;
    for (E e : snapshot)
        result = f.apply(result, e);
    return result;
}
```

이 코드는 앞서 보았던 코드보다 조금 길지만, 실행 도중에 ClassCastException이 발생할 일이 없으므로 그만한 값어치가 있다.

#### 요약
- 배열은 공변 자료형이자 실체화 가능 자료형이다.
- 제네릭은 불변 자료형이며, 실행 시간에 형인자의 정보는 삭제된다.
- 따라서 배열은 컴파일 시간에 형 안전성을 보장하지 못하며, 제네릭은 그 반대다.

---

# 규칙 26. 가능하면 제네릭 자료형으로 만들 것
제네릭 자료형을 직접 만드는 것은 좀 더 까다로운데, 그렇다 해도 배워둘 만한 가치는 있다.

```
// Object를 사용한 컬렉션 - 제네릭을 적용할 중요 후보
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
        Object result = elements[--size];
        elements[size] = null;  // 만기 참조 제거
        return result;
    }

    public boolean isEmpty() {
        return size == 0;
    }

    private void ensureCapacity() {
        if (elements.length == size)
            elements = Arrays.copyOf(elements, 2 * size + 1);
    }
}
```

이 클래스는 *제네릭화*(generification)하면 딱 좋을 후보다. 호환성을 유지하면서도 제네릭 자료형을 사용하도록 개선할 수 있다. 위의 코드를 사용하면 스택에서 꺼낸 객체를 사용하기 전에 형변환을 해야 하는데, 그런 형변환은 프로그램 실행 중에 실패할 가능성이 있다. 클래스를 제네릭화하는 첫 단계는 선언부에 형인자(type parameter)를 추가하는 것이다. 위의 경우에는 스택에 담길 원의 자료형을 나타내는 형인자 하나가 필요한데, 관습적으로 이름은 E라고 붙이도록 하겠다(규칙 56).

```
// 제네릭을 사용해 작성한 최초 Stack 클래스 - 컴파일되지 않는다!
public class Stack<E> {
    private E[] elements;
    private int size = 0;
    private static final int DEFAULT_INITIAL_CAPACITY = 16;

    public Stack() {
        elements = new E[DEFAULT_INITIAL_CAPACITY];
    }

    public void push(E e) {
        ensureCapacity();
        elements[size++] = e;
    }

    public E pop() {
        if (size == 0)
            throw new EmptyStackException();
        E result = elements[--size];
        elements[size] = null;  // 만기 참조 제거
        return result;
    }

    ... // isEmpty와 ensureCapacity는 동일
}

// 컴파일 에러
Stack.java:8: generic array creation
    elements = new E[DEFAULT_INITIAL_CAPACITY];
```

규칙 25에서 설명한 대로, E 같은 실체화 불가능 자료형으로는 배열을 생성할 수 없다. 배열을 사용하는 제네릭 자료형을 구현할 때마다 이런 문제를 겪게 될 것이다. 해결책은 두 가지다. 첫 번째 방법은 제네릭 배열을 만들 수 없다는 조건을 우회하는 것이다. Object의 배열을 만들어서 제네릭 배열 자료형으로 형변환(cast)하는 방법이다. 그런데 그 방법을 사용한 코드를 컴파일해 보면 오류 대신 경고 메시지가 출력된다. 문법적으로는 문제는 없지만, 일반적으로 형 안전성을 보장하는 방법은 아니다. 컴파일러는 프로그램의 형 안전성을 입증할 수 없을지 모르지만, 프로그래머는 할 수 있다. 무점검 형변환(unchecked cast)을 하기 전에 개발자는 반드시 그런 형변환이 프로그램의 형 안전성을 해치지 않음을 확실히 해야 한다.

```
// elements 배열에는 push(E)를 통해 전달된 E 형의 객체만 저장된다.
// 이 정도면 형 안전성은 보장할 수 있지만, 배열의 실행시간 자료형은 E[]가
// 아니라 항상 Object[]이다.
@SupressWarnings("unchecked")
public Stack() {
    elements = (E[]) new Object[DEFAULT_INITIAL_CAPACITY];
}
```

제네릭 배열 생성을 피하는 두 번째 방법은 elements의 자료형을 E[]에서 Object[]로 바꾸는 것이다. E는 실체화 불가능 자료형이므로 컴파일러는 이 형변환을 실행 중에 검사할 수 없다. 하지만 무점검 형변환이 안전하다는 것, 그래서 경고를 억제해도 좋다는 것은 개발자 스스로 쉽게 입증할 수 있다.

```
// 무점검 경고를 적절히 억제한 사례
public E pop() {
    if (size == 0)
        throw new EmptyStackException();

    // 자료형이 E인 원소만 push하므로, 아래의 형변환은 안전하다.
    @SupressWarnings("unchecked")
    E result = (E) elements[--size];

    elements[size] = null;
    return result;
}
```

제네릭 배열 생성 오류를 피하는 두 방법 가운데 어떤 것을 쓸지는 대체로 취향 문제다. 다른 모든 조건이 같다면, 무점검 형변환(unchecked cast) 경고 억제의 위험성은 스칼라(scalar) 자료형보다 배열 자료형 쪽이 더 크기 때문에, 두 번째 해법이 더 낫다고 볼 수도 있다. 하지만 Stack 예제보다 좀 더 현실적인 제네릭 클래스라면 어떨까? 아마 배열을 사용하는 코드가 클래스 이곳저곳에 흩어져 있을 것이다. 그런 클래스에 첫 번째 해법을 적용하면 E[]로 한 번만 형변환을 하면 되겠지만, 두번째 해법을 쓰면 코드 여기저기서 E로 형변환을 해야한다. 그것이 바로 첫번째 해법이 좀 더 보편적으로 쓰이는 이유다.

#### 요약
- 제네릭 자료형은 클라이언트가 형변환을 해야만 사용할 수 있는 자료형보다 안전할 뿐 아니라 사용하기도 쉽다.
- 새로운 자료형을 설계할 때는 형변환 없이도 사용할 수 있도록 하라(제네릭으로).

---

# 규칙 27. 가능하면 제네릭 메서드로 만들 것
세 집합(인자 두 개와 반홥값 하나)에 보관될 원소의 자료형을 나타내는 형인자(type parameter)를 메서드 선언에 추가하고, 그 인자를 사용해서 메서드를 구현해야 한다. **형인자를 선언하는 형인자 목록(type parameter list)은 메서드의 수정자(modifier)와 반환값 자료형 사이에 둔다.** 이 예제에서 형인자 목록은 \<E\>이고 반환값 자료형은 Set\<E\>이다. 형인자의 이름을 지울 때는 제네릭 자료형과 같은 관습을 따른다.

```
// 제네릭 메서드
public static <E> Set<E> union(Set<E> s1, Set<E> s2) {
  Set<E> result = new HashSet<E>(s1);
  result.addAll(s2);
  return result;
}

// 제네릭 메서드의 용례를 보이는 프로그램
public static void main(String[] args) {
  Set<String> guys = new HashSet<String>(Arrays.asList("Tom", "Dick", "Harry"));
  Set<String> stooges = new HashSet<String>(Arrays.asList("Larry", "Moe", "Curly"));
  Set<String> aflCio = union(guys, stooges);
  System.out.println(aflCio);
}
```

제네릭 메서드의 주목할 만한 특징 하나는, 제네릭 생성자를 호출할 때는 명시적으로 주어야 했던 형인자를 전달할 필요가 없다는 것이다. 컴파일러는 메서드에 전해진 인자의 자료형을 보고 형인자의 값을 알아낸다. 위의 예제에서는 union에 전달된 자료형이 Set<String>이므로, 컴파일러는 E가 String임을 알아낼 수 있다. 이 과정을 *자료형 유추*(type inference)라 한다.

제네릭 생성자를 호출할 때는 형인자를 명시적으로 전달해야 하는데 이런 번거러움을 피하려면, 사용할 생성자마다 제네릭 정적 팩터리 메서드(generic static factory method)를 만들면 된다. 예를 들어, 아래는 아무 인자도 받지 않는 HashMap 생성자에 대한 제네릭 정적 팩터리 메서드이다.

```
// 제네릭 정적 팩털 ㅣ메서드
public static <K, V> HashMap<K, V> newHashMap() {
  return new HashMap<K, V>();
}
```

이 제네릭 정적 팩터리 메서드를 사용하면 중복되는 형인자를 제거하여 간결한 코드를 만들 수 있다.

```
// 정적 팩터리 메서드를 통한 형인자 자료형 객체 생성
Map<String, List<String>> anagrams = newHashMap();
```

#### 요약
- 제제릭 메서드는 클라이언트가 직접 입력 값과 반환값의 자료형을 형변환해야 하는 메서드보다 사용하기 쉽고 형 안전성도 높다.
- 자료형을 만들 때처럼, 새로운 메서드를 고안할 때는 형변환 없이도 사용할 수 있을지 살펴보자.

---

# 규칙 28. 한정적 와일드카드를 써서 API 유연성을 높여라
일련의 원소들을 인자로 받아 차례로 스택에 집어넣는 메서드를 추가하는 pushAll 메서드를 정의했다. Integer 형의 intVal로 push(intVal)을 호출하면 제대로 동작할 것이다. Integer는 Number의 하위 자료형(subtype)이기 때문이다. 그러니 논리적으로 보자면 아래의 코드는 문제가 없어야 할 것이지만, 실제로 해 보면 에러가 발생한다. 앞서 설명한 대로, 형인자 자료형은 불변(invariant)이기 때문이다.
```
public class Stack<E> {
  public Stack();
  public void push(E e);
  public E pop();
  public boolean isEmpty();
}

// 와일드카드 자료형을 사용하지 않는 pushAll 메서드 - 문제가 있다.
public void pushAll(Iterable<E> src) {
  for (E e : src)
    push(e);
}

Stack<Number> numberStack = new Stack<Number>();
Iterable<Integer> integers = ... ;
numberStack.pushAll(integers);  // 에러 발생
```

자바는 이런 상황을 해결하기 위해, 한정적 와일드카드 자료형(bounded wildcard type)이라는 특별한 형인자 자료형을 제공한다. 따라서, pushAll의 인자 자료형을 \"E의 Iterable\"이 아니라 \"E의 하위 자로형의 Iterable\"이라고 명시할 방법이 필요한데, 와일드카드 자료형을 써서 Iterable\<? extends E\>라고 하면 된다는 것이다.

```
// E 객체 생산자 역할을 하는 인자에 대한 와일드카드 자료형
public void pushAll(Iterable<? extends E> src) {
  for (E e : src)
    push(e);
}
```

popAll 메서드는 스택의 모든 원소를 꺼내서 인자로 주어진 컬렉션에 넣는다. 이 메서드는 깔끔하게 컴파일될 뿐 아니라 인자로 주어진 컬렉션의 원소 자료형이 스택의 원소 자료형과 일치할 때는 완벽히 동작한다. 하지만 스택에서 원소를 꺼내는 코드는 에러가 발생한다.

```
// 와일드카드 자료형 없이 구현한 popAll 메서드 - 문제가 있다!
public void popAll(Collection<E> dst) {
  while (!isEmpty())
    dst.add(pop());
}

Stack<Number> numberStack = new Stack<Number>();
Collection<Object> objects = ... ;
numberStack.popAll(objects);  // pushAll의 첫 번째 버전과 같은 오류 발생
```

Collection\<Object\>가 Collection\<Number\>의 하위 자료형이 아니라는 오류가 난다. 이는 popAll의 인자 자료형을 \"E의 컬렉션\"이 아니라 \"E의 상위 자료형(supertype)의 컬렉션\"이라고 명시하면 된다.

```
// E의 소비자 구실을 하는 인자에 대한 와일드카드 자료형
public void popAll(Collection<? super E> dst) {
  while (!isEmpty())
    dst.add(pop());
}
```

여기서 배울 교훈은 명확하다. 유연성을 최대화하려면, 객체 생산자(producer)나 소비자(consumer) 구실을 하는 메서드 인자의 자료형은 와일드카드 자료형으로 하라는 것이다.

어떤 와일드카드를 쓸지 암기하기 어렵다면, PECS (Produce - Extends, Consumer - Super) 약어를 활용하자. 다시 말해서, 인자가 T 생성자라면 \<? extends T\>라고 하라는 것이다. PECS는 와일드카드 자료형을 사용할 때 지켜야 할 기본적 원칙을 훌륭히 표현하는 약어다.

---

# 규칙 29. 형 안전 다형성 컨테이너를 쓰면 어떨지 따져보라
제네릭은 Set이나 Map 같은 컬렉션(collection)과 ThreadLocal, AtomicReference처럼 하나의 원소만을 담는 컨테이너(container)에 가장 많이 쓰인다. 이때 형인자를 받는 것은 컨테이너 구실을 하는 부분이다. 따라서 컨테이너별로 형인자의 수는 고정된다.

하지만 좀 더 유연한 방법이 필요할 때도 있다. 예를 들어, 데이터베이스에 저장되는 레코드는 임의 개수의 열(column)을 갖는데, 형 안전성(typesafe)을 깨지 않으면서 각 열에 접근할 방법이 있다면 좋을 것이다. 이는 *컨테이너* 대신 *키*(key)에 형인자를 지정하는 것이 기본적 아이디어다. 그런 다음, 컨테이너에 값을 넣거나 뺄 때마다 키를 제공하는 것이다. 값의 자료형이 키의 자료형에 부합하도록 하는 것은 제네릭 자료형 시스템(generic type system)을 통해 처리한다.

임의 클래스 객체 가운데 맘에 드는 것을 골라 저장하고 꺼낼 수 있는 Favorites 클래스를 만든다고 하자. 이 API를 사용하는 클라이언트는 좋아하는 객체를 넣거나 뺼 때 Class 객체를 함께 전달해야 한다.

```
// 형 안전 다형성(heterogeneous) 컨테이너 패턴 - API
public class Favorites {
  public <T> void putFavorite(Class<T> type, T instance);
  public <T> T getFavorite(Class<T> type);
}

// 형 안전 다형성(heterogeneous) 컨테이너 패턴 - 클라이언트
public static void main(String[] args) {
  Favorites f = new Favorites();
  f.putFavorite(String.class, "Java");
  f.putFavorite(Integer.class, 0xcafebabe);
  f.putFavorite(Class.class, Favorites.class);
  String favoriteString = f.getFavorite(String.class);
  int favoriteInteger = f.getFavorite(Integer.class);
  Class<?> favoriteClass = f.getFavorite(Class.class);
  System.out.printf("%s %x %s%n", favoriteString, favoriteInteger, favoriteClass.getName());
}
```

실행해 보면 기대하는 대로 Java cafebabe Favorites가 출력된다.

Favorites 객체는 형 안전성을 보장한다. 다시 말해, String을 요청했는데 Integer를 반환한다거나 하지 않는다. 또한, 다형성(heterogeneous)을 갖고 있다. 일반적인 맵과 달리, 모든 키의 자료형이 서로 다르다. 따라서 Favorites 같은 클래스를 형 안전 다형성 컨테이너(typesafe heterogeneous container)라 부른다.

```
// 형 안전 다형성(heterogeneous) 컨테이너 패턴 - 구현
public class Favorites {
  private Map<Class<?>, Object> favorites = new HashMap<Class<?>, Object>();

  public <T> void putFavorite(Class<T> type, T instance) {
    if (type == null)
      throw new NullPointerException("Type is null");
    favorites.put(type, instance);
  }

  public <T> T getFavorite(Class<T> type) {
    return type.cast(favorites.get(type));
  }
}
```

cast 메서드의 시그니처를 보면, Class가 제네릭 클래스라는 사실을 완벽히 이용하고 있음을 알 수 있다. cast 메서드의 반환값 자료형이 Class 객체의 형인자와 일치하도록 선언되어 있는 것이다.

```
public class Class<T> {
  T cast(Object obj);
}
```

getFavorite 메서드가 필요로 하는 것이 바로 이것이다. cast가 이렇게 선언된 덕분에, T 형으로 무점검 형변환(unchecked cast)하는 코드가 없는, 형 안전성이 보장되는 Favorites 클래스를 만들 수 있었던 것이다.

Favorites 클래스에는 중요한 문제점이 두 가지 있다. 첫 번째는 악의적인 클라이언트가 Favorites 객체의 형 안전성을 쉽게 깨뜨릴 수 있다는 것이다. Class 객체를 무인자 형태(raw form)로 사용하기만 하면 된다. 이는 Favorites 클래스가 자료형 불변식을 위반하지 않도록 보장하는 한 가지 방법은 putFavorite 메서드가 instance의 자료형이 정말로 type이 나타내는 자료형과 일치하는지 동적 형변환을 통해 검사하도록 하는 것이다.

```
// 동적 형변환으로 실행시간 형 안전성 확보
public <T> void putFavorite(Class<T> type, T instance) {
  favorites.put(type, type.cast(instance));
}
```

Favorites 클래스의 두 번째 단점은 실체화 불가능 자료형(non-reifiable type)에는 쓰일 수 없다는 것이다. 따라서 String이나 String[]은 저장할 수 있으나 List\<String\>은 저장할 수 없다. List\<String\>의 Class 객체를 얻을 수 없기 때문에 이를 저장하는 코드는 컴파일되지 않는다. 이를 피하기 위해 *상위 자료형 토큰*(super type token)이라는 기법이 만들어지기는 했으나 아직 완벽한 해법은 없다.

클래스 Class에는 무점검 형변환을 안전하게, 그리고 동적으로 처리해주는 객체 메서드(instance method)가 정의되어 있다. asSubclass인데, 특정한 Class 객체를 인자로 주어진 하위 클래스의 Class 객체로 형변환해 준다. 형변환이 성공하면 인자로 주어진 Class 객체가 반환되고, 형변환 할 수 없는 경우에는 ClassCastException이 뜬다.

컴파일 시점에는 자료형을 알 수 없는 어노테이션을 실행시간에 읽어내는 메서드를 asSubclass를 사용해 구현한 예이다.

```
static Annotation getAnnotation(AnnotatedElement element, String annotationTypeName) {
  Class<?> annotationType = null; // 비한정적 자료형 토큰
  try {
    annotationType = Class.forName(annotationTypeName);
  } catch (Exception ex) {
    throw new IllegalArgumentException(ex);
  }
  return element.getAnnotation(annotationType.asSubclass(Annotation.class));
}
```

#### 요약
컬렉션 API는 컨테이너별로 형인자 개수가 고정되어 있는데, 컨테이너 대신 키를 제네릭으로 만들면 그런 제약이 없는 형 안전 다형성을 만들 수 있다.

---

# Reference
- [Effective Java 2/E](http://www.insightbook.co.kr/%EB%8F%84%EC%84%9C-%EB%AA%A9%EB%A1%9D/programming-insight/%EC%9D%B4%ED%8E%99%ED%8B%B0%EB%B8%8C-%EC%9E%90%EB%B0%94effective-java-2e)
