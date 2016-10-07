---
layout: entry
title: 인터뷰 - 디자인 패턴
author: 김성중
author-email: ajax0615@gmail.com
description: 인터뷰에서 다룰만한 기본적인 디자인 패턴에 대한 설명입니다.
publish: true
---

면접에서는 지식이 아니라 능력을 테스트하기 때문에 디자인 패턴은 보통 면접 범위 외로 다루고 있습니다. 하지만 Singleton이나 Factory method와 같은 디자인 패턴을 알아두면 면접 볼 때 특히 유용하므로, 이 두 가지를 중심으로 다루겠습니다.

#### 싱글톤 클래스 *Singleton Class*
싱글톤 패턴은 **어떤 클래스가 오직 하나의 객체만을 갖도록 하며, 프로그램 전반에 그 객체 하나만 사용되도록 보장** 합니다. 정확히 하나만 생성되어야 하는 전역적 객체를 구현해야 하는 경우에 특히 유용합니다. 가령, Restaurant와 같은 클래스는 정확히 하나의 객체만 갖도록 구현하면 좋습니다.

![singleton](/images/2016/10/07/singleton.png "singleton"){: .center-image }

```
// C++
class Restaurant {
    Restaurant() {};
    Restaurant(const Restaurant& other) {...};
    ~Restaurant() {};
    static Restaurant* instance;
public:
    static Restaurant* getInstance() {
        if (instance == NULL) {
            instance = new Restaurant();
        }
        return instance;
    }
};
Restaurant* Restaurant::instance = nullptr;


// Java
public class Restaurant {
    private static Restaurant instance = null;
    protected Restaurant() {...}
    public static Restaurant getInstance() {
        if (instance == null) {
            instance = new Restaurant();
        }
        return instance;
    }
}


// Javascript in ES6
let instance = null;

class Restaurant {  
    constructor() {
        if(!instance){
              instance = this;
        }
        return instance;
      }
}
```

#### 팩토리 메서드 *Factory Method*
팩토리 메서드 패턴은 **어떤 클래스의 객체를 생성하기 위한 인터페이스를 제공하되, 하위 클래스에서 어떤 클래스를 생성할지 결정** 할 수 있도록 합니다. 팩토리 메서드 패턴을 구현하는 한 가지 방법은 객체 생성을 처리하는 클래스를 abstract로 선언하여, 객체 생성을 처리하는 클래스를 concrete 클래스로 만들어 팩토리 메서드를 구현하고, 생성해야 할 클래스를 나타내는 값을 팩토리 메서드의 인자로 받는 것입니다.

![factorymethod](/images/2016/10/07/factorymethod.png "factorymethod"){: .center-image }

```
// Java
public class CardGame {
    public static CardGame createCardGame(GameType type) {
        if (type == GameType.Poker) {
            return new PokerGame();
        }
        else if (type == GameType.BlackJack) {
            return new BlackJackGame();
        }
        return null;
    }
}
```

#### 참고 자료
[Singleton Classes In Es6](http://amanvirk.me/singleton-classes-in-es6/)
