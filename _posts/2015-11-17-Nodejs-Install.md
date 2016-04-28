---
layout: post
title: Node.js 설치 및 개발 환경 구축하기
categories: [general, setup, demo]
tags: [demo, dbyll, dbtek, setup]
fullview: false
comments: true
---


# nvm으로 Node.js 버전 관리

Node에는 nvm이라는 Node Version Manager가 있다. 버전이 올라가거나 아니면 다른 버전의 노드를 사용하고 싶을 때 nvm을 통해서 설치 및 변경할 수 있다.

### nvm을 설치

`apt-get update`

`apt-get install build-essential libssl-dev`

[nvm 홈페이지](https://github.com/creationix/nvm)에서 최신 버전 확인 후 설치 <br>

`curl https://raw.githubusercontent.com/creationix/nvm/v0.18.0/install.sh | bash`

`~/.bashrc` 파일이 수정되므로 터미널(콘솔)을 종료하고 다시 로그인 한다.


### 사용 가능한 nodejs 버전 확인

`nvm ls-remote` <br>

```
…
v0.11.0
v0.11.1
v0.11.2
v0.11.3
v0.11.4
v0.11.5
v0.11.6
v0.11.7
v0.11.8
v0.11.9
v0.11.10
v0.11.11
v0.11.12
v0.11.13
v0.11.14
...
```

### nvm 버전 확인

`nvm --version` <br><br><br>


# Node.js 설치

`nvm install 4.2.1` <br>

nvm으로 Node.js를 설치하면 가장 최근에 설치한 버전으로 사용하도록 설정이 되는데, 버전을 변경하고 싶다면 아래와 같이 한다.

`nvm use 4.2.1`


### 현재 Node.js 버전 확인

`node -v`

현재 사용 중인 Node.js 버전을 확인할 수 있다.


### 설치된 Node.js 버전 목록 확인

`nvm ls`

 현재 로컬 PC에 설치 된 Node.js의 모든 버전을 확인할 수 있다.


### alias 지정(option)

nvm에서는 설치된 버전들에 alias를 설정하는 기능도 제공는하데, 버전이 다른 프로젝트를 동시에 진행할 경우 프로젝트 또는 프로젝트 아이디 등으로 alias를 지정해주면 편하다.

`nvm alias default 4.2.1`

alias로 지정한 버전을 사용하고 싶다면 아래의 명령어를 사용한다.

`nvm use default`


### npm으로 모듈 설치

npm(Node package manager) 이용해서 express 모듈을 설치해보자.  
현재 디렉토리 아래에 node_modules라는 디렉토리가 생성되고 그 아래에 설치하게 된다.

`npm install express`


현재 Node.js 버전에서 전역으로 패키지를 사용하도록 설치할려면 -g(또는 -global) 옵션을 사용한다.

`npm install express -g`


`~/.nvm/v4.2.0/lib/node_modules/express` 와 같이 nvm 아래에 node.js 버전 별로 설치된다.


실제 프로젝트에서 사용할려면 link 명령을 이용해서 링크를 걸어준다.

`npm link express`

현재 디렉토리의 node_modules 아래에 express 라는 이름으로 아래의 전역 패키지로 심볼릭 링크가 걸린다.
