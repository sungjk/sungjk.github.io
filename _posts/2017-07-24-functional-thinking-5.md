---
layout: entry
post-category: fp
title: 함수형 사고(5)
author: 김성중
author-email: ajax0615@gmail.com
description: 함수형 사고 - 객체지향 개발자에서 함수형 개발자로 거듭나기
publish: true
---

함수형 언어에서의 코드 재사용은 객체지향 언어와는 접근 방법이 다르다. 객체지향 언어는 주로 수많은 자료구조와 거기에 딸린 수많은 연산을 포함한다. 반면에 함수형 언어에는 적은 수의 자료구조와 많은 연산들이 있기 마련이다. 객체지향 언어는 클래스에 종속된 메서드를 만드는 것을 권장하여 반복되는 패턴을 재사용하려 한다. 함수형 언어는 **자료구조에 대해 공통된 변형 연산을 적용하고, 특정 경우에 맞춰서 주어진 함수를 사용하여 작업을 커스터마이즈함으로써 재사용을 장려한다.**

# 5.1 적은 수의 자료구조, 많은 연산자
> 100개의 함수를 하나의 자료구조에 적용하는 것이 10개의 함수를 10개의 자료구조에 적용하는 것보다 낫다. -앨런 펄리스(Alan Perlis)

객체지향적인 명령형 프로그래밍 언어에서 재사용의 단위는 클래스와 그것들이 주고받는 메시지들이다. 이것들은 클래스 도표(class diagram)로 표시되곤 한다. 이 방면의 중요한 책인 "GoF의 디자인 패턴"에서는 각 패턴마다 적어도 하나씩의 클래스 도표를 제공한다. OOP 세상에서는 특정한 메서드가 장착된 특정한 자료구조를 개발자가 만들기를 권장한다. 함수형 프로그래밍 언어에서는 이 같은 방식으로 재사용을 하려 하지 않는다. 대신 몇몇 주요 자료구조(list, set, map)와 거기에 따른 최적화된 연산들을 선호한다. **이런 기계장치와 자료구조와 함수를 끼워 넣어서 특정한 목적에 맞게 커스터마이즈하는 것이다.** 예를 들면, 앞에서 여러 언어를 통해서 본 filter() 함수는 필터 조건을 결정하는 코드 블록을 플러그인 함수로 받고, 기계장치가 효율적으로 그 조건을 적용하여 필터된 목록을 리턴한다. 함수 수준에서 캡슐화하면 커스텀 클래스 구조를 만드는 것보다 좀 더 세밀하고 기본적인 수준에서 재사용이 가능해진다.

# 5.2 문제를 향하여 언어를 구부리기
대부분의 개발자들은 복잡한 비즈니스 문제를 자바와 같은 언어로 번역하는 것이 그들의 할 일이라고 착각 속에서 일을 한다. 자바가 언어로서 유연하지 못하기 때문에, 아이디어를 기존의 고정된 구조에 맞게 주물러야 하기 때문이다. 그런 개발자가 **유연한 언어를 접하면 문제를 언어에 맞게 구부리는(바꾸는) 대신 언어를 문제에 어울리게 구부릴 수 있다는 것을 깨닫게 된다.** 루비 같은 언어는 도메인 특화 언어(DSL)를 주류 언어들보다 잘 지원하기 때문에 이런 것이 가능하다. 현대적 함수형 언어들은 좀 더 진보했다. 스칼라는 내부 DSL을 지원하기 위해서 설계된 언어이고, 클로저와 같은 모든 리스프 계열 언어들도 개발자가 문제에 맞게 언어를 바꾸는 유연성 면에서 어떤 언어 못지않다.

예제 5-1. 스칼라의 XML용 문법적 설탕

```
import scala.xml._
import java.net._
import scala.io.Source

val theUrl = "https://query.yahooapis.com/v1/public/yql?q=select+*from+wheather.forecast+where+woeid=12770744&format=xml"

val xmlString = Source.fromURL(new URL(theUrl)).mkString
val xml = XML.loadString(xmlString)
val city = xml \\ "location" \\ "@city"
val state = xml \\ "location" \\ "@region"
val temperature = xml \\ "condition" \\ "@temp"

println(city + ", " + state + " " + temperature)
```

스칼라는 가단성(malleability, 소프트웨어에서 언어나 프레임워크가 사용하는 코드에 의해 용도나 반응이 변하는 성질)을 위해 설계되었기 때문에 연산자 오버로딩이나 묵시적 자료형 같은 확장이 가능하다. 위 코드에서는 스칼라를 확장해서 \\\\란 언산자를 사용하여 XPath 방식의 쿼리를 사용할 수 있었다.

특별히 함수형 언어만의 기능은 아니지만, 언어를 우아하게 문제 도메인으로 바꾸는 기능은 함수형, 선언형 방식의 현대 언어에서 흔히 볼 수 있다.

# 5.3 디스패치 다시 생각하기
3장에서 대안적 디스패치 방식의 한 예로 스칼라의 패턴 매칭을 살펴봤다. 여기서 디스패치란 넓은 의미로 언어가 작동 방식을 동적으로 선택하는 것을 말한다.

#### **5.3.1 그루비로 디스패치 개선하기**
자바에서 조건부 실행은 특별한 경우의 switch 문을 제외하고는 if 문을 사용하게 된다. if 문이 길게 연결되면 가독성이 떨어지기 때문에 자바 개발자들은 주로 GoF의 팩토리나 추상 팩토리 패턴을 사용한다. 좀 더 유연하게 결정을 표현할 수 있는 언어를 사용하면 이런 패턴들을 사용하지 않고도 간결하게 코드를 짤 수 있다.

예제 5-2. 그루비의 개선된 switch 문

```
class LetterGrade {
  def gradeFromScore(score) {
    switch (score) {
      case 90..100 : return "A"
      case 80..<90 : return "B"
      case 70..<80 : return "C"
      case 60..<70 : return "D"
      case 00..<60 : return "F"
      case ~"[ABCDFabcdf]": return score.toUpperCase()
      default: throw new IllegalArgumentException("Invalid score: ${score}")
    }
  }
}
```

위 코드는 점수를 받아서 그에 해당하는 학점을 리턴한다. 자바와는 달리, 그루비의 switch 문은 여러 가지 동적 자료형을 받을 수 있다. 매개변수 score는 0에서 100까지의 수나 학점이 될 수 있다. 자바처럼 폴-스루(fall-through; switch 문에서 조건이 맞지 않으면 바로 다음 조건으로 제어가 넘어가는 형식) 형식을 따라 각 경우를 return이나 break로 마쳐야 한다. 하지만 자바와는 다르게 그루비에서는 범위(90..100), 열린 범위(80..<90), 정규식(~\"[ABCDFabcdf]\"), 디폴트 조건을 모두 사용할 수 있다.

아래 코드의 유닛 테스트에서 볼 수 있듯이, 그루비는 동적 자료형을 사용하므로 매개변수로 다른 자료형을 넣어서 각각 그에 맞게 반응하게 하는 것이 가능하다.

예제 5-3. 그루비의 학점 코드 테스트하기

```
class LetterGradeText {
  @Test
  public void test_letter_grades() {
    def lg = new LetterGrade()
    assertEquals("A", lg.gradeFromScore(92))
    assertEquals("B", lg.gradeFromScore(85))
    assertEquals("D", lg.gradeFromScore(65))
    assertEquals("F", lg.gradeFromScore("f"))
  }
}
```

이렇게 강력한 switch 문은 if 문의 연속 사용과 팩토리 패턴의 중간 정도로 생각하고 간편하게 사용할 수 있다. 그루비의 switch 문은 범위나 다른 복합 자료형을 사용할 수 있다는 면에서 스칼라의 패턴 매칭과 유사한 용도로 사용된다.

#### **5.3.2 클로저 언어 구부리기**
자바나 자바 계열 언어들에는 키워드가 있다. 키워드들은 문법의 기반을 이룬다. 개발자들은 언어 내에서 키워드를 만들 수 없고(어떤 자바 계열의 언어는 메타프로그래밍을 통해 확장을 허용하기도 한다), 이 키워드들은 개발자들이 사용할 수 없는 것으로서 특별한 의미를 갖는다. 일례로 자바의 if 문은 단축(short-circuit) 불리언 평가 같은 것을 '이해'한다. 자바에서는 함수나 클래스를 만들 수 있지만 기초적인 빌딩 블록을 만드는 것은 불가능하다. 따라서 자바 개발자는 문제를 프로그래밍 언어로 번역해야 한다. 실질적으로 많은 개발자들은 이 번역 작업이 그들의 업무라고 생각한다. 클로저 같은 리스프 계열의 언어에서는 개발자가 언어를 문제에 맞게 변형할 수 있다. 즉 언어 설계자와 그 언어를 사용하는 개발자가 만들 수 있는 것들의 경계가 불분명해지게 된다.

예제 5-4. 클로저로 만든 학점 프로그램

```
(ns lettergrades)

(defn in [score low high]
  (and (number? score) (<= low score high)))

(defn letter-grade [score]
  (cond
  (in score 90 100) "A"
  (in score 80 90) "B"
  (in score 70 80) "C"
  (in score 60 70) "D"
  (in score 0 60) "F"
  (re-find #"[ABCDFabcdf]" score) (.toUpperCase score)))
```

위 코드에서는 읽기 좋은 letter-grade 함수를 만들고, 거기서 사용할 in 함수를 구현했다. 이 코드에서는 in 함수를 사용하여 cond 함수가 일련의 테스트를 평가한다. 앞에서 본 예제처럼 숫자와 문자로 된 변수를 다 처리할 수 있다. 궁극적으로 리턴 값은 대문자이기 때문에 소문자가 입력되면 toUpperCase 함수를 호출한다. 클로저에서는 클래스가 아니라 함수가 일급 시민이므로 함수 호출이 '뒤집어져' 보인다. 자바의 score.toUpperCase()는 클로저의 (.toUpperCase score)와 동등하다.

예제 5-5. 클로저 학점 프로그램 테스트

```
(ns lettergradetest
  (:use clojure.test)
  (:use lettergrades))

(deftest numeric-letter-grades
  (dorun (map #(is (= "A" (letter-grade %))) (range 90 100)))
  (dorun (map #(is (= "B" (letter-grade %))) (range 80 89)))
  (dorun (map #(is (= "C" (letter-grade %))) (range 70 79)))
  (dorun (map #(is (= "D" (letter-grade %))) (range 60 69)))
  (dorun (map #(is (= "F" (letter-grade %))) (range 0 59))))

(deftest string-letter-grades
  (dorun (map #(is (= (.toUpperCase %)
                  (letter-grade %))) ["A" "B" "C" "D" "F" "a" "b" "c" "d" "f"])))

(run-all-tests)
```

이 경우에는 테스트 코드가 구현된 코드보다 더 복잡하다! 하지만 이 예제로 클로저 코드가 얼마나 간결한지는 볼 수 있다.

numeric-letter-grades 테스트에서는 모든 입력 값의 범위를 점검한다. 안쪽부터 읽자면 #(is (= "A" (letter-grade %))) 코드 블록은 매개변수 하나를 받아서 학점이 제대로 주어지면 true를 리턴하는 익명함수를 만든다. map 함수는 이 익명함수를 둘째 매개변수인 컬렉션의 모든 요소들에 적용한다. 이 컬렉션은 적합한 범위에 속한 숫자들의 목록이다.

(dorun ) 함수는 부수효과가 있다. 테스트 프레임워크는 이 부수효과에 의존한다. 위 코드의 모든 범위에 대해 map 함수를 호출하면 모든 true 값의 목록을 리턴할 것이다. clojure.test 네임스페이스에서 (is ) 함수는 부수효과로서의 리턴 값을 확인해본다. (dorun ) 함수 안에서 매핑 함수를 호출하면 이 부수효과가 정확하게 일어나 모든 테스트를 실행한다.

#### **5.3.3 클로저의 멀티메서드와 맞춤식 다형성**
계속되는 if 문은 읽기도 어렵고 디버그하기는 더 어렵다. 하지만 자바에는 언어 수준에서 대체할 만한 적당한 것이 없다. 보통 이런 문제를 GoF의 팩토리나 추상 팩토리 패턴을 사용하여 해결한다. 팩토리 패턴은 클래스를 사용한 다형성(polymorphism)이므로 자바에서 사용할 만하다. 이 패턴을 사용하면 상위 클래스나 인터페이스에 일반적인 메서드 시그니처를 정해놓고, 동적으로 실행되게끔 구현하면 된다.

클로저가 다른 객체지향 언어의 모든 기능이 다른 기능들과는 별개로 구현되어 있다. 예를 들면 클로저가 다형성을 지원하지만 클래스를 평가해서 디스패치를 결정하는 것에 국한되어 있지는 않다. 클로저는 개발자가 원하는 대로 디스패치가 결정되는 다형성 멀티메서드를 지원한다.

예제 5-6. 클로저로 색 주고를 정의하기

```
(defstruct color :red :green :blue)

(defn red [v]
  (struct color v 0 0))

(defn green [v]
  (struct color 0 v 0))

(defn blue [v]
  (struct color 0 0 v))
```

위 코드는 세 가지 색깔 값을 저장하는 구조를 정의한다. 그리고 각각 한 색깔을 포함하는 구조를 리턴하는 세 메서드를 만들었다.

클로저의 **멀티메서드** 는 디스패치 결정 조건을 리턴하는 디스패치 함수를 받아들이는 메서드를 말한다. 그 다음에 딸려오는 정의로 메서드의 각기 다른 버전을 완성할 수 있다.

예제 5-7. 멀티메서드 정의하기

```
(defn basic-colors-in [color]
  (for [[k v] color :when (not= v 0)] k))

(defmulti color-string basic-colors-in)

(defmethod color-string [:red] [color]
  (str "Red: " (:red color)))

(defmethod color-string [:green] [color]
  (str "Green: " (:green color)))

(defmethod color-string [:blue] [color]
  (str "Blue: " (:blue color)))

(defmethod color-string :default [color]
  (str "Red: " (:red color) ", Green: " (:green color) ", Blue: " (:blue color)))
```

위 코드에서는 basic-colors-in이란 디스패치 함수를 정의한다. 이 함수는 정해진 모든 색깔들을 벡터 형태로 리턴한다. 이 함수를 변형하여, 디스패치 함수가 한 색깔을 리턴하는 경우 어떻게 될지를 지정했다. 그 경우 해당 색깔을 표시하는 문자열을 리턴하게 했다. 마지막 경우는 모두 다른 경우를 처리하는 :default 키워드를 포함한다. 이 경우에는 색깔을 한 가지만 받는다고 장담할 수 없기 때문에 모든 색깔의 목록을 리턴한다.

# 5.4 연산자 오버로딩
함수형 언어의 공통적인 기능은 연산자 오버로딩이다. 이것은 +, -, \*와 같은 연산자를 새로 정의하여 새로운 자료형에 적용하고 새로운 행동을 하게 하는 기능이다. 자바가 처음 만들어질 때는 의도적으로 연산자 오버로딩이 제외되었지만, 자바의 후계 언어들을 비롯해 거의 모든 현대 언어들에는 이 기능이 들어 있다.

#### **5.4.1 그루비**
그루비는 자바의 근본적인 의미를 유지하면서 그 문법을 개선하려 하는 언어다. 그러기 위해서 그루비는 연산자들을 메서드 이름에 자동으로 매핑하는 연산자 오버로딩을 허용한다. 일례로 정수 클래스에서 + 연산자를 오버로딩하려면 plus 메서드를 오버라이딩하면 된다.

표 5-1. 그루비의 연산자/메서드 매핑 목록의 일부

| :--- | :--- |
| 연산자 | 메서드 |
| :---: | :---: |
| x + y | x.plus() |
| x * y | x.multiply(y) |
| x / y | x.div(y) |
| x ** y | x.power(y) |

#### **5.4.2 스칼라**
스칼라는 연산자와 메서드의 차이점을 없애는 방법으로 연산자 오버로딩을 허용한다. 즉 **연산자는 특별한 이름을 가진 메서드에 불과하다.** 따라서 곱셈 연산자를 스칼라에서 오버라이드하려면 \* 메서드를 오버라이드하면 된다.

# 5.5 함수형 자료구조
자바에서는 언어 자체의 예외 생성 및 전파 기능을 사용하는 전통적인 방법으로 오류를 처리한다. 만약 구조적인 예외 처리 기능이 존재하지 않는다면 어떻게 될까? 대부분의 함수형 언어들은 예외 패러다임을 지원하지 않기 때문에 개발자는 다른 방법으로 오류 조건을 표현해야 한다.

예외는 많은 함수형 언어가 준수하는 전제 몇 가지를 깨뜨린다. 첫째, 함수형 언어는 부수효과가 없는 **순수** 함수를 선호한다. 그런데 예외를 발생시키는 것은 예외적인 프로그램 흐름을 야기하는 부수효과다. 함수형 언어들은 주로 **값** 을 처리하기 때문에 프로그램의 흐름을 막기보다는 오류를 나타내는 리턴 값에 반응하는 것을 선호한다.

함수형 프로그램이 선호하는 또 하나의 특성은 **참조 투명성** 이다. 호출하는 입장에서는 단순한 값 하나를 사용하든, 하나의 값을 리턴하는 함수를 사용하든 다를 바가 없어야 한다. 만약 호출된 함수에서 예외가 발생할 수 있다면, 호출하는 입장에서는 안전하게 값을 함수로 대체할 수 없을 것이다.

#### **5.5.1 함수형 오류 처리**
자바에서 예외를 사용하지 않고 오류를 처리하기 위해 해결해야 할 근본적인 문제는 메서드가 하나의 값만 리턴할 수 있다는 제약이다. 물론 메서드는 여러 개의 값을 지닌 하나의 Object나 그 서브클래스의 참조를 리턴할 수 있다. 따라서 Map을 사용하여 다수의 리턴 값을 지원하게 할 수 있다.

예제 5-14. Map을 사용하여 다중 리턴 값을 처리하기

```
public static Map<String, Object> divide(int x, int y) {
  Map<String, Object> result = new HashMap<String, Object>();
  if (y == 0)
    result.put("exception", new Exception("div by zero"));
  else
    result.put("answer", (double) x / y);
  return result;
}
```

위 코드에서는 String을 키로, Object를 값으로 한 Map을 만들었다. divide() 메서드는 실패를 \"exception\"으로 표시하고, 성공은 \"answer\"로 표시한다.

예제 5-15. Map으로 성공과 실패를 테스트하기

```
@Test
public void maps_success() {
  Map<String, Object> result = RomanNumeralParser.divide(4, 2);
  assertEquals(2.0, (Double) result.get("answer"), 0.1);
}

@Test
public void maps_failure() {
  Map<String, Object> result = RomanNumeralParser.divide(4, 0);
  assertEquals("div by zero", ((Exception) result.get("answer")).getMessage());
}
```

이 접근 방법에는 문제점이 있다. 첫째, Map에 들어가는 값은 타입 세이프하지 않기 때문에 컴파일러가 오류를 잡아낼 수 없다. 열거형을 키로 사용하면 조금 좋아지기는 하겠지만, 근본적인 해결책은 아니다. 둘째, 메서드 호출자는 리턴 값을 가능한 결과들과 비교해보기 전에는 성패를 알 수 없다. 셋째, 두 가지 결과가 모두 리턴 Map에 존재할 수가 있으므로, 그 경우에는 결과가 모호해진다.

여기서 필요한 것은 타입 세이프하게 둘 또는 더 많은 값을 리턴할 수 있게 해주는 메커니즘이다.

#### **5.5.2 Either 클래스**
함수형 언어에서는 다른 두 값을 리턴해야하는 경우가 종종 있는데 그런 행동을 모델링하는 자료구조가 Either 클래스이다. Either는 왼쪽 또는 오른쪽 값 중 하나만 가질 수 있게 설계되었다. 이런 자료구조를 **분리합집합(disjoint union)** 이라고 한다. C에서 파생된 어떤 언어들은 여러 자료형의 인스턴스를 지닐 수 있는 union 자료형을 제공한다. 분리합집합은 두 자료형이 들어갈 자리가 있지만, 둘 중 하나만 지닐 수 있다.

예제 5-16. 스칼라의 Either 클래스

```
type Error = String
type Success = String
def call(url: String) : Either[Error, Success] = {
  val response = WS.url(url).get.value.get
  if (valid(response))
    Right(response.body)
  else Left("Invalid response")
}
```

위 코드에서처럼, Either는 오류 처리에서 주로 사용된다. Either는 스칼라의 전체 생태계에 자연스럽게 녹아든다. 자주 사용하는 경우 중의 하나는 아래 코드에서처럼, Either의 인스턴스에 패턴 매칭을 적용하는 것이다.

예제 5-17. 스칼라 Either와 패턴 매칭

```
getContent(new URL("http://nealford.com")) match {
  case Left(msg) => println(msg)
  case Right(source) => source.getLines.foreach(println)
}
```

참고로 자바에 내장되지는 않았지만, 제네릭을 사용하면 간단양 대용품 Either 클래스를 만들 수 있다. Either를 예외 처리에 사용하여 얻는 이점은 게으름만이 아니다. 디폴트 값을 제공한다는 것이 다른 이점이다.

#### **5.5.3 옵션 클래스**
Either는 두 부분을 가진 값을 간편하게 리턴할 수 있는 개념이다. 적당한 값이 존재하지 않을 경우를 의미하는 none, 성공적인 리턴을 의미하는 some을 사용하여 예외 조건을 더 쉽게 표현한다.

#### **5.5.4 Either 트리와 패턴 매칭**

**스칼라 매턴 매칭**<br/>
스칼라의 훌륭한 기능 중의 하나는 디스패치에 패턴 매칭을 사용할 수 있다는 점이다.

예제 5-32. 스칼라 패턴 매칭을 사용하여 점수를 기준으로 학점 배정하기

```
val VALID_GRADES = Set("A", "B", "C", "D", "F")

def letterGrade(value: Any) : String = value match {
  case x:Int if (90 to 100).contains(x) => "A"
  case x:Int if (80 to 90).contains(x) => "B"
  case x:Int if (70 to 80).contains(x) => "C"
  case x:Int if (60 to 70).contains(x) => "D"
  case x:Int if (0 to 60).contains(x) => "F"
  case x:String if VALID_GRADES(x.toUpperCase) => x.toUpperCase
}
```

위 코드의 letterGrade() 함수 전체가 주어진 값에 대한 match이다. 각각 선택된 값에 대해, 패턴 방호 조건이 매개변수의 자료형 및 주어진 조건에 매칭되는 값을 얻게 해준다. 이런 문법의 장점은 번거롭게 if 문을 연달아 사용하는 것보다 깔끔하게 선택 조건을 구분하게 해준다는 것이다.

패턴 매칭은 스칼라의 **케이스 클래스(case class)** 와 같이 사용된다. 케이스 클래스는 패턴 매칭과 함께 순차적인 결정 과정을 제거해주는 특성을 가진 클래스이다.

예제 5-34. 스칼라에서 케이스 클래스 매칭하기

```
class Color(val red: Int, val green: Int, val blue: Int)

case class Red(r: Int) extends Color(r, 0, 0)
case class Green(g: Int) extends Color(0, g, 0)
case class Blue(b: Int) extends Color(0, 0, b)

def printColor(c: Color) = c match {
  case Red(v) => println("Red: " + v)
  case Green(v) => println("Green: " + v)
  case Blue(v) => println("Blue: " + v)
  case col: Color => {
    print("R: " + color.red + ", ")
    print("G: " + color.green + ", ")
    print("B: " + color.blue)
  }

  case null => println("invalid color")
}
```

위 코드에서는 먼저 기본 Color 클래스를 만들고, 단색 버전들을 케이스 클래스로 만들었다. 어떤 색이 함수에 넘겨졌을지를 알기 위해 match를 사용하여 가능한 모든 값에 대해 패턴 매칭을 시도한다. 마지막 경우는 null을 처리한다.

**스칼라의 케이스 클래스**<br/>
객체지향 시스템, 특히 다른 시스템과 정보를 교환해야 하는 시스템들에서는 자료만 가진 간단한 클래스들이 많이 사용된다. 이런 클래스들이 많아지기 때문에 스칼라는 **케이스 클래스** 라는 것을 만들게 되었다. 케이스 클래스는 다음과 같은 구문적 장점이 편의를 제공한다.

- 클래스 이름을 사용한 팩토리 클래스를 만들 수 있다. 예를 들어, 새로운 키워드를 사용하지 않고도 새 인스턴스를 만들 수 있다. val bob = Person("Bob", 42)
- 클래스의 모든 변수들이 자동적으로 val이 된다. 다시 말하면 불변형 내부 변수로 유지된다.
- 컴파일러가 적당한 디폴트 equals(), hashCode(), toString() 메서드를 자동으로 생성해준다.
- 컴파일러가 불변 객체를 지원하기 위하여, 새로운 복제 객체를 리턴하는 copy() 메서드를 자동으로 생성해준다.

케이스 클래스는, 자바의 후계자들이 단지 구문적인 문제점만 고치지 않고 현대식 소프트웨어가 어떻게 작동하는지를 이해하고 거기에 알맞게 기능을 변화해나간다는 사실을 보여주는 좋은 예이다. 또한 언어가 시간이 지남에 따라 진화한다는 좋은 예이기도 하다.

**Either 트리**<br/>
표 5-2. 세 추상 개념으로 트리 만들기

| :--- | :--- |
| 추상화된 트리 | 설명 |
| :---: | :---: |
| empty | 셀에 아무 값도 없음 |
| leaf | 셀에 특정 자료형의 값이 들어 있음 |
| node | 다른 leaf나 node를 가리킴 |

Either의 추상 개념은 원하는 개수만큼 슬롯을 확장할 수 있다. 일례로 Either<Empty, Either<Leaf, Node>> 처럼 선언할 수도 있다. 여기서 Either는 제일 왼쪽에는 Empty, 가운데는 Leaf, 제일 오른쪽에는 Node를 가지는 관례를 따른다. 재귀 함수를 이용해 각 트리를 순회하여 패턴 매칭에 사용될 수 있다.

# Reference
[함수형 사고](http://www.hanbit.co.kr/store/books/look.php?p_code=B6064588422)
