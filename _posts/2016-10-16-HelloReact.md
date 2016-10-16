---
layout: entry
title: Node.js와 Express를 이용한 "Hello World" 애플리케이션 제작하기
author: 김성중
author-email: ajax0615@gmail.com
description: Node.js와 Express를 이용하여 "Hello World" 애플리케이션을 제작하는 방법입니다.
publish: true
---

리액트 애플리케이션을 서버에서 실행하고 미리 처리하는 데는 Node.js와 익스프레스 *Express* 를 사용한다. 익스프레스는 단일 페이지, 다중 페이지, 하이브리드 웹 애플리케이션을 구축하기 위한 Node.js 웹 애플리케이션 서버 프레임워크다.

프로젝트의 의존성인 익스프레스 프레임워크와 바벨(자바스크립트의 최신 문법을 지원하는 컴파일러)을 설치해야 한다.

```
// 익스프레스 설치
npm install --save express

// ES6 프리셋 이용
npm install --save babel-core babel-preset-es2015

// 커맨드라인에서 파일을 컴파일
npm install --global babel-cli
```

---

## 바벨 구성
바벨은 프로젝트의 루트 폴더에 .babelrc 파일을 만들어서 프로젝트별로 구성해야 한다.

```bash
{
    "presets": ["es2015"]
}
```

---

## 익스프레스 서버
Node.js와 익스프레스 프로젝트의 기본 구조는 다음과 같다.

![express-structure](/images/2016/10/16/express-structure.png "express-structure"){: .center-image }

server.js 파일에서는 익스프레스를 임포트하고 익스프레스 서버의 인스턴스를 생성해야 한다. 다음과 같이 express.Server를 가리키는 app 상수를 이용하는 것이 일반적이다.

```javascript
import express from 'express';
const app = express();
```

그런 다음 애플리케이션에 대한 라우트를 하나 이상 설정할 수 있다. 라우트는 경로(문자열 또는 정규표현식), 콜백 함수, HTTP 방식으로 구성된다. 콜백함수는 request와 response의 두 매개변수를 받는다. request 객체는 이벤트를 발생시킨 HTTP 요청에 대한 정보(쿼리 문자열, 매개변수, 본문, HTTP 헤더 등)를 포함한다. response 객체는 요청에 대한 응답으로서 원하는 HTTP 응답을 클라이언트 브라우저로 전달하는 데 사용된다.

이 Hello World 예제에서는 HTTP GET 방식을 나타내는 app.get()을 호출하며, "/" 경로와 response 객체를 이용해 브라우저로 문자열을 전달하는 콜백 함수를 전달한다.

```javascript
app.get('/', (request, response) => {
    response.send('<html><body><p>Hello World!</p></body></html>');
});
```

마지막으로 지정한 포트를 수신하는 서버를 시작할 수 있다. 다음 코드에서는 3000번 포트와 서버가 실행될 때 호출될 콜백 메서드를 지정하고 listen()을 호출한다.

```javascript
app.listen(3000, ()=>{
    console.log('Express app listening on port 3000');
});
```

다음은 server.js 파일의 전체 소스코드이다.

```javascript
import express from 'express';
const app = express();

app.get('/', (request, response) => {
    response.send('<html><body><p>Hello World!</p></body></html>');
});

app.listen(3000, ()=> {
    console.log('Express app listening on port 3000');
});
```

---

## 서버 실행
익스프레스가 생성하는 로그를 보려면 터미널에서 다음 명령을 실행해 디버그 모드로 서버를 시작해야 한다.

```bash
DEBUG=express:* babel-node server.js
```

이 명령을 start 스크립트로 전달하도록 package.json 파일을 수정하면 다음부터는 로컬에서 npm start를 입력해 서버를 시작할 수 있다.

```json
{
    "name": "helloexpress",
    "version": "0.0.1",
    "description": "Hello World sample application in Node.js + Express",
    "scripts": {
        "start": "DEBUG=express:* babel-node server.js"
    },
    "author": "Jeremy Kim",
    "dependencies": {
        "babel": "^5.8.29",
        "express": "^4.13.3"
    }
}
```

---

## 템플릿 활용
템플릿은 변수를 삽입하거나 프로그래밍 논리를 실행하는 태그가 포함된 HTML 마크업이다. 익스프레스는 다양한 템플릿 포맷을 지원하며, 이 예제에서는 EJS라는 템플릿 포맷을 이용한다.

먼저 `npm install --global ejs` 명령으로 EJS를 애플리케이션의 의존성으로 설치한다. 그리고 EJS 템플릿을 이용하도록 애플리케이션에 set 메서드로 구성한다.

```javascript
app.set('view engine', 'ejs');
```

템플릿 파일은 기본적으로 views 폴더에 저장해야 한다. views 폴더를 만들고 이 폴더에 index.ejs 템플릿 파일을 작성한다.

![ejs-structure](/images/2016/10/16/ejs-structure.png "ejs-structure"){: .center-image }

애플리케이션이 문자열을 전달하는 대신 템플릿을 렌더링하도록 지시하려면 동적 값을 표시하기 위해 템플릿 안에서 접근 가능한 객체와 템플릿 이름을 지정하고 response.render 메서드를 호출하면 된다.

```javascript
// 템플릿을 렌더링하도록 업데이트된 server.js
import express from 'express';
const app = express();

app.set('view engine', 'ejs');

app.get('/', (request, response) => {
    response.render('index', {message: 'Hello World'});
});

app.listen(3000, () => {
    console.log('Express log listening on port 3000');
});
```

```html
<!-- views/index.ejs 템플릿 파일 -->
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>Express Template</title>
    </head>
    <body>
        <h1><%= message %></h1>
    </body>
</html>
```

---

## 정적 애셋 제공
익스프레스에는 정적 콘텐츠를 제공하기 위한 미들웨어가 내장돼 있다. express.static() 미들웨어는 정적 애셋을 제공할 루트 디렉토리를 지정하는 인수를 하나 받는다. 예를 들어, public 폴더에 있는 정적 파일을 제공하려면 서버 코드에 다음과 같은 행을 추가하면 된다.

```javascript
app.use(express.static(__dirname + '/public'));
```

---

#### 소스코드
[Hello Express!](https://github.com/sungjungkim/react-practice/tree/master/practice04)
