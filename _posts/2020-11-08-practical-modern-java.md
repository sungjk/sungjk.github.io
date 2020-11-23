---
layout: entry
post-category: java
title: Practical 모던 자바
author: 김성중
author-email: ajax0615@gmail.com
keywords: Practical 모던 자바, Java
publish: true
---

# 2. 인터페이스와 클래스

최초 자바 버전에서는 인터페이스에 다음과 같은 제약이 있었다.
- 상수를 선언할 수 있다. 해당 상수는 반드시 값이 할당되어 있어야 하며 값을 변경할 수 없다. 명시적으로 final을 선언하지 않더라도 final로 인식된다.
- 메서드는 반드시 추상(abstract) 메서드여야 한다. 즉, 구현체가 아니라 메서드 명세만 정의되어 있어야 한다.
- 인터페이스를 구현한 클래스는 인터페이스에서 정의한 메서드를 구현하지 않았다면 반드시 추상 클래스로 선언되어야 한다.
- 인터페이스에 선언된 상수와 메서드에 public을 선언하지 않더라도 public으로 인식한다.

```java
public interface Vehicle {
  // public static final로 인식한다.
  int SPEED_LIMIT = 200;

  // public으로 인식한다.
  int getSpeedLimit();
}

public VehicleImpl implements Vehicle {
  // 반드시 public으로 선언되어야 한다.
  public int getSpeedLimit() {
    // SPEED_LIMIT 속성이 public static final로 인식된다.
    return Vehicle.SPEED_LIMIT;
  }
}
```

자바 1.2부터는 위의 두 가지 항목 외에 선언할 수 있는 항목이 추가되었다.
- 중첩(Nested) 클래스를 선언할 수 있다. 선언은 내부(Inner) 클래스 같지만 실제로는 중첩 클래스로 인식한다.
- 중첩(Nested) 인터페이스를 선언할 수 있다.
- 위의 중첩 클래스와 중첩 인터페이스는 모두 public과 static이어야 하며 생략 가능하다.
> 중첩 클래스는 클래스나 인터페이스 내부에 static으로 선언된 클래스이다. 인터페이스 내부의 클래스는 비록 static으로 선언하지 않더라도 static과 동일한 것으로 간주하기 때문에 내부 클래스가 아니라 중첩 클래스가 맞다.

자바 5에서 추가된 새로운 기능인 제네릭과 열거형(Enum) 그리고 어노테이션이 인터페이스에도 영향을 주었다.
- 중첩(Nested) 열거형(Enum)을 선언할 수 있다.
- 중첩(Nested) 어노테이션을 선언할 수 있다.
- 제네릭의 등장으로 인터페이스 선언문과 메서드 언언에 모두 타입 파라미터를 사용할 수 있게 되었다.

자바 8에서 적용된 가장 큰 변경 사항은 메서드에 실제 구현된 코드를 정의할 수 있다는 점이다.
- 실제 코드가 완성되어 있는 static 메서드를 선언할 수 있다.
- 실제 코드가 완성되어 있는 default 메서드를 선언할 수 있다.

자바 9에서도 인터페이스에 선언할 수 있는 항목이 하나 추가되었다.
- private 메서드를 선언할 수 있다.
> 클래스 외부에는 공개되지 않더라도 인터페이스 내부의 static 메서드와 default 메서드의 로직을 공통화하고 재사용하는데 유용하다.

### default, static, private 메서드
default 키워드에는 public 메서드라는 것이 함축되어 있다. 이렇게 구현한 메서드는 해당 인터페이스를 구현한 클래스에 메서드의 명세와 기능이 상속된다. 마치 implements 키워드를 이용한 것이 아니라 extends 키워드를 이용해서 클래스를 정의한 것과 비슷하다.

default 메서드의 경우는 메서드를 직접 구현하겠다고 컴파일러에게 알려주는 역할을 하지만 static 메서드와 private 메서드에는 별도의 키워드 정의 없이 메서드의 명세를 선언하고 내용을 정의하면 된다. 이때 인터페이스 내에 static과 private 메서드로 정의한 다음 코드를 작성하지 않으면 컴파일 에러가 발생한다는 점에 주의해야 한다.

왜 default 메서드는 다른 메서드와 구분하기 위한 별도의 키워드가 필요하고 static과 private은 아무런 키워드나 표시 없이 바로 메서드를 정의하고 구현해도 될까? static과 private은 과거에는 인터페이스에 허용되지 않던 메서드 형태라서 컴파일러가 혼란을 일으키지 않기 때문이다. 이와 달리 default로 선언되는 메서드는 키워드를 제외하면 인터페이스의 추상 메서드와 일치하므로 컴파일러가 혼동을 일으킨다. 그래서 default라는 키워드를 통해 컴파일러에게 이것은 특별한 메서드 유형이라고 알리는 것이다.

### 클래스와의 차이점과 제약 조건
추상 클래스와 인터페이스의 가장 큰 차이점은 두 가지다.
- 추상 클래스는 멤버 변수를 가질 수 있지만 인터페이스는 멤버 변수를 가질 수 없다. 물론 인터페이스도 static으로 정의된 변수를 내부적으로 선언할 수 있지만 멤버 변수는 선언할 수 없다.
- 클래스를 구현할 때 오직 하나의 클래스만을 상속받을 수 있는 반면에 인터페이스는 여러 개를 상속받거나 구현할 수 있다.

### 다중 상속 관계
자바에서는 상위 클래스 혹은 인터페이스를 상속/구현하기 위해 다음 두 개의 키워드를 제공한다.
- extends: 상속. 클래스가 상위 클래스를 상속받을 때 사용하며 인터페이스가 상위 인터페이스를 상속받을 때도 사용할 수 있다.
- implements: 구현. 클래스가 인터페이스를 구현할 때 사용한다.

우선 private 메서드는 자바의 접근 규칙에 따라 하위 클래스로 상속되지 않는다. 그러므로 private 메서드를 인터페이스에 정의할 수 있더라도 이를 구현해야 하는 클래스에는 아무런 영향을 미치지 못한다. static 메서드도 인터페이스 레벨 혹은 클래스 레벨로 정의되는 메서드이기 때문에 메서드 오버라이드의 범위에 속하지 않는다. 하지만 default 메서드의 경우 앞에 default라는 키워드를 붙였을 뿐 메서드 규격은 기존 인터페이스에서 정의하던 것과 동일하므로 여러 개의 인터페이스를 implements 키워드를 이용해서 하나의 클래스에서 구현할 경우 **다중 상속의 효과**를 얻게 된다.

인터페이스에서 default 메서드를 제공하게 되면서 제한적이긴 하지만 자바에서 다중 상속이 가능해졌다. 따라서 이에 대한 원칙 및 호출 관계를 반드시 이해해야 한다. 가장 중요한 원칙 3가지는 다음과 같다.
1. 클래스가 인터페이스에 대해 우선순위를 가진다. 동일한 메서드가 인터페이스와 클래스에 둘 다 있다면 클래스가 먼저 호출된다.
2. 위의 조건을 제외하고 상속 관계에 있을 경우에는 하위 클래스/인터페이스가 상위 클래스/인터페이스보다 우선 호출된다.
3. 위의 두 가지 경우를 제외하고 메서드 호출 시 어떤 메서드를 호출해야 할지 모호할 경우 컴파일 에러가 발생할 수 있으며, 반드시 호출하고자 하는 클래스 혹은 인터페이스를 명확하게 지정해야 한다.

---

# 3. 함수형 프로그래밍
자바 8에서는 인터페이스에 하나의 메서드만 정의한 것을 함수형 인터페이스라고 부른다.

```java
// 함수형 인터페이스
public interface TravelInfoFilter {
  public boolean isMatched(TravelInfoVO TravelInfo);
}

...

// 외부에서 전달된 조건으로 검색
public List<TravelInfoVO> searchTravelInfo(TravelInfoFilter searchCondition) {
  List<TravelInfoVO> returnValue = new ArrayList<>();

  for (TravelInfoVO travelInfo : travelInfoList) {
    if (searchCondition.isMatched(travelInfo)) {
      returnValue.add(travelInfo);
    }
  }
  return returnValue;
}

...

public static void main(String[] args) {
  ...
  // 조회 조건을 외부로 분리
  List<TravelInfoVO> searchTravel = travelSearch.searchTravelInfo(new TravelInfoFilter() {
    @Override
    public boolean isMatched(TravelInfoVO travelInfo) {
      return travelInfo.getCountry().equals("vietnam");
    }
  });
}
```

searchTravelInfo 메서드만 보면 isMatched에 내부적으로 어떤 조건을 구현해 놓았는지 알지 못하지만 그 결과값에 따라 true/false 값을 확인할 수 있으므로 외부에서 들어오는 다양한 조건에 대해 처리가 가능하다.

### 메서드 참조
람다 표현식을 사용하면 익명 클래스의 소스 코드 중복성은 해결할 수 있지만, 소스 코드의 재사용이라는 측면에서는 활용도가 떨어진다. 이 경우 람다 표현식을 하나의 함수로 선언하고 이 함수를 다른 곳에서 활용하면 재사용성을 높일 수 있다.

---

# 4. 람다와 함수형 인터페이스

TODO


---

### References
- [Practical 모던 자바](http://www.yes24.com/Product/Goods/92529658)
