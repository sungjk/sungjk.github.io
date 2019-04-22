---
layout: entry
post-category: java
title: JAVA 프로그래머를 위한 UML - 1
author: 김성중
author-email: ajax0615@gmail.com
description: 로버트 C. 마틴의 'UML for Java Programmers'를 읽고 정리한 글입니다.
keywords: Java, 자바, UML
publish: false
---

# 1. 개요
UML(Unified Modeling Language)은 소프트웨어 개념을 다이어그램으로 그리기 위해 사용하는 시각적인 표기법이다. 마틴 파울러(Martin Fowler)는 UML을 각각 개념(conceptual), 명세(specification), 구현(implementation)이라는 말을 붙여 구분하였다.

명세 차원 다이어그램은 결국에는 소스코드로 바꾸려고 그리는 것이며, 구현 차원 다이어그램도 이미 있는 소스코드를 설명하려고 그리는 것이다. 반면, 개념 차원 다이어그램은 사람이 풀고자 하는 문제 도메인 안에 있는 개념과 추상적 개념을 기술하기 위한 속기용 기호에 가깝다. 따라서 의미론적 규칙에 그다지 얽매이지 않으며 의미하는 바도 모호하거나 해석에 따라 달라질 수 있다.

### 다이어그램의 유형
- **정적 다이어그램(static diagram)**: 클래스, 객체, 데이터 구조와 이것들의 관계를 그림으로 표현해서 소프트웨어 요소에서 변하지 않는 논리적 구조를 보여 준다.
- **동적 다이어그램(dynamic diagram)**: 실행 흐름을 그림으로 그리거나 실체의 상태가 어떻게 바뀌는지 그림으로 표현해서 소프트웨어 안의 실체가 실행 도중 어떻게 변하는지 보여 준다.
- **물리적 다이어그램(physical diagram)**: 소스 파일, 라이브러리, 바이너리 파일, 데이터 파일 등의 물리적 실체와 이것들의관계들을 그림으로 표현해서 소프트웨어 실체의 변하지 않는 물리적 구조를 보여준다.

```java
public class TreeMap {
  TreeMapNode topNode = null;

  public void add(Comparable key, Object value) {
    if (topNode == null)
      topNode = new TreeMapNode(key, value);
    else
      topNode.add(key, value);
  }

  public Object get(Comparable key) {
    return topNode == null ? null : topNode.find(key);
  }
}

class TreeMapNode {
  private final static int LESS = 0;
  private final static int GREATER = 1;
  private Comparable itsKey;
  private Object itsValue;
  private TreeMapNode nodes[] = new TreeMapNode[2];

  public TreeMapNode(Comparable key, Object value) {
    itsKey = key;
    itsValue = value;
  }

  public Object find(Comparable key) {
    if (key.compareTo(itsKey) == 0) return itsValue;
    return findSubNodeForKey(selectSubNode(key), key);
  }

  private int selectSubNode(Comparable key) {
    return (key.compareTo(itsKey) < 0) ? LESS : GREATER;
  }

  private Object findSubNodeForKey(int node, Comparable key) {
    return nodes[node] == null ? null : nodes[node].find(key);
  }

  public void add(Comparable key, Object value) {
    if (key.compareTo(itsKey) == 0)
      itsValue = value;
    else
      addSubNode(selectSubNode(key), key, value);
  }

  private void addSubNode(int node, Comparable key, Object value) {
    if (nodes[node] == null)
      nodes[node] = new TreeMapNode(key, value);
    else
      nodes[node].add(key, value);
  }
}
```

### 클래스 다이어그램
클래스 다이어그램(class diagram)은 프로그램 안의 주요 클래스와 주요 관계를 보여 준다.

![class-diagram](/images/2019/04/21/class-diagram.png "class-diagram"){: .center-image }

- 사각형은 클래스를 나타내고, 화살표는 관계를 나타낸다.
- 위 다이어그램에서 모든 관계는 연관(association)이다. 연관은 한쪽 객체가 다른 쪽 객체를 참조하며, 그 참조를 통해 그 객체의 메서드를 호출하는 것을 나타내는 단순한 데이터 관계다.
- 연관 위에 쓴 이름은 참조를 담는 변수의 이름과 대응된다.
- 화살표 옆에 쓴 숫자는 인스턴스의 개수를 타나낸다.
- 클래스 아이콘은 여러 구획으로 나뉠 수도 있다. 첫번째 구획은 언제나 클래스 이름을 쓴다. 다른 구획에는 각각 함수와 변수를 쓴다.
- <<interface>> 표기법은 Comparable이 인터페이스임을 나타낸다.

### 객체 다이어그램
객체 다이어그램(object diagram)은 시스템 실행 중 어느 순간의 객체와 관계를 포착해서 보여준다.

![object-diagram](/images/2019/04/21/object-diagram.png "object-diagram"){: .center-image }

- 객체는 사각형과 밑줄로 표현
- 이 객체가 속하는 클래스의 이름은 콜론(:) 다음에 표현
- 객체마다 아래 구획에 그 객체의 itsKey 변수의 값이 나와 있다.
- 객체 사이의 관계는 연결(link)이라고 한다.

### 시퀀스 다이어그램
![sequence-diagram](/images/2019/04/21/sequence-diagram.png "sequence-diagram"){: .center-image }

- 허수아비는 알려지지 않은 메서드 호출자를 나타낸다.
- 대괄호([ ]) 안의 불린 표현식은 \'가드(gaurd)\'라고 하며, 어떤 경로를 따라가야 할 지 알려 준다.
- TreeMapNode 아이콘에 닿은 화살표는 \'생성(construction)\'을 나타낸다.
- 한쪽 끝에 원이 그려진 작은 화살표는 \'데이터 토큰(data token)\'이라고 하고, 이 경우에는 생성자의 인자를 나타낸다.
- TreeMap 아래 홀쭉한 사각형은 \'활성 상자(activation)\'라고 부르는데, add 메서드가 실행되는 데 시간이 어느 정도 걸리는지 보여 준다.

### 협력 다이어그램
협력 다이어그램(collaboration diagram)의 정보는 시퀀스 다이어그램에 담긴 정보와 똑같다. 하지만 시퀀스 다이어그램은 메시지를 보내고 받는 순서를 명확히 하는 것이 목적인 반면, 협력 다이어그램은 객체 사이의 관계를 명확히 하는 것이 목적이다.

![Collaboration-diagram](/images/2019/04/21/collaboration-diagram.png "Collaboration-diagram"){: .center-image }

- 객체들은 연결이라고 부르는 관계로 맺어지고, 어떤 객체가 다른 객체에 메시지를 보낼 수 있다면 두 객체 사이에 연결이 있다고 말한다.
- 메시지는 작은 화살표로 그리며, 메시지 위에는 메시지 일므과 시퀀스 숫자, 그리고 이 메시지를 보낼 때 적용하는 모든 가드를 적는다.
- 호출의 계층 구조는 시퀀스 숫자에서 볼 수 있는 점(.)을 사용한 구조로 알 수 있다.

### 상태 다이어그램
아래는 지하철 개찰구를 상태 기계로 표현한 것인데, Locked(잠김)와 Unlocked(풀림)라는 두 가지 \'상태\'가 있고, 두 가지 \'이벤트\'를 받을 수 있다. coin 이벤트는 사용자가 개찰구에 표를 넣었음을 뜻하고, pass 이벤트는 사용자가 개찰구를 통해 지나감을 뜻한다.

![state-diagram](/images/2019/04/21/state-diagram.png "state-diagram"){: .center-image }

화살표는 \'전이(transition)\'라고 부른다. 이 전이 화살표에는 전이를 일으키는 이벤트와 전이가 수행하는 행동을 레이블로 단다. 전이가 일어나면 시스템의 상태가 바뀐다.

이런 다이어그램은 시스템의 행동 방식을 파악할 때 유용하다. 어떤 사용자가 표를 넣은 다음 아무 이유 없이 \'다시 표를 넣는 것처럼\' 예상하지 못한 경우에 시스템이 어떻게 행동해야 하는지 탐색할 기회를 마련해 준다.

---

# 2. 다이어그램으로 작업하기

### 왜 모델을 만들어야 하는가
어떤 것이 실제로도 잘 작동하느지 알아보려고 만드는 것이 모델이다. 여기에 모델은 반드시 시험해 볼 수 있어야 한다는 의미가 함축되어 있다. 모델을 만드는 비용이 실제 물건을 만드는 비용보다 훨씬 적을 경우에 모델을 만들어서 설계를 검사해 본다.

**왜 소프트웨어 모델을 만드는가**<br/>
UML 다이어그램을 그리는 일은 소프트웨어를 작성하는 일보다 비용이 적긴 하지만, 다른 분야(항공, 건축 등)의 모델처럼 훨씬 적게 드는 것은 아니다. 시험해 볼 구체적인 것이 있고, 그것을 코드로 시험해 보는 것보다 UML로 시험해 보는 쪽이 비용이 덜 들 때 UML을 사용한다.

**반드시 코딩을 시작하기에 앞서 포괄적인 설계를 해야 하는가**<br/>
계획 없이 어떤 빌딩을 짓는 것보다 미리 계획을 짜는 것이 비용이 \'훨씬 적게\' 든다. 잘못된 청사진을 던져 버리는 일에는 비용이 별로 들지 않지만, 잘못된 빌딩을 부수려면 비용이 \'엄청나게\' 든다. 모델의 경우와 마찬가지로 다른 분야에 비해 소프트웨어 분야에서는 모든것이 이렇게 분명하지 않다. 코드를 작성하는 것보다 UML 다이어그램을 그리는 것이 훨씬 비용이 적은지는 명확하지 않다. 그러므로 코드를 작성하기에 앞서 포괄적인 UML 설계를 만들면 드는 비용만큼 효과가 있는지 명확하게 알 수 없다.

### UML을 효과적으로 사용하기

**다른 사람들과 의사 소통하기**<br/>
UML은 소프트웨어 개발자끼리 설계 개념에 대한 의견을 주고 받을 때 굉장히 편리하며, 몇몇 개발자가 칠판 주위에 모여서 상당히 많은 일을 할 수 있게 해준다.

**로드맵**<br/>
어떤 클래스가 다른 클래스에 의존하는지 개발자가 빨리 파악할 수 있게 해주고 전체 시스템의 구조에 대한 참조 도표로도 사용된다.

**백엔드(back-end) 문서**<br/>
문서 작성을 프로젝트 막바지에 팀의 마지막 작업으로 하는 것이 가장 좋다. 그러면 작성한 문서가 팀이 프로젝트를 떠나는 마지막 시점의 사정을 잘 반영해주기 때문에 다음 프로젝트를 맡을 팀에게도 유용할 것이다.

**무엇을 보관하고 무엇을 버려야 하는가**<br/>
UML 다이어그램을 던져 버리는 습관을 길러라. 더 좋은 방법은, 다이어그램을 오랫동안 기록되는 매체에 기록하지 않는 습관을 기르는 것이다. 하지만 시스템 안에서 자주 사용되는 설계상의 해결 방법을 표현하는 것은 저장해 두는 편이 좋다. 정말로 유용한 다이어그램은 자꾸만 그리게 되는데, 누군가 귀찮게 다시 그릴 필요가 없게 다이어그램을 그려서 지속되는 매체에 저장할 것이다. 이때가 이 다이어그램을 모든 사람이 볼 수 있는 곳에 붙여 놓을 시기다.

### 반복을 통해 다듬기

**행위를 제일 먼저**<br/>
버튼이 눌릴 때마다 다이얼을 돌리는 일을 제어하는 프로그램을 예로 들어보자. 버튼(Button) 객체와 다이얼(Dialer) 객체를 그리고, Button이 Dialer에 번호 메시지를 여러 개 보내는 것도 그린다. 별표(\*)는 \'여러 개\'를 의미한다.

![behavior-first-1](/images/2019/04/21/behavior-first-1.png "behavior-first-1"){: .center-image }

번호 j메시지를 받으면 Dialer는 화면에 번호를 표시해야 하니까 아마 화면(Screen) 객체에 displayDigit 메시지를 보낼 것이다.

![behavior-first-2](/images/2019/04/21/behavior-first-2.png "behavior-first-2"){: .center-image }

그리고 스피커를 통해 어떤 톤을 들려주는 것도 좋다. 그러므로 Button이 스피커(Speaker) 객체에도 tone 메시지를 보내게 한다.

![behavior-first-3](/images/2019/04/21/behavior-first-3.png "behavior-first-3"){: .center-image }

숫자를 누르다가 마지막으로 사용자는 전송(Send) 버튼을 눌러서 이 번호로 전화를 걸고 싶다고 알려줄 것이다. 이 시점에서 우리는 셀 네트워크에 접속해서 사용자가 누른 전화번호를 전달하라고 휴대전화의 무선 부분(Radio)에 말해야 한다.

![behavior-first-4](/images/2019/04/21/behavior-first-4.png "behavior-first-4"){: .center-image }

연결이 맺어지면 Radio은 화면 객체에 사용중 지시자에 불을 켜라고 말할 수 있다. 그런데 이 메시지를 보낼 떄는 다른 제어 스레드를 사용할 가능성이 굉장히 높다. 그럴 때는 시퀀스 번호 앞에 글자를 붙여서 이 사실을 표현한다.

![behavior-first-5](/images/2019/04/21/behavior-first-5.png "behavior-first-5"){: .center-image }

**구조를 점검하기**<br/>
중요한 것은 의존 관계를 분석하는 일이다. 왜 Button이 Dialer에 의존해야 하는가?

```java
public class Button {
  private Dialler itsDialler;

  public Button(Dialler dialler) {
    itsDialler = dialler;
  }
  ...
}
```

Button은 다른 맥락에서도 사용할 수 있는 클래스다. 이 문제는 Button과 Dialer 사이에 인터페이스를 하나 만들어 넣으면 해결할 수 있다. Button은 저마다 고유한 식별자 토큰을 하나씩 가진다. Button 클래스는 자기가 눌렸다는 사실을 감지하면, ButtonListener 인터페이스의 buttonPressed 메서드를 호출하면서 자기 식별자 토큰을 인자로 넘긴다. 이렇게 하면 Button이 Dialer에 의존하지 않게 할 수 있으며 버튼이 눌렸다는 사실을 알아야 하는 거의 모든 경우에 Button을 사용할 수 있다.

![isolating-button](/images/2019/04/21/isolating-button.png "isolating-button"){: .center-image }

불행하게도 이번에는 Dialer가 Button에 대해 알아야 한다. 어댑터를 몇 개 쓰면 이 문제를 풀 수 있으며, 덤으로 식별자 토큰 사용이라는 어설픈 아이디어도 없앨 수 있다. ButtonDialerAdapter는 ButtonListener 인터페이스를 구현한다. 이 어댑터의 buttonPressed 메서드가 호출될 때, 이 어댑터는 Dialer에 digit(n) 메시지를 보낸다. Dialer에 전달할 숫자(n)는 어댑터가 기억하고 있다.

![adapting-button](/images/2019/04/21/adapting-button.png "adapting-button"){: .center-image }

**코드를 마음속으로 그려보기**<br/>
다이어그램을 그려 놓고 그 다이어그램이 나타내는 코드를 마음 속에서 그려 보지 못한다면, 공중에 누각을 짓는 것과 다를 바 없다. \'지금 하는 작업을 당장 중단하고 어떻게 그 다이어그램을 코드로 바꿀 수 있는지 찾아내라.\' 다이어그램 자체가 목적이 되어서는 안 된다.

```java
public class ButtonDiallerAdapter implements ButtonListener {
  private int digit;
  private Dialler dialler;

  public ButtonDiallerAdapter(int digit, Dialler dialler) {
    this.digit = digit;
    this.dialler = dialler;
  }

  public void buttonPressed() {
    dialler.digit(digit);
  }
}
```

**다이어그램의 진화**<br/>
간단한 동적인 다이어그램부터 시작해서 이런 동적인 것이 정적 관계에선느 어떤 의미인지 조사해본다. 이런 단계 하나하나는 아주 작다. 다이어그램을 아주 짧은 주기로 번갈아 보며 서로 상대를 발판 삼아 발전시킨다.

![adapting-to-dynamic](/images/2019/04/21/adapting-to-dynamic.png "adapting-to-dynamic"){: .center-image }

**미니멀리즘**<br/>
다이어그램이 가장 유용한 때는 다른 사람과 의사 소통을 할 때와, 여러분이 설계에 관한 문제점을 푸는 일에 도움이 될 때다. UML 다이어그램은 소스코드가 아니며, 따라서 모든 메서드나 변수, 관계를 선언하는 장소로 취급해서는 안 된다.

### 언제, 어떻게 다이어그램을 그려야 하는가

**다이어그램을 그려야 할 경우**<br/>
- 모두 설계에서 특정한 부분의 구조를 이해해야 할 때 그려라.
- 두 명 이상이 특정 요소를 어떻게 설계할지 의견을 모을 필요가 있을때 그려라.
- 설계 아이디어로 이것저것 시도해 보고 싶을 때 그려라.
- 누군가에세 코드 일부분의 구조를 설명할 때 그려라.
- 프로젝트 마지막에 고객이나 다른 사람을 위한 문서에 포함하기 위해 다이어그램을 요구할 때 그려라.

**다이어그램을 그리지 말아야 할 경우**<br/>
- 공정에서 다이어그램을 그려야 한다고 정해서 다이어그램을 그리지는 마라.
- 코딩을 시작하기에 앞서 설계 단계의 포괄적인 문서를 만들기 위해서 그리지 마라.
- 다른 사람에게 어떻게 코딩을 해야 할지 알려 주기 위해서 다이어그램을 그리지 마라.

**하지만 문서화는 어떻게 합니까**<br/>
복잡한 통신 프로토콜은 문서화해야 한다. 복잡한 관계형 데이터베이스의 스키마도 문서화해야 한다. 재사용 가능한 복잡한 프레임워크도 마찬가지다. 백만 줄의 자바 코드로 된 프로젝트에 12명이 일하는 팀이라면, 모두 합쳐 25쪽에서 200쪽 사이의 영구 문서로 충분하다고 생각한다.

---

# 3. 클래스 다이어그램
클래스 다이어그램으로 소스코드에 나타내는 클래스 사이의 의존 관계를 모두 표기할 수 있다.

### 기본 개념

**클래스(Class)**<br/>
클래스는 사각형으로 표시한다. 대시(-)는 private, 해시(#)는 protected, 더하기(+)는 public을 나타낸다. 변수나 함수 인자의 타입은 저마다 자기 이름 뒤에 콜론을 찍고 적는다. 함수의 반환값도 비슷하게 함수 뒤에 콜론(:)을 찍고 적는다. 세부사항은 다이어그램을 그리는 목적에 꼭 필요한 것만 사용해야 한다.

![class-diagram-1](/images/2019/04/21/class-diagram-1.png "class-diagram-1"){: .center-image }

**연관(Association)**<br/>
클래스 사이의 연관은 다른 객체의 참조(reference)를 가지는 인스턴스 변수를 의미한다. Phonebook은 \'여러 개의\' PhoneNumber 객체와 \'연결된다\'.

![class-diagram-2](/images/2019/04/21/class-diagram-2.png "class-diagram-2"){: .center-image }

\"Phonebook은 PhoneNumber를 여러 개 가진다.\"라고 말할 수도 있지만 일부러 그리 하지 않았다. 자주 사용하는 객체지향(Object Oriented)  동사인 HAS-A와 IS-A 때문에 불행한 오해가 많았다.

**상속(Inheritance)**<br/>
화살촉을 조심해서 그리지 않으면 상속을 표현하는지 연관을 표현하는지 구분하기 힘들 수 있다.

![inheritance-1](/images/2019/04/21/inheritance-1.png "inheritance-1"){: .center-image }

자바 클래스와 자바 인터페이스 사이의 상속(implements) 관계를 나타내기 위해 점선을 그리기도 하지만, 칠판에 다이어그램을 그릴 때는 점선으로 그리는 것을 무시했으면 좋겠다.

![inheritance-2](/images/2019/04/21/inheritance-2.png "inheritance-2"){: .center-image }

###
























---

# References
- [UML 실전에서는 이것만 쓴다: JAVA 프로그래머를 위한 UM](http://www.kyobobook.co.kr/product/detailViewKor.laf?ejkGb=KOR&mallGb=KOR&barcode=9788991268937)
- [UML_for_Java_Programmers](https://www.csd.uoc.gr/~hy252/references/UML_for_Java_Programmers-Book.pdf)
