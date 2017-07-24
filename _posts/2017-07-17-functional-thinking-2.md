---
layout: entry
title: 함수형 사고(2)
author: 김성중
author-email: ajax0615@gmail.com
description: 함수형 사고 - 객체지향 개발자에서 함수형 개발자로 거듭나기
publish: true
---

# 2.1 일반적인 예제
가비지 컬렉션이 주류로 자리 잡은 이후 디버그하기 어려운 일련의 문제들은 사라져버렸고, 개발자가 처리하기엔 복잡하고 오류가 잦은 프로세스를 런타임이 알아서 처리할 수 있게 되었다. 함수형 프로그래밍은, **복잡한 최적화는 런타임에게 맡기고 개발자가 좀 더 추상화된 수준에서 코드를 작성할 수 있게 함** 으로써, 알고리즘 측면에서 가비지 컬렉션과 동일한 역할을 수행할 것이다.

#### **2.1.1 명령형 처리**
**명령형** 프로그램이란 상태를 변형하는 일련의 명령들로 구성된 프로그래밍 방식을 말한다. 전형적인 for 루프가 명령형 프로그래밍의 훌륭한 예이다. 초기 상태를 설정하고, 되풀이할 때마다 일련의 명령을 실행한다.

```java
import java.util.List;

public class TheCompanyProcess {
  public String cleanNames(List<String> listOfNames) {
    StringBuilder result = new StringBuilder();
    for (int i = 0; i < listOfNames.size(); i++) {
      if (listOfNames.get(i).length() > 1) {
        result.append(capitalizeString(listOfNames.get(i))).append(",");
      }
    }
    return result.substring(0, result.length() - 1).toString();
  }

  public String capitalizeString(String s) {
    return s.substring(0, 1).toUpperCase() + s.substring(1, s.length());
  }
}
```

명령형 프로그래밍은 개발자로 하여금 루프 내에서 연산하기를 권장한다. 예제에서 세가지를 실행했다. 한 글자짜리 이름을 **필터했고**, 목록에 남아 있는 이름들을 대문자로 **변형하고**, 이 목록을 하나의 문자열로 **변환했다.**

#### **2.1.2 함수형 처리**
함수형 프로그래밍 언어는 명령형 언어와는 다르게 문제를 분류한다. 앞에서 언급한 **필터**, **변형**, **변환** 등의 논리적 분류도 저수준의 변형을 구현하는 함수들이었다. 개발자는 고계함수에 매개변수로 주어지는 함수를 이용하여 저수준의 작업을 커스터마이즈할 수 있다.

```
listOfEmps
  -> filter(x.length > 1)
  -> transform(x.capitalize)
  -> convert(x + "," + y)
```

함수형 언어는 이런 개념화된 해법을 세부사항에 구애받지 않고 모델링할 수 있게 해준다.

```
val employees = List("neal", "s", "stu", "j", "rich", "bob", "aiden", "j", "ethan", "liam", "mason", "noah", "lucas", "jacob", "jayden", "jack")

val result = employees
  .filter(_.length() > 1)
  .map(_.capitalize)
  .reduce(_ + "," + _)
```

함수형 사고로의 전환은, 어떤 경우에 세부적인 구현에 뛰어들지 않고 이런 고수준 추상 개념을 적용할지를 배우는 것이다.

그렇다면 고수준의 추상적 사고로 얻는 이점은 무엇일까? 첫째로, 문제의 공통점을 고려하여 다른 방식으로 분류하기를 권장한다는 것이다. 둘째로, 런타임이 최적화를 잘할 수 있도록 해준다는 것이다. 어떤 경우에서는, 결과를 반환하지 않는 한, 작업 순서를 바꾸면 더 능률적이 된다(예를 들어 더 적은 아이템을 처리함으로써). 셋째로, 개발자가 엔진 세부사항에 깊이 파묻힐 경우 불가능한 해답을 가능하게 한다.

# 2.3 공통된 빌딩블록
필터(filter), 맵(map), 폴드(fold)/리듀스(reduce)

함수형 프로그래밍같이 다른 패러다임을 익힐 때 어려운 점은 새로운 빌딩블록을 배우고, 풀고자 하는 문제에서 그것이 해법이 될 수 있다는 점을 인지하는 것이다. 함수형 프로그래밍에서는 추상 개념이 많지 않은 대신, 그 각 개념이 범용성을 띤다(구체성은 고계함수에 매개변수로 주어지는 함수를 통해 덧붙여진다). 함수형 프로그래밍은 매개변수와 구성에 크기 의존하므로 '움직이는 부분' 사이의 상호작용에 대한 규칙이 많지 않고, 따라서 개발자의 작업을 쉽게 해준다.

# Reference
[함수형 사고](http://www.hanbit.co.kr/store/books/look.php?p_code=B6064588422)
