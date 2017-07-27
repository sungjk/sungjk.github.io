---
layout: entry
title: Clean Code
author: 김성중
author-email: ajax0615@gmail.com
description: 로버트 C. 마틴의 Clean Code를 읽고 정리한 글입니다.
publish: false
---

로버트 C. 마틴의 Clean Code를 읽고 정리를 한 글입니다. 정리한 내용에 대해 구체적인 이유가 적혀 있지 않은 것들은 책을 통해 직접 확인하시면 좋겠습니다.

# **의미 있는 이름**
프로그래머는 코드를 최대한 이해하기 쉽게 짜야 한다. 집중적인 탐구가 필요한 코드가 아니라 대충 훑어봐도 이해할 코드 작성이 목표다.

- 의도를 분명히 밝혀라.
- 그릇된 정보를 피하라.
- 의미 있게 구분하라.
- 발음하기 쉬운 이름을 사용하라.
- 검색하기 쉬운 이름을 사용하라.
- 인코딩을 피하라.
- 자신의 기억력을 자랑하지 마라.
- 클래스나 객체 이름은 명사나 명사구가 적합하다.
- 메서드 이름은 동사나 동사구가 적합하다.
- 기발한 이름은 피하라.
- 한 개념에 한 단어를 사용하라.
- 말장난을 하지 마라.
- 해법 영역에서 가져온 이름을 사용하라.
- 문제 영역에서 가져온 이름을 사용하라.
- 의미 있는 맥락을 추가하라.
- 불필요한 맥락을 없애라.

---

# **함수**
우리가 함수를 만드는 이유는 큰 개념을 (다시 말해, 함수 이름을) 다음 추상화 수준에서 여러 단계로 나눠 수행하기 위해서이다.

#### 작게 만들어라!
함수를 만드는 첫째 규칙은 '**작게!**'다. 함수를 만드는 둘째 규칙은 '**더 작게**'다.

#### 한 가지만 해라!
> "함수는 한 가지를 해야 한다. 그 한 가지를 잘 해야 한다. 그 한 가지만을 해야 한다."

```java
public static String renderPageWithSetupsAndTeardowns(
    PageData pageData, boolean isSuite) throws Exception {
    if (isTestPage(pageData))
        includeSetupAndTeardownPages(pageData, isSuite);
    return pageData.getHtml();
}
```

이 충고에서 문제라면 그 '한 가지'가 무엇인지 알기가 어렵다는 점이다. 위 코드는 한 가지만 하는가? 세가지를 한다고 주장할 수도 있다.

1. 페이지가 테스트 페이지인지 판단한다.
2. 그렇다면 설정 페이지와 해제 페이지를 넣는다.
3. 페이지를 HTML로 렌더링한다.

위에서 언급한 세 단계는 지정된 함수 이름 아래에서 추상화 수준이 하나다. 함수는 간단한 TO 문단으로 기술할 수 있다.

> TO renderPageWithSetupsAndTeardowns, 페이지가 테스트 페이지인지 확인한 후 테스트 페이지라면 설정 페이지와 해제 페이지를 넣는다. 테스트 페이지든 아니든 페이지를 HTML로 렌더링한다.

지정된 함수 이름 아래에서 추상화 수준이 하나인 단계만 수행한다면 그 함수는 한 가지 작업만 한다.

#### 함수당 추상화 수준은 하나로!
함수가 확실히 '한 가지' 작업만 하려면 함수 내 모든 문장의 추상화 수준이 동일해야 한다.
한 함수 다음에는 추상화 수준이 한 단계 낮은 함수가 온다. 즉, 위에서 아래로 프로그램을 읽으면 함수 추상화 수준이 한 번에 한 단계씩 낮아진다.
하지만 추상화 수준이 하나인 함수를 구현하기란 쉽지 않다. **핵심은 짧으면서도 '한 가지'만 하는 함수** 다.

#### 서술적인 이름을 사용하라!
> "코드를 읽으면서 짐작했던 기능을 각 루틴이 그대로 수행했다면 깨끗한 코드라 불러도 되겠다."

- 한 가지만 하는 작은 함수에 좋은 이름을 붙인다면 이런 원칙을 달성함에 있어 이미 절반은 성공했다.
- 함수가 작고 단순할수록 서술적인 이름을 고르기도 쉬워진다.
- 길고 서술적인 이름이 짧고 어려운 이름보다 좋다.
- 이름을 정하느라 시간을 들여도 괜찮다.
- 이름을 붙일 때는 일관성이 있어야 한다. 모듈 내에서 함수 이름은 같은 문구, 명사, 동사를 사용한다. includeSetupAndTeardownPages, includeSetupPages, includeSuiteSetupPage, includeSetupPage 등이 좋은 예다.

#### 함수 인수
함수에서 이상적인 인수 개수는 0개(무항)다. 다음은 1개(단항)고, 다음은 2개(이항)다. 3개(삼항)은 가능한 피하는 편이 좋다. 4개 이상(다항)은 특별한 이유가 필요하다. 특별한 이유가 있어도 사용하면 안 된다. **최선은 입력 인수가 없는 경우이며, 차선은 입력 인수가 1개뿐인 경우다.**

플래그 인수는 추하다. 왜냐하면 함수가 한꺼번에 여러 가지를 처리한다고 대놓고 공표하는 셈이기 때문이다.

인수가 2개인 함수는 인수가 1개인 함수보다 이해하기 어렵다. 예를 들어, writeField(name)는 writeField(outputStream, name)보다 이해하기 쉽다. 이항 함수가 무조건 나쁘다는 소리는 아니다. 하지만 그만큼 위험이 따른다는 사실을 이해하고 가능하면 단항 함수로 바꾸도록 애써야 한다. 예를 들어, writeField 메서드를 outputStream 클래스 구성원으로 만들어 outputStream.writeField(name)으로 호출한다. 아니면 outputStream을 현재 클래스 멤버 변수로 만들어 인수로 넘기지 않는다. 아니면 FieldWriter라는 새 클래스를 만들어 구성자에서 outputStream을 받고 write 메서드를 구현한다.

함수의 의도나 인수의 순서와 의돌르 제대로 표현하려면 좋은 함수 이름이 필수다. 단항 함수는 함수와 인수가 동사/명사 쌍을 이뤄야 한다. 예를 들어, writeField(name)은 누구나 곧바로 이해한다.

#### 부수 효과를 일으키지 마라!
```
public boolean checkPassword(String userName, String password) {
    User user = UserGateWay.findByName(userName);
    if (user != User.NULL) {
        String codedPhrase = user.getPhraseEncodedByPassword();
        String phrase = cryptographer.decrypt(codedPhrase, password);
        if ("Valid Password".equals(phrase)) {
            Session.initialize();
            return true;
        }
    }
    return false;
}
```

여기서, 함수가 일으키는 부수 효과는 Session.initialize() 호출이다. checkPassword 함수는 이름 그대로 암호를 확인한다. 이름만 봐서는 세션을 초기화한다는 사실이 드러나지 않는다. 이런 부수 효과가 시간적인 결합을 초래한다. 즉, checkPassword 함수는 특정 상황에서만 호출이 가능하다. 만약 **시간적인 결합이 필요하다면 함수 이름에 분명히 명시한다.** checkPasswordAndInitializeSession이라는 이름이 훨씬 좋다. 물론 함수가 '한 가지'만 한다는 규칙을 위반하지만.

#### 명령과 조회를 분리하라!
함수는 뭔가를 수행하거나 뭔가에 답하거나 둘 중 하나만 해야 한다. 객체 상태를 변경하거나 아니면 객체 정보를 반환하거나 둘 중 하나다.

#### 오류 코드보다 예외를 사용하라!
```
if (deletePage(page) == E_OK) {
    if (registry.deleteReference(page.name) == E_OK) {
        if (configKeys.deleteKey(page.name.makeKey()) == E_OK) {
            logger.log("page deleted");
        } else {
            logger.log("configKey not deleted");
        }
    } else {
        logger.log("deleteReference from registry failed");
    }
} else {
    logger.log("delete failed");
    return E_ERROR;
}
```

위 코드는 동사/형용사 혼란을 일으키지 않는 대신 여러 단계로 중첩되는 코드를 야기한다. 반면 오류 코드 대신 예외를 사용하면 오류 처리 코드가 원래 코드에서 분리되므로 코드가 깔끔해진다.

```
try {
    deletePage(page);
    registry.deleteReference(page.name);
    configKeys.deleteKey(page.name.makeKey());
}
catch (Exception e) {
    logger.log(e.getMessage());
}
```

try/catch 블록은 원래 추하다. 코드 구조에 혼란을 일으키며, 정상 동작과 오류 처리 동작을 뒤섞는다. 그러므로 try/catch 블록을 별도 함수로 뽑아내는 편이 좋다.

```
public void delete(Page page) {
    try {
        deletePageAndAllReferences(page);
    }
    catch (Exception e) {
        logError(e);
    }
}

private void deletePageAndAllReferences(Page page) throws Exception {
    deletePage(page);
    registry.deleteReference(page.name);
    configKeys.deleteKey(page.name.makeKey());
}

private void logError(Exception e) {
    logger.log(e.getMessage());
}
```

---

# **주석**
> "나쁜 코드에 주석을 달지 마라. 새로 짜라."

우리에게 프로그래밍 언어를 치밀하게 사용해 의도를 표현할 능력이 있다면, 주석은 거의 필요하지 않으리라. 우리는 코드로 의도를 표현하지 못해, 그러니까 실패를 만회하기 위해 주석을 사용한다. 주석을 달 때마다 자신에게 표현력이 없다는 사실을 푸념해야 마땅하다.

프로그래머들이 주석을 엄격하게 관리해야 한다고, 그래서 복구성과 관련성과 정확성이 언제나 높아야 한다고 주장할지도 모르겠다. 하지만 나라면 코드를 깔끔하게 정리하고 표현력을 강화하는 방향으로, 그래서 애초에 주석이 필요없는 방향으로 에너지를 쏟겠다. 진실은 한곳에만 존재한다. 바로 코드다.

#### 주석은 나쁜 코드를 보완하지 못한다
표현력이 풍부하고 깔끔하며 주석이 거의 없는 코드가, 복잡하고 어수선하며 주석이 많이달린 코드보다 훨씬 좋다.

#### 코드로 의도를 표현하라!
```
// 직원에게 복지 혜택을 받을 자격이 있는지 검사한다.
if ((employee.flags & HOURLY_FLAG) && (employee.age > 65))
```

보다는

```
if (employee.isEligibleForFullBenefits())
```

몇 초만 더 생각하면 코드로 대다수 의도를 표현할 수 있다. 많은 경우 주석으로 달려는 설명을 함수로 만들어 표현해도 충분하다.

#### 좋은 주석
- 법적인 주석
- 정보를 제공하는 주석
- 의도를 설명하는 주석
- 의미를 명료하게 밝힌 주석: 인수나 반환값이 표준 라이브러리나 변경하지 못하는 코드에 속한다면 의미를 명료하게 밝히는 주석이 유용하다.
- 결과를 경고하는 주석
- TODO 주석
- 중요성을 강조하는 주석
- 공개 API에서 Javadocs

#### 나쁜 주석
대다수 주석이 허술한 코드를 지탱하거나, 엉성한 코드를 변명하거나, 미숙한 결정을 합리화하는 등 프로그래머가 주절거리는 독백에서 크게 벗어나지 못한다.

- 주절거리는 주석 : 주석을 달기로 결정했다면 충분한 시간을 들여 최고의 주석을 달도록 노력한다. 이해가 안되어 다른 모듈까지 뒤져야 하는 주석은 독자와 제대로 소통하지 못하는 주석이다. 그런 주석은 바이트만 낭비할 뿐이다.
- 같은 이야기를 중복하는 주석
- 오해할 여지가 있는 주석
- 의무적으로 다는 주석
- 이력을 기록하는 주석
- 있으나 마나 한 주석
- 함수나 변수로 표현할 수 있다면 주석을 달지 마라
- 위치를 표시하는 주석
- 닫는 괄호에 다는 주석: 닫는 괄호에 주석을 달아야겠다는 생각이 든다면 함수를 줄이려 시도하자.
- 공로를 돌리거나 저자를 표시하는 주석
- 주석으로 처리한 코드
- HTML 주석
- 전역 정보
- 너무 많은 정보 : 흥미로운 역사나 관련 없는 정보를 장황하게 늘어놓지 마라.
- 모호한 관계 : 주석과 주석이 설명하는 코드는 둘 사이 관계가 명백해야 한다.
- 함수 헤더 : 짧고 한 가지만 수행하며 이름을 잘 붙인 함수가 주석으로 헤더를 추가한 함수보다 훨씬 좋다.
- 비공개 코드에서 Javadocs

---

# **형식 맞추기**
- 적절한 행 길이를 유지하라

#### 개념은 빈 행으로 분리하라
일련의 행 묶음은 완결된 생각 하나를 표현한다. 빈 행은 새로운 개념을 시작한다는 시각적 단서다.

#### 수직 거리
**변수 선언.** 변수는 사용하는 위치에 최대한 가까이 선언한다.

**인스턴스 변수.** 인스턴스 변수는 클래스 맨 처음에 선언한다.

**종속 함수.** 한 함수가 다른 함수를 호출한다면 두 함수는 세로로 가까이 배치한다. 또한 가능하다면 호출하는 함수를 호출되는 함수보다 먼저 배치한다.

**개념적 유사성.** 어떤 코드는 서로 끌어당긴다. 개념적인 친화도가 높기 때문이다. 친화도가 높을수록 코드를 가까이 배치한다.<br />
친화도가 높은 요인은 여러 가지다. 앞서 보았듯이, 한 함수가 다른 함수를 호출해 생기는 직접적인 종속성이 한 예다. 변수와 그 변수를 사용하는 함수도 한 예다. 하지만 그 외에도 친화도를 높이는 요인이 있다. 비슷한 동작을 수행하는 일군의 함수가 좋은 예다. 명명법이 똑같고 기본 기능이 유사하고 간단하다.

```java
public class Assert {
    static public void assertTrue(String message, boolean condition) {
        if (!condition)
            fail(message);
    }

    static public void assertTrue(bool condition) {
        assertTrue(null, condition);
    }

    static public void assertFalse(String message, boolean condition) {
        assertTrue(message, !condition);
    }

    static public void assertFalse(boolean condition) {
        assertFalse(null, condition);
    }
    ...
}
```

#### 세로 순서


#### 가로 공백과 밀집도
가로로는 공백을 사용해 밀접한 개념과 느슨한 개념을 표현한다.

```java
private void measureLine(String line) {
    lineCount++;
    int lineSize = line.length();
    totalChars += lineSize;
    lineWidthHistogram.addLine(lineSize, lineCount);
    recordWidestLine(lineSize);
}
```

할당 연산자를 강조하려고 앞뒤에 공백을 줬다. 할당문은 왼쪽 요소와 오른쪽 요소가 분명히 나뉜다. 공백을 넣으면 두 가지 주요 요소가 확실히 나뉜다는 사실이 더욱 명백해진다.

반면, 함수 이름과 이어지는 괄호 사이에는 공백을 넣지 않는다. 함수와 인수는 서로 밀접하기 때문이다. 함수를 호출하는 코드에서 괄호 안 인수는 공백으로 분리했다. 쉼표를 강조해 인수가 별개라는 사실을 보여주기 위해서다.

#### 가로 정렬

**들여쓰기 무시하기.** 때로는 간단한 if 문, 짧은 while 문, 짧은 함수에 들여쓰기 규칙을 무시하고픈 유혹이 생긴다. 이런 유혹에 빠질 때마다 나는 항상 원점으로 돌아가 들여쓰기를 넣는다.

```java
public class CommentWidget extends TextWidget
{
    public static final String REGEXP = "^#[%\r\n]*(?:(?:\r\n)|\n|\r)?";

    public CommentWidget(ParentWidget parent, String text){super(parent, text);}
    public String render() throws Exception {return "";}
}
```

위 코드를 다음과 같이 들여쓰기로 범위를 제대로 표현한 코드를 선호한다.

```java
public class CommentWidget extends TextWidget {
    public static final String REGEXP = "^#[%\r\n]*(?:(?:\r\n)|\n|\r)?";

    public CommentWidget(ParentWidget parent, String text) {
        super(parent, text);
    }

    public String render() throws Exception {
        return "";
    }
}
```

---

# **객체와 자료 구조**

---

# **오류 처리**

---

# **경계**

---

# **단위 테스트**

---

# **클래스**

---

# **시스템**

---

# **창발성**

---

# **동시성**
무엇보다 먼저, SRP를 준수한다. POJO를 사용해 스레드를 아는 코드와 스레드를 모르는 코드를 분리한다.

#### 동시성 방어 원칙
- 단일 책임 원칙 *Single Responsibility Principle, SRP*

    > SRP는 주어진 메서드/클래스/컴포넌트를 변경할 이유가 하나여야 한다는 원칙이다. 동시성은 복잡성 하나만으로도 따로 분리할 이유가 충분하다. 즉, 동시성 관련 코드는 다른 코드와 분리해야 한다.

- 자료 범위를 제한하라

    > 자료를 캡슐화 *encapsulation* 해서 공유 자료를 최대한 줄여라.

- 자료 사본을 사용하라

    > 공유 자원을 줄이려면 처음부터 공유하지 않는 방법이 제일 좋다. 어떤 경우에는 객체를 복사해 읽기 전용으로 사용하는 방법이 가능하다. 어떤 경우에는 각 스레드가 객체를 복사해 사용한 후 한 스레드가 해당 사본에서 결과를 가져오는 방법도 가능하다.

#### 라이브러리를 이해하라
- 언어가 제공하는 클래스를 검토하라.
- 스레드 환경에 안전한 컬렉션을 사용하라.

#### 실행 모델을 이해하라
- 생산자-소비자 *Producer-Consumer*
- 읽기-쓰기  *Readers-Writers*
- 식사하는 철학자들 *Dining Philosophers*

#### 동기화하는 메서드 사이에 존재하는 의존성을 이해하라
공유 클래스 하나에 동기화된 메서드가 여럿이라면 구현이 올바른지 다시 한 번 확인하기 바란다. 되도록이면 공유 객체 하나에는 메서드 하나만 사용하라.

#### 동기화하는 부분을 작게 만들어라
락은 스레드를 지연시키고 부하를 가중시킨다. 그러므로 여기저기서 synchronized 문을 남밯라는 코드는 바랍직하지 않다. 반면, 임계영역 *critical section* 은 반드시 보호해야 한다. 따라서, 코드를 짤 때는 임계영역 수를 최대한 줄여야 한다.

#### 스레드 코드 테스트하기
- 말이 안 되는 실패는 잠정적인 스레드 문제로 취급하라.
- 다중 스레드를 고려하지 않은 순차 코드부터 제대로 돌게 만들자.
- 다중 스레드를 쓰는 코드 부분을 다양한 환경에서 쉽게 끼워 넣을 수 있도록 스레드 코드를 구현하라.
- 다중 스레드를 쓰는 코드 부분을 상황에 맞게 조정할 수 있게 작성하라.
- 프로세서 수보다 많은 스레드를 돌려보라.
- 다른 플랫폼에서 돌려보라.
- 코드에 보조 코드 *instrument* 를 넣어 돌려라. 강제로 실패를 일으키게 해보라.

---

# **점진적인 개선**

---

# **JUnit 들여다보기**

---

# **SerialDate 리팩터링**

---

# **냄새와 휴리스틱**
