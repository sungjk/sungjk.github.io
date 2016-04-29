---
layout: post
title: AngularJS - Scope(1)
categories: [general, web]
tags: [angularjs]
fullview: false
comments: true
---

# $rootScope와 $scope

앞에서 보았듯이 AngularJS에서 $scope는 중요한 역할을 한다. **양방향 데이터 바인딩의 핵심이자 뷰와 컨트롤러를 이어주는 징검다리** 이기도 하다. 사실 $scope는 그저 단순한 자바스크립트 객체에 불과하다. 하지만 이 자바스크립트 객체는 연결된 DOM 요소에서 표현식이 계산되는 실행환경이며 뷰와 컨트롤러에서 사용되는 데이터 data와 기능 function이 살아 숨쉬는 공간이다. $scope는 DOM 요소와 마찬가지로 계층적 구조를 가진다. 다음 목록은 AngularJS 애플리케이션에서의 $scope의 특징을 보여준다.

* 뷰와 컨트롤러를 이어주는 다리

* 연결된 DOM에서의 실행환경

* 양방향 데이터 바인딩 처리

* 이벤트 전파 처리

* 계층적 구조

<br>

# $scope의 계층구조
모든 AngularJS 애플리케이션은 하나의 **$rootScope** 를 가진다. 이 $rootScope는 ng-app을 생성하며 ng-app이 선언된 DOM 요소가 최상위
노드가 되어 여러 자식 $scope를 가지게 된다. 즉, DOM과 같은 계층적 구조에서 최상위 계층에 $rootScope가 존재하는 것이다. 이는 어쩌면
window와 같은 **전역 변수** 영역이라고 생각할 수도 있다. 또한 ng-controller나 ng-repeat과 같이 별도의 $scope를 생성하는 지시자는 각
**지역변수** 영역을 가지고 있다고 생각할 수 있다. ng-controller를 계층적으로 가지는 예제 코드이다.

    <!doctype html>
    <html ng-app>
        <head>
            <meta charset="UTF-8">
            <script src="../angular/angular.js"></script>
            <script type="text/javacsript">
                function parentCtrl($scope) {
                    $scope.parent = {name: "parent Kim"};
                }

                function childCtrl($scope) {
                    $scope.child = {name: "child Ko"};
                    $scope.changeParentName = function() {
                        $scope.parent.name = "another Kim";
                    };
                }
            </script>
        </head>
        <body>
            <div ng-controller="parentCtrl">
                <h1>부모이름: {{parent.name}}</h1>
                <div ng-controller="childCtrl" style="padding-left: 20px;">
                    <h2>부모이름: {{parent.name}}</h2>
                    <h2>자식이름: {{child.name}}</h2>
                    <button ng-click="changeParentName()">부모이름변경</button>
                </div>
            </div>
        </body>
    </html>

위 예제 코드를 보면 우선 <html> 태그에 ng-app을 사용해 $rootScope가 하나 만들어진다. 그리고 parentCtrl 함수와 해당 컨트롤러 이름이
ng-controller로 작성된 <div> 태그를 연결하는 $scope가 있고, childCtrl 함수와 해당 컨트롤러 이름이 ng-controller로 작성된 <div>
태그를 연결하는 $scope가 있다. 그래서 총 세 개의 $scope가 있다. 그리고 parentCtrl 컨트롤러에서 parent 모델을 선언했고 childCtrl
컨트롤러에서 child 컨트롤러를 선언했다. childCtrl 컨트롤러와 연결된 <div> 태그를 보면 <h2>부모이름: {{parent.name}}</h2>라고
작성된 부분이 있다. 이 부분을 보면 $scope의 parent 모델에 접근하는 표현식이 작성됐는데 childCtrl 컨트롤러 함수에서는 parent라는
모델이 선언되지 않았다. 하지만 브라우저에서 결과를 보게 되면 부모이름: parent Kim이라고 출력되는 모습을 볼 수 있다. 또한, 부모이름
변경 버튼을 클릭하면 parentCtrl 컨트롤러의 parent 모델까지 값을 변경한느 것을 볼 수 있다. 이는 부모 $scope로부터 프로토타입을 상속
받기 때문이다. 즉, 자식 $scope에서 없는 모델 즉, 속성을 부모 $scope에서 찾는다. 다음은 계층적 구조를 가지는 $scope가 프로토타입 상속으로
이루어져 있음을 보여주는 그림이다.

![MVC_Pattern_3](/img/2015/11/26/MVC_Pattern_3.png "MVC_Pattern_3")
