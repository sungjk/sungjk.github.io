---
layout: entry
title: Clean Code
author: 김성중
author-email: ajax0615@gmail.com
description: 로버트 C. 마틴의 Clean Code를 읽고 정리한 글입니다.
next_url: /2017/07/31/effective-java-1.html
keywords: clean code, 클린코드
publish: true
---

![clean-code](/images/2017/07/27/clean-code.jpg "clean-code"){: .center-image }

로버트 C. 마틴의 Clean Code를 읽고 정리를 한 글입니다. 본 포스팅에 14장(점진적인 개선), 15장(JUnit 들여다보기), 16장(SerialDate 리팩터링), 17장(냄새와 휴리스틱)은 제외하였고, 정리한 내용에 대해 구체적인 이유가 적혀 있지 않은 것들은 책을 통해 직접 확인하시면 좋겠습니다.

---

# 2장. 의미 있는 이름
프로그래머는 코드를 최대한 이해하기 쉽게 짜야 한다. 집중적인 탐구가 필요한 코드가 아니라 대충 훑어봐도 이해할 코드 작성이 목표다.

- 의도를 분명히 밝혀라
- 그릇된 정보를 피하라
- 의미 있게 구분하라
- 발음하기 쉬운 이름을 사용하라
- 검색하기 쉬운 이름을 사용하라
- 인코딩을 피하라
- 자신의 기억력을 자랑하지 마라
- 클래스나 객체 이름은 명사나 명사구가 적합하다
- 메서드 이름은 동사나 동사구가 적합하다
- 기발한 이름은 피하라
- 한 개념에 한 단어를 사용하라
- 말장난을 하지 마라
- 해법 영역에서 가져온 이름을 사용하라
- 문제 영역에서 가져온 이름을 사용하라
- 의미 있는 맥락을 추가하라
- 불필요한 맥락을 없애라

---

# 3장. 함수
우리가 함수를 만드는 이유는 큰 개념을 (다시 말해, 함수 이름을) 다음 추상화 수준에서 여러 단계로 나눠 수행하기 위해서이다.

#### **작게 만들어라!**
함수를 만드는 첫째 규칙은 '작게!'다. 함수를 만드는 둘째 규칙은 '더 작게'다.

#### **한 가지만 해라!**
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

지정된 함수 이름 아래에서 추상화 수준이 하나인 단계만 수행한다면 그 함수는 한 가지 작업만 한다. 따라서, 의미 있는 이름으로 다른 함수를 추출할 수 있다면 그 함수는 여러 작업을 하는 셈이다.

#### **함수당 추상화 수준은 하나로!**
함수가 확실히 '한 가지' 작업만 하려면 함수 내 모든 문장의 추상화 수준이 동일해야 한다.

한 함수 다음에는 추상화 수준이 한 단계 낮은 함수가 온다. 즉, 위에서 아래로 프로그램을 읽으면 함수 추상화 수준이 한 번에 한 단계씩 낮아진다. 이것을 **내려가기**(위에서 아래로 코드를 읽는) 규칙이라 부른다.

하지만 추상화 수준이 하나인 함수를 구현하기란 쉽지 않다. 핵심은 짧으면서도 '한 가지'만 하는 함수다.

#### **서술적인 이름을 사용하라!**
> \"코드를 읽으면서 짐작했던 기능을 각 루틴이 그대로 수행했다면 깨끗한 코드라 불러도 되겠다.\"

- 한 가지만 하는 작은 함수에 좋은 이름을 붙인다면 이런 원칙을 달성함에 있어 이미 절반은 성공했다.
- 함수가 작고 단순할수록 서술적인 이름을 고르기도 쉬워진다.
- 길고 서술적인 이름이 짧고 어려운 이름보다 좋다.
- 이름을 정하느라 시간을 들여도 괜찮다.
- 이름을 붙일 때는 일관성이 있어야 한다. 모듈 내에서 함수 이름은 같은 문구, 명사, 동사를 사용한다. includeSetupAndTeardownPages, includeSetupPages, includeSuiteSetupPage, includeSetupPage 등이 좋은 예다.

#### **함수 인수**
함수에서 이상적인 인수 개수는 0개(무항)다. 다음은 1개(단항)고, 다음은 2개(이항)다. 3개(삼항)은 가능한 피하는 편이 좋다. 4개 이상(다항)은 특별한 이유가 필요하다. 특별한 이유가 있어도 사용하면 안 된다. 최선은 입력 인수가 없는 경우이며, 차선은 입력 인수가 1개뿐인 경우다.

플래그 인수는 추하다. 왜냐하면 함수가 한꺼번에 여러 가지를 처리한다고 대놓고 공표하는 셈이기 때문이다.

인수가 2개인 함수는 인수가 1개인 함수보다 이해하기 어렵다. 예를 들어, writeField(name)는 writeField(outputStream, name)보다 이해하기 쉽다. 이항 함수가 무조건 나쁘다는 소리는 아니다. 하지만 그만큼 위험이 따른다는 사실을 이해하고 가능하면 단항 함수로 바꾸도록 애써야 한다. 예를 들어, writeField 메서드를 outputStream 클래스 구성원으로 만들어 outputStream.writeField(name)으로 호출한다. 아니면 outputStream을 현재 클래스 멤버 변수로 만들어 인수로 넘기지 않는다. 아니면 FieldWriter라는 새 클래스를 만들어 구성자에서 outputStream을 받고 write 메서드를 구현한다.

함수의 의도나 인수의 순서와 의돌르 제대로 표현하려면 좋은 함수 이름이 필수다. 단항 함수는 함수와 인수가 동사/명사 쌍을 이뤄야 한다. 예를 들어, writeField(name)은 누구나 곧바로 이해한다.

#### **부수 효과를 일으키지 마라!**
```java
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

#### **명령과 조회를 분리하라!**
함수는 뭔가를 수행하거나 뭔가에 답하거나 둘 중 하나만 해야 한다. 객체 상태를 변경하거나 아니면 객체 정보를 반환하거나 둘 중 하나다.

#### **오류 코드보다 예외를 사용하라!**
```java
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

```java
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

```java
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

# 4장. 주석
> "나쁜 코드에 주석을 달지 마라. 새로 짜라."

우리에게 프로그래밍 언어를 치밀하게 사용해 의도를 표현할 능력이 있다면, 주석은 거의 필요하지 않으리라. 우리는 코드로 의도를 표현하지 못해, 그러니까 실패를 만회하기 위해 주석을 사용한다. 주석을 달 때마다 자신에게 표현력이 없다는 사실을 푸념해야 마땅하다.

프로그래머들이 주석을 엄격하게 관리해야 한다고, 그래서 복구성과 관련성과 정확성이 언제나 높아야 한다고 주장할지도 모르겠다. 하지만 나라면 코드를 깔끔하게 정리하고 표현력을 강화하는 방향으로, 그래서 애초에 주석이 필요없는 방향으로 에너지를 쏟겠다. 진실은 한곳에만 존재한다. 바로 코드다.

#### **주석은 나쁜 코드를 보완하지 못한다**
표현력이 풍부하고 깔끔하며 주석이 거의 없는 코드가, 복잡하고 어수선하며 주석이 많이달린 코드보다 훨씬 좋다.

#### **코드로 의도를 표현하라!**
```java
// 직원에게 복지 혜택을 받을 자격이 있는지 검사한다.
if ((employee.flags & HOURLY_FLAG) && (employee.age > 65))
```

보다는

```java
if (employee.isEligibleForFullBenefits())
```

몇 초만 더 생각하면 코드로 대다수 의도를 표현할 수 있다. 많은 경우 주석으로 달려는 설명을 함수로 만들어 표현해도 충분하다.

#### **좋은 주석**
- 법적인 주석
- 정보를 제공하는 주석
- 의도를 설명하는 주석
- 의미를 명료하게 밝힌 주석: 인수나 반환값이 표준 라이브러리나 변경하지 못하는 코드에 속한다면 의미를 명료하게 밝히는 주석이 유용하다.
- 결과를 경고하는 주석
- TODO 주석
- 중요성을 강조하는 주석
- 공개 API에서 Javadocs

#### **나쁜 주석**
대다수 주석이 허술한 코드를 지탱하거나, 엉성한 코드를 변명하거나, 미숙한 결정을 합리화하는 등 프로그래머가 주절거리는 독백에서 크게 벗어나지 못한다.

- 주절거리는 주석: 주석을 달기로 결정했다면 충분한 시간을 들여 최고의 주석을 달도록 노력한다. 이해가 안되어 다른 모듈까지 뒤져야 하는 주석은 독자와 제대로 소통하지 못하는 주석이다. 그런 주석은 바이트만 낭비할 뿐이다.
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
- 너무 많은 정보: 흥미로운 역사나 관련 없는 정보를 장황하게 늘어놓지 마라.
- 모호한 관계: 주석과 주석이 설명하는 코드는 둘 사이 관계가 명백해야 한다.
- 함수 헤더: 짧고 한 가지만 수행하며 이름을 잘 붙인 함수가 주석으로 헤더를 추가한 함수보다 훨씬 좋다.
- 비공개 코드에서 Javadocs

---

# 5장. 형식 맞추기
오랜 시간이 지나 원래 코드의 흔적을 더 이상 찾아보기 어려울 정도로 코드가 바뀌어도 맨 처음 잡아놓은 구현 스타일과 가독성 수준은 유지보수 용이성과 확장성에 계속 영향을 미친다.

#### **적절한 행 길이를 유지하라**
큰 파일보다는 작은 파일이 이해하기 쉬우므로 적절한 행 길이를 유지해야 한다.

#### **개념은 빈 행으로 분리하라**
일련의 행 묶음은 완결된 생각 하나를 표현한다. 빈 행은 새로운 개념을 시작한다는 시각적 단서다.

#### **수직 거리**
**변수 선언**<br/>
변수는 사용하는 위치에 최대한 가까이 선언한다.

**인스턴스 변수**<br/>
인스턴스 변수는 클래스 맨 처음에 선언한다.

**종속 함수**<br/>
한 함수가 다른 함수를 호출한다면 두 함수는 세로로 가까이 배치한다. 또한 가능하다면 호출하는 함수를 호출되는 함수보다 먼저 배치한다.

**개념적 유사성**<br/>
어떤 코드는 서로 끌어당긴다. 개념적인 친화도가 높기 때문이다. 친화도가 높을수록 코드를 가까이 배치한다.<br />
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

#### **가로 공백과 밀집도**
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

#### **가로 정렬**
**들여쓰기 무시하기**<br/>
때로는 간단한 if 문, 짧은 while 문, 짧은 함수에 들여쓰기 규칙을 무시하고픈 유혹이 생긴다. 이런 유혹에 빠질 때마다 나는 항상 원점으로 돌아가 들여쓰기를 넣는다.

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

# 6장. 객체와 자료 구조

#### **자료 추상화**
추상 인터페이스를 제공해 사용자가 구현을 모른 채 자료의 핵심을 조작할 수 있어야 진정한 의미의 클래스다.

```java
// 구체적인 Point 클래스
public class Point {
  public double x;
  public double y;
}

// 추상적인 Point 클래스
public interface Point {
  double getX();
  double getY();
  void setCartesian(double x, double y);
  double getR();
  double getTheta();
  void setPolar(double r, double theta);
}

// 구체적인 Vehicle 클래스
public interface Vehicle {
  double getFuelTankCapacityInGallons();
  double getGallonsOfGasoline();
}

// 추상적인 Vehicle 클래스
public interface Vehicle {
  double getPercentFuelRemaining();
}
```

자료를 세세하게 공개하기보다는 추상적인 개념으로 표현하는 편이 좋다. 인터페이스나 get/set 함수만으로는 추상화가 이뤄지지 않는다. 개발자는 객체가 포함하는 자료를 표현할 가장 좋은 방법을 심각하게 고민해야 한다.

#### **자료/객체 비대칭**
복잡한 시스템을 짜다 보면 새로운 함수가 아니라 새로운 자료 타입이 필요한 경우가 생긴다. 이때는 클래스와 객체 지향 기법이 가장 적합하다. 반면, 새로운 자료 타입이 아니라 새로운 함수가 필요한 경우도 생긴다. 이 때는 절차적인 코드와 자료 구조가 좀 더 적합하다.

#### **디미터 법칙**
디미터 법칙은 모듈은 자신이 조작하는 객체의 속사정을 몰라야 한다는 법칙이다. 즉, 객체는 조회 함수로 내부 구조를 공개하면 안 된다는 의미다.

#### **자료 전달 객체**
자료 구조체의 전형적인 형태는 공개 변수만 있고 함수가 없는 클래스다. 이런 자료 구조체를 때로는 자료 전달 객체(Data Transfer Object, DTO)라 한다.

#### **결론**
객체는 동작을 공개하고 자료를 숨긴다. 그래서 기존 동작을 변경하지 않으면서 새 객체 타입을 추가하기 쉬운 반면, 기존 객체에 새 동작을 추가하기는 어렵다. 자료 구조는 별다른 동작 없이 자료를 노출한다. 그래서 기존 자료 구조에 새 동작을 추가하기는 쉬우나, 기존 함수에 새 자료 구조를 추가하기는 어렵다.

(어떤) 시스템을 구현할 때, 새로운 자료 타입을 추가하는 유연성이 필요하면 객체가 더 적합하다. 다른 경우도 새로운 동작을 추가하는 유연성이 필요하면 자료 구조와 절차적인 코드가 더 적합하다.

---

# 7장. 오류 처리
깨끗한 코드와 오류 처리는 확실히 연관성이 있다. 상당수 코드 기반은 전적으로 오류 처리 코드에 좌우된다.

#### **오류 코드보다 예외를 사용하라**
```java
public class DeviceController {
  ...

  public void sendShutDown() {
    try {
      tryToShutDown();
    } catch (DeviceShutDownError e) {
      logger.log(e);
    }
  }

  private void tryToShutDown() throws DeviceShutDownError {
    DeviceHandle handle = getHandle(DEV1);
    DeviceRecord record = retrieveDeviceRecord(handle);

    pauseDevice(handle);
    clearDeviceWorkQueue(handle);
    closeDevice(handle);
  }

  private DeviceHandle getHandle(DeviceID id) {
    ...
    throws new DeviceShutDownError("Invalid handle for: " + id.toString());
    ...
  }

  ...
}
```

뒤섞였던 개념, 즉 디바이스를 종료하는 알고리즘과 오류를 처리하는 알고리즘을 분리하여 코드를 깔끔하고, 품질도 나아졌다.

#### **Try-Catch-Finally 문부터 작성하라**
예외에서 프로그램 안에다 **범위를 정의한다** 는 사실은 매우 흥미롭다.

어떤 면에서 try 블록은 트랜잭션과 비슷하다. try 블록에서 무슨 일이 생기든지 catch 블록은 프로그램 상태를 일관성 있게 유지한다. 그러므로 예외가 발생할 코드를 짤 때는 Try-Catch-Finally 문으로 시작하는 편이 낫다.

#### **예외에 의미를 제공하라**
전후 상황을 충분히 덧붙여 오류 메시지에 정보를 담아 예외와 함께 던진다.

#### **호출자를 고려해 예외 클래스를 정의하라**
애플리케이션에서 오류를 정의할 때 프로그래머에게 가장 중요한 관심사는 **오류를 잡아내는 방법** 이 되어야 한다. 흔히 예외 클래스가 하나만 있어도 충분한 코드가 많다. 예외 클래스에 포함된 정보로 오류를 구분해도 괜찮은 경우가 그렇다. 한 예외는 잡아내고 다른 예외는 무시해도 괜찮은 경우라면 여러 예외 클래스를 사용한다.

#### **결론**
깨끗한 코드는 읽기도 좋아야 하지만 안정성도 높아야 한다. 이 둘은 상충하는 목표가 아니다. 오류 처리를 프로그램 논리와 분리해 독자적인 사안으로 고려하면 튼튼하고 깨끗한 코드를 작성할 수 있다. 오류 처리를 프로그램 논리와 분리하면 독립적인 추론이 가능해지며 코드 유지보수성도 크게 높아진다.

---

# 8장. 경계

#### **경계 살피고 익히기**
간단한 테스트 케이스를 작성해 외부 코드를 익히면 어떨가? 짐 뉴커크(Jim Newkirk)는 이를 **학습 테스트** 라 부른다. 학습 테스트는 프로그램에서 사용하려면 방식대로 외부 API를 호출한다. 통제된 환경에서 API를 제대로 이해하는지를 확인하는 셈이다.

#### **깨끗한 경계**
외부 패키지를 호출하는 코드를 가능한 줄여 경계를 관리하자. Map에서 봤듯이, 새로운 클래스로 경계를 감싸거나 아니면 ADAPTER 패턴을 사용해 우리가 원하는 인터페이스를 패키지가 제공하는 인터페이스로 변환하자.

---

# 9장. 단위 테스트

#### **TDD 법칙 세 가지**
1. **첫째 법칙**: 실패하는 단위 테스트를 작성할 때까지 실제 코드를 작성하지 않는다.
2. **둘째 법칙**: 컴파일은 실패하지 않으면서 실행히 실패하는 정도로만 단위 테스트를 작성한다.
3. **셋째 법칙**: 현재 실패하는 테스트를 통과할 정도로만 실제 코드를 작성한다.

#### **깨끗한 테스트 코드 유지하기**
실제 코드가 진화하면 테스트 코드도 변해야 한다. 그런데 테스트 코드가 지저분할 수록 변경이 어려워진다. 실제 코드를 변경해 기존 테스트 케이스가 실패하기 시작하면, 지저분한 코드로 인해, 실패하는 테스트 케이스를 점점 더 통과시키기 어려워진다. 그래서 테스트 코드는 계속해서 늘어가는 부담이 되어버린다.

**테스트 코드는 실제 코드 못지 않게 중요하다.** 테스트 코드는 이류 시민이 아니다. 테스트 코드는 사고와 설계와 주의가 필요하다. 실제 코드 못지 않게 깨끗하게 짜야 한다.

**테스트는 유연성, 유지보수성, 재사용성을 제공한다**<br/>
코드에 유연성, 유지보수성, 재사용성을 제공하는 버팀목이 바로 **단위 테스트** 다. 테스트 케이스가 없다면 모든 변경이 잠정적인 버그다. 실제 코드를 점검하는 자동화된 단위 테스트 슈트는 설계와 아키텍처를 최대한 깨끗하게 보존하는 열쇠다. 따라서 테스트 코드가 지저분하면 코드를 변경하는 능력이 떨어지며 코드 구조를 개선하는 능력도 떨어진다. 테스트 코드가 지저분할수록 실제 코드도 지저분해진다. 결국 테스트 코드를 잃어버리고 실제 코드도 망가진다.

#### **깨끗한 테스트 코드**
깨끗한 테스트 코드를 만들려면? 세 가지가 필요하다. 가독성, 가독성, 가독성.

잡다하고 세세한 코드를 거의 다 없애고, 테스트 코드는 본론에 돌입해 진짜 필요한 자료 유형과 함수만 사용한다.

#### **테스트 당 assert 하나**
assert 문이 단 하나인 함수는 결론이 하나라서 코드를 이해하기 쉽고 빠르다.

```java
public void testGetPageHierarchyAsXml() throws Exception {
  givenPages("PageOne", "PageOne.ChildOne", "PageTwo");

  whenRequestIsIssued("root", "type:pages");

  thenResponseShouldBeXML();
}

public void testGetPageHierarchyHasRightTags() throws Exception {
  givenPages("PageOne", "PageOne.ChildOne", "PageTwo");

  whenRequestIsIssued("root", "type:pages");

  thenResponseShouldContain(
    "<name>PageOne</name>", "<name>PageTwo</name>", "<name>ChildOne</name>"
  );
}
```

함수 이름을 바꿔 given-when-then이라는 관례를 사용했다. 그러면 테스트 코드를 읽기가 쉬워진다. 불행하게도, 위에서 보듯이, 테스트를 분리하면 중복되는 코드가 많아진다.

TEMPLATE METHOD 패턴을 사용하면 중복을 제거할 수 있다. 아니면 독자적인 클래스를 만들어 @Before 함수에 given/when 부분을 넣고 @Test 함수에 then 부분을 넣어도 된다.

나는 \'단일 assert 문\'이라는 규칙이 훌륭한 지침이라 생각한다. 대체로 나는 단일 assert를 지원하는 해당 분야 테스트 언어를 만들려 노력한다. 하지만 때로는 주저 없이 함수 하나에 여러 assert 넣기도 한다. 단지 assert 문 개수는 최대한 줄여야 좋다는 생각이다.

#### **테스트 당 개념 하나**
\"테스트 함수마다 한 개념만 테스트하라\"는 규칙이 더 낫겠다. 가장 좋은 규칙은 \"개념 당 assert 문 수를 최소로 줄여라\"와 \"테스트 함수 하나는 개념 하나만 테스트하라\"라 하겠다.

#### **F.I.R.S.T**
깨끗한 테스트는 다음 다섯 가지 규칙을 따른다.

- **빠르게(Fast)**: 테스트는 빨라야 한다.
- **독립적으로(Independent)**: 각 테스트는 서로 의존하면 안 된다. 한 테스트가 다음 테스트가 실행될 환경을 준비해서는 안 된다.
- **반복가능하게(Repeatable)**: 테스트는 어떤 환경에서도 반복 가능해야 한다.
- **자가검증하는(Self-Validating)**: 테스트는 부울(bool) 값으로 결과를 내야 한다.
- **적시에(Timely)**: 테스트는 적시에 작성해야 한다. 단위 테스트는 테스트하려는 실제 코드를 구현하기 직전에 구현한다.

#### **결론**
테스트 코드는 실제 코드의 유연성, 유지보수성, 재사용성을 보존하고 강화한다. 그러므로 테스트 코드는 지속적으로 깨끗하게 관리하자. 표현력을 높이고 간결하게 정리하자. 테스트 API를 구현해 도메인 특화 언어(Domain Specific Language, DSL)를 만들자.

---

# 10장. 클래스

#### **클래스 체계**
클래스를 정의하는 표준 자바 관례에 따르면, 정적 공개(static public) 상수, 정적 비공개(private) 변수, 비공개 인스턴스 변수, 공개 변수가 나오고, 변수 목록 다음에는 공개 함수가 나온다. 비공개 함수는 자신을 호출하는 공개 함수 직후에 넣는다. 즉, 추상화 단계가 순차적으로 내려간다.

#### **클래스는 작아야 한다.**
클래스 이름은 해당 클래스 책임을 기술해야 한다.

**단일 책임 원칙**<br/>
단일 책임 원칙(Single Responsibility Principle, SRP)은 클래스나 모듈을 **변경할 이유** 가 하나, 단 하나뿐이어야 한다는 원칙이다. 클래스는 책임, 즉 변경할 이유가 하나여야 한다는 의미다.

```java
// 단일 책임 클래스
public class Version {
  public int getMajorVersionNumber()
  public int getMinorVersionNumber()
  public int getBuildNumber()
}
```

큰 클래스 몇 개가 아니라 작은 클래스 여럿으로 이뤄진 시스템이 더 바람직하다. 작은 클래스는 각자 맡은 책임이 하나며, 변경할 이유가 하나며, 다른 작은 클래스와 협력해 시스템에 필요한 동작을 수행한다.

**응집도(Cohesion)**<br/>
응집도가 높다는 말은 클래스에 속한 메서드와 변수가 서로 의존하며 논리적인 단위로 묶인다는 의미다. \'함수를 작게, 매개변수 목록을 짧게\'라는 전략을 따르다 보면 때때로 몇몇 메서드만이 사용하는 인스턴스 변수가 아주 많아진다. 이는 십중팔구 새로운 클래스로 쪼개야 한다는 신호다. 응집도가 높아지도록 변수와 메서드를 적절히 분리해 새로운 클래스 두세 개로 쪼개준다.

**응집도를 유지하면 작은 클래스 여럿이 나온다**<br/>
예를 들어, 변수가 아주 많은 큰 함수가 하나 있다. 큰 함수 일부를 작은 함수로 빼내고 싶은데, 빼내려는 코드가 큰 함수에 정의된 변수 넷을 사용한다. 그렇다면 변수 네 개를 새 함수에 인수로 넘겨야 옳을까? 아니다! 만약 네 변수를 클래스 인스턴스 변수로 승격한다면 새 함수는 인수가 **필요없다.** 그만큼 함수를 쪼개기 **쉬워진다.** 불행히도 이렇게 하면 클래스가 응집력을 잃는다. 몇몇 함수만 사용하는 인스턴스 변수가 점점 더 늘어나기 때문이다. 클래스가 응집력을 잃는다면 쪼개라!

#### **변경하기 쉬운 클래스**
깨끗한 시스템은 클래스를 체계적으로 정리해 변경에 수반하는 위험을 낮춘다.

테스트가 가능할 정도로 시스템의 결합도를 낮추면 유연성과 재사용성도 더욱 높아진다. 결합도가 낮다는 소리는 각 시스템 요소가 다른 요소로부터 그리고 변경으로부터 잘 격리되어 있다는 의미다. 시스템 요소가 서로 잘 격리되어 있으면 각 요소를 이해하기도 더 쉬워진다.

---

# 12장. 창발성
컨트 벡은 다음 규칙을 따르면 설계는 \'단순하다\'고 말한다.

- 모든 테스트를 실행한다.
- 중복을 없앤다.
- 프로그래머 의도를 표현한다.
- 클래스와 메서드 수를 최소로 줄인다.

#### **단순한 설계 규칙 1: 모든 테스트를 실행하라**
문서로는 시스템을 완벽하게 설계했지만, 시스템이 의도한 대로 돌아가는지 검증할 간단한 방법이 없다면, 문서 작성을 위해 투자한 노력에 대한 가치는 인정받기 힘들다.

놀랍게도 \"테스트 케이스를 만들고 계속 돌려라\"라는 간단하고 단순한 규칙을 따르면 시스템은 낮은 결합도와 높은 응집력이라는, 객체 지향 방법론이 지향하는 목표로 저절로 달성한다. 즉, 테스트 케이스를 작성하면 설계 품질이 높아진다.

#### **단순한 설계 규칙 2~4: 리팩터링**
테스트 케이스를 모두 작성했다면 코드를 점진적으로 리팩터링 해나간다. **코드를 정리하면서 시스템이 깨질까 걱정할 필요가 없다. 테스트 케이스가 있으니까!**

리팩터링 단계에서는 응집도를 높이고, 결합도를 낮추고, 관심사를 분리하고, 시스템 관심사를 모듈로 나누고, 함수와 클래스 크기를 줄이고, 더 나은 이름을 선택하는 등 다양한 기법을 동원한다.

#### **중복을 없애라**
중복은 추가 작업, 추가 위험, 불필요한 복잡도를 뜻한다.

```java
public class VacationPolicy {
  public void accrueUSDivisionVacation() {
    // 지금까지 근무한 시간을 바탕으로 휴가 일수를 계산하는 코드
    // ...
    // 휴가 일수가 미국 최소 법정 일수를 만족하는지 확인하는 코드
    // ...
    // 휴가 일수를 급여 대장에 적용하는 코드
    // ...
  }

  public void accrueEUDivisionVacation() {
    // 지금까지 근무한 시간을 바탕으로 휴가 일수를 계산하는 코드
    // 휴가 일수가 유럽연합 최소 법정 일수를 만족하는지 확인하는 코드
    // ...
    // 휴가 일수를 급여 대장에 적용하는 코드
    // ...
  }
}
```

최조 법정 일수를 계산하는 코드만 제외하면 두 메서드는 거의 동일하다. TEMPLATE METHOD 패턴은 고차원 중복을 제거할 목적으로 자주 사용하는 기법이다. 여기에 이를 적용해 눈에 들어오는 중복을 제거한다.

```java
abstract public class VacationPolicy {
  public void accrueVacation() {
    calculateBaseVacationHours();
    alterForLegalMinimums();
    applyToPayroll();
  }

  private void calculateBaseVacationHours() { /* ... */ };
  abstract protected void alterForLegalMinimums();
  private void applyToPayroll() { /* ... */ };
}

public class USVacationPolicy extends VacationPolicy {
  @Override protected void alterForLegalMinimums() {
    // 미국 최소 법정 일수를 사용한다.
  }
}

public class EUVacationPolicy extends VacationPolicy {
  @Override protected void alterForLegalMinimums() {
    // 유럽연합 최소 법정 일수를 사용한다.
  }
}
```

#### **표현하라**
시스템이 점차 복잡해지면서 유지보수 개발자가 시스템을 이해하느라 보내는 시간은 점점 늘어나고 동시에 코드를 오해할 가능성도 점점 커진다. 그러므로 코드는 개발자의 의도를 분명히 표현해야 한다.

우선, **좋은 이름을 선택한다.**

둘째, **함수와 클래스 크기를 가능한 줄인다.**

셋째, **표준 명칭을 사용한다.** 예를 들어, 클래스가 COMMAND나 VISITOR와 같은 표준 패턴을 사용해 구현된다면 클래스 이름에 패턴 이름을 넣어준다.

넷째, **단위 테스트 케이스를 꼼꼼히 작성한다.**

나중에 코드를 읽을 사람은 바로 자신일 가능성이 높다는 사실을 명심하자.

#### **클래스와 메서드 수를 최소로 줄여라**
목표는 함수와 클래스 크기를 작게 유지하면서 동시에 시스템 크기도 작게 유지하는데 있다. 하지만 이 규칙은 간단한 설계 규칙 네 개 중 우선순위가 가장 낮다. 다시 말해, 클래스와 함수 수를 줄이는 작업도 중요하지만, 테스트 케이스를 만들고 중복을 제거하고 의도를 표현하는 작업이 더 중요하다는 뜻이다.

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

# Reference
- [Clean Code 클린 코드](http://www.yes24.co.kr/Product/goods/11681152)
