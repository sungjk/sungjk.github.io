---
layout: entry
title: Alfred 꿀팁
author: 김성중
author-email: ajax0615@gmail.com
description: 사용해보지 않은 사람은 있어도, 한 번만 사용해 본 사람은 없는 Alfred
keywords: Alfred, 자동화
publish: true
---

Mac에는 정말 유용한 앱들이 많은데, 그 중에서 귀차니즘을 해결해주는 [**Alfred**](https://www.alfredapp.com/)를 소개하려 합니다. 개인적으로 Alfred는 사용해보지 않은 사람은 있어도, 한 번만 사용해 본 사람은 없을거라 생각합니다. 그만큼 강력하고 없으면 안되는 Tool 중 하나죠. 여유가 생길때 마다 본 포스팅에 제가 사용하고 있는 기능과 Workflow들을 하나, 둘 추가하려 합니다(꽤 많아서 한번에 공유를 못해요). Workflow는 Alfred에 추가할 수 있는 플러그인이라고 생각하시면 됩니다.

![Alfred](/images/2020/10/07/alfred.png "Alfred"){: .center-image }

간단히 얘기하자면, **Alfred**는 Mac OS에서 기본으로 제공하는 Spotlight를 대체할 뿐만 아니라, 자동완성이나 각종 스크립트 등을 실행할 수 있는 툴입니다. 파일이나 북마크 검색은 Spotlight로도 충분히 커버가 가능하지만, 그 이상의 자동완성을 원할때에는 Alfred만한 것이 없습니다.

대부분의 Mac App들이 그렇듯이, Alfred는 무료버전과 유료버전([Powerpack](https://www.alfredapp.com/powerpack/))을 제공합니다. 유료버전인 Powerpack에 추가된 기능 몇 가지를 살펴보면 검색 기능 강화, **클립보드 히스토리(Use Clipboard History)**, **커맨드 실행(Run Smell & Terminal Commands)**, **1Password** 등이 있습니다. Mega Supporter 등급의 가격은 £49. 한화 7만원이 넘는 금액인데 한 번 결제하면 평생 업그레이드하며 사용 가능해서 아깝지 않은 금액입니다. Alfred 한 번 써보시기를 강추합니다(광고 받지 않았습니다).

---

# Keyword Web Search
![Alfred Search](/images/2020/10/07/alfred-search.gif "Alfred Search"){: .center-image }

Alfread의 입력창은 기본적으로 파일과 웹에서 검색할 수 있는 검색창입니다. 그리고 웹 검색에 `Keyword`를 추가하여 원하는 숏컷을 완성할 수 있습니다. Preferences \> Features \> Web Search \> Add Custom Search 에서 등록할 수 있습니다.

- 파파고로 번역기 실행: ![Alfred Search](/images/2020/10/07/alfred-search-1.png "Alfred Search"){: .center-image }
- 유튜브 뮤직에서 음악 검색: ![Alfred Search](/images/2020/10/07/alfred-search-2.png "Alfred Search"){: .center-image }

---

# JetBrains
![Alfred Jetbrains](/images/2020/10/07/alfred-jetbrains.gif "Alfred Jetbrains"){: .center-image }

저는 주로 JetBrains 사의 IntelliJ, DataGrip, WebStorm을 사용합니다. 그리고 각 IDE에서 특정 프로젝트를 열려면 File \> New 또는, File \> Open Recent 을 통해 프로젝트를 열어야 합니다. 매일 많게는 수십번 해야하는데 귀찮습니다. 그래서 이러한 단순하지만 매번 귀찮은 동작을 Alfred Workflow에 추가하였습니다. 해당 Workflow의 자세한 내용은 [bchatard/alfred-jetbrains](https://github.com/bchatard/alfred-jetbrains)에서 확인하실 수 있습니다.

설치 방법은 아래와 같습니다. Jetbrains Toolbox를 통해서 사용한 예시입니다. Toolbox를 이용하지 않고, 개별 IDE를 다운받아 실행한 경우에는 [이 곳](https://github.com/bchatard/alfred-jetbrains#init-shell-script)를 참고하시면 됩니다.

1. 설치하기: `$ npm install -g @bchatard/alfred-jetbrains`
2. Toolbox > Toolbox App Settings > Shell Scripts location에 `/usr/local/bin` 입력
   - `/usr/local/bin` 아래에 ToolboxApp(idea) 링크가 있습니다.
   - ToolboxApp이 아닌 IDEA에서 직접 location을 지정하고 싶다면 `/usr/local/bin/{AppName}` 처럼 명시해줘야합니다.
   - AppName은 [이 곳](https://github.com/bchatard/jetbrains-alfred-workflow#default-keywords)에서 확인할 수 있습니다.
   - ![Alfred Jetbrains](/images/2020/10/07/alfred-jetbrains-1.png "Alfred Jetbrains"){: .center-image }
3. 명령어(IDE 이름)를 변경하고 싶다면 Preferences \> Workflows \> JetBrains 에서 `keyword`를 수정하시면 됩니다.
   - ![Alfred Jetbrains](/images/2020/10/07/alfred-jetbrains-2.png "Alfred Jetbrains"){: .center-image }
4. 검색 결과는 기본적으로 Alfred의 캐시에 저장된 목록을 보여주므로 IDE로 특정 프로젝트를 열었더라도 바로 안보일 수 있습니다. 이때는 환경 변수값(Workflow Environment Variables)을 조정해주시면 됩니다. 자세한 설명은 [이 곳](https://github.com/bchatard/alfred-jetbrains#workflow-environment-variables)를 참고하시면 됩니다.
   - ![Alfred Jetbrains](/images/2020/10/07/alfred-jetbrains-3.png "Alfred Jetbrains"){: .center-image }
   - ![Alfred Jetbrains](/images/2020/10/07/alfred-jetbrains-4.png "Alfred Jetbrains"){: .center-image }
4. 캐시 목록 확인하기: `$ cat ~/Library/Caches/com.runningwithcrayons.Alfred/Workflow\ Data/fr.chatard.jetbrains.workflow/cache.json`

### JetBrains 업데이트 후 에러가 발생할때

```
// node_modules 설치 위치 확인
$ ll /usr/local/lib/node_modules

// @bchatard 모듈 제거
$ rm -rf /usr/local/lib/node_modules/@bchatard

// npm 의존성 제거 후 재설치
$ npm uninstall -g @bchatard/alfred-jetbrains
$ npm install -g @bchatard/alfred-jetbrains
```

---

# Visual Studio Code
TODO

---

# AWS
TODO

---

# curl
TODO

---

도움이나 질문이 필요하신 분은 <a href="mailto:ajax0615gmail.com">ajax0615@gmail.com</a>으로 편하게 메일 보내주세요.
