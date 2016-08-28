---
layout: entry
title: Google I/O 2016 Extended Seoul 후기
author: 김성중
author-email: ajax0615@gmail.com
description: Google I/O 2016 Extended Seoul 행사 후기입니다.
publish: true
---

안녕하세요? 김성중입니다.

매년 Google I/O에 관심을 가지고 있는 본인은 올해에도 지난 5월 18일에 있었던 Google I/O Extended live에 참여하려고 하였으나.. 의지 박약으로 참여를 하지 못했습니다. 내년에도 기회가 생긴다면 꼭 참여를 해보고 싶습니다.

![Google I/O 2016](/images/2016/06/20/google01.jpeg "Google I/O 2016")

세종대학교 광개토관에서 열렸던 Google I/O 2016 Extended Seoul 행사에 참여하였습니다. 카테고리는 크게 Android, Web App, Firebase, Tensorflow, VR(Virtual Reality)로 총 3개의 트랙에서 각각 진행되었습니다.


서론이 매우 길었네요.. 저는 이 중에서 개인적인 관심이 많았던 Firebase, Web app, Tensorflow, VR을 적절히 섞어서 들었고, 아래 1, 2, 3번 발표에 대해 요약을 해보았습니다.ㅎㅎ

- Firebase Overview: App success made Simple - 권순선님
- What's next for the web? - 도창욱님
- Google Firebase 로 레고블록 조립하기 - 최치웅님
- Tensorflow 101 - 김용욱님
- 우리는 낮에도 꿈을 꾸는 개발자들~ Daydream - 이원제님

## Firebase Overview: App success made Simple

앱 개발 뿐만 아니라 백엔드까지.. 풀스택 개발에 대한 관심이 많아지고 있습니다. 이러한 경우에 순수하게 안드로이드 SDK만 가지고 개발하는 것이 아니라 많은 외부 라이브러리를 사용하게 되는 경우가 많이 있습니다. 이런 상황에서 앱 개발자에게 큰 도움을 줄 수 있는 것이 바로 **Firebase** 입니다.

- Single SDK
- Cross Platform
- Better Together

Firebase는 안드로이드 앱 개발자, iOS 앱 개발자, 웹 개발자 모두를 커버할 수 있는 하나의 SDK를 제공합니다. 쉽고 간편하게 하나의 대시보드(Dashboard)를 통해서 앱을 모니터링하고 데이터를 관리할 수 있습니다. 현재 Firebase는 14~15개의 기능을 제공하고 있는데, 처음 사용 시 약간 혼란스러울 수 있습니다.

![Google I/O 2016](/images/2016/06/20/google02.png "Google I/O 2016")

Firebase의 가장 강력한 기능은 Analytics입니다. 앱 개발자들에게 도전적인 사항은 바로 유저를 확보하고, 좋은 품질의 앱을 만드는 것입니다. 기존 구글의 Analytics는 웹 페이지 기반이라서 모바일 개발자 입장에서는 제한적인 이슈가 있었고, 100% 모든 데이터 및 이벤트를 트래킹하는 것이 아니었습니다. 하지만, Firebase의 Analytics는 100% 무료, unlimited 스토리지, 앱 개발자를 위해 모든 이벤트(데이터)를 하나도 빠짐없이 캐치할 수 있도록 하고 잇습니다.

- **Realtime Databases** : 구글에서 Firebase를 인수할 당시에는 여러 개의 데이터가 쉽게 동기화되고, 네트워크 환경이 좋지 않아도 데이터가 메모리에 상주해서 추후에 동기화가 할 수 있는 기능을 제공하는 Realtime DB(NoSQL 기반) 이었습니다.
- **Authentication** : 사용자의 Email, Password, OAuth 관련한 기능을 제공합니다.
- **Storage** : Google Cloud Storage를 사용해서 서버없이 파일이나 이미지를 저장할 수 있습니다.
- **Remote Config** : 콘솔에서 Key-Value 방식으로 직접 커스터마이징해서 A/B 테스트(앱 자체는 동일하지만 속성을 바꿔서 사용자마다 다른 테스트 환경을 제공해주는 방법. 예를 들어, 구버전의 안드로이드를 사용하는 사람에게는 A라는 테스트를 하고, 최신버전을 사용하는 사람에게는 B라는 테스트를 하는 것) 를 할 수 있습니다.
- **Hosting** : 요즘은 서비스를 런칭할 때 마켓에 앱만 올리고 끝나는게 아니라 앱이나 서비스에 대해 소개하는 웹 사이트를 제공하는 것이 대부분입니다. 이러한 웹 사이트에 대해 정적인 호스팅을 할 수 있는 기능을 제공합니다.
- **Cloud Messaging** : 기존 GCM(Google Cloud Messaging)이 있지만, Firebase Messaging은 데이터의 양에 상관없이 무료로 사용할 수 있습니다.
- **Test Lab** : 굉장히 많은 virtual device로 테스트를 할 수 있는 Cloud Test Lab을 제공합니다. 여러 개의 다른 디바이스에서 환경 별로 로그, 스크린샷(앱이 어떠한 형태로 보이는지), 비디오(앱이 어떻게 작동하는지) 등의 기능을 이용할 수 있습니다.
- **Dynamic Links** : 안드로이드와 iOS에서 동시에 사용할 수 있는 앱의 특정한 state까지 링크를 제공하는 기능입니다.
- **Acquisition** : 새로운 유저를 찾기 위한 과정입니다.
- **Notifications** : 기존 Push 알림에 더하여, 유저 정보를 기반으로 특정 유저에게만 알림을 줄 수 있는 기능을 제공합니다.
- **App Indexing** : 앱을 웹 페이지로 생각하고 크롤링 할 수 있습니다.

즉, Firebase를 이용하면 소규모 혹은 대규모 앱을 개발할 때 공통적인 작업들을 복잡하지 않고 간편하게 개발할 수 있습니다. 앱의 품질과 사용성을 높일 수 있고, 시간과 비용을 줄이고, 사용자 간의 밸런스를 맞출 수 있는 등 앱 개발에 많은 도움을 가져다 줄 수 있습니다.

## What's next for the web?

Progressive Web App은 웹이 가지고 있는 장점과 네이티브 앱을 합쳐 놓은 신기술입니다. 간단히 말하자면 네이티브 앱스럽게 웹 앱을 만들 수 있는 것입니다. 사용자의 디바이스와 환경이 모두 다르기 때문에 웹 앱이 모든 사용자에게 정상적으로 동작될 수 있도록 하는 것이 목표입니다.

![Google I/O 2016](/images/2016/06/20/google03.jpg "Google I/O 2016")

PWA Demo는 아래의 사이트에서 확인하실 수 있습니다.

- [Air Horner](https://airhorner.com/)
- [Voice Memos](https://voice-memos.appspot.com/)
- [Weather](https://weather-pwa-sample.firebaseapp.com/final/)

PWA 강연에서 Promise, Fetch, Stream 등 몇 가지 API들을 소개하였는데, 이 글에서는 전부다 소개를 하지 않고 대표적인 것만 얘기하도록 하겠습니다.

- **Promise** : 비동기적인 로직을 동기적으로 기술할 수 있는 기술입니다. 새로운 웹 표준 API들이 Promise를 통해서 많이 기술되고 있습니다.
- **Fetch** : Promise 기반으로 되어 있고, 리소스를 패치 할 수 있습니다. 기존의 XMLHttpRequest와 유사합니다. 하지만 아직 IE(Internet Explorer)에서는 Fetch API를 지원하지 않습니다.
- **Stream** : 기존에는 네트워크로 던진 Request에 대해 Response가 오기 전까지 이에 대해 아무런 작업을 할 수 없었습니다. 데이터를 전부다 받아야 핸들링을 할 수 있었습니다. 하지만 Stream을 사용하면 어느정도 받고 나서 핸들링 하는 것이 가능해집니다. 예를 들어, JSON 데이터를 받고 있는 도중에 렌더링을 할 수 있습니다.
이외에도 RequestIdleCallback, PassiveEventListener, MediaRecorder, MediaSession, CSS Variables, CSS Containment, CSS Font Loading 등의 API를 소개하였습니다.

이 발표에서 흥미로웠던 부분은 바로 웹 블루투스에 대한 부분이었습니다.

- **[Web MIDI](https://webaudio.github.io/web-midi-api/)** : 웹에 MIDI를 연결해서 사용할 수 있습니다.
- **Web Bluetooth** : 웹에서 블루투스를 사용할 수 있습니다. 블루투스 4.0 API가 제공되므로 디바이스 선택, 연결, 데이터 전송 등 서버-클라이언트 구조를 구현할 수 있습니다. 웹 페이지를 통해서 블루투스로 연결하여 로봇을 조작하는 [프로젝트](https://github.com/urish/purple-eye)입니다.
- **Web USB** : 웹 앱을 통해 USB 연결된 디바이스를 조작할 수 있습니다.
- **Physical Web** : 실제 사물에게 웹 블루투스를 통해 URL을 보낼 수 있습니다. 실제 블루투스를 통해 URL을 Broadcast 할 수 있고, URL은 17바이트 내에서 URL을 사용할 수 있으며, 일반적인 HTTP 프로토콜과 일상적인 URL 구성요소(www.과 국가 코드가 없는 gtld)는 encoding되어 보다 공간을 절약할 수 있습니다. 예를 들어, 자판기로부터 광고 페이지 URL을 전달받아 광고를 보고 무료 음료를 마시는 것입니다. 관심있으신 분은 Eddystone Beacon에 대해 알아보면 좋을것 같습니다.

## Google Firebase 로 레고블록 조립하기

개인적으로 가장 재미있고 흥미로웠던 발표였습니다!! 발표자는 말랑스튜디오의 최치웅님으로, Google I/O 2016 live에 Firebase를 이용하고 있는 회사로 말랑스튜디오의 로고가 소개되었습니다.

Firebase는 앱 개발을 위한 통합 플랫폼입니다. 앱 개발의 비효율적인 면들을 효율적으로 해결할 수 있도록 많은 기능을 제공하고 있고, 하나의 SDK만 삽입을 하면 통합된 콘솔에서 앱을 관리할 수 있습니다.
- 사용하기 쉬운 개발 도구
- 다양한 플랫폼 지원
- 통합된 개발 환경

높아진 시장 기준과 늘어나는 개발 기간에 대응하기 위해 말랑스튜디오에서는 핵심 기술 외의 작업들은 적절한 외부 서비스를 찾아 적용하는 방법을 선택하였습니다. 그게 바로 Firebase입니다!!

- **Analytics** : Analytics는 Firebase의 핵심 기능입니다. 사용자의 행동 패턴이나 참여율을 높이는 등에 사용될 수 있는 기능입니다. 장점은 무료로 제공되기 때문에 데이터 제한이 있는 ga(Google Analytics)보다 사용면에서 좋습니다. 모든 이벤트나 데이터들을 트래킹 할 수 있습니다. 또한, 커스텀 이벤트를 제공합니다. 예를 들어, 알람몬에서 사용자가 어느 요일에 알람을 가장 많이 설정하였고, 대부분 몇 초 이내에 알람을 끄는지 등을 분석하는 등 특정 사용자의 이벤트를 캐치할 수 있습니다. 눈에 띄는 점은 원하는 데이터를 쉽게 확인할 수 있는 예븐 대시보드입니다. 단점은 ga보다 쉽지만, 아직은 복잡하다는 것입니다.
- **Crash Reporting** : 서비스를 만들고 앱을 런칭하면 사용자가 너무 많아서 버그에 대해 일일이 체크를 할 수 없습니다. 하지만 이 기능을 사용하면 일부 사용자에게만 릴리즈하고 크래쉬 리포팅을 하여 문제에 대응할 수 있습니다. 하나의 SDK를 삽입하면 되기 때문에 구현에도 굉장히 간단합니다. 추가적으로 Analytics와 연계되기 때문에 대시보드에서 한눈에 확인할 수 있습니다. 단점은 리포트를 꾸준히 하기 위해서 Crash Reporting을 위한 프로세스 하나를 fork하게 되는데, 멀티 프로세스에 대한 이슈가 발생 할 수 있다는 것입니다.
- **Authentication** : 사용자 인증 작업을 최소화시키고 손쉽게 유저를 관리할 수 있도록 대시보드를 제공합니다. 기존 서비스의 인증같은 경우에는 별도의 DB(인증 서버)에 사용자 관련 정보를 저장해야 했지만, Firebase의 Authentication을 이용하면 이러한 과정이 필요 없습니다. 또한, Android Auth는 코드 상에서 3줄이면 가능하기 때문에 매우 쉽습니다. 사용자에 관한 정보(이메일, 가입 경로 등) 을 대시보드를 통해 확인할 수 있습니다. 단점은 Email, facebook, google, twitter, github, anonymous. 기본적으로 제공되는 이 6가지 Login provider 이외의 타 Provider에 대한 구현이 어렵다는 것입니다.
- **Dynamic Links** : 유저가 사용하고 있는 플랫폼, 상황에 따라 사용자 경험을 달리하여 서비스에 대한 만족도를 극대화 할 수 있도록 돕기 위한 기능입니다. 쉽게 이야기하면, 안드로이드와 iOS에서 동시에 사용할 수 있는 Deep Link를 구현해놓은 것이라고 할 수 있습니다. 이 또한 무료로 제공되고, 구현 부분도 굉장히 단순합니다. 통합 링크를 어떠한 용도로 만들어달라는 마케터와의 갈등을 해결 할 수 있죠. Dynamic Link를 이용하면 Analytics 연계분석을 해주기 때문에 통합 링크를 통해서 들어온 사용자를 쉽게 관리할 수 있습니다. 단점은 앱에서 앱으로 초대를 하는 기능을 구현할 때 Shorten URL을 제공하지 않기 때문에 불편한 점이 있다는 것입니다(Google Shortening은 iOS에서 동작안합니다). 또한 Meta tag 수정이 불가능합니다.
- **Notification** : 사용자에게 적시에 적절한 내용의 메시지를 전송해 서비스 retention을 강화시키기 위한 기능입니다. 기존 구글의 GCM 연동을 하려면 이어서 많은 작업을 해야하지만, Firebase Messaging은 그에 비해 매우 간단합니다. 또한 얼마나 많은 사용자가 읽었고, 알림을 클릭한 이벤트가 얼마나 있는지 등을 대시보드를 통해 확인할 수 있습니다. 대량 전송에도 자체 서버가 필요가 없이 Google Firebase 서버를 통해 전송하면 됩니다. 당연히 Analytics 연계분석을 해줍니다. 또한 특정 Segment에 대해서 Push message를 보낼 수 있습니다. 로컬 타임 존 기능을 지원하므로 시차를 계산해서 예약 전송을 할 필요가 없어졌습니다. 단점은 push를 보냈을 때 아이콘을 변경하거나 이미지를 보내는 기능을 지원하지 않고, 테스트 디바이스에만 메시지를 보내는 기능을 제공하지 않습니다. 따라서 Segment를 나눠서 테스트해야 합니다.

긴 글 읽어주셔서 감사합니다!!

참조: [Eddystone](https://github.com/google/eddystone/tree/master/eddystone-url)
