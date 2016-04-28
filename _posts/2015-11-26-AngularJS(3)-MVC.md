---
layout: post
title: AngularJS - MVC 모델, 뷰, 컨트롤러
categories: [general, setup, demo]
tags: [demo, dbyll, dbtek, setup]
fullview: false
comments: true
---


AngularJS는 자바스크립트 MVC 프레임워크 중 하나다. 하지만 AngularJS는 Smalltalk-80 언어부터 시작된 전통적인 MVC 패턴을 구현하지 않고
MVVM(Model-View-View-Model)과 비슷하게 독자적인 방식으로 MVC 패턴을 구현했다. 초기 AngularJS는 전통적인 MVC 패턴을 흡사하게 구현하여
MVC 프레임워크로 소개됐다. 하지만 AngularJS가 버전이 올라가며 다양한 기능이 추가됨에 따라 MVVM에 가깝게 되어 AngularJS 사용자들 간에
MVVM 프레임워크라는 주장이 다분했다. 그런데 AngularJS 팀에서는 AngularJS 팀에서는 AngularJS를 어느 패턴으로도 분류하지 않고 사용하는
사람 마음대로 정의하라는 의미에서 MVW(Model-View-View-Whatever) 프레임워크라 칭하였다. 그래서 AngularJS를 정식으로 소개할 때는
자바스크립트 MVW 프레임워크라 한다. 하지만 어찌됐든 사용자 인터페이스와 데이터와 애플리케이션 로직을 분리하는 개념은 MVC 패턴과 같으므로
이해하기 쉽게 좀더 친숙한 MVC 패턴 요소별로 AngularJS를 설명한다.

![MVC_Pattern_1](/img/2015/11/26/MVC_Pattern_1.jpg "MVC_Pattern_1")

#### 1. 모델 Model
도메인에 해당하는 정보를 나타내는 오브젝트다. 대체로 애플리케이션의 데이터와 행위를 포함하고 있다.

#### 2. 뷰 View
모델의 정보를 UI에서 보여주는 역할을 한다. 하나의 모델을 다양한 뷰에서 사용할 수도 있고, 여러 모델을 하나의 뷰에서 사용할 수도 있다.

#### 3. 컨트롤러 Controller
애플리케이션에서 사용자의 입력을 받아 모델에 변경된 상태를 반영한다. 이는 모델이 변하게 하여 결국 뷰를 갱신하게 한다. 컨트롤러는 직접 뷰를
변경하는 것이 아니라 주요 로직이 모델을 변경하고 그 결과가 뷰로 나타나는 것이다.

MVC 패턴을 이용하면 애플리케이션 개발과 유지보수에 있어서 몇 가지 이점이 생긴다. 첫째로 사용자 인터페이스와 비즈니스 데이터를 분리할 수 있다.
따라서 비즈니스 데이터에 해당하는 모델을 다른 뷰에서도 사용하여 모델을 재사용할 수 있게 된다. 둘째로 MVC 패턴으로 개발함으로써 팀 사이에 표준화된
개발 방식을 제공할 수 있다. 이는 제각기 개발하기 쉬운 자바스크립트 개발 환경에서 표준화된 개발 환경을 제시하는 이점을 준다.
