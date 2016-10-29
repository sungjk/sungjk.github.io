---
layout: entry
title: React - Life Cycle
author: 김성중
author-email: ajax0615@gmail.com
description: 리액트의 컴포넌트의 생명주기(Life Cycle)에 대한 설명입니다.
publish: true
---

리액트 컴포넌트를 만들 때 **컴포넌트 생명주기의 특정 시점에 자동으로 호출될 메서드** 를 선언할 수 있다. 각 생명주기 API를 이해하고 있으면 컴포넌트가 생성 또는 삭제될 때 특정한 작업을 수행할 수 있다.

---

## 생명주기 단계와 API

초기 컴포넌트 생성 단계, 상태와 속성 변경, 트리거된 업데이트, 컴포넌트의 언마운트 단계 간의 차이를 구분할 수 있어야 한다.

![LifeCycle](/images/2016/10/29/LifeCycle.png "LifeCycle"){: .center-image }

컴포넌트를 생성(마운팅)할 때는 **constructor -> componentWillMount -> render -> componentDidMount** 순으로 진행된다.<br>
컴포넌트를 제거(언마운팅)할 때는 **componentWillUnMount** 메서드만 실행하면 된다.<br>
컴포넌트 업데이트는 속성과 상태에 따라 비슷하지만, 차이가 있다. 좀 더 자세히 알아보자.

#### 마운팅(Mounting)
- **componentWillMount**: 렌더링을 수행하기 전에 호출된다. 이 단계에서 상태를 설정하더라도 렌덜이이 다시 트리거되지 않는다.
- **componentDidMount**: 렌더링을 수행한 후에 호출된다. 이 시점에서 컴포넌트에 대한 DOM 표현이 생성되기 때문에 데이터 가져오기 등의 작업을 할 수 있다.

#### 언마운팅(Unmounting)
- **componentWillUnMount**: 컴포넌트가 DOM에서 언마운팅되기 전에 호출된다.

#### 속성 변경(Updating - prop)
- **componentWillReceiveProps**: 컴포넌트가 새 속성을 받을 때 호출된다. 이 함수 안에 this.setState()를 호출해도 렌더링이 트리거되지 않는다.
- **shouldComponentUpdate**: render 함수보다 먼저 호출되는 함수이며, 해당 컴포넌트의 렌더링을 생략할 수 있는 기회를 제공한다.
- **componentWillUpdate**: 새로운 속성이나 상태를 수신하고 렌더링하기 전에 호출된다. 등록된 업데이트에만 이용해야 하며, 업데이트 자체를 트리거하지 않아야 하므로 this.setState를 통한 상태 변경은 허용되지 않는다.
- **componentDidUpdate**: 컴포넌트 업데이트가 DOM으로 플러시된 후에 호출된다.

#### 상태 변경(Updating - state)
- 속성 변경과 거의 동일한 생명주기를 가지고 있지만, componentWillReceiveProps에 해당하는 메서드는 없다. 따라서 shouldComponentUpdate부터 시작된다.

---

## 생명주기 API의 실제 활용: 데이터 가져오기
데이터를 가져오는 것은 리액트보다는 자바스크립트에 대한 주제지만 **컴포넌트의 특정 생명주기(componentDidMount API)** 에서 데이터를 가져와야 한다는 점이 중요하다.

데이터를 가져올 때, 다른 역할을 가지고 있는 컴포넌트에 데이터 가져오기 논리를 추가하는 것보다 **원격 API와 통신하고 속성을 통해 데이터와 콜백을 전달하는 역할만 수행하는 상태 저장 컴포넌트** 를 새로 만드는 것을 권장한다. 이러한 역할을 하는 컴포넌트를 *컨테이너 컴포넌트* 라고 한다.

색상 찾기 앱에도 이 컨테이너 컴포넌트의 개념을 이용할 수 있다. 즉, 기존 ColorsApp 컴포넌트에 데이터 가져오기 논리를 추가하는 것이 아니라 계층 위쪽에 ColorsAppContainer라는 컴포넌트를 새로 만든다. 기존 ColorsApp에는 변경 사항이 없으며 여전히 속성을 통해 데이터를 받는다.

```javascript
import React, {Component, PropTypes} from 'react';
import {render} from 'react-dom';
import 'whatwg-fetch';

class ColorsAppContainer extends Component {
    constructor() {
        super();
        this.state = {
            colors: []
        };
    }

    componentDidMount() {
        fetch('./colors.json')
        .then((response) => response.json())
        .then((responseData) => {
            this.setState({colors: responseData});
        })
        .catch((error)=>{
            console.log('Error fetching and parsing data', error);
        });
    }

    render() {
        return (
            <ColorsApp colors={this.state.colors} />
        );
    }
}

// 아래의 나머지 컴포넌트에는 변경 사항이 없다.
class ColorsApp extends Component {
    constructor(){...}
    handleUserInput(searchTerm){...}
    render(){...}
}
ColorsApp.propTypes = {...}

class SearchBar extends Component {
    handleChange(event){...}
    render(){...}
}
SearchBar.propTypes = {...}

class ColorList extends Component {
    render(){...}
}
ColorList.propTypes = {...}

class ColorItem extends Component {
    render() {...}
}
ColorItem.propTypes = {...}

// 이제 ColorsApp이 아닌 ColorsAppContainer를 렌더링한다.
render(<ColorsAppContainer />, document.getElementById('root'));
```

[예제코드]((https://github.com/sungjungkim/react-practice/tree/master/practice03))를 직접 실행을 해보고, componentDidMount API와 컨테이너의 역할을 확인해보기 바란다.
