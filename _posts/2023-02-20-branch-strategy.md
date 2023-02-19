---
layout: entry
post-category: git
title: 우리 팀에 맞는 Git Branch 전략 선택하기
author: 김성중
author-email: ajax0615@gmail.com
description: 우리 팀에 맞는 Git Branch 전략을 찾아나갔던 여정을 기록
keywords: Git, Git Branch, 브랜치 전략, git flow, github flow
publish: true
---

지금 팀에 합류한지 어느덧 2년이 다 되어간다. 합류 당시 작성된 코드 베이스가 한 줄도 없는 상황에서 새로운 제품을 만드는 것과 별개로, 개발 문화와 프로세스도 함께 만들어 나아갔다. 그 중에서도 배포를 하는 과정에서 우리 팀에 더 적합한 브랜치 전략을 찾아갔던 여정에 대해서 기록해보자.

### Git Flow
<script type="text/javascript" src="https://ssl.gstatic.com/trends_nrtr/3197_RC04/embed_loader.js"></script> <script type="text/javascript"> trends.embed.renderExploreWidget("TIMESERIES", {"comparisonItem":[{"keyword":"git flow","geo":"KR","time":"today 12-m"},{"keyword":"github flow","geo":"KR","time":"today 12-m"},{"keyword":"gitlab flow","geo":"KR","time":"today 12-m"}],"category":0,"property":""}, {"exploreQuery":"geo=KR&q=git%20flow,github%20flow,gitlab%20flow&date=today 12-m,today 12-m,today 12-m","guestPath":"https://trends.google.co.kr:443/trends/embed/"}); </script>

브랜치 전략하면 가장 먼저 떠오르기도 하고, 많은 회사와 팀에서 기본으로 사용하고 있는게 Git Flow 전략이라고 생각한다. Git Flow의 특징 몇가지만 살펴보면,

1. 각 용도에 맞게 main(master), develop, feature, release, hotfix 브랜치를 분리해서 사용
2. 명확한 릴리즈 기간과 주기적인 버전이 정해진 프로덕트를 개발하는 환경에 적합
3. 릴리즈 버전 관리를 위한 release 브랜치를 따로 관리하기 때문에, 특정 버전에 대한 유지보수 기간이 길고, 여러 버전을 동시에 관리해야 할 필요가 있을때 유용함
4. 2, 3과 같은 장점 때문에 소규모 팀보다는 규모가 있는 팀에 더 어울림

이렇게 4가지 정도로 특징을 정리할 수 있다. 

![git-flow](/images/2023/02/20/git-flow.png "git-flow"){: .center-image }


우리 팀도 마찬가지로 Branch 전략에 Git Flow를 사용하기로 했다. 맨 처음에 어떤 이유 때문에 Git Flow를 사용하기로 했는지 정확히 기억은 안나지만, 위에 나열한 특징 외에도 아래 항목들을 추가로 고려했지 않았을까...

1. 운영 환경(Production) 배포 브랜치와 개발 환경(Develop) 배포 브랜치를 명시적으로 분리해서, 운영 환경에 어떤 코드 베이스가 배포 되어 있는지 한 눈에 확인할 수 있다는 점
2. 운영 환경에 언제 배포해도 상관없는 Stable 브랜치(main)를 별도로 관리해서, 장애 혹은 버그 수정이 필요한 경우 main 브랜치를 기준으로 빠르게 수정
3. 아직 테스트가 완료되지 않은 피쳐가 운영 환경에 배포되는걸 방지하기 위함(2번과 관련)
4. 그리고 마지막, 모두에게 가장 익숙한 브랜치 전략

역사엔 다양한 이유가 있듯이, 이 과정에도 더 많은 이유와 외부 환경 때문에 어쩔 수 없는 것들이 함께 반영되었을텐데 당장 떠오르는건 이렇게 4가지 정도다. 새로 만들고 있는 서비스의 경우엔 자유롭게 단일 브랜치를 사용했는데, 사용자에게 릴리즈된 서비스는 모든 팀이 Git Flow 브랜치를 바탕으로 개발하고 안전하게 배포까지 했다.

### 배포 열차
배포 열차가 필요한 이유. 우리 팀이 만들고 있는 제품과 업의 특성상 Production 환경에 자유로운 배포는 불가능하다. 제품을 만들어 나가는 개발자와 별개로, 배포를 하기 전에는 항상 배포 승인자의 승인이 필요하다. 배포가 많아지면 많아질수록 배포 승인자는 리뷰와 승인에 할애하는 시간이 많아지고 하루의 대부분 시간을 배포 승인에 쏟아야 하는 상황까지 생길 수 있었다. 전체 팀의 규모는 작지만, 다양한 서비스들이 동시에 만들어지고 있다보니 배포 대상 서비스도 많았다. 그래서 우리 팀은 매주 수요일이면 수요일, 목요일이면 목요일에 정기 배포 요일을 정하고, 그 날에는 배포를 집중적으로 하기로 했다. 리뷰, 승인, 배포, 모니터링 등 어느 요일 오후에 집중해서 끝내기로. 정기 배포 요일과 별개로 다른날에도 배포가 필요하면 비정기 배포를 하곤 했다. 그래서 매주 정기 배포 요일의 오후가 되면 배포 열차가 떠나고, 탑승한 팀원들은 배포 모니터링을 시작한다.

### 지옥철
처음엔 아무런 문제나 불편한 점이 없었는데, 정기 배포를 1년 이상 하다보니 배포 과정에서 생기는 비효율적인 면과 불안함도 생겼다. 배포 열차니까 굳이(실제론 여유로움) 비유하자면 지옥철이라고 표현할 수 있을까. 일단 탐승해야 하니까 뒤죽박죽 낑겨서라도 탑승. 불편함이 상당하지만 어쩔 수 없다. 사람이 많아질수록 통제가 어려워지는 것과 마찬가지로, 배포 대상 서비스(마이크로서비스)가 늘어나면서 배포 진행중 혹은 그 이후에 발생한 이슈가 어떤 서비스의 영향 때문인지 추적하기가 어려워지고, 릴리즈에 포함된 변경 사항이 너무 많아서 확인에 어려움이 생긴다. 날짜를 특정해서 전체 배포를 하니 더욱더.

그리고 배포 대상 서비스가 늘어가는 것과 별개로, 우리 팀의 일하는 방식이 배포 프로세스와 맞지 않아서 생기는 불안함도 생기기 시작했다. 우리 팀은 속도가 굉장히 빠른 편인데, 속도가 빠르다는건 그만큼 릴리즈도 많이 하고 릴리즈에 포함된 변경 사항이 상당하다는걸 의미한다. 사소한 버그라도 사용자에게 치명적인 금융 서비스를 만들고 있다보니, 자동화된 테스트 뿐만 아니라 꼼꼼한 리뷰도 중요하다. 모든 피쳐들이 개발 환경이나 테스트 단계에서 검증되어서 실제로 문제는 없었지만, 난 배포 열차가 출발하는 날이면 Release 브랜치에 있는 탑승 대기중인 코드들을 매번, 모두 살펴보았다. 한 주 동안 새로 추가되고 수정되고 삭제되는 코드 라인이 정말 많았는데, 마음 편하게 열차를 떠나 보내고 싶었다. 겉으론 아무렇지 않아보였지만, Deploy 버튼을 누를 때면 심장 박동수가 조금씩 올라갔다. 지금 생각해보면 이미 검증된 코드를 한 번 더 사서 고생했다는 생각도 드는 한편, 그 때의 꼼꼼함이 성장에 많은 도움이 된거 같기도 하고.

잠깐 배포의 불안함에 대해서 이야기 했는데 다시 돌아와서. 오랫동안 정기 배포를 하다보니 매주 Git Flow 때문에 발생하는 비효율적인 면도 보이기 시작했다. Git Flow 브랜치 전략은 코드 릴리즈를 위해 release 브랜치를 생성하고 생성된 release 브랜치에서 테스트(QA)를 마친 후에 Stable 브랜치(main)로 합친다(merge). 우리팀도 마찬가지로 매주 정기 배포 요일이 되면 아래와 같은 일을 하고 있었다.

1. develop 브랜치에서 release branch 생성
2. release 브랜치를 main 브랜치로 merge 하는 PR 생성(CI, Build)
3. main 브랜치에 merge 후 release tag 생성

Git Flow의 장점 중 하나는 release 브랜치를 별도로 관리해서 배포 전에 테스트할 수 있는 환경을 만들 수 있다는 것인데, 아직 우리는 이런 환경(Beta/Staging과 별개로 흔히 얘기하는 QA 환경)이 갖춰져 있지 않아서 별도의 테스트를 하지 않고 바로 main branch로 코드를 합쳤다. 그리고 정기 배포 요일에는 모든 서비스들의 배포 준비 때문에 CI 작업이 몰리면서 적어도 30분 정도는 기다리고만 있어야 했다. release branch 만들고, main branch 머지를 위한 PR을 생성하고, CI 기다리고, 머지한 뒤에 release tag 생성하고. 매주 이렇게 기계적인 과정을 반복했어야 했다. 빌드 기다리면서 다른 작업을 하는 것도 컨텍스트 스위칭이 여간.. 그래서 배포 열차에 탑승하기 위해서는 적지 않은 리소스가 매주 소요되었다.

### Github Flow
문제라고 하면 문제일 수 있는 이런 불편함과 불안함들을 없애기 위해서 스터디를 시작했다. Git Flow, Github Flow, Gitlab Flow 등 다양한 Feature Branching 전략 뿐만 아니라, Mainline 기반으로 개발하는 Trunk-Based Development 방법론도 살펴보았다.

- [Patterns for Managing Source Code Branches](https://martinfowler.com/articles/branching-patterns.html): 이것만 정독하고 이해한다면 Git Branch 전략은 마스터할 수 있다고 생각. 다양한 방법론에 대한 자세한 설명 뿐만 아니라, 적절한 브랜치 전략을 고를 수 있는 방법까지 소개해주고 있다.
- [Git Branching Strategies vs. Trunk-Based Development](https://launchdarkly.com/blog/git-branching-strategies-vs-trunk-based-development/): Feature Branching 전략에 비해 trunk-based 개발 방법론이 가지고 있는 장점과 Trunk 기반의 개발을 위해서 반드시 필요한 Feature Flag에 대해서 잘 소개해주고 있다.
- [trunkbaseddevelopment](https://trunkbaseddevelopment.com/): Trunk 기반 개발의 정의와 필요한 사항들에 대한 가이드 문서. 이 사이트만 제대로 이해하고 있다면 Trunk 기반 개발에 관한 다른 문서는 안봐도 된다고 생각.
- [Git Flow에서 트렁크 기반 개발으로 나아가기](https://tech.mfort.co.kr/blog/2022-08-05-trunk-based-development/): 국내 기술 블로그 중에 Trunk-Based 개발이 잘 소개된 유일한 자료가 아닐까. 실무에서는 어떻게 사용하고 있는지 더 많이 공유가 되었으면 좋겠다.

![github-flow](/images/2023/02/20/github-flow.png "github-flow"){: .center-image }

Github Flow는 Git Flow에서 develop, release, hotfix 브랜치를 제거한 형태다. Git Flow가 Production 환경에 여러 버전을 관리하고 있는 제품을 위한 전략이라고 하면, Github Flow는 Production 환경에 단일 버전이 있는 제품을 위한 전략이라고 볼 수 있다. 그래서 배포를 위한 Release 브랜치를 따로 관리하지 않고 Hotfix도 마찬가지다. Github Flow에서는 Mainline을 main(master)라고 부르고, 개발자는 작업을 feature 브랜치에서 한다.

(이론적으로) 작업도 마찬가지로 Feature 브랜치에서 하니까 Git Flow에서 develop, release, hotfix 브랜치만 제거하면 Github Flow와 똑같다고 생각했는데, 인지해야 할 중요한 점이 하나 더 있다고 생각한다. Git Flow 뿐만 아니라 모든 브랜치 전략에는 Mainline이 존재하는데, Mainline은 모든 작업(Feature)의 시작점을 의미한다. Git Flow는 develop 브랜치가 Mainline이고, Github Flow는 main 브랜치가 Mainline이다. 그리고 언제 배포해도 상관없는 Stable 브랜치가 Release 형태로 분리되어 있는 Git Flow와 다르게, Github Flow는 배포 브랜치와 작업을 시작하는 Mainline이 동일한 main 브랜치를 사용하고 있다. **즉, Github Flow 전략에서 main 브랜치는 mainline의 역할과 동시에 Stable 해야 한다.** 따라서, Github Flow를 사용하는 팀원 모두는 main 브랜치가 항상 Stable 해야 한다는 명시적 혹은 암묵적 합의가 필요하다. Github Flow 전략을 사용하고 있는데 릴리즈에 포함되면 안되는 피쳐가 main 브랜치에 존재한다면 의도치 않은 장애로 이어질 수 있다.

Github Flow는 Git flow에 비해서 Release를 위한 절차가 굉장히 줄어들기 때문에 잦은 기능 수정과 배포가 있는 애자일 조직에 적합한 전략이라고 볼 수 있다. 그리고 여러 버전을 동시에 관리할 필요가 없는 Middle급 조직에 어울리는 전략이기도 하다.

### Trunk-Based Development
Github Flow 외에 Trunk-Based 방법론도 살펴보았는데, [https://trunkbaseddevelopment.com/](https://trunkbaseddevelopment.com/)에서는 아래와 같이 설명하고 있다.

> A source-control branching model, where developers collaborate on code in a single branch called ‘trunk’, resist any pressure to create other long-lived development branches by employing documented techniques. They therefore avoid merge hell, do not break the build, and live happily ever after.

![merge-hell](/images/2023/02/20/merge-hell.png "merge-hell"){: .center-image }

처음엔 trunk가 뭐지 했는데 Trunk-Based 방법론에서 Maineline을 부르는 용어다. Github Flow로 치면 main(master) branch와 똑같은. Feature Branch 기반이 아닌, Trunk 기반으로 작업을 하기 때문에 Mainline으로 변경사항을 바로 바로 추가할 수 있고, 수명이 긴 Feature Branch를 관리하지 않아서 Merge Hell에 빠지거나 빌드가 깨지는 경험에서 벗어날 수 있다. 물론 빌드가 깨지는 결과물을 Mainline에 추가하는건 논외로.

Trunk 기반 개발을 더 살펴보다 보면 여기에도 Feature Branch를 사용하는 부분이 나오는데, Github Flow의 Feature와는 다르게 지켜야 할 규칙이 있다. Trunk 기반 개발은 단일 브랜치를 지향하기 때문에, 오랫동안 지속되는 브랜치를 지양하고 있다(Short-Lived Feature Branches). 브랜치가 Merge, Delete 되기 전에는 며칠 동안만 지속되어야 하고, 오랜 기간 남아있는 브랜치가 있다면 Trunk 기반 개발의 철학과 정반대의 기능을 하고 있다고 볼 수 있다. 

![trunk-feature-branch](/images/2023/02/20/trunk-feature-branch.png "trunk-feature-branch"){: .center-image }

이처럼 Trunk 기반으로 작업하는 것과 Feature Branch 수명이 굉장히 짧은 특징은 잦은 기능 수정과 빠른 릴리즈가 필요한 조직에 적합하다. 하지만 검증되지 않은 기능이 사용자에게 노출되는건 위험하기 때문에 단순히 빠른 속도를 위해서 Trunk 기반을 채택해서는 안되고, 몇 가지 약속과 준비해야 할 것들이 있다.

- Quick rhythm to deliver code to production
- Small Changes
- Merge branches to the trunk at least once a day
- Continuous Integration; Automated testing
- Continuous Delivery
- Feature flags

Trunk 기반 개발을 위해서는 갖추어야 할 기술 기반 뿐만 아니라 코드 리뷰, 페어프로그래밍, 코드 스타일 등 개발팀의 문화와 더불어서 Trunk를 안전하게 운영할 수 있는 경험과 노하우도 필요해보였다. 하지만 우리팀에는 이 전략을 경험했거나 시도해 본 사람이 아무도 없었고, 상대적으로 익숙한 Github Flow를 기본 브랜치 전략으로 가져가보기로 했다. 

### 매일 배포하기
배포에 포함되지 말아야 할 피쳐가 mainline에 포함되어 있으면 어떡하냐, 여러명이 작업하면 Merge Conflict는 어차피 발생하는거 아니냐 등 Github Flow를 사용한다고 했을때 우려되는 점이 많았었다. 전자는 각 프로젝트에 Feature Flag를 도입해서 해결할 수 있고, 후자는 어느 브랜칭 전략을 사용하던지 간에 발생하는건데 Trunk 기반 개발에서 Feature 브랜치의 수명을 짧게 가져 가는 것처럼 피쳐의 수명을 줄이면 고통이 많이 줄어들거라 생각했다. 이전에 코드 충돌에서 발생하는 고통을 [고통스러우면 더 자주하라](https://sungjk.github.io/2022/11/12/frequency-reduces-difficulty.html) 글에서 소개하기도 했는데, PR/커밋의 단위를 작게 가져가면 많은 부분을 해소할 수 있을거라 생각. 그리고 새로운 전략을 사용해보면서 우리팀 전체의 역량과 경험도 쌓아가고 팀에 맞게 개선할 수 있는 부분도 있을거라 믿었다.

브랜치 전략에 Github Flow를 사용한 지 3달 정도가 지났다. 그 전에는(Git Flow) 배포를 하기 위해 1시간은 넉넉히 생각하고 있었는데 지금은 20분 정도 걸리려나? 지금도 배포 프로세스 과정에서 개선해야 할 부분이 많이 남아있는데 더 줄이고 싶다. 아무튼, 배포에 쏟는 시간이 절반 이상으로 줄어들었다. 아직 3달 밖에 안됐는데 팀에 새로운 경험치도 많이 쌓였다고 생각한다. 더 빠른 배포와 수명이 짧은 피쳐 브랜치 관리를 위해 빌드 속도 개선에도 신경을 많이 쓰게 되었고(개발 생산성도 덩달아 올라갔다), 새로 작성한 코드나 수정한 코드를 안전하게 관리하기 위해 Feature Flag도 적극적으로 사용하고 있다. 

안정적인 개발과 운영이 중요한 프로젝트를 하고 있다보니 불안함도 많았었는데 교훈도 하나 배웠다. 문제 없이 잘 동작하는 레거시 코드가 많은 이유이기도 한데, 개인적으로 안정적인 코드는 가장 많이 실행되는 코드라고 생각한다. 그리고 코드 리뷰어와 배포 승인자의 피로를 덜기 위해 배포에 포함되는 변경사항이 많지 않도록(Maineline에 새로운 코드가 많이 쌓이지 않도록) 신경쓰고 있고, 더 자주 배포하고 더 자주 실행되고 만들기 위해 노력하고 있다. 지금은 매일 배포하는 팀이 되었다. 이전처럼 배포할 때 긴장되는 느낌과 불안함도 사라졌다. 지금 팀에서 배포 1000번 하는게 목표인데 생각보다 금방 달성할거 같기도 하고.. 아무튼, Github Flow(with Short-Lived Feature Branches)를 적용하고 나서 우리 팀의 특성에 맞게 빠른 속도와 안정적인 운영을 동시에 가져갈 수 있어서 만족하고 있다. Trunk 기반 개발을 포함해서 새로운 전략들을 스터디해보면서 개선할 부분이 있는지 계속해서 살펴봐야겠다.

---

### 참고
- [Patterns for Managing Source Code Branches](https://martinfowler.com/articles/branching-patterns.html)
- [Git Branching Strategies vs. Trunk-Based Development](https://launchdarkly.com/blog/git-branching-strategies-vs-trunk-based-development/)
- [trunkbaseddevelopment](https://trunkbaseddevelopment.com/)
- [Convinced Coder - Trunk Based Development](https://convincedcoder.com/2019/02/16/Trunk-based-development/)