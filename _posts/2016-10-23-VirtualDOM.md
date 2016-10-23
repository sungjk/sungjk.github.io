---
layout: entry
title: React - Virtual DOM
author: 김성중
author-email: ajax0615@gmail.com
description: 리액트의 가상 DOM 작동 방식에 대한 설명입니다.
publish: true
---

DOM 조작은 여러 가지 이유로 속도가 느리므로 리액트는 성능을 개선하기 위해 가상 DOM을 구현한다. 리액트는 애플리케이션의 상태가 바뀔 때마다 실제 DOM을 업데이트하는 대신 원하는 DOM 상태와 비슷한 가상 트리를 생성한다. 그런 다음 전체 DOM 모드를 다시 생성하지 않고도 실제 DOM을 가상 DOM과 같이 만드는 방법을 알아낸다.

가상 DOM 트리와 실제 DOM 트리를 동일하게 만드는 데 필요한 최소 변경 횟수를 알아내는 프로세스를 조정 *reconcilation* 이라고 하며, 일반적으로 이 작업은 아주 복잡하고 실행 비용이 높다. 이러한 조정 작업은 여러 차례에 걸쳐 반복과 최적화를 거친 후에도 매우 까다롭고 시간을 많이 소비한다. 리액트는 이 작업을 조금이라도 수월하게 하고 훨씬 빠르고 실용적인 알고리즘을 적용하기 위해 일반적인 애플리케이션의 작동 방법에 대해 몇 가지 사항을 가정한다.

- DOM 트리의 노드를 비교할 때 노드가 다른 유형일 경우(예: div를 span으로 변경) 리액트는 이를 서로 다른 하위 트리로 취급해 첫 번째 항목을 버리고 두 번째 항목을 생성/삽입한다.
- 커스텀 컴포넌트에도 동일한 논리를 적용한다. 컴포넌트가 동일한 유형이 아닌 경우 리액트는 컴포넌트가 렌더링하는 내용을 비교조차 하지 않고 DOM에서 첫 번째 항목을 제거한 후 두 번째 항목을 삽입한다.
- 노드가 같은 유형인 경우 리액트는 둘 중 한 가지 방법으로 이를 처리한다.
    - DOM 요소의 경우(예: <div id="before" /> 를  <div id="after" /> 로 변경) 리액트는 특성과 스타일만 변경한다(요소 트리는 대체하지 않음).
    - 커스텀 컴포넌트의 경우(예: <Contact details={false} /> 를  <Contact details={true} /> 로 변경) 리액트는 컴포넌트를 대체하지 않고 새로운 속성을 현재 마운팅된 컴포넌트로 전달한다. 그러면 이 컴포넌트에서 새로 render()가 트리거되고 새로운 결과를 이용한 프로세스가 다시 시작된다.

---

## 키
리액트의 가상 DOM과 비교 알고리즘은 상당히 영리하지만 속도를 높이기 위해 리액트는 몇 가지 가정하에 작업하며 일부 상황에서는 단순한 방식을 이용한다. 반복되는 항목의 리스트는 특히 처리하기 까다롭다.

```
// 이전 리스트
<li>Orange</li> <li>Banana</li>

// 이후 리스트
<li>Apple</li> <li>Orange</li>
```

두 리스트의 차이는 아주 쉽게 알 수 있지만, 한 리스트를 다른 리스트로 변환하는 최상의 방법을 말하기는 쉽지 않다. 예를 들어, 새 항목 *Apple* 을 리스트 앞부분에 추가하고 마지막 항목 *Banana* 을 삭제해도 되지만 마지막 항목의 이름과 위치를 변경해도 된다. 이보다 큰 리스트의 경우 더 많은 가능성이 있고 각 방법마다 부수 효과가 다를 수 있다. 노드를 삽입, 삭제, 대체, 이동할 수 있다는 것을 감안하면 하나의 알고리즘으로 모든 가능한 상황에서 최상의 접근법을 가려내기는 어려울 수 있다.

이런 이유로 리액트는 key 특성을 도입했다. **key는 트리 간에 항목 삽입, 삭제, 대체, 이동이 발생했는지 파악하기 위해 빠른 조회를 가능하게 하는 고유 식별자** 다. 루프 안에서 컴포넌트를 생성할 때마다 각 자식에 대한 key를 지정하면 리액트 라이브러리가 이를 비교해 성능 병목 현상을 예방할 수 있다.

---

## 칸반 앱: 키
key 속성은 고유하고 상수인 어떤 값이라도 포함할 수 있다. 카드의 데이터에는 각 카드의 ID가 포함돼 있으므로 이를 List 컴포넌트에서 key 속성으로 이용해보자.

```javascript
class List extends Component {
    render() {
        let cards = this.props.cards.map((card) => {
            return <Card key={card.id}
                id={card.id}
                title={card.title}
                description={card.description}
                color={card.color}
                tasks={card.tasks} />
        });

        return (
            <div className="list">
                <h1>{this.props.title}</h1>
                {cards}
            </div>
        )
    }
}
```

Checklist에도 배열이 있다. 여기에도 키를 추가한다.

```javascript
class CheckList extends Component {
    render(){
        let tasks = this.props.tasks.map((task) => {
            <li key={task.id} className="checklist__task">
                <input type="checkbox" defaultChecked={task.done} />
                {task.name}{' '}
                <a href="#" className="checklist__task--remove" />
            </li>
        });
        return (...);
    }
}
```

---

## ref
리액트는 컴포넌트를 렌더링할 때 항상 가상 DOM을 대상으로 작업한다. 예를 들어, 컴포넌트의 상태를 변경하거나 새로운 속성을 자식으로 전달하는 경우, 이러한 변경 사항은 반응적으로 가상 DOM으로 렌더링된다. 그런 다음 리액트가 조정 단계를 거쳐 실제 DOM을 업데이트한다.

즉, 개발자가 실제 DOM을 조작하지는 않는다. 그런데 **컴포넌트에 의해 렌더링되는 실제 DOM 마크업에 접근하고 싶은 경우** 가 생길 수 있다. 물론 대부분의 경우 실제 DOM을 조작하는 것보다 리액트 모델 안에서 더 깔끔하게 코드를 구성할 수 있는 방법이 있다는 것을 알아두자. 그러나 꼭 필요하거나 도움이 되는 상황을 위해 리액트는 ref라는 탈출구를 마련해 놓았다. 다음과 같이 컴포넌트에서 문자열 속성으로 ref를 이용할 수 있다.

```
<input ref="myInput" />
```

참조된 DOM 마크업은 다음과 같이 this.refs를 통해 접근할 수 있다.

```javascript
let input = this.refs.myInput;
let inputValue = input.value;
let inputRect = input.getBoundingClientRect();
```

다음은 그에 해당하는 예로서 사용자가 클릭하면 텍스트 입력으로 포커스를 전환하는 텍스트와 버튼으로 구성된 컴포넌트를 만든다.

```javascript
class FocusText extends Component {
    handleClick() {
        // 원시 DOM API를 이용해 텍스트 입력으로 포커스 전환
        this.refs.myTextInput.focus();
    }

    render() {
        // ref 특성은 컴포넌트가 마운팅될 때 컴포넌트에 대한 참조를 this.refs에 추가
        return (
            <div>
                <input type="text" ref="myTextInput" />
                <input
                    type="button"
                    value="Focus the text input"
                    onClick={this.handleClick.bind(this)}
                />
            </div>
        );
    }
}
```
