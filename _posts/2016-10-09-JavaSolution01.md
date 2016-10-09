---
layout: entry
title: 인터뷰 - Java 해법
author: 김성중
author-email: ajax0615@gmail.com
description: 인터뷰에서 다룰만한 기본적인 자바(Java)에 대한 설명입니다.
publish: false
---

#### 1. 생성자를 private으로 선언하면 계승 관점에서 어떤 영향을 주게 되나요?
생성자를 private로 선언하면 클래스 외부에서는 해당 클래스의 객체를 생성할 수 없게 됩니다. 따라서 객체를 생성하려면 해당 클래스는 객체를 생성해 반환하는 static public 메서드를 제공해야 합니다. 팩토리 메서드 패턴 *factory mathod pattern* 을 참조하세요.

#### 2. Java의 객체 리플랙션 *reflection* 에 대해 설명하고, 유용한 이야기를 밝혀라.
객체 리플렉션은 **Java 클래스와 객체에 대한 정보를 프로그램 내에서 동적으로 알아낼 수 있도록 하는 기능** 입니다. 리플렉션을 이용하면 다음과 같은 작업을 할 수 있습니다.

* 클래스 내부에서, 실행 시간에, 메서드와 필드에 대한 정보를 얻을 수 있습니다.

* 어떤 클래스로부터 객체를 생성할 수 있습니다.

* 객체 필드의 유효 범위가 어떻게 선언되어 있느냐에 관계없이 *access modifier* , 그 필드에 대한 참조를 얻어내어 값을 가져오거나 설정할 수 있습니다.

이에 대한 예를 코드로 살펴보겠습니다.

```
// 인자
Object[] doubleArgs = new Object[] { 4.2, 3.9 };

// 클래스를 가져온다.
Class rectangleDefinition = Class.forName("MyProj.Rectangle");

// Rectangle rectangle = new Ractangle(4.2, 3.9); 을 실행하는 것과 같다.
Class[] doubleArgsClass = new Class[] {double.class, double.class};
Constructor doubleArgsConstructor = rectangleDefinition.getConstructor(doubleArgsClass);
Rectangle rectangle = (Rectangle) doubleArgsConstructor.newInstance(doubleArgs);

// Double area = rectangle.area(); 을 실행하는 것과 같다.
Method m = rectangleDefinition.getDeclaredMethod("area");
Double area = (Double) m.invoke(rectangle);
```

위 코드는 아래 코드와 같은 일을 합니다.

```
Rectangle rectangle = new Rectangle(4.2, 3.9);
Double area = rectangle.area();
```

#### 객체 리플랙션은 왜 유요한가?
위 예제는 그다지 쓸모 있어 보이지 않습니다. 하지만 어떤 경우에는 굉장히 유용하게 쓰입니다.

1. 프로그램이 어떻게 동작하고 있는지에 대한 정보를 **실행 시간에 관측하고 조정** 할 수 있도록 해줍니다.

2. 메서드나 생성자, 필드를 직접 접근할 수 있기 때문에 프로그램을 디버깅하거나 테스트할 때 유용합니다.

3. 호출할 메서드를 미리 알고 있지 않더라도 그 이름을 사용하여 호출할 수 있습니다. 가령, 사용자가 클래스 이름과 생성자에 전달할 인자와 메서드 이름을 주면 그 정보를 사용해 객체를 생성하고 메서드를 호출할 수 있습니다. 리플랙션 없이 그런 절차를 구현하려면 if 문을 복잡하게 엮어 사용해야 할 것입니다.
