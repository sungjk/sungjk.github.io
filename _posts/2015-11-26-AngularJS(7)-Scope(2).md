---
layout: post
title: AngularJS - Scope(2)
categories: [general, web]
tags: [angularjs]
fullview: false
comments: true
---

# Scope 타입

지금까지 본 $scope 객체나 $rootScope 객체는 AngularJS 내부에서 정의하는 Scope 타입의 인스턴스다. 즉, 다음과 같이 별도의 생성자 함수가 AngularJS 내부에 정의돼 있다.

    function Scope() { .... }
    Scope.prototype.$apply = function(){};
    Scope.prototype.$digest = function(){ ... };
    Scope.prototype.$watch = function(){ ... };
    Scope.prototype.$new = function(){ ... };
    // ...

AngularJS는 초기 부트스트랩 시 프레임워크 내부에서 $rootScope을 new Scope()과 같이 생성한 후 해당 $rootScope을 서비스로 제공한다. 그리고 ng-controller나 웹 애플리케이션에서는 다음과 같이 $rootScope을 이용해 자식 $scope 객체들을 만들수 있다.

    var $scope = $rootScope.$new();

scope 타입의 프로토타입 메소드를 살펴보자.

* $apply(표현식 혹은 함수)
주로 외부 환경에서 AngularJS 표현식을 실행할 때 사용한다. 즉, 외부 라이브러리로 이벤트를 처리할 때나 setTimeout 메소드를 사용할 떄 사용한다.
인자로는 표현식이나 함수를 전달할 수 있다. 표현식으로 전달하면 해당 표현식을 계산하고 함수를 전달하면 함수를 실행시킨다. 그리고 내부적으로
$rootScope의 $digest를 실행해 등록된 모든 $watch를 실행하게 된다.

* $broadcast(이벤트 이름, 인자들 ...)
첫 번째 인자인 이벤트 이름으로 하는 이벤트를 모든 하위 $scope에게 발생시킨다. 가령 `$scope.$broadcast('popup:open', {title: "hello"});`
를 호출하면 $on 메소드를 이용해 해당 이벤트(popup:open)를 듣고 있는 $scope들에게 {title: "hello"}의 데이터를 전달할 수 있다. 잘 활용하면
$scope들 사이의 참조 관계를 매우 느슨하게 만들어 재활용할 수 있는 UI 컴포넌트 개발에 용이하다.

* $destroy()
현재 $scope를 제거할 수 있다. 또한, 모든 자식 $scope까지 파괴된다.

* $digest()
$scope와 그 자식에 등록된 모든 $watch 리스너 함수를 실행시킨다. $watch 리스너 함수가 보는 표현식에 대하여 변화가 없다면 리스너 함수는
실행시키지 않는다.

* $emit(이벤트명, 인자들 ...)
해당 $scope를 기준으로 상위 계층 $scope에게 이벤트 명으로 인자를 전달한다. 물론 $on으로 이벤트를 듣고 있는 상위 계층에 한하여 전파한다.

* $eval(표현식, 로케일)
주어진 표현식을 계산하고 그 결과를 반환한다. 물론 현재 $scope를 기준으로 표현식이 계산된다. 예를 들어, $scope의 b라는 속성에 3이라는 값이
있으면 `$scope.$eval('b+3');` 결과는 6이 된다.

* $evalAsync(표현식)
$eval과 마찬가지나, 표현식의 결과값이 바로 반환되지 않고 나중에 어떻나 시점에서 그 결과가 반환된다. 하지만 적어도 한번의 $digest가 호출된다.

* $new(독립여부)
새로운 자식 $scope를 생성한다. 독립여부를 true, false로 전달하는데 true일 경우 프로토타입을 기반으로 상속하지 않게 된다.

* $on(이벤트 이름, 리스너 함수)
주어진 이벤트 이름으로 이벤트를 감지하다가 해당 이벤트가 발생하면 리스너 함수를 실행한다. 이벤트 리스너 함수는 첫 번째 인자로 이벤트 객체를
받고 다음으로 $emit이나 $broadcast에서 전달한 값을 인자로 받는다.

* $watch(표현식, 리스너 함수, 동등성여부)
대상 $scope에 특정 표현식을 감지하는 리스너 함수를 등록한다. 가령 $scope의 data 속성에 특정 객체가 할당되어 있다고 하자. 그리고
`$scope.$watch("data", function() {...})` 로 함수를 호출하면 $scope.data의 레퍼런스가 변경될 때 리스너 함수가 호출된다. 리스너
함수에는 인자로 새로운 값과 이전 값이 주어진다. 동등성 여부는 변경을 레퍼런스로 감지할 것인지 동등한 여부로 감지할 것인지를 정할 때 사용한다.
기본값은 false이며 레퍼런스 변경 시에만 리스너 함수가 호출된다.

* $watchCollection(표현식, 리스너 함수)
기본적으로 $watch와 같은 기능을 하며 대신 배열이나 객체에 대한 변경을 감지할 떄 사용한다. 배열일 경우 새로운 배열 요소가 추가되거나 배열
요소들 사이의 순서가 변경되거나 배열 요소가 삭제될 때마다 리스너 함수가 호출된다. 객체일 경우 속성에 변경이 있을 떄마다 리스너 함수가 호출된다.

위 함수를 사용 시점별로 묶으면 데이터 바인딩 처리 시 $apply, $digest, $watch, $watchCollection을 사용하고, 사용자 정의 이벤트처리 시
$broadcast, $emit, $on 을 사용한다. $eval과 $evalAsync는 표현식을 $scope 객체의 컨텍스트 context에서 계산할 때 사용하고, $new와
$destroy는 $scope의 생성과 파괴 처리 시 사용한다. 컨트롤러에서 사용하는 $scope 객체는 scope 타입의 인스턴스이므로 프로토타입 상속에 의해
위 메소드를 사용할 수 있다.

<br>

# $scope에서 사용자 정의 이벤트 처리
AngularJS에서는 웹 애플리케이션에 애플리케이션 이벤트를 정의하고 이런 이벤트 처리에 대한 일련의 매커니즘을 제공한다. 이러한 사용자 정의
이벤트는 모두 $scope 객체를 통하여 처리되는데 $scope 객체에서 특정 이벤트를 발생시키면 이벤트를 발생한 $scope 객체의 자식이나 부모
$scope에서 해당 이벤트를 듣고 있다 처리할 수 있다.

이벤트를 발생시키는 API는 $scope 객체의 **$broadcast**와 **$emit** 메서드가 있다. $broadcast는 앞의 Scope 타입의 프로토타입 메서드
목록에서 설명했듯이 자식 $scope에게 특정 이벤트의 이름으로 주어진 데이터와 함께 이벤트를 발생시킨다. 그리고 $emit은 반대로 부모
$scope에게 특정 이벤트의 이름으로 주어진 데이터와 함께 이벤트를 발생시킨다.

$emit과 $broadcast로 발생되는 이벤트는 모두 $on 메서드를 이용해 특정 이벤트 이름에 해당하는 이벤트 리스너 함수를 등록할 수 있다.
이렇게 등록된 이벤트 리스너는 등록된 이벤트 이름으로 발생하게 되면 해당 이벤트 리스너 함수가 호출된다. 이벤트 리스너 함수의 첫 번째 인자는
이벤트 객체이고 다음 인자는 $emit과 $broadcast로 이벤트 발생 시 전달하는 데이터가 된다.

하단에 메시지를 입력하면 중앙에 입력한 메시지가 보이고 상단에 공지사항을 입력하면 "[공지]"라는 접두사가 붙어 중앙에 미시지가 보이는 예제다.

    <!doctype html>
    <html ng-app>
        <head>
            <meta charset="UTF-8">
            <style>
                .ng-scope {border: 1px solid red; padding: 5px;}
                .msg-list-area {margin: 10px; height: 400px; border: 1px solid black;}
            </style>
            <script src="../angular/angular.js"></script>
            <script type="text/javascript">
                function mainCtrl ($scope) {
                    $scope.$broadcast("chat:noticeMsg", noticeMsg);
                    $scope.noticeMsg = "";
                }

                function chatMsgListCtrl ($scope, $rootScope) {
                    $scope.msgList = [];
                    $rootScope.$on("chat:newMsg", function (e, newMsg) {
                        $scope.msgList.push(newMsg);
                    });

                    $scope.$on("chat:noticeMsg", function (e, noticeMsg) {
                        $scope.msgList.push("[공지] " + noticeMsg);
                    });
                }

                function chatMsgInputCtrl ($scope) {
                    $scope.submit = function (newMsg) {
                        $scope.$emit("chat:newMsg", newMsg);
                        $scope.newMsg = "";
                    };
                }
            </script>
        </head>
        <body ng-controller="mainCtrl">
            <input type="text" ng-model="noticeMsg">
            <input type="button" value="공지 전송" ng-click="broadcast(noticeMsg)">
            <div class="msg-list-area" ng-controller="chatMsgListCtrl">
                <ul>
                    <li ng-repeat="msg in msgList track by $index">{{msg}}</li>
                </ul>
            </div>
            <div ng-controller="chatMsgInputCtrl">
                <input type="text" ng-model="newMsg">
                <input type="button" value="전송" ng-click="submit(newMsg)">
            </div>
        </body>
    </html>

위 예제를 보면 간단히 세 개의 컨트롤러 함수가 정의된 것을 볼 수 있다. 맨 위에 mainCtrl 컨트롤러 함수가 정의되고 그 아래 chatMsgListCtrl
컨트롤러 함수와 chatMsgInputCtrl 컨트롤러 함수가 정의돼 있다. 각 컨트롤러와 연결된 DOM에는 각 컨트롤러가 생성하는 $scope 객체가 연결된다.
그리고 chatMsgListCtrl과 chatMsgInputCtrl 컨트롤러 함수에 연결된 DOM이 모두 mainCtrl 컨트롤러 함수 $scope의 자식이 된다(이전의 $scope
의 계층구조 참고).

상단의 mainCtrl 컨트롤러 함수의 broadcast 메서드는 "chat:noticeMsg" 이벤트 이름으로 사용자가 입력한 메시지 내용과 함께 이벤트를
발생시킨다($broadcast로). 그러면 chatMsgListCtrl 컨트롤러 함수와 $scope 객체는 mainCtrl 컨트롤러 함수의 부모 $scope에서 발생한
"chat:noticeMsg" 이벤트를 듣고 있다가 공지사항 내용을 "[공지]" 문자열과 결합하여 메시지 목록에 추가하고 이를 메시지 목록 화면에 반영한다.

하지만 하단의 chatMsgInputCtrl 컨트롤러 함수의 $scope 객체는 chatMsgListCtrl 컨트롤러 함수와 형제 관계 sibling다. 그래서
chatMsgInputCtrl 컨트롤러 함수에서 $broadcast 이벤트가 발생하면 chatMsgListCtrl 컨트롤러 함수의 $scope가 이벤트를 감지할 방법이
없다. 이럴 떄는 chatMsgInputCtrl 컨트롤러가 $rootScope까지 이벤트를 전파하고 chatMstListCtrl 컨트롤러는 $rootScope를 주입받아
$rootScope에 $on 메서드를 이용해 "chat:newMsg" 이벤트에 대한 처리를 할 수 있다.

위 예제에서 중요한 점은 각 컨트롤러가 서로 강력하게 엮여있지 않다는 점이다. 상단의 공지 전송 영역과 중앙의 메시지 목록을 보여주는 영역
그리고 하단의 메시지를 작성하는 영역이 이벤트 기반으로 서로에게 필요한 데이터를 전달하는 것이다. 각 영역의 기능을 수정하고 컨트롤러의
메서드를 수정해도 다른 영역에 영향을 주지 않는다. 만약 공지 전송 컨트롤러가 중앙 메시지 목록을 보여주는 화면에 해당하는 컨트롤러 함수의
특정 메서드를 직접 사용하다가 해당 메서드의 이름이 바뀌면 에러가 발생할 것이다. 하지만 이렇게 이벤트 기반으로 작성하면 이러한 문제점을
막을 수 있고 심지어 새로운 화면 영역과 해당 컨트롤러 함수가 추가되더라도 이벤트만 적절히 처리하면 얼마든지 기존 영역을 수정하지 않고 웹
애플리케이션을 확장할 수 있다.
