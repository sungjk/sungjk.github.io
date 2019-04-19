---
layout: entry
post-category: java
title: 자바 성능 튜닝 이야기 - 3
author: 김성중
author-email: ajax0615@gmail.com
description: 이상민님의 '자바 성능 튜닝 이야기'를 읽고 정리한 글입니다.
keywords: Java, 자바
next_url: /2019/04/16/java-performance-tuning-4.html
publish: true
---

![java_performance_tuning](/images/2019/03/28/java_performance_tuning.jpeg "java_performance_tuning"){: .center-image }

# 11. JSP와 서블릿, Spring에서 발생할 수 있는 여러 문제점
JSP의 라이프 사이클은 다음의 단계를 거친다.

1. JSP URL 호출
2. 페이지 번역
3. JSP 페이지 컴파일
4. 클래스 로드
5. 인스턴스 생성
6. jspInit 메서드 호출
7. \_jspService 메서드 호출
8. jspDestroy 메서드 호출

여기서 해당 JSP 페이지가 이미 컴파일되어 있고, 클래스가 로드외어 있고, JSP 파일이 변경되지 않았다면, 가장 많은 시간이 소요되는 2~4 프로세스는 생략된다. 서버의 종류에 따라서 서버가 기동될 때 컴파일을 미리 수행하는 Precompile 옵션이 있다. 이 옵션을 선택하면 서버에 최신 버전을 반영한 이후에 처음 호출되었을 때 응답 시간이 느린 현상을 방지할 수 있다.

이번에는 서블릿의 라이프 사이클을 살펴보자. WAS의 JVM이 시작한 후에는,

- Servlet 객체가 자동으로 생성되고 초기화 되거나,
- 사용자가 해당 Servlet을 처음으로 호출했을 때 생성되고 초기화 된다.

![servlet-life-cycle](/images/2019/04/06/servlet-life-cycle.png "servlet-life-cycle"){: .center-image }

그 다음에는 계속 \'사용 가능\' 상태로 대기한다. 그리고 중간에 예외가 발생하면 \'사용 불가능\' 상태로 빠졌다가 다시 \'사용 가능\' 상태로 변환되기도 한다. 그리고 나서, 해당 서블릿이 더 이상 필요 없을 때는 \'파기\' 상태로 넘어간 후 JVM에서 \'제거\'된다.

서블릿은 JVM에 여러 객체로 생성되지 않는다. 다시 말해서 WAS가 시작하고, \'사용 가능\' 상태가 된 이상 대부분의 서블릿은 JVM에 살아있고, 여러 스레드에서 해당 서블릿의 service() 메서드를 호출하여 공유한다.

만약 서블릿 클래스의 메서드 내에 선언한 지역변수가 아닌 멤버변수(인스턴스 변수)를 선언하여 service() 메서드에서 사용하면 어떤 일이 벌어질까?

```java
public class DontUserLikeThisServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;
  String successFlag = "N";

  public DontUserLikeThisServlet() {
    super();
  }

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    successFlag = request.getParameter("successFlag");
  }
}
```

successFlag 값은 여러 스레드에서 접근하면서 계속 바뀔 것이다. static을 사용하는 것과 거의 동일한 결과를 나타낸다. 그러므로, service() 메서드를 구현할 때는 멤버 변수나 static한 클래스 변수를 선언하여 지속적으로 변경하는 작업은 피하기 바란다.

### 적절한 include 사용하기
JSP에서 사용할 수 있는 include 방식은 정적진 방식(include directive)과 동적인 방식(include action)이 있다. 정적인 방식은 JSP의 라이플 사이클 중 JSP 페이지 번역 및 컴파일 단계에서 필요한 JSP를 읽어서 메인 JSP의 자바 소스 및 클래스에 포함을 시키는 방식이다. 이와 반대로, 동적인 방식은 페이지가 호출될 때마다 지정된 페이지를 불러들여서 수행하도록 되어 있다.

- 정적인 방식: <%@include file=\"FILE_URL\"%>
- 동적인 방식: <jsp:include page=\"FILE_URL\"/>

동적인 방식이 정직인 방식보다 느릴 수밖에 없다. 정적인 방식과 동적인 방식의 응답 속도를 비교해보면 동적인 방식이 약 30배 더 느리게 나타난다. 즉, 성능을 더 빠르게 하려면 정적인 방식을 사용해야 한다는 의미다. 하지만 모든 화면을 정적인 방식으로 구성하면 잘 수행되던 화면에서 오류가 발생할 수 있다. 정적인 방식을 사용하면 메인 JSP에 추가되는 JSP가 생긴다. 이 때 추가된 JSP와 메인 JSP에 동일한 이름의 변수가 있으면 심각한 오류가 발생할 수 있다.

### 자바 빈즈, 잘 쓰면 약 못 쓰면 독
자바 빈즈(Java Beans)는 UI에서 서버 측 데이터를 담아서 처리하기 위한 컴포넌트이다. 자바 빈즈를 통하여 userBean을 하면 성능에 많은 영향을 미치지는 않지만, 너무 많이 사용하면 JSP에서 소요되는 시간이 증가될 수 있다.

한 두 개의 자바 빈즈를 사용하는 것은 상관없지만, 10~20개의 자바 빈즈를 사용하면 성능에 영향을 주게 된다. 그러므로 TO(Transfer Object) 패턴을 사용하도록 하자.

### 스프링 프레임워크 간단 정리
스프링의 핵심 기술은 바로 Dependency Injection, Aspect Oriented Programming, Portable Service Abstraction으로 함축할 수 있다.

![spring-triangle](/images/2019/04/06/spring-triangle.png "spring-triangle"){: .center-image }

Dependency Injection(의존성 주입)은 객체 간의 의존 관계를 관리하는 기술 정도로 생각하면 된다. 객체는 보통 혼자서 모든 일을 처리하지 않고, 여러 다른 객체와 협엽하여 일을 처리한다. 이때 자신과 협업하는 객체와 자신과의 의존성을 가능한 낮춰야 유리하다. 다시 말해서, 어떤 객체가 필요로 하는 객체를 자기 자신이 직접 생성하여 사용하는 것이 아니라 외부에 있는 다른 무언가로부터 필요로 하는 객체를 주입 받는 기술이다. 스프링은 이렇게 의존성을 쉽게 주입하는 틀을 제공한다. XML이나 어노테이션 등으로 의존성을 주입하는 방법을 제공하며 생성자 주입, 세터 주입, 필드 주입 등 다양한 의존성 주입 방법을 제공하고 있다.

AOP(Aspect Oriented Programming)는 우리나라 말로 \'관점 지향 프로그래밍\'이라고 부른다. 이 기술은 OOP를 보다 더 OOP스럽게 보완해주는 기술이다. 트랜잭션, 로깅, 보완 체크 코드 등은 대부분 비슷한 코드가 중복된다. 이런 코드를 실제 비즈니스 로직과 분리할 수 있도록 도와주는 것이 바로 AOP이다. 이 기술을 잘 활용하면 핵심 비즈니스 코드의 가독성을 높여준다.

마지막으로 스프링이 제공하는 핵심 기술로 PSA를 꼽을 수 있다. 사용 중인 라이브러리나 프레임워크를 바꿔야할 때 심각한 문제가 발생할 수 있어서 추상화가 중요하다. 스프링은 그런 일이 생기지 않도록 비슷한 기술을 모두 아우를 수 있는 추상화 계층을 제공하여, 사용하는 기술이 바뀌더라도 비즈니스 로직의 변화가 없도록 도와준다.

### 스프링 프레임워크를 사용하면서 발생할 수 있는 문제점들
빈 설정을 잘못해서 발생하는 문제도 있을 수 있고, 스프링의 동작 원리를 이해하지 않고서는 해결되지 않는 문제도 발생할 수 있다.

스프링 프레임워크를 사용할 때 성능 문제가 가장 많이 발생하는 부분은 \'프록시(proxy)\'와 관련되어 있다. 스프링 프록시는 기본적으로 실행 시에 생성된다. 따라서, 개발할 때 적은 요청에는 이상이 없다가 요청량이 많은 운영 상황으로 넘어가면 문제가 나타날 수 있다. 스프링이 프록시를 사용하게 하는 주요 기능은 바로 트랜잭션이다. \@Transactional 어노테이션을 사용하면 해당 어노테이션을 사용한 클래스의 인스턴스를 처음 만들 때 프록시 객체를 만든다. 이밖에도, 개발자가 직접 스프링 AOP를 사용해서 별도의 기능을 추가하는 경우에도 프록시를 사용하는데, 이 부분에서 문제가 가장 많이 발생한다. \@Transactional처럼 스프링이 자체적으로 제공하는 기능은 이미 상당히 오랜 시간 테스트를 거치고 많은 사용자에게 검증을 받았지만, 개발자가 직접 작성한 AOP 코드는 예상하지 못한 성능 문제를 보일 가능성이 매우 높다. 따라서, 간단한 부하 툴을 사용해서라도 성능적인 면을 테스트해야만 한다.

추가로, 스프링이 내부 매커니즘에서 사용하는 캐시도 조심해서 써야 한다.

```java
public class SampleController {
  @RequestMapping("/member/{id}")
  public String hello(@PathVariable int id) {
    return "redirect:/member/" + id;
  }
}
```

이렇게 문자열 자체를 리턴하면 스프링은 해당 문자열에 해당하는 실제 뷰 객체를 찾는 매커니즘을 사용하는데, 이 때 매번 동일한 문자열에 대한 뷰 객체를 새로 찾기 보다는 이미 찾아본 뷰 객체를 캐싱해두면 다음에도 동일한 문자열이 반환됐을 때 훨씬 빠르게 뷰 객체를 찾을 수 있다. 스프링에서 제공하는 ViewResolver 중에 자주 사용되는 InternalResourceViewResolver에는 그러한 캐싱 기능이 내장되어 있다.

만약 매번 다른 문자열이 생성될 가능성이 높고, 상당히 많은 수의 키 값으로 캐시 값이 생성될 여지가 있는 상황에서는 문자열을 반환하는 게 메모리에 치명적일 수 있다. 따라서 이런 상황에서는 뷰 이름을 문자열로 반환하기보다는 뷰 객체 자체를 반환하는 방법이 메모리 릭을 방지하는 데 도움이 된다.

```java
public class SampleController {
  @RequestMapping("/member/{id}")
  public View hello(@PathVariable int id) {
    return new RedirectView("/member/" + id);
  }
}
```

---

# 12. DB를 사용하면서 발생 가능한 문제점들

### DB Connection과 Connection Pool, DataSource
JDBC 관련 API는 클래스가 아니라 인터페이스다. JDK의 API에 있는 java.sql 인터페이스를 각 DB 벤더에서 상황에 맞게 구현하도록 되어 있다. 같은 인터페이스라고 해도, 각 DB 벤더에 따라서 처리되는 속도나 내부 처리 방식은 상이하다.

Connection 객체를 생성하는 부분에서 발생하는 대기 시간을 줄이고, 네트워크의 부담을 줄이기 위해서 사용하는 것이 DB Connection Pool이다.

Statement와 PreparedStatement의 가장 큰 차이점은 캐시(cache) 사용 여부이다. Statement를 사용할 때와 PreparedStatement를 처음 사용할 때는 다음과 같은 프로세스를 거친다.

1. 쿼리 문장 분석
2. 컴파일
3. 실행

Statement를 사용하면 매번 쿼리를 수행할 때마다 1~3 단계를 거치고, PreparedStatement는 처음 한 번만 세 단계를 거친 후 캐시에 담아서 재사용한다. 동일한 쿼리를 반복적으로 수행한다면 PreparedStatement가 DB에 훨씬 적은 부하를 주며, 성능도 좋다.

### DB를 사용할 때 닫아야 하는 것들
ResultSet 객체가 닫히는 경우는 다음과 같다.

- close() 메서드를 호출하는 경우
- GC의 대상이 되어 GC되는 경우
- 관련된 Statement 객체의 close() 메서드가 호출되는 경우

GC가 되면 자동으로 닫히고, Statement 객체가 close되면 알아서 닫히지만, 0.00001초라도 빨리 닫으면 그만큼 해당 DB 서버의 부담이 적어지게 된다.

Conenction 객체는 다음 세 가지 경우에 닫히게 된다.

- close() 메서드를 호출하는 경우
- GC의 대상이 되어 GC되는 경우
- 치명적인 에러가 발생하는 경우

```java
connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
  ...
} catch (Exception e) {
  ...
} finally {
  try { rs.close(); } catch (Exception rse) {}
  try { ps.close(); } catch (Exception pse) {}
  try { conn.close(); } catch (Exception conne) {}
}
```

### JDK 7에서 등장한 AutoClosable 인터페이스
try 블록이 시작될 때 소괄호 안에 close() 메서드를 호출하는 객체를 생성해 주면 간단하게 처리할 수 있다.

```java
public String readFileNew(String fileName) throws IOException {
  FileReader reader = new FileReader(new FIle(fileName));
  try (BufferedReader br = new BufferedReader(reader)) {
    return br.readLine();
  }
}
```

별도로 finally 블록에서 close() 메서드를 호출할 필요가 없어졌다. 만약 close() 메서드 호출 대상이 여러 개라면 세미콜론으로 구분하여 try-with-resources 구문에 두 개 이상의 문장을 추가하면 된다.

### JDBC를 사용하면서 유의할 만한 몇 가지 팁

- setAutoCommit() 메서드는 필요할 때만 사용하자. 여러 개의 쿼리를 동시에 작업할 때 성능에 영향을 주게 되므로 되도록 자제하자.
- 배치성 작업은 executeBatch() 메서드를 사용하자. 여러 개의 쿼리를 한 번에 수행할 수 있기 때문에 JDBC 호출 횟수가 감소되어 성능이 좋아진다.
- setFetchSize() 메서드를 사용하여 데이터를 더 빠르게 가져오자.
- 한 건만 필요할 때는 한 건만 가져오자.

---

# 13. XML과 JSON도 잘 쓰자

| 데이터 개수 | XML SAX | XML DOM | JSON |
| :---: | :---: | :---: | :---: |
| 100 | 847 | 1,395 | 245 |
| 1,000 | 3,925 | 7,129 | 1,379 |

이 결과만 보면 XML 파싱이 JSON 보다 매우 느리다고 생각할 수 있다. 그런데, 데이터를 전송하기 위해서 XML 및 JSON 데이터를 Serialize나 Deserialize 할 경우도 있다. JSON 데이터는 Serialize와 Deserialize를 처리하는 성능이 좋지 않다. XML 파서보다 JSON 파서가 더 느린 경우가 대부분이다.

JSON이나 XML은 데이터가 커질수록 전송해야 하는 양도 증가하고, 파싱하는 성능도 무시할 수 없다. 그래서 protobuf, Thrift, avro 등의 오픈소스가 많이 사용되고 있다.

---

# 14. 서버를 어떻게 세팅해야 할까?

### 웹 서버의 Keep Alive
웹 서버와 웹 브라우저가 연결 되었을때 KeepAlive 기능이 켜져 있지 않으면, 매번 HTTP 연결을 맺었다 끊었다 하는 작업을 반복한다. KeepAlive 기능이 켜져 있으면 두 개 정도의 연결을 열어서 끊지 않고, 연결을 계속 재사용할 수 있다. KeepAlive 설정을 할 때는 반드시 KeepAlive-Timeout 설정도 같이 해야 한다. 이 설정은 초 단위로 KeepAlive가 끊기는 시간을 설정하기 위한 부분이다. 마지막 연결이 끝난 이후에 다음 연결이 될 때까지 얼마나 기다릴지를 지정한다.

```java
KeepAliveTimeout 15
```
사용자가 너무 많아 접속이 잘 안될 경우, 이 설정을 5초 정도로 짧게 주는 것도 서버의 리소스를 보다 효율적으로 사용할 수 있는 방법이다.

### DB Connection Pool 및 스레드 개수 설정
DB Connection Pool은 보통 40~50개로 지정하며, 스레드 개수는 이보다 10개 정도 더 지정한다. 가장 좋은 방법은 성능 테스트를 통해서 가장 적절한 값을 구하는 것이다.

DB의 CPU 사용량이 100%에 도달했다면 CPU를 점유하는 쿼리를 찾아서 튜닝해야 한다. 인덱스가 없거나 테이블을 풀 스캔하는 쿼리가 있는건 아닌지 쿼리의 플랜을 떠서 확인해 봐야 한다.

DB의 CPU 사용량이 50%도 되지 않는 상황에서 WAS의 CPU 사용량이 100%에 도달했다면 WAS의 애플리케이션을 튜닝해야 한다. 이미 튜닝된 상태라면 서버의 DB Connection Pool의 개수는 약간 여유를 두기 위해서 25~30개 정도로 지정하는 것이 좋다(서버를 늘리는 것은 가장 마지막에 해야 한다).

Connection Pool의 개수만큼 중요한 값이 대기 시간(wait time)과 관련된 값이다. DB Connection Pool의 개수를 넘어 섰을 때 애플리케이션에서는 \'어디 남는 Connection 없나?\' 하고 두리번거리면서 기다린다. 대기 시간이 20초라면 DB 연결을 못해 기다리는 사용자들이 적어도 20초는 대기해야 한다는 말이다.

대기 시간을 100ms 정도로 줄 경우에는 문제가 없을까? 필자가 경험한바로는 메모리를 1GB로 할당한 WAS에서 300ms 이하의 Full GC 시간을 만들기는 매우 어렵다. 만약 DB 연결을 하려고 대기하는 순간 Full GC가 발생하면 그 순간에 대기하고 있는 모든 스레드는 DB와 연결을 못했다고 Timeout을 내뿜을 수도 있다.

### WAS 인스턴스 개수 설정
예를 들어 CPU core 개수가 모두 36개인 장비가 있다. 인스턴스가 1개 일때 500 TPS가 나오고, 인스턴스가 2개 일때 700 TPS, 인스턴스가 3개 일때 720 TPS, 4개 일때 730 TPS가 나온다고 가정하다. 필자라면 이 상황에서 인스턴스를 2~3개 정도만 띄울 것이다. 인스턴스를 더 늘린다고 해서 TPS가 증가하지 않는 상황에서는 오히려 유지보수성만 떨어지기 때문이다.

만약 WAS 장비에 4GB의 여유 메모리가 있다고 하더라도 하나의 인스턴스에 4GB의 메모리를 지정하여 사용하는 것은 굉장히 좋지 않은 방법이다. 왜냐하면 Full GC가 발생할 때마다 많은 시간이 소요될 확률이 커지기 때문이다. 가급적이면 512MB~2GB 사이에서 메모리를 지정하는 것이 좋다. 예를 들어 1GB로 메모리를 지정하여 2개의 인스턴스를 사용하는 것이 좋은 방법일 것이다.

### Session Timeout 시간 설정
WAS에서 따로 설정한 바가 없거나 세션 객체의 invalidate() 메서드가 수행되지 않으면 세션은 삭제되지 않으므로 유의하자.

---

# 15. 안드로이드 개발하면서 이것만은 피하자

### 일반적인 서버 프로그램 개발과 안드로이드 개발은 다르다
안드로이드는 오라클이나 IBM에서 만든 JVM을 사용하지 않고, Dalvik VM이라는 것을 사용한다.

![java-code](/images/2019/04/06/javacode.png "java-code"){: .center-image }

첫번째 컴파일은 javac를 통해서 수행되며, 두번째 컴파일은 dex라는 구글에서 제공하는 컴파일러에서 수행한다. 자바와 문법은 같지만 컴파일러와 가상 머신(VM)은 다르다.

윈도우, 맥, 리눅스 장비는 물리적인 RAM이 부족할 경우 디스크를 메모리처럼 사용하는 SWAP이 발생하지만, 안드로이드의 경우 이러한 SWAP이 존재핮 ㅣ않는다.

### 구글에서 이야기하는 안드로이드 성능 개선

- **Avoid Creating Unnecessary Objects**
- **Prefer Static Over Virtual**: 만약 인스턴스 변수에 접근할 일이 없을 경우엔 static 메서드를 선언하여 호출하는 것은 15~20%의 성능 개선이 발생할 수 있다.
- **Use Static Final For Constants**: 변하지 않는 상수를 선언할 때 static final로 선언할 경우와 static으로 선언할 때 저장되고 참조되는 위치가 달라진다. static final이 접근 속도가 훨씬 빠르다.
- **Avoid Internal Getters/Setters**: 인스턴스 변수에 직접 접근하는 것이 getter나 setter 메서드를 사용하여 접근하는 것보다 빠르다. JIT 컴파일러가 적용되지 않을 경우 3배, 적용될 경우 7배 정도 빠르다.
- **Use Enhanced For Loop Syntax**: Iterable 인터페이스를 사용하는 대부분의 Collection에서 제공하는 클래스들은 전통적인 for 루프를 사용하는 것보다 for-each 루프를 사용하는 방법이 더 성능상 유리하다. 하지만 ArrayList는 전통적인 for 루프가 3배 빠르다.
- **Consider Package Instead of Private Access with Private Inner Classes**: 자바에서 Inner 클래스는 감싸고 있는 클래스의 private 변수를 접근할 수 있다. 그런데 VM에서는 내부 클래스와 감싸고 있는 클래스는 다른 클래스로 인식한다. 그래서 컴파일러는 감싸고 있는 클래스의 private 변수에 접근할 수 있는 메서드를 자동으로 생성해 준다. 따라서 변수에 직접 접근이 불가하므로 getter나 setter를 사용하는 것처럼 성능이 저하된다.
- **Avoid Using Floating-Point**: 안드로이드 기기에서는 정수 연산보다 소수점 연산이 2배 느리다. 그리고 double이 float보다 2배의 저장 공간을 사용하므로, 가능하다면 float을 사용하는 것을 권장한다.
- **Know and User the Libraries**: 직접 만드는 것보다 API에서 제공하는 클래스와 메서드가 훨씬 더 빠를 수 있다. 예를 들어 배열을 복사할 때 System.arraycopy() 메서드를 사용하면 루프를 사용하는 것보다 9배 이상 빠르다.
- **Use Native Methods Carefully**

### 안드로이드에서는 이미지 처리만 잘해도 성능이 좋아진다

- 이미지 크기가 얼마나 되나 확인해보자.
- ImageView의 setImageResource() 메서드 사용을 자제하자. 이 메서드를 사용하면 Bitmap 이미지를 읽고 디코딩하는 작업을 UI 스레드에서 수행하기 때문에 응답 시간이 저하된다. 따라서 setImageDrawable이나 setImageBitmap 메서드를 사용하고, BitmapFactory 사용을 권장하고 있다. 추가로 ImageView를 사용하는 것보다 WebView를 사용할 경우에도 큰 효과를 볼 수 있다.

---

# References
- [개발자가 반드시 알아야 할 자바 성능 튜닝 이야기](http://www.yes24.com/Product/Goods/11261731)
- [Servlet Life Cycle](https://sridharu.wordpress.com/2016/01/31/servlet-life-cycle/)
- [Closer Look At Android Runtime: DVM vs ART](https://android.jlelse.eu/closer-look-at-android-runtime-dvm-vs-art-1dc5240c3924)
