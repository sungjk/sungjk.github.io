---
layout: entry
title: React - Component
author: 김성중
author-email: ajax0615@gmail.com
description: 컴포넌트를 조합하여 리액트 애플리케이션을 구축하는 방법에 대한 설명입니다.
publish: true
---

#### Component 생성 및 모듈화

```javascript
import React from 'react';

class App extends React.Component {
    render() {
        return (
            <div>
                <Header />
                <Content />
            </div>
        );
    }
}
```

컴포넌트를 만들때는 `React.Component` 클래스를 상속하여 만듭니다. 하나의 파일에 여러 개의 컴포넌트가 존재할 수 있습니다. 위 코드에서는 하나의 App은 Header와 Content 컴포넌트로 이루어져 있습니다. 이어서 Header와 Content 컴포넌트를 만들어 보겠습니다.

```javascript
import React from 'react';

class App extends React.Component {
    render() {
        return (
            <div>
                <Header />
                <Content />
            </div>
        );
    }
}

class Header extends React.Component {
    render() {
        return (
            <h1>Header</h1>
        );
    }
}

class Content extends React.Component {
    render() {
        return (
            <div>
                <h2>Content</h2>
                <p>This is Content.</p>
            </div>
        );
    }
}

export deafult App;
```

위와 같이 하나의 클래스를 여러 개의 컴포넌트로 구성하여 작성 할 수 있습니다. 하지만, 애플리케이션의 규모가 커지면 유지/보수가 불편해지므로 컴포넌트들을 모듈화하여 여러 파일로 분리해서 사용하는 것이 좋습니다.

---

```javascript
import React from 'react';

class Header extends React.Component {
    render() {
        return (
            <h1>Header</h1>
        );
    }
}

export deafult Header;
```

```javascript
import React from 'react';

class Content extends React.Component {
    render() {
        return (
            <div>
                <h2>Content</h2>
                <p>This is Content.</p>
            </div>
        );
    }
}
```

모듈화한 컴포넌트들을 export 했으니 App.js에서 import를 하여 하나의 컴포넌트로 조합합니다.

```javascript
import React from 'react';
import Header from './Header';
import Content from './Content';

class App extends React.Component {
    render() {
        return (
            <div>
                <Header />
                <Content />
            </div>
        );
    }
}

export default App;
```

---

#### 상태 저장 컴포넌트와 순수 컴포넌트
컴포넌트는 속성과 상태로서 데이터를 가질 수 있습니다.

- 속성 *Props* 은 컴포넌트의 구성 정보에 해당합니다. 속성은 상위 컴포넌트로부터 받으며, 이를 받은 컴포넌트 내에서는 변경할 수 없습니다.
- 상태 *State* 는 컴포넌트의 생성자에 정의된 기본값에서 시작해 (일반적으로 사용자 이벤트에 의해) 여러 차례 변경될 수 있습니다. 컴포넌트는 자신의 상태를 내부적으로 관리합니다. 또한 상태가 변경될 때마다 컴포넌트가 다시 렌더링됩니다.

대부분의 리액트 애플리케이션에서 컴포넌트는 **상태를 관리하는 컴포넌트(상태 저장 컴포넌트)** 와 **내부 상태가 없고 데이터를 표시하는 역할만 하는 컴포넌트(순수 컴포넌트)** 의 두 가지 유형으로 나뉩니다.

순수 컴포넌트의 목적은 속성을 받고 이를 뷰에 렌더링하고, 이러한 컴포넌트는 재사용하거나 테스트하기가 수월합니다. 상태 저장 컴포넌트는 일반적으로 컴포넌트 계층에서 상위를 차지하며, 상태 저장 컴포넌트나 순수 컴포넌트를 하나 이상 래핑합니다.

앱의 컴포넌트는 대부분 상태 비저장으로 만드는 것이 좋습니다. 애플리케이션의 상태를 다수의 컴포넌트로 분산하면 관리가 힘들고, 작동 방식을 확인하기도 어렵기 때문입니다.
