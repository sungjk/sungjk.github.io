---
layout: entry
title: Testing React application with Karma, Jest or Mocha.
author: 김성중
author-email: ajax0615@gmail.com
description: 리액트 컴포넌트 테스트에 사용되는 Karma, Jest 그리고 Mocha 라이브러리에 대한 비교 설명입니다.
publish: true
---

MARTIN BIELIK님의 게시글 [TESTING REACT APPLICATIONS WITH KARMA, JEST OR MOCHA](http://instea.sk/2016/08/testing-react-applications-with-karma-jest-or-mocha/)(CC BY) 전문을 번역했습니다.

![photo](/images/2017/03/03/still-life.jpg "photo"){: .center-image }

리액트 컴포넌트를 테스트하기 위한 라이브러리를 쉽게 찾을 수 있습니다. 하지만 이제 막 리액트나 자바스크립트를 배우기 시작하는 사람들에게는 어떤 라이브러리가 어떠한 상황에 사용하기에 적합한지 판단하기 어려울 것입니다.

일반적으로 테스트 프레임워크는 다음과 같은 것들을 제공할 것입니다.

- 구조적인 테스트를 제공한다([Mocha](https://mochajs.org/), [Jasmine](https://github.com/jasmine/jasmine), [Jest](https://facebook.github.io/jest/)).
- 테스트 결과를 보여준다(Mocha, Jasmine, Jest, [Karma](https://karma-runner.github.io/1.0/index.html)).
- 단언문을 제공한다([Chai](http://chaijs.com/), Jasmine).
- 목, 스파이, 스텁 등을 지원한다([Sinon.JS](http://sinonjs.org/), Jasmine).
- 코드 커버리지 리포트를 생성한다([Istanbul](https://github.com/gotwarlost/istanbul)).

이 글에서 리액트 컴포넌트를 테스트하기 위해 사용되는 라이브러리 중 Karma, Jest 그리고 Mocha가 어떤 것이고, 이들을 각각 비교하여 알아보도록 하겠습니다.

# Karma
Karma는 실제 브라우저에서 테스트를 실행할 수 있도록 도와줍니다. 특히, 해당 애플리케이션이 오래된 브라우저나 여러 브라우저의 호환성을 지원해야할 때 좋습니다. 게다가 BrowserStack이나 SauceLabs와 같은 서비스나 웹드라이버(webdriver)를 이용해서 원격으로 테스트를 할 수 있습니다. 몇 줄의 설정과 관련된 도구만 설치하면 여러 브라우저를 동시에 테스트할 수 있습니다.

예를 들어, 파이어폭스 브라우저를 테스트하려면 다음과 같이 설정해주면 됩니다.

```javascript
npm install karma-firefox-launcher --save-dev
```

그리고 설정 파일에 다음과 같이 작성해주면 됩니다.

```javascript
module.exports = function(config) {
  config.set({
    browsers : ['Chrome', 'Firefox']
  });
};
```

Karma는 Phantom.js를 포함한 모든 브라우저를 지원하고, jsdom을 사용해서 Node.js 내부에서도 실행될 수 있습니다. 그래서 Mocha나 Jest와 같은 다른 테스트 러너와 함께 Karma를 사용하는 것이 일반적입니다.

일부 개발자들은 실제 브라우저에 대해 단위 테스트를 하는 것은 쓸모 없다고 말하면서, 종단간(end to end) 테스트를 작성하고 있습니다. 그러나 e2e 테스트는 비용이 많이 들고, 실행하는 시간도 오래 걸리고, 대부분 각 유스케이스를 다루지 않습니다. 그래서 저는 Karma가 호환성 버그를 찾는데 가장 쉽고 빠른 솔루션을 제공한다고 생각합니다(실패하면 가장 빨리 실패할 것입니다). Karma는 분명히 시도해 볼 가치가 있습니다!


# Jest vs. Mocha
핵심 논점은 Jest와 Mocha 중 무엇을 사용할지 여부입니다. 둘 다 훌륭한 라이브러리이고, 각각 장단점을 가지고 있습니다. Jest가 페이스북 개발자들에 의해 공식적으로 추천되었지만, Mocha 스택이 더 많이 사용되는 것 같습니다(특히 Enzyme과 조합해서).

주요 차이점은 (미래지향적인) Jest의 접근 방식인 "자동 모의(auto mocking)"입니다 - Jest 개발자들은 단위 테스트된 것들을 제외한 모든 의존성을 모의(mock)하기로 결정했습니다. 이는 좋지도 나쁘지도 않은 접근이고, 단지 차이일 뿐입니다. 이는 모든 종속성을 모의해야 하는 애플리케이션에서 상용문(boilerplate)을 크게 줄이고 테스트 작성을 쉽게 도와줍니다. 하지만 리액트를 테스트 할 때, 얕은 렌더링(shallow rendering)을 제공하는 유틸리티([React Test Utils](https://facebook.github.io/react/docs/test-utils.html))가 있는 동안에는 자동 모의가 독점적으로 필요하지 않습니다. Enzyme과 같은 테스트 유틸리티는 렌더링, 컴포넌트 순회, 클릭 등 기타 시뮬레이션에 유용한 많은 방법들을 제공합니다. 자동 모의는 상대적으로 값 비싸며, 개발 과정에서 실제로 피곤함이 오래 지속될 수 있습니다.

다음 차이점은 Jest는 단언문, 모의 그리고 자체 모의 메소드를 가지는 Jasmine 2를 기본값으로 사용한다는 것입니다. 반면에 Mocha는 더 유연하고 원하는 것을 필요에 따라 선택할 수 있습니다. 그래서 Mocha는 다른 모의 라이브러리(Chai, Sinon.JS 등)와 함께 사용할 수 있습니다.

일부 사람들은 Jest 테스트의 설치, 설정 및 구성이 Mocha보다 덜 복잡하다고 주장합니다. 사실 Jest는 하나의 패키지에 모든게 들어 있기 때문에 맞는 말입니다. 그리고 Mocha를 사용할 때는 단언 라이브러리를 설정해주어야 합니다. 하지만 노력은 최소한이고 이 기준으로 확실히 결정할 필요는 없습니다. 제 개인적인 경험으로는 Jest를 처음 설치하려고 시도헀을 때 모든 *node_modules* 를 자동 모의하는 문제가 발생했었습니다. 이 때 제가 작성한 테스트는 실행되지 않았고, 모든 Mocha 설정을 하는 것보다 더 혼란스럽게 모의하지 않을 모듈들을 명확하게 설정해야 했습니다.

아래 표는 각 장단점에 대해 요약한 것입니다.

| :---: | :---: |
| **Jest** | |
| 장점 | 단점 |
| 리액트에서 공식적으로 지원하고 있다. | 자동 모의 때문에 상대적으로 느리다. |
| 자동 모의(Auto mocking) | Jasmine 사용을 강요한다(추후 변경될 수 있다). |
| 스냅샷 테스트 | 문서가 빈약하다. |
| 비동기 코드의 테스트를 지원한다. |  |
| React native 테스트를 지원한다. |  |

| :---: | :---: |
| **Mocha** |  |
| 장점 | 단점 |
| 자바스크립트 커뮤니티에서 더 대중적이다. | 자동 모의나 스냅샷 테스트를 지원하지 않는다. |
| 리액트에서 공식적으로 지원하고 있다. | 자동 모의 때문에 상대적으로 느리다. |
| 유연하다(어느 라이브러리와도 함께 사용될 수 있다). | |
| 간단하고 명료한 API | |
| 비동기 코드의 테스트를 지원한다. | |
| 테스트 실행이 빠르다. | |
| React native 테스트를 지원한다. | |

이에 대해 요약하자면,

- Jest는 리액트 컴포넌트를 테스트하기 위해 페이스북에 의해 추천되었지만, Enzyme과 Mocha가 더 많이 사용되고 있습니다.
- Jest가 가지고 있는 자동 모의 때문에 상대적으로 더 느립니다.
- 리액트 컴포넌트를 테스트할 때 자동 모의가 필요하지 않습니다.
- Mocha가 더 유연하고, Chai나 Sinon.JS 같은 다른 라이브러리와 함께 사용될 것으로 예상됩니다.
- Jasmine은 하나로 통합된 테스트 라이브러리입니다(러너, 단언문, 모의).
- 설치와 설정은 적합한 테스트 프레임워크를 선택할 수 있는 기준이 아닙니다.

# 결론
위에서 언급된 모든 라이브러리는 매우 정교하고 맞게 사용될 때 훌륭한 작업을 수행합니다. Karma는 다른 테스트 러너와 독립적으로 사용할 수 있는 좋은 툴입니다. 이에 대해 기회를 주지 않을 이유가 없습니다! 개인적으로 저는 Jest보다는 Enzyme과 묶어서 Mocha를 선택하는 것이 상대적으로 속도가 빨라서 개발하는 동안(매일 하는 일이죠) 편합니다. 라이브 테스트를 할 때도 마찬가지입니다. 또한 더 유연하고 Chai나 Sinon.JS와 같은 멋진 프로젝트도 함께 사용할 수 있습니다. 반면에 Jest는 자동 모의나 스냅샷 테스트와 같은 매력적인 아이디어를 가지고 있습니다. 여전히 개선되고 있고 앞으로의 진전을 보기에 좋을 것입니다. Jest와 Mocha 모두 훌륭한 테스트 도구이며 사용하고자 하는 필요에 따라 선택은 달라질 수 있습니다.
