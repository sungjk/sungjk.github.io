---
layout: post
title: AngularJS - 컨트롤러 Controller
---

# 컨트롤러
AngularJS에서 컨트롤러는 많은 일을 하지 않는다. 단 하나의 역할 즉, **애플리케이션의 로직**을 담당한다. 이를 다르게 설명하면 컨트롤러는 모델의 
상태를 정의, 변경한다고 할 수 있다. 결국 $scope 객체에 데이터나 행위를 선언하는 것이다. 그리고 컨트롤러는 인자로 $scope를 전달받는 단순한 
자바스크립트 함수다. 다음은 초기 모델의 상태를 정의하는 컨트롤러 함수다.

    function demoCtrl($scope) {
        $scope.bookmarkList = [{ name: "구글", url: "google.com"}, { name: "네이버", url: "naver.com"}];
    }
    
이렇게 정의된 컨트롤러는 템플릿에서 ng-controller 지시자를 이용해 템플릿에서 사용할 수 있다.

    <div ng-controller="demoCtrl">
        <ul><li ng-repeat="bookmark in bookmarkList"><p>{{bookmark.name}}</p></li></ul>
    </div>
    
위처럼 컨트롤러에서 애플리케이션에 사용되는 북마크 모델과 그 초기 상태를 정의할 수 있을 뿐만 아니라 몇 가지 행위를 추가할 수도 있다. 다음은 
새로운 북마크 정보를 추가하는 행위를 컨트롤러에서 기술한 코드다.

    function demoCtrl($scope) {
        $scope.addBookmark = function(name, url) {
            $scope.bookMarkList.push({ name: name, url: url });
        }
    }
    
하지만 컨트롤러 코드를 작성할 때 주의해야 할 점이 있다. 컨트롤러는 **단 하나의 뷰에 해당하는 애플리케이션 로직**만을 담당해야 한다. 화면상의 
로직이 아니라 애플리케이션의 비즈니스 로직이다. 즉 DOM을 조작하는 행위와 같은 화면 상의 로직은 다음에 설명한 지시자에서 구현하고 컨트롤러에서는 
애플리케이션의 비즈니스 로직만을 구현해야 한다. 다음과 같은 코드는 사용해서는 안 된다.

    function demoCtrl($scope) {
        $scope.addBookmark = function(name, url) {
            // 컨트롤러에서 DOM을 조작하면 안 된다.
            $("ul#bookmarkList").add("<li> 이름: " + name + ", 주소: " + url + "</li>");
        }
    }
    
AngularJS에서는 하나의 화면에 여러 컨트롤러를 작성할 수 있다. 하나의 화면은 사실 여러 뷰의 조합으로 이뤄질 수 있기 때문이다. 가령 검색 조건 뷰와 
검색 결과 목록 뷰가 이루어진 북마크 조회 화면과 같이 말이다. 이렇게 여러 뷰가 만들어지면 하나의 컨트롤러를 하나의 뷰와 연결하는 것을 권장한다.
    
AngularJS의 컨트롤러는 하나의 컨트롤러에 하나의 $scope만을 가지게 된다. 즉 searchCtrl 컨트롤 함수와 bookmarkListCtrl 컨트롤 함수 두 개가 
있을 경우 컨트롤 함수와 별도의 $scope 객체가 생성된다. 그리고 AngularJS 애플리케이션 루트에 해당하는 $rootScope가 있다.

하나의 화면에 여러 컨트롤러를 사용하면 컨트롤러별로 독립된 $scope가 생성된다. 각 독립된 $scope는 서로 참조할 수 없다. 그래서 컨트롤러 사이에 
데이터를 공유해야 할 경우 다른 방법을 찾아야 한다. 이를 해결하는 방법으로 서비스(의존관계 주입과 서비스)를 이용할 수 있다.