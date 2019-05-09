---
layout: entry
title: JAVA 프로그래머를 위한 UML - 4
author: 김성중
author-email: ajax0615@gmail.com
description: 로버트 C. 마틴의 'UML for Java Programmers'를 읽고 정리한 글입니다.
keywords: Java, 자바, UML
publish: true
---

# 10. 상태 다이어그램
아래 그림은 사용자가 시스템에 로그인하는 방법을 제어하는 상태 기계를 기술하는 \'간단한 상태 전이 다이어그램(State Transition Diagram, STD)\'이다. 이 그림에서 모서리가 둥근 사각형은 \'상태(state)\'를 나타낸다. 사각형을 둘로 나눠 위 부분에 각 상태의 이름을 적고, 아래 부분에는 그 상태에 들어가거나 나갈때 특별히 무엇을 해야 할지 적는다. 예를 들어, 로그인 메시지를 띄우기(Prompting for Login) 상태에 들어갈 때에는 showLoginScreen 행동을 호출한다. 이 상태에 나갈 때에는 hideLoginScreen 행동을 호출한다.

상태 사이의 화살표는 \'전이(transition)\'라고 부른다. 전이마다 그것을 발생시키는 이벤트의 이름이 붙어 있다. 몇몇 전이에는 전이가 일어날 때 수행할 행동이 붙기도 한다. 예를 들어, Prompting for Login 상태에서 로그인 이벤트를 받으면, 사용자가 검증하기(Validating User) 상태로 전이하면서 validateUser 행동도 호출한다.

다이어그램 왼쪽 상단의 검은 동그라미는 \'최초 의사-상태(pseudo state)\'라고 부른다. FSM의 생명은 이 의사 상태에서 전이해 나오며 시작된다. 그러므로 지금 예로 든 상태 기계는 Prompting for Login 상태로 전이해 들어가면서 동작을 시작한다.

![login-state-machine](/images/2019/05/08/login-state-machine.png "login-state-machine"){: .center-image }

비밀번호 보냄 실패(Sending Password Failed) 상태와 비밀번호 보냄 성공(Sending Password Succeeded) 상태를 둘러싼 \'상위 상태(superstate)\'도 하나 그렸는데, 두 상태 모두 똑같이 Prompting for Login 상태로 전이함으로써 OK 이벤트에 반응하기 때문이다. 상위 상태를 사용하면 동일한 화살표를 중복해서 그리지 않아도 되므로 편리하다.

이 유한 상태 기계는 로그인 과정이 어떻게 작동하는지 명확하게 정의한다. 또 이 과정을 작고 간결해서 좋은 함수들로 쪼개 주기까지 한다. 만약 showLoginScreen, validateUser, sendPassword 등의 행동 함수를 모두 구현한 다음, 이 다이어그램에서 보이는 논리 구조로 연결만 하면, 이 로그인 과정이 올바로 작동할 것임을 확신할 수 있다.

### 특수 이벤트
상태 사각형의 아래 부분에는 여러 \'이벤트 / 행동\' 쌍이 들어 있다. 이것 가운데 들어옴(entry) 이벤트와 나감(exit) 이벤트는 표준 이벤트다.

![state-in-uml](/images/2019/05/08/state-in-uml.png "state-in-uml"){: .center-image }

### 상위 상태
비슷한 상태를 둘러싼 상위 상태를 그린 다음, 상태마다 전이 화살표를 그리는 대신 상위 상태에만 그리면 된다. 그러므로 아래 두 다이어그램은 동일하다.

![super-state](/images/2019/05/08/super-state.png "super-state"){: .center-image }

하위 상태에 명시적으로 전이를 그려 넣으면 상위 상태의 전이보다 우선순위가 앞선다. 따라서 아래 그림처럼 S3 상태의 pause 전이가 Cancelable 상위 상태의 기본 pause 전이보다 우선한다. 이렇게 보면 상위 상태가 기반 클래스와 비슷함을 알 수 있다. 유도 클래스가 자기 기반 클래스의 메서드를 재정의(override)하는 것과 마찬가지로 하위 상태는 상위 상태의 전이를 재정의할 수 있다.

상위 상태도 보통 상태처럼 들어옴 이벤트, 나감 이벤트, 특수 이벤트를 가질 수 있다. 위 그림은 상위 상태와 하위 상태 모두 들어옴 행동과 나감 행동이 있는 FSM이다. 어떤 상태(Some state)에서 Sub 상태로 전이되어 들어오면 먼저 enterSuper 행동을 호출하고 그 다음 enterSub 행동을 호출한다. 마찬가지로 FSM 전이가 Sub2에서 어떤 상태(Some State)로 돌아간다면, 먼저 exitSub2를 호출한 다음 exitSuper를 호출한다. 하지만, Sub에서 Sub2로 가는 e2 전이는 상위 상태 바깥으로 나가지 않기 때문에, 단지 exitSub와 enterSub2만 호출한다.

### 최초 의사-상태와 최종 의사-상태
아래 그림에서 UML에서 자주 사용되는 두 의사-상태를 볼 수 있다. FSM의 생명은 최초 의사-상태에서 전이되어 나오는 \'과정\'에서 시작된다. 최초 전이는 이벤트를 가지지 못하는데, 상태 기계 생성이 바로 이 전이를 시작하는 이벤트이기 때문이다. 하지만 행동은 가질 수 있으며, 이 행동이 바로 FSM이 만들어진 다음 곧바로 호출되는 첫 행동이다.

마찬가지로, FSM은 \'최종 의사-상태\'로 전이되는 과정에서 소멸한다. 최종 의사-상태에는 절대로 도달하지 못한다. 만약 최종 의사-상태에 행동이 붙어 있다면, 이 행동은 FSM이 마지막으로 호출하는 행동이 될 것이다.

![initial-final-pseudo-state](/images/2019/05/08/initial-final-pseudo-state.png "initial-final-pseudo-state"){: .center-image }

### FSM 다이어그램 사용하기
다이어그램은 자주 변경해야 하는 시스템을 표현하기에 좋은 매체가 아니다. 반면 글은 변화를 다루기에 아주 유연한 매체다. 그러므로 진화하는 시스템에는 STD보다는 상태 전이 테이블(State Transition Tables, STT)이 좋다.

![subway-std](/images/2019/05/08/subway-std.png "subway-std"){: .center-image }

STT는 열이 네 개 있는 단순한 테이블이다. 테이블의 행 하나는 전이 하나를 나타낸다. 테이블의 한 행을 보면, 전이 화살표의 시작 지점과 끝 지점, 그리고 이벤트와 액션이 모두 들어있다. STT를 읽을 때는 다음 문장을 기본 틀로 삼아서 읽으면 된다. \"만약 Locked(잠김) 상태에서 coin(동전 투입) 이벤트를 받으면, Unlocked(풀림) 상태로 가고, Unlock(풀음) 함수를 호출한다.

![subway-stt](/images/2019/05/08/subway-stt.png "subway-stt"){: .center-image }

---

# 11. 휴리스틱과 커피























---

# References
- [UML 실전에서는 이것만 쓴다: JAVA 프로그래머를 위한 UM](http://www.kyobobook.co.kr/product/detailViewKor.laf?ejkGb=KOR&mallGb=KOR&barcode=9788991268937)
- [UML_for_Java_Programmers](https://www.csd.uoc.gr/~hy252/references/UML_for_Java_Programmers-Book.pdf)
