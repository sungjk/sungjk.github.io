---
layout: entry
title: Flux와 EventEmitter
author: 김성중
author-email: ajax0615@gmail.com
description: Flux 아키텍처의 흐름과 비동기 이벤트 드리븐을 위해 작성된 EventEmitter에 대한 설명입니다.
publish: true
---

일반적으로 리액트 애플리케이션은 최상위 컴포넌트와 그 아래에 다수의 순수 컴포넌트가 트리처럼 이루어져있고, 상위 컴포넌트에서 하위 컴포넌트로 속성(props)을 통한 단방향 데이터 흐름을 추구하고 있다.

그렇다면 하위 컴포넌트에서 상위 컴포넌트로 데이터를 전달하고 싶을 때는 어떻게 해야할까? 상위 컴포넌트에서 하위 컴포넌트에 콜백 *Callback* 을 제공하는 방법이 가장 먼저 떠오를 것이다. Button의 onClick에 이벤트 핸들러를 등록하는 것처럼 하위 컴포넌트에서 변화(Event)가 생긴다면 상위 컴포넌트로부터 받은 콜백에 변화에 대한 정보를 넘겨주면 된다. 하지만 애플리케이션을 구성하는 컴포넌트의 단계가 깊어지면 콜백을 다단계로 전달하게 되는 경우가 발생하는데, 이는 컴포넌트 간의 종속성이 깊어지는 것과 동시에 리팩토링의 어려움, 오류가 발생할 수 있는 문제점을 초래한다. 이를 해결하기 위해 Flux는 Action, Dispatcher, Store의 개념을 도입하여 단방향 데이터 흐름을 지원하고 있다. 예를 들어, 채팅방에 입장하는 버튼을 클릭하면 다음과 같은 순서로 진행된다.

1. View(컴포넌트)에서 입장 버튼을 클릭하는 Action이 발생한다.
2. 버튼 클릭에 대한 Action이 Dispatcher에 등록된다.
3. Dispatcher는 Store에게 버튼 클릭 Action이 발생하였으니 상태를 변경하라고 알려준다.
4. Store는 자신의 상태가 변경되었음을 View에게 알려주는 이벤트를 발생시킨다.
5. View는 이벤트가 발생됨을 알고, Store의 상태를 참조하여 변경된 부분을 업데이트한다.

![flux-action](/images/2016/10/03/flux-action.png "flux-action"){: .center-image }

4번에서 Store는 자신의 상태가 변경되었다는 이벤트를 발생시켜야 하는데 어떻게 하면 이벤트를 발생시킬 수 있을까? 5번에서 이벤트가 발생되었음을 알아야하는데 어떻게 알 수 있을까? '버튼이 클릭되었다'와 같은 이벤트를 발생시킬 수 있게끔 도와주는 것이 바로 **EventEmitter** 이다.

---

## EventEmitter
EventEmitter는 Node.js에 내장되어 있는 이벤트 드리븐 아키텍처를 위한 API이다. Node 뿐만 아니라 이벤트 기반의 다양한 환경에서 사용할 수 있다. EventEmitter를 사용하여 이벤트를 생성하고 감지하고 싶다면 기본적으로 `.emit()`와 `.on()` 메서드를 각각 정의해야 한다.

- **`.emit('EVENT_NAME')`**  'EVENT_NAME'으로 정의된 이벤트를 발생시키는 역할을 한다.
- **`.on('EVENT_NAME', callback)`**  'EVENT_NAME'으로 정의된 이벤트가 발생됨을 감지하여 callback을 호출한다.

위에서 설명한 상황을 코드를 통해 직접 확인해보자(Dispatcher는 생략).

#### View
먼저 채팅방 참여 버튼을 구성하고 있는 View는 다음과 같은 형태로 이루어져 있다. 참여 버튼이 클릭되면 spaceAction에 정의된 joinSpace 메서드가 호출될 것이다. Store에서 상태가 변경되었다는 이벤트가 발생하면 `spaceStore.onJoinSpace(callback)`에서 이를 감지한 후, callback을 실행한다. 이 때 callback은 Store에서 변경된 값을 받아 View에 업데이트하는 역할을 한다.

```javascript
import React, {Component} from 'react';
import spaceAction from '...';
import spaceStore from '...';

class JoinSpace extends Component {
    constructor() {
        ...
        this.state = {
            spaceInfo: spaceStore.spaceInfo
        };
        this.onJoinSpace = this.onJoinSpace.bind(this);
    }

    componentDidMount() {
        ...
        spaceStore.onJoinSpace(this.onJoinSpace);  // Store에서 이벤트가 발생되면 callback 메서드인 this.onJoinSpace()를 호출한다.
    }

    componentWillUnmount() {
        ...
        spaceStore.removeJoinSpaces(this.onJoinSpace);
    }

    ...

    joinSpace() {
        spaceAction.joinSpace(this.state.spaceId);
    }

    onJoinSpace() {
        this.setState({spaceInfo: spaceStore.spaceInfo});  // Store의 변경된 상태를 View에 반영한다.
    }

    render() {
        return (
            <button onClick={this.joinSpace}>방 참여</button>
        );
    }
}

export default JoinSpace;
```

#### Action
사용자가 방 참여 버튼을 클릭하면 joinSpace 메서드가 실행되고, Dispatcher에 'JOIN_SPACE'라는 액션이 발생하였다고 디스패치한다. 이 때, 디스패처가 Store에게 전달할 데이터도 함께 명시해준다.

```javascript
// action
import Dispatcher from '...';
import ActionTypes from '...';
import socketManager from '...';

const spaceAction = {
    ...
    joinSpace: (spaceId) => {
        socketManager.send('/joinSpaces', {
            spaceId: spaceId
        }, function(err, result) { // result: 입장한 채팅방에 대한 정보
            Dispatcher.dispatch({
                actionType: ActionTypes.JOIN_SPACE,
                data: result    // data: store에게 넘겨줄 데이터
            });
        });
    },
    ...
};

export default spaceAction;
```

#### Store
Store는 Dispatcher로부터 'JOIN_SPACE'라는 액션이 발생되었음을 알게 되고, Dispatcher로부터 전달받은 데이터로 자신의 상태를 변경한다. 자신의 상태가 변경되었음을 View에게 알리기 위해 `.emitJoinSpace()` 메서드를 호출하여 'EVENT_JOIN_SPACE'라는 이벤트가 발생되었음을 알린다. 이벤트가 발생하면 View에서 이벤트에 대한 callback을 호출한다.

```javascript
import Dispatcher from '...';
import {ActionTypes} from '...'
import {EventEmitter} from 'events';

class SpaceStore extends EventEmitter {
    constructor() {
        super();
        this._spaceInfo = null;
        this.EVENT_JOIN_SPACE = 'EVENT_JOIN_SPACE';
    }

    ...

    setSpaceInfo(data) {
        this._spaceInfo = data.result.spaceInfo;
    }

    get spaceInfo() {
        return this._spaceInfo;
    }

    emitJoinSpace() {
        this.emit(this.EVENT_JOIN_SPACE);
    }

    onJoinSpace(callback) {
        this.on(this.EVENT_JOIN_SPACE, callback);
    }

    removeJoinSpaces(callback) {
        this.removeListener(this.EVENT_JOIN_SPACE, callback);
    }

    ...
}

const spaceStore = new SpaceStore();

spaceStore.dispatchToken = Dispatcher.register((action) => {
    switch (action.actionType) {
        ...
        case ActionTypes.JOIN_SPACE:
            spaceStore.setSpaceInfo(action.data); // Dispatcher로부터 전달받은 데이터로 상태를 변경시킨다.
            spaceStore.emitJoinSpace();           // 상태가 변경되었다는 이벤트를 발생시킨다.
            break;
        ...
    }
});

export default spaceStore;
```

---

이상 Flux의 Action, Dispatcher, Store, View의 동작 방식과 이벤트 발생을 위한 EventEmitter에 대해 알아보았다.

읽어주셔서 감사합니다.

## 더보기
[Node.js의 Events 'EventEmitter' 번역](http://www.haruair.com/blog/3396)
