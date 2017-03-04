---
layout: entry
title: Why use Redux over Facebook Flux?
author: 김성중
author-email: ajax0615@gmail.com
description: 웹 애플리케이션의 아키텍처 중 Flux 대신에 Redux 사용을 권장하는 이유에 대한 글입니다.
publish: true
---

[Flux](https://facebook.github.io/flux/)는 웹 애플리케이션의 단방향 데이터 흐름을 위해 페이스북에서 개발한 아키텍처입니다. Flux에 대한 자세한 설명은 [이전에 작성한 글](http://ajax0615.github.io/2016/11/19/Flux.html)을 참조하면 좋겠습니다.

Flux는 페이스북에서 MVC 패턴의 고질적인 문제를 해결하기 위해 개발한 아키텍처입니다. 그리고 이 Flux를 구현한 라이브러리 중 하나가 바로 [Redux](http://redux.js.org/)입니다. Flux를 기반으로 웹 애플리케이션을 개발하면서 Flux보다는 Redux의 사용을 권하는 글을 많이 보았습니다. Flux 만으로도 충분히 단방향 데이터 애플리케이션을 개발할 수 있는데 왜 굳이 구현체인 Redux를 사용하면 좋다는걸까? 이에 대한 해답은 Redux 개발자인 [Dan Abramov의 답글](http://stackoverflow.com/questions/32461229/why-use-redux-over-facebook-flux)을 통해 알 수 있었습니다.

Redux는 Flux와 다르지 않습니다. 전반적으로 같은 아키텍처를 가지고 있지만, Redux를 사용하면 Flux에서 사용하는 콜백인 functional composition을 이용하여 복잡한 코너들을 생략할 수 있습니다.

근본적으로 다른 것은 아니지만, Redux는 Flux에서 구현하기가 어렵거나 불가능한 것들을 구현할 수 있고, 추상화 또한 상대적으로 쉽습니다.

# Reducer Composition
페이지네이션(Pagination)을 예로 들어보겠습니다. Flux와 [React Router](https://reacttraining.com/react-router/)를 사용해서 페이지네이션을 처리한다면 코드가 무시무시해집니다. 그 이유 중 하나는 Flux가 스토어(Stores) 전반에 걸쳐 기능 재사용을 어렵게 만들기 때문입니다. 두 개의 스토어가 서로 다른 액션(Actions)에 대한 응답으로 페이지네이션을 처리해야 한다면, 공통의 베이스 스토어로부터 상속하거나(별로임! 상속을 하게 되면 특정 디자인에 묶이게 됩니다), Flux 스토어의 개인 상태(Private state)에서 작동하는 함수인 핸들러로부터 함수를 호출해야합니다.

```javascript
import { EventEmitter } from 'events'

class UserStore extends EventEmitter {
  constructor() {
    super()
    this.UPDATE_USER = 'UPDATE_USER'
  }

  emitChangeUser() {
    this.emit(this.UPDATE_USER)
  }

  // 이벤트 리스너의 콜백을 통해 함수를 호출하는 Flux
  addChangeUserListener(callback) {
    this.on(this.UPDATE_USER, callback)
  }

  removeChangeUserListener(callback) {
    this.remove(this.UPDATE_USER, callback)
  }
}
```

아무튼.. 모든 것이 지저분합니다.

반면에, Redux 페이지네이션은 리듀서 조합(reducer composition) 덕분에 자연스럽습니다. 이는 리듀서의 모든 단계인데, 개발자는 리듀서 팩토리를 만들 수 있는데, 이는 [페이지네이션 리듀서를 생산](https://github.com/reactjs/redux/blob/ecb1bb453a60408543f5760bba0aa4c767650ba2/examples/real-world/reducers/paginate.js)하고 [리듀서 트리에서 이를 사용](https://github.com/reactjs/redux/blob/ecb1bb453a60408543f5760bba0aa4c767650ba2/examples/real-world/reducers/index.js#L29-L46)합니다. 이게 왜 쉽냐면, **Flux에서 스토어는 수평적이지만, 리액트 컴포넌트가 중첩될 수 있는 것처럼 Redux에서도 리듀서는 functional composition을 통해 중첩될 수 있기 때문입니다.**

![redux-pagination](/images/2017/03/04/redux-pagination.png "redux-pagination"){: .center-image }

이 패턴은 no-user-code인 [undo/redo](https://github.com/omnidan/redux-undo)와 같은 멋진 기능을 가능하게 합니다. **Flux 앱에 있는 두 줄의 코드로 Undo와 Redo를 플러깅하는게 상상이나 됩니까? 전혀요. 리덕스를 사용하면,** 리듀서 조합 패턴 덕분에 가능합니다. 이에 대해 새로운 점이 없다는 것을 강조할 필요가 있습니다. - Flux의 영향을 받은 [Elm 아키텍처](https://github.com/evancz/elm-architecture-tutorial/)에서 개척되고 상세하게 설명된 패턴입니다.

# Ecosystem
Redux는 [풍부하고 빠르게 성장하는 생태계](https://github.com/xgrommx/awesome-redux)를 가지고 있습니다. 이는 [미들웨어(Middleware)](http://redux.js.org/docs/advanced/Middleware.html)와 같은 몇 가지 확장점을 제공하기 때문입니다. [logging](https://github.com/evgenyrodionov/redux-logger), [Promises](https://github.com/acdlite/redux-promise), [Observables](https://github.com/acdlite/redux-rx), [routing](https://github.com/reactjs/react-router-redux), [immutability dev checks](https://github.com/leoasis/redux-immutable-state-invariant), [persistence](https://github.com/elgerlambert/redux-localstorage/) 등의 유스케이스를 염두에 두고 설계되었습니다. 이 모든게 유용할지 모르겠지만, 쉽게 조합하여 사용할 수 있는 좋은 도구들입니다.

# Simplicity
Redux는 Flux의 모든 이점(액션의 기록 및 재생, 단방향 데이터 흐름, Mutation 의존적)을 가지고 있고, 디스패처(Dispatcher)와 스토어 등록없이 새로운 장점들(쉬운 undo-redo, 새로고침)을 더했습니다.

더 높은 수준의 추상화를 구현하는 동안에 힘들지 않으려면, 최대한 간결함을 유지하는 것이 중요합니다.

대부분의 Flux 라이브러리와 달리 Redux API는 아주 작은 편입니다. 주석, 정밀 검사, 경고를 제외하면 [99줄](https://gist.github.com/gaearon/ffd88b0e4f00b22c3159) 밖에 안됩니다. 여기에 디버그하기 위한 까다로운 비동기 코드는 없습니다.

좀 더 궁금하다면 [다른 답변](http://stackoverflow.com/questions/32021763/what-could-be-the-downsides-of-using-redux-instead-of-flux/32916602#32916602)도 참고해보세요!!

# Review
Redux가 무엇인지는 알고 있었는데, 왜 리덕스를 사용하면 좋은가? 에 대해 명쾌한 답을 하지 못했다. Redux 개발자의 답글을 통해서 Flux에 비해 Redux가 가지고 있는 장점들에 대한 궁금증이 어느정도 풀린거 같다. 하지만 글은 글일뿐.. 실제 코드로 작성하면서 느껴봐야 제대로 알 것 같기 때문에 Flux 기반으로 작성된 애플리케이션을 Redux로 조금씩 리팩토링하면서 더 알아봐야겠다.
