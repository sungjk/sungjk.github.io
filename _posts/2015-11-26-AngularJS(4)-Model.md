---
layout: post
title: AngularJS - 모델 Model
categories: [general, setup, demo]
tags: [demo, dbyll, dbtek, setup]
fullview: false
comments: true
---

# 모델

AngularJS에서는 사용자 정보, 도서 정보, 북마크 정보처럼 하나의 엔터티 Entity나 여러 개의 엔터티가 모델이 된다. 하지만 AngularJS의 모델을 정의하는 데 있어서 다른 자바스크립트 프레임워크와 다른 점이 있다. ExtJS나 BackbonJS에서는 기본 모델 클래스가 있고 이를 개별 모델 클래스가 상속받는 구조인 반면 AngularJS에서는 별다른 상속 없이 순수 자바스크립트 객체가 모델이 된다는 것이다. 하지만 중요한 점은 이러한 모델 객체는 AngularJS의 **$scope** 객체로부터 접근할 수 있어야 한다는 것이다.

모델을 컨트롤러에서 $scope 객체에 선언하거나 템플릿에서 선언할 수 있다. 다음 코드는 컨트롤러에서 모델을 선언한 코드다.

    function mainCtrl($scope) {
        $scope.userId : "map";
        $scope.bookmark : { name: "구글", url: "www.google.com", image: "google.png" };
        $scope.bookmarkList : [{ name: "구글", url: "www.google.com", image: "google.png" }, { name: "네이버", url: "www.
        naver.com", image: "naver.png" }];
    }

위 코드에서 볼 수 있듯이 컨트롤러에서(자바스크립트에서) 모델을 선언하고 있다. $scope의 속성명은 모델명을 나타내고 값은 모델이 된다. 여기서
모델은 단순한 문자열이 될 수도 있고 객체나 배열이 될 수도 있다. 즉, 모델은 평범한 자바스크립트 객체 Plain Old JavaScript Object다. 모델은
자바스크립트에서 선언할 수도 있지만 HTML 템플릿에서도 선언할 수도 있다.

    <div ng-init="userId = 'map'; bookmark={ name: '구글', url: 'www.google.com', image: 'google.png' }"> <p>{{userId}},
    {{bookmark}}</p> <button ng-click="userEmail = 'ajax@gmail.com'">Email 추가</button>
    </div>

위 코드에서 ng-init 지시자에서 userId에 "map"라는 값을 대입함으로써 모델을 선언하였다. 그리고 ng-click에서 대입 연산자를 표현식에서 사용하여
userEmail 모델을 만들었다. 이렇게 HTML 템플릿에서 표현식에서 대입연산자를 이용함으로써 직접 모델을 선언할 수 있다. 하지만 HTML 템플릿에서
직접 모델을 선언하지 않았는데 간접적으로 모델이 만들어지기도 한다.

    <input type="text" ng-model="search">
    <ul>
        <li ng-repeat="bookmark in bookmarkList">
        <p><a href="{{bookmark.href}}">{{bookmark.name}}</a></p>
    </ul>

위 템플릿 코드를 보면 `<input>` 태그에서 `ng-model` 속성에 search 값을 대입했다. AngularJS에서는 ng-model 지시자를 사용하면 해당 모델이
$scope에 없을 경우 암묵적으로 $scope에 search 속성을 만들고 `<input>` 태그의 값을 search 속성의 값으로 대입한다. 즉 모델을 만들고 데이터를
연결하는 것이다. 또한 앞에서 언급했듯이 ng-repeat 지시자에서도 모델을 만들게 되는데 bookmarkList 배열 요소의 개수만큼 DOM을 생성하면서(앞의
코드에서는 <li> 요소) 해당 DOM과 연결된 $scope를 만든다. 그리고 해당 $scope에 모델을 추가한다(bookmark 모델). 반복적인 데이터 표현을 위한
템플릿(반복 지시자)에서 `ng-repeat` 사용 시 HTML 요소별 $scope 생성을 참고하자.
