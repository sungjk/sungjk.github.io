---
layout: post
title: AngularJS - routeProvider
categories: [general, web]
tags: [angularjs]
fullview: false
comments: true
---


# $routeProvider.when(라우트 경로, 라우트 연결 설정 객체)

$routeProvider는 말 그대로 라우트를 정의한다. 라우트 객체에 따른 라우트 연결 설정 정보를 등록할 수 있다. 라우트 경로는 문자열로 작성하면
되고 route 연결 설정 객체는 라우트 연결 정보를 객체로 표현한 것인데 다음과 같은 속성 키를 가질 수 있다.

* controller
컨트롤러 함수나 등록된 컨트롤러 함수명을 설정한다.

* controllerAs
컨트롤러의 이름을 지정한다. 나중에 scope에서 해당 이름으로 컨트롤러에 접근할 수 있다.

* template
나중에 ng-view 지시자가 사용할 템플릿을 설정한다. 문자열로 템플릿을 기술하거나 템플릿 문자열을 반환하는 함수를 기술할 수 있다. 해당 템플릿
함수에는 현재 경로에 해당하는 라우터 매개변수를 인자로 전달받는다.

* templateUrl
나중에 ng-view가 사용할 템플릿을 요청할 URL을 설정한다. 해당 URL로 HTTP 요청을 보내 템플릿을 받아온 다음 ng-view에 전달하게 된다.
template 설정과 마찬가지로 함수로도 전달할 수 있으며 URL을 반환해야 한다.

* resolve
나중에 해당 컨트롤러에 주입할 의존 관계 대상에 대한 정보를 담는 객체를 설정한다. 가령 { depA: "$log" } 로 설정되었으면 라우터와 연결되는
컨트롤러 함수에서 depA를 인자로 작성하여 $log 서비스를 주입 받을 수 있다. 즉, 해당 설정객체의 속성 키로는 컨트롤러에 주입되는 서비스의 이름이
된다. 속성 값으로는 실제 등록된 서비스명 또는 팩토리 함수가 된다. 이 팩토리 함수에서 promise를 반환할 수 있다.

* redirectTo
URL 경로를 바꾸면서 해당 URL로 이동할 경로를 설정한다. 가령 해당 라우터의 경로가 '/home'으로 설정되고 redirectTo가 '/main'으로 설정되어
있으면 브라우저의 URL이 '/home'일 때 '/main'으로 URL이 바뀌고 '/main' 경로로 설정된 라우트에 해당하는 템플릿과 컨트롤러가 활성화된다.
함수로 전달할 수 있으며 해당 함수의 반환 값은 경로를 나타내는 문자열이다.

* reloadOnSearch
오직 $location.search()나 $location.hash()가 호출 될 때만 라우팅 처리를 할지 결정한다. true / false 값을 주어 설정한다.

* caseInsensitiveMatch
대소문자 구분에 따르지 않고 라우팅 처리를 할지 여부를 결정한다. true / false 값을 주어 설정한다.

<br>

# $routeProvider.otherwise(라우트 연결 설정 객체)
브라우저의 URL이 변경될 때의 URL이 등록된 라우트 경로와 일치하는 것이 없을 때 활성화될 라우트 연결 정보를 설정한다. 단, 하나의 매개변수로
라우트 연결 설정 객체를 받는다.


    <!doctype html>
    <html ng-app="sampleApp">
    <head>
        <meta charset="UTF-8">
        <style>
            ul { padding: 0;}
            ul.menu li {
                padding: 5px;
                border: 1px solid black;
                background: black;
                display: inline;
            }
            ul li a {
                text-decoration: none;
                color: white;
            }
        </style>
        <script src="angular/angular.js"></script>
        <script src="angular/angular-route.js"></script>
        <script type="text/javascript">
            angular.module('sampleApp', ['ngRoute']).
                    config(function ($routeProvider) {
                        $routeProvider
                                .when('/home', {templateUrl: 'template/home.tmpl.html'})
                                .when('/about', {templateUrl: 'template/about.tmpl.html', controller: 'aboutCtrl'})
                                .when('/contact', {templateUrl: 'template/contact.tmpl.html', controller: 'contactCtrl'})
                                .otherwise({redirectTo: '/home'});
                    }).
                    controller('mainCtrl', function ($scope, $route) {
                        $scope.route = $route;
                        $scope.routes = $route.routes;
                        $scope.$on("$routeChangeSuccess", function (e, cRtoue, pRoute) {
                            console.log("현재 라우트 정보: ", cRoute.loadedTemplateUrl);
                            if (pRoute) console.log("이전 라우트 정보: ", pRoute.loadedTemplateUrl);
                        });
                        $scope.reload = function ($scope) {
                            $route.reload();
                        }
                    }).
                    controller('aboutCtrl', function ($scope) {
                        $scope.sales = 20000000;
                    }).
                    controller('contactCtrl', function ($scope) {
                        $scope.contactSubmit = function (contact) {
                            alert(contact.name + "에게 " + contact.contents + "를 전달했습니다.");
                        };
                    });
        </script>
    </head>
    <body ng-controller="mainCtrl">
        <ul class="menu">
            <li><a href="#home">홈</a></li>
            <li><a href="#about">회사에 관하여</a></li>
            <li><a href="#contact">회사 연락</a></li>
        </ul>
        <ng-view></ng-view>
        <hr>
        <div>
            <h2>라우트 정보</h2>
            <h3>현재 라우트 정보</h3>
            {{route.current}}
            <br>
            <h4>등록된 라우트 정보</h4>
            <ul>
                <li ng-repeat="(key, value) in routes">
                    <h5>{{key}}</h5>
                    <p>{{value}}</p>
                </li>
            </ul>
        </div>
        <button ng-click="reload()">리로드</button>
    </body>
    </html>

위 예제를 보면 mainCtrl 컨트롤러 함수에서 $route 서비스를 주입받는 것을 확인할 수 있따. 해당 $route 서비스를 이용해 현재 라우트 정보와
전체 등록된 라우트 목록을 확인할 수 있다. 또한, 라우트에 발생하는 이벤트에 대한 리스너 함수를 등록할 수 있으며, current 속성을 이용해
현재 라우트 정보를 가져오고 routes 속성을 이용해 라우트 목록을 가져온다.

$scope에 $routeChangeSuccess 이벤트에 대한 리스너 함수를 등록해 라우트가 성공적으로 변경될 때 이전 라우트 정보나 새로운 라우트 정보를
콘솔에 출력하고 있다. 내부적으로 라우팅되거나 라우트 정보가 바뀔 때 여러 이벤트를 $rootScope에서 브로드캐스트하고 있어 어느 $scope에서든
$on 메서드를 이용해 이벤트 리스너 함수를 등록할 수 있다.

* $routeChangeError
만약 어떠한 의존 관계 대상이 해결되지 않으면 해당 이벤트가 발생한다. 가령 템플릿을 불러오지 못해 라우팅이 실패하면 해당 이벤트가 발생한다.

* $routeChangeStart
라우트 변경이 일어나기 전에 해당 이벤트가 발생한다. 템플릿을 불러오는 일이 해결되기 전에 호출된다고 보면 된다.

* $routeChangeSuccess
모든 의존 관계 대상이 해결되면 해당 이벤트가 발생한다.

* $routeUpdate
라우트 정보가 갱신되면 해당 이벤트가 발생한다.

$route 서비스는 update 메서드를 제공한다. 해당 메서드는 브라우저의 URL이 바뀌지 않아도 컨트롤러를 다시 초기화하고 ngView 지시자에 새로운
scope를 생성하게 해준다.
