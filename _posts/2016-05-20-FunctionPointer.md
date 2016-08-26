---
layout: entry
title: 함수 포인터(Function Pointer)
author: 김성중
author-email: ajax0615@gmail.com
description: 함수 포인터(Function Pointer)에 대한 설명입니다.
publish: true
---

포인터(Pointer) 앞에 함수(Function)가 붙은 함수 포인터는 함수를 가리키는 포인터입니다. 함수에도 주소가 존재함을 알 수 있죠. 함수명은 함수의 시작 주소를 의미하고, 이 함수 포인터를 선언할 때에는 함수 시그니처(Signature)와 같도록 선언해야 합니다. 즉, 원형과 같도록 선언해야 한다는 말입니다.

<br>
만약 아래의 원형을 갖는 함수를 가리키는 포인터를 선언하려면 어떻게 해야 할까요?
```
int sum(int a, int b);
```

반환형은 int이며, 매개변수는 int, int임을 알 수 있습니다. 함수 포인터는 아래와 같이 선언할 수 있습니다.
```
int (*pf)(int, int) = sum;
```
<br>

위와 같이 선언을 하고 초기화를 한 후로부터, 함수 포인터 pf는 함수 sum의 시작 주소를 가리킵니다. 이제부터 함수 포인터 pf를 가지고 함수 sum에 전달하는 것과 동일하게 전달할 수 있습니다.
```
#include <iostream>
using namespace std;

int sum(int a, int b)
{
    return a + b;
}

int main()
{
    int (*pf)(int, int) = sum;

    cout << "pf(int, int): " << pf(4, 5) << endl;
    cout << "sum(int, int): " << sum(4, 5) << endl;
    cout << "pf address: " << pf << endl;
    cout << "sum address: " << sum << endl;

    return 0;
}
```

결과:
![result](/img/2016/05/20/result.PNG "result")

<br>
위 예제의 결과를 보시면 pf(4, 5)나 sum(4, 5) 둘 다 같은 값을 반환하고, 주소 또한 같다는 것을 확인하실 수 있습니다. 추가로, 만약 함수 sum의 반환형이 void라면 아래와 같이 원형을 가지겠죠?
```
void sum(int, int b);
```

이는 반환형이 void고 매개변수의 타입이 int, int임을 알 수 있습니다. 그렇다면, 함수 포인터는 아래와 같이 선언할 수 있습니다.
```
void (*pf)(int, int) = sum;
```

의외로 간단하죠? 정적 함수 포인터는 여기까지 설명하도록 하고, 이번에는 멤버 함수 포인터에 대해 알아보도록 하겠습니다.


## 멤버 함수 포인터(Member Function Pointer)

여기서 멤버 함수(Member Function)는 클래스 내부에 있는 함수로써, 클래스가 멤버로 가지고 있는 함수를 의미합니다. 그렇다면 멤버 함수 포인터(Member Function Pointer)는 멤버 함수를 가리키는 포인터를 의미한다는 것을 알 수 있습니다. 멤버 함수 포인터를 선언하는 방법은 정적 함수 포인터를 선언하는 방법과 조금 다릅니다.

<br>
만약 Rectangle 클래스에서 area 함수의 원형이 아래와 같다고 해봅시다.
```
int Rectangle::area(int width, int height);
```
위 area 함수의 반환형은 int이며, 매개변수의 타입은 int, int입니다. 그리고 area 함수는 Rantangle 클래스의 멤버 함수입니다. 이는 아래와 같이 함수 포인터를 선언할 수 있습니다.
```
int (Rectangle::*pf)(int, int) = &Rectangle::area;
```
<br>

확실한 이해를 위해 예제를 보겠습니다.
```
#include <iostream>
using namespace std;

class Rectangle
{
    int width, height;
public:
    explicit Rectangle(int w = 0, int h = 0) : width(w), height(h) {}
    int area()
    {
        return width * height;
    }
};

int main()
{
    Rectangle rc(10, 5);
    int (Rectangle::*pf)(void) = &Rectangle::area;

    cout << "rc.area(): " << rc.area() << endl;
    cout << "(rc.*pf)(): " << (rc.*pf)() << endl;

    return 0;
}
```

결과:
![result2](/img/2016/05/20/result2.PNG "result2")
<br>

위 예제에서는 함수 포인터 pf가 Rectangle 클래스에서 area 멤버 함수의 시작 주소를 가리키도록 하고, rc.area()와 (rc.\*pf)()의 반환값을 출력합니다. 결과를 보시면, 두 결과값이 동일하다는 것을 알 수 있습니다. (rc.\*pf)()처럼 객체를 통해 멤버 함수를 호출할 때에는 .\* 연산자를 사용합니다. (연산자 우선순위 때문에 괄호를 제거하여 rc.\*pf*()와 같이 호출하려고 한다면 오류가 발생합니다. 반드시 괄호를 포함하도록 합시다.) 예를 들어, Lion 클래스의 cry 함수 원형이 아래와 같다고 가정해봅시다.
```
void Lion::cry();
```
이는 반환형이 void이고, 매개변수의 타입도 void입니다. 그리고, cry 함수는 Lion 클래스의 멤버 함수입니다. 이는 아래와 같이 함수 포인터를 선언할 수 있습니다.
```
void (Lion::*pf)() = &Lion::cry;
```
