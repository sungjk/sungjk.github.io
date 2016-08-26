---
layout: entry
title: C++ Interview Questions
author: 김성중
author-email: ajax0615@gmail.com
description: 구글 소프트웨어 엔지니어 면접 준비를 하면서 공부했던 자료입니다.
publish: true
---

### What are the differences between C and C++?

1) C++ is a kind of superset of C, most of C programs except few exceptions (See [this](http://www.geeksforgeeks.org/write-c-program-produce-different-result-c/) and [this](http://www.geeksforgeeks.org/write-c-program-wont-compiler-c/)) work in C++ as well.<br>
2) C is a procedural programming language, but C++ supports both procedural and Object Oriented programming.<br>
3) Since C++ supports object oriented programming, it supports features like function overloading, templates, inheritance, virtual functions, friend functions. These features are absent in C.<br>
4) C++ supports exception handling at language level, in C exception handling is done in traditional if-else style.<br>
5) C++ supports [references](http://www.geeksforgeeks.org/references-in-c/), C doesn’t.<br>
6) In C, scanf() and printf() are mainly used input/output. C++ mainly uses streams to perform input and output operations. cin is standard input stream and cout is standard output stream.

1) C++은 C의 상위집합(superset) 의 한 종류이다. 몇가지 예외들을 제외하고 대부분의 C프로그램들은 C++에서 잘 동작한다.<br>
2) C는 절차 지향 언어인 반면, C++은 절차 지향과 객체 지향 프로그랭을 둘 다 지원한다.<br>
3) C++이 객체 지향 프로그래밍을 지원하기 때문에, 함수 오버로딩(function overlading), 템플릿(templates), 상속(inheritance), 가상 함수(virtual functions), 프렌드 함수(freind functions)와 같은 형태를 제공한다. 이러한 것들은 C에는 없는 것들이다.<br>
4) C++은 언어 단계(language level)에서의 예외 처리를 제공한다. 하지만 C의 예외 처리는 if-else 스타일의 전통적인 방법이다.<br>
5) C++은 참조자([references](http://www.geeksforgeeks.org/references-in-c/))를 제공하지만, C는 그렇지 않다.<br>
6) C에서는 입출력으로 scanf()와 printf()가 주로 사용되지만, C++은 주로 입출력을 위해 스트림을 사용한다. cin은 표준 입력 스트림이고, cout은 표준 출력 스트림이다.


### What are the differences between references and pointers?

Both references and pointers can be used to change local variables of one function inside another function. Both of them can also be used to save copying of big objects when passed as arguments to functions or returned from functions, to get efficiency gain.
Despite above similarities, there are following differences between references and pointers.

References are less powerful than pointers:<br>
1) Once a reference is created, it cannot be later made to reference another object; it cannot be reseated. This is often done with pointers.<br>
2) References cannot be NULL. Pointers are often made NULL to indicate that they are not pointing to any valid thing.<br>
3) A reference must be initialized when declared. There is no such restriction with pointers<br>
Due to the above limitations, references in C++ cannot be used for implementing data structures like Linked List, Tree, etc. In Java, references don’t have above restrictions, and can be used to implement all data structures. References being more powerful in Java, is the main reason Java doesn’t need pointers.<br>

References are safer and easier to use:<br>
1) Safer: Since references must be initialized, wild references like wild pointers are unlikely to exist. It is still possible to have references that don’t refer to a valid location (See questions 5 and 6 in the below exercise )<br>
2) Easier to use: References don’t need dereferencing operator to access the value. They can be used like normal variables. ‘&’ operator is needed only at the time of declaration. Also, members of an object reference can be accessed with dot operator (‘.’), unlike pointers where arrow operator (->) is needed to access members.<br>

참조자와 포인터는 함수 내에 있는 지역 변수를 다른 함수에서 변경하고 싶을 때 사용된다. 이 둘은 함수로부터 반환되거나 함수의 인자로 전달됐을 때, 효율적으로 얻기 위해 객체의 복사본을 저장하는데 사용된다.<br>
이러한 유사함에도 불구하고, 참조자와 포인터 사이에는 이러한 차이점이 있다.

참조자는 포인터보다 덜 강력하다.<br>
1) 일단 참조자가 생성되면, 이후에 다른 객체를 참조할 수 없다. 즉, 재사용(reseat) 될 수 없다. 대체로 포인터는 가능하다.<br>
2) 참조자는 NULL 값을 가질 수 없다. 포인터는 유효한 값을 가리키지 않는다면 NULL이 된다.<br>
3) 참조자는 선언할 때 초기화되어야 한다. 포인터는 이러한 제약 사항이 없다.<br>
이러한 제한들 때문에, C++에서는 링크드 리스트, 트리와 같은 자료구조를 구현할 때 참조자를 사용하지 않는다. 자바에서는 이러한 제약 사항이 없어서 모든 자료구조를 구현할 때 참조자가 사용된다. 자바에서 참조자는 매우 강력한데, 이는 자바에서 포인터가 필요없는 이유이다.

참조자는 안전하고 사용하기에 쉽다.<br>
1) 안전성: 참조자가 초기화되어야 하기 때문에, 와일드 포인터와 같은 와일드 참조자는 종료할 것 같지 않다. 유효한 장소를 참조하지 않는 참조자 또한 그러하다.<br>
2) 사용하기에 쉽다: 참조자는 값에 접근하기 위한 디레퍼런스 연산자가 필요없어서 일반적인 변수처럼 사용 가능하다. 단지, 선언시에 '&' 연산자만 필요하다. 또한 포인터가 멤버에 접근하기 위해 '->' 연산자를 사용하는 것과 달리, 참조자는 '.' 연산자로 접근하면 된다.


### What are virtual functions – Write an example?

Virtual functions are used with inheritance, they are called according to the type of object pointed or referred, not according to the type of pointer or reference. In other words, virtual functions are resolved late, at runtime. Virtual keyword is used to make a function virtual.

Following things are necessary to write a C++ program with runtime polymorphism (use of virtual functions)<br>
1) A base class and a derived class.<br>
2) A function with same name in base class and derived class.<br>
3) A pointer or reference of base class type pointing or referring to an object of derived class.<br>
For example, in the following program bp is a pointer of type Base, but a call to bp->show() calls show() function of Derived class, because bp points to an object of Derived class.

가상 함수는 상속에 사용되는데, 포인터나 참조 타입에 의해서가 아닌 가리키고 있거나 참조하고 있는 객체의 타입에 따라 호출된다. 즉, 가상 함수는 런타임에 늦게 해석된다. Virtual 키워드는 가상 함수를 만들 때 사용된다.

런타임 다형성(가상 함수의 사용)을 가진 C++ 프로그램을 작성하기 위해 다음과 같은 것들이 필요하다.<br>
1) 기본 클래스와 파생 클래스.<br>
2) 같은 이름의 함수를 가진 기본 클래스와 파생 클래스.<br>
3) 유도 클래스 객체를 가리키거나 참조하고 있는 기본 클래스의 포인터나 참조자.<br>
예를 들어, bp는 Base 타입의 포인터이다. 하지만 bp->show()는 파생 클래스의 show() 함수를 호출한다. 왜냐하면, bp는 파생 클래스의 객체를 가리키고 있기 때문이다.

    #include<iostream>
    using namespace std;

    class Base {
    public:
        virtual void show() { cout << " In Base \n"; }
    };

    class Derived : public Base {
    public:
        void show() { cout << "In Derived \n"; }
    };

    int main(void) {
        Base \*bp = new Derived;
        bp->show(); // Runtime-Polymorphism
        return 0;
    }


### What is this pointer?

The ‘this’ pointer is passed as a hidden argument to all nonstatic member function calls and is available as a local variable within the body of all nonstatic functions. ‘this’ pointer is a constant pointer that holds the memory address of the current object. ‘this’ pointer is not available in static member functions as static member functions can be called without any object (with class name).

'this' 포인터는 모든 비정적 멤버 함수에게 숨겨진 인수로서 넘겨주고 모든 비정적 함수 내에서 지역 변수로서 사용 가능하다. 'this' 포인터는 현재 객체의 메모리 주소를 가지고 있는 상수 포인터이다. 'this' 포인터는 객체 없이 호출될 수 있는 정적 멤버 함수 내에서 사용할 수 없다.


### Can we do “delete this”?
See http://www.geeksforgeeks.org/delete-this-in-c/


### What are VTABLE and VPTR?

vtable is a table of function pointers. It is maintained per class.<br>
vptr is a pointer to vtable. It is maintained per object (See this for an example).

Compiler adds additional code at two places to maintain and use vtable and vptr.<br>
1) Code in every constructor. This code sets vptr of the object being created. This code sets vptr to point to vtable of the class.<br>
2) Code with polymorphic function call (e.g. bp->show() in above code). Wherever a polymorphic call is made, compiler inserts code to first look for vptr using base class pointer or reference (In the above example, since pointed or referred object is of derived type, vptr of derived class is accessed). Once vptr is fetched, vtable of derived class can be accessed. Using vtable, address of derived derived class function show() is accessed and called.

VTABLE은 함수 포인터들의 테이블이다. 이는 클래스별로 유지하고 있다.<br>
VPTR은 VTABLE을 가리키고 있는 포인터다. 이는 객체별로 유지하고 있다.

컴파일러는 VTABLE과 VPTR을 유지하고 사용하기 위해 두 부분에 추가적인 코드를 추가한다.<br>
1) 모든 생성자의 코드. 이 코드는 객체의 vptr이 생성되도록 하고, vptr이 클래스의 vtable을 가리키도록 한다.<br>
2) 다형성 함수 호출(위의 bp->show()와 같은) 코드. 다형성 함수가 만들어지는 부분에서 컴파일러는 vptr를 위한 코드를 삽입한다. 일단 vptr이 패치되면, 파생 클래스의 vtable은 접근 가능하다. vtable을 이용해서 파생 클래스의 함수 show()의 주소에 접근하고 호출된다.
