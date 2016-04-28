---
layout: post
title: AngularJS - 뷰 View
---

# 뷰
AngularJS에서 뷰는 문서 객체 모델 Document Object Model 이다. 브라우저에서 HTML 문서를 읽어서 DOM을 생성하는데 AngularJS에서는 이 DOM이 
뷰가 되는 것이다. 템플릿과 뷰를 혼동할 수 있는데 AngularJS에서는 HTML 문서가 템플릿이고 이 템플릿을 AngularJS가 읽어서 뷰를 생성한다. 뷰를 
생성하는 과정은 다음과 같다.

1. HTML로 작성한 템플릿을 브라우저가 읽는다.
2. 브라우저는 문서 객체 모델 DOM 을 생성한다.
3. `<script src="angular.js">`가 실행되어 AngularJS 소스가 실행된다.
4. DOM 생성 시 DOM Content Loaded 이벤트가 발생하는데 AngularJS가 이 때 생성된 정적 DOM을 읽고 뷰를 컴파일한다. 컴파일 시 확장 태그나 
속성을 처리한 후 데이터를 바인딩한다.
5. 컴파일을 완료하면 동적 DOM, 즉 뷰가 생성된다.

![MVC_Pattern_2](/img/2015/11/26/MVC_Pattern_2.jpg "MVC_Pattern_2")
