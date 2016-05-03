---
layout: post
title: Google C++ Style Guide - Naming
categories: [general, cpp]
tags: [cpp]
fullview: false
comments: true
---

일관성을 위한 가장 중요한 규칙은 이름 규칙을 정하는 것이다. 이름 스타일을 통해 요소의 선언을 찾지 않고도 해당 요소가 타입인지, 변수인지, 함수인지, 상수인지, 혹은 매크로인지 바로 알 수 있다. 우리 머리 속의 패턴-매칭 엔진은 이러한 이름 규칙에 상당히 의존한다.

이름 규칙은 상당히 모호하지만 이 영역에서 개인의 선호도보다 **일관성** 이 더 중요하다. 합리적이라고 생각하든 아니든 규칙은 지켜야 한다.


### 일반적인 이름 규칙

이름들(함수, 변수, 파일 등)은 약어를 피하고 서술적으로 지어야 한다.

가능한 이름은 서술적으로 사용하라. 새로 읽는 사람이 즉시 이해할 수 있는 것이 글자 길이를 줄이는 것보다 훨씬 중요하다. 프로젝트에 관계없는 사람에게 익숙하지 않거나 모호한 약어를 사용하지 말고, 중간 글자를 지워서 약어로 만들지 마라.

     int price_count_reader;    // 축약없음.
     int num_errors;            // "num"은 누구나 이해가능.
     int num_dns_connections;   // "DNS"도 누구나 이해가능.
     int n;                     // 의미없음.
     int nerr;                  // 모호한 축약.
     int n_comp_conns;          // 모호한 축약.
     int wgc_connections;       // 팀 내부사람들만 아는 약어.
     int pc_reader;             // "pc"는 다양한 의미가 있다.
     int cstmr_id;              // 중간 단어를 지웠음.


### 파일 이름

파일 이름은 모두 소문자이어야 하고 언더스코어(\_) 혹은 대쉬 (-)를 포함할 수 있다. 반드시 언더스코어를 사용할 필요는 없고 프로젝트에 사용하는 관례를 따른다.

사용 가능한 파일 이름 예시:

    my_useful_class.cc
    my-useful-class.cc
    myusefulclass.cc
    myusefulclass_test.cc // \_unittest와 \_regtest는 deprecate되었다.

C++ 파일은 .cc으로 끝나고 헤더 파일은 .h로 끝난다.

db.h와 같이 /usr/include에 이미 존재하는 파일 이름은 사용하지 말자.


일반적으로 상세하게 파일 이름을 지어라. 예를 들면, http_server_logs.h가 logs.h보다 좋다. FooBar 클래스를 정의할 때 일반적으로 한 쌍의 파일을 갖는다. 예를 들어, foo_bar.h, foo_bar.cc 처럼 말이다.

인라인 함수는 .h에 있어야 한다. 인라인 함수의 코드가 짧으면 .h 안에 들어가고, 길다면 -inl.h로 가야 한다. 클래스 안에 많은 인라인 코드가 있다면 3개의 파일로 분리한다.

    url_table.h      // 클래스 선언
    url_table.cc     // 클래스 정의
    url_table-inl.h  // 많은 코드를 포함한 인라인 함수


### 타입 이름

타입 이름은 대문자로 시작하고 언더스코어 없이 단어마다 첫 글자로 대문자를 사용한다. 예를 들면, MyExcitingClass, MyExcitingEnum.

클래스, 구조체, typedef, 열거형 같은 타입의 이름에는 같은 규칙이 적용된다. 다음 예시처럼 타입 이름은 단어마다 대문자로 시작하며 언더스코어를 사용하지 않는다.

    // classes, structs
    class UrlTable { ...
    class UrlTableTester { ...
    struct UrlTableProperties { ...

    // typedefs
    typedef hash_map<UrlTableProperties \*, string> PropertiesMap;

    // aliases
    using PropertiesMap = hash_map<UrlTableProperties \*, string>;

    // enums
    enum UrlTableErrors { ...


### 변수 이름

변수 이름은 모두 소문자로 작성하며 단어 사이에 언더스코어를 사용한다. 클래스 멤버 변수는 이름의 끝에 언더스코어를 사용한다. 예를 들면, a_local_variable, a_struct_data_member, a_class_data_member_ 처럼 말이다.

#### 공통 사항

예시:

    string table_name;  // 좋음 - 언더스코어를 사용한다.
    string tablename;   // 좋음 - 모두 소문자이다.
    string tableName;   // 나쁨 - 대문자 사용

#### 클래스 데이터 멤버

데이터 멤버(인스턴스 변수 또는 멤버 변수)의 이름은 보통 변수처럼 소문자와 선택적인 언더스코어로 작성하지만, 항상 끝에 언더스코어를 붙인다.

    string table_name_;  // 좋음 - 끝에 언더스코어가 있다.
    string tablename_;   // 좋음

#### 구조체 변수

구조체에 안에 있는 데이터 멤버는 클래스에 있는 데이터 멤버와 다르게 끝에 언더스코어를 붙이지 않고 보통 변수처럼 이름 짓는다.

    struct UrlTableProperties {
      string name;
      int num_entries;
    }

어떤 경우에 클래스와 구조체를 써야 할 지에 대해서는 구조체 대 클래스를 참고하라.

#### 전역 변수

제한적으로 사용되어야 하는 전역 변수의 이름에 대한 특별한 규칙은 없다. 하지만 전역 변수를 사용할 때에는 g_와 같이 로컬 변수와 쉽게 구분할 수 있는 접두어를 사용하는 것이 좋다.


### 상수 이름

k로 시작하는 대소문자가 섞인 이름을 사용한다.

    const int kDaysInAWeek = 7;

지역변수인지, 전역변수인지, 클래스의 일부인지와 상관 없이 모든 컴파일 시점 상수들은 다른 변수들과 조금 다른 이름 규칙을 사용한다. k로 시작하여 매 단어의 첫 글자를 대문자로 쓴다.


### 함수 이름

일반적인 함수들은 대소문자가 섞여 있다. 보통, 함수들은 대문자로 시작하고 각 새로운 단어는 \'upper camelcase\'나 \'Pascal case\'로 표현한다. 이러한 이름들은 소문자로 작성하면 안된다. 예를 들어, \'StartRPC()\'가 아닌 \'StartRpc()\'처럼 단어마다 두문자어를 대문자로 쓰기를 선호해라.

    AddTableEntry()
    DeleteUrl()
    OpenFileOrDie()

접근자와 변경자는 해당하는 변수의 이름과 같은 것을 쓴다. MyExcitingFunction(), MyExcitingMethod(), my_exciting_member_variable(), set_my_exciting_member_variable().

일반 함수

    class MyClass {
    public:
        ...
        bool is_empty() const { return num_entries_ == 0; }

    private:
        int num_entries_;
    };


함수 이름은 대문자로 시작하여 각 단어의 첫 글자를 대문자로 쓰고, 언더스코어는 사용하지 않는다.

함수의 실행 중 크래시가 발생할 수 있다면 함수의 이름 뒤에 OrDie 를 붙인다. 이 규칙은 프로덕션 코드에서도 에러가 발생할 가능성이 어느 정도 있는 함수에 한해 적용한다.

    AddTableEntry()
    DeleteUrl()
    OpenFileOrDie()
