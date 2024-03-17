---
layout: entry
title: Stacked Diffs(Stacked PR)
author-email: ajax0615@gmail.com
description: 효율적인 리뷰와 개발 생산성을 높이기 위한 Pull Request 관리 방법론에 대해서 살펴봅니다.
keywords: stacked diffs, stacked diff, stacked pr, stacked changes, pull request, interactive rebasing, github
thumbnail-image: /images/profile/stacked-diff.png
publish: true
---

커밋을 잘게 쪼개거나 PR(Pull Request) 본문에 친절하고 자세한 내용을 담아서 코드 리뷰를 요청하는 것은 리뷰를 좀 더 효율적으로 하기 위한 당연한 방법으로 여겨지곤 합니다. 이 외에도 더 나은 코드 리뷰 프로세스와 피쳐 개발에 속도를 더해주는 다양한 소프트웨어 개발 방법론이 있는데요. 오늘은 PR(Pull Request)과 비교되는 Stacked Diffs 에 대해서 알아보겠습니다.

> Stacking makes the unit of change an individual commit, rather than a pull request composed of several commits. The idea behind stacked diffs is that you can keep working on your main branch, and worry about reviews later.

처음 Stacked Diffs를 소개하는 문장을 접했을 때가 생각납니다. "Stacked"과 "Diffs"라는 단어가 호기심을 자아내면서, 단순히 커밋을 잘게 쪼개고 PR을 자주 그리고 여러번 요청하는 것과 어떤 차이가 있는지 의문이 들기 시작했습니다. 마치 Trunk-based Development에서 Trunk의 의미를 알기 전까지는 아주 복잡하고 대단한 방법론인 것처럼 보였던 것처럼 말이에요(실제로는 생산성을 아주 끌어올려주는 대단한 방법론이라고 생각합니다). 그 의미를 알고 이해한 뒤부터는 없으면 어색할 정도로 당연하고 친숙한 개념이 되었습니다. "Stacked Diffs" 단어에 집중해서 스택된 Diff를 이해하기보다는, 친숙한 Pull Request와 비교하면서 이해하면 용어가 가져다주는 호기심이 해소될 거라고 믿습니다.

---

## Pull Request Flow

피쳐 개발에 코드 리뷰가 수반되는 경우, 흔히 개발을 마치고 리뷰를 요청할 때 아래와 같은 절차를 따릅니다. 먼저 Mainline에서 Feature Branch를 생성하고 작업을 완료한 후, GitHub과 같은 플랫폼에서 Pull Request를 생성합니다. 그리고 작업자는 리뷰가 완료되기를 기다립니다. 이 과정에서 PR을 검토하기 쉽게 하는 데 노력할 수 있는 방법은 커밋을 작게 쪼개거나 PR을 가볍게 유지하는 것(변경 사항을 최소화)뿐만 아니라 변경 사항에 대해 자세한 코멘트를 남기는 것입니다.

![Pull Request Flow](/images/2024/03/17/pull-request-flow.png "Pull Request Flow"){: .center-image }

그런데 제품의 변화 속도나 피쳐 개발 속도가 다소 빠른 환경에서 리뷰가 끝날 때까지 기다려야 한다면 답답하기 그지 없습니다. 너무 급하다 싶으면 리뷰를 재촉하거나 머지를 할 수도 있을 것 같습니다. 아니면 리뷰를 빠르게 할 수 있도록 단일 PR을 가볍게 만들고 PR을 여러 번 요청할 수도 있습니다. 만약 위와 같은 Pull Request 흐름에서 PR을 여러 번 나눠야 한다면 어떻게 하면 좋을까요? 

![Pull Request Flow](/images/2024/03/17/pull-request-flow-2.png "Pull Request Flow"){: .center-image }

첫 번째 PR이 Mainline에 머지되면 Mainline을 로컬에 동기화(Pull)한 다음, Feature Branch를 만드는 과정부터 두 번째 PR 생성까지 다시 반복하면 됩니다. 이건 현재 작업하려는 피쳐(또는 PR)들이 서로 의존하고 있기 때문에 발생하는 어쩔 수 없는 현상입니다. 피쳐(PR)들이 완전히 독립적이라면 기존의 흐름과 상관없이 Feature Branch를 전환하면서 작업할 수 있을텐데 말이죠. 같은 맥락의 작업을 여러 개의 독립된 부분으로 나누는 좋은 방법이 없기 때문에 이게 최선인 것 같습니다. 여기서 '독립적이다'는 의미는 코드상에서 충돌이 발생할 여지가 없는 것 뿐만 아니라 기능적으로 독립적으로 존재할 수 있다는 것을 포함하고 있습니다.

만약 같은 맥락의 작업을 독립적인 부분으로 나누는 대신 이어서 진행할 수 있다면 어떨까요? 예를 들어, 기훈이형이 상우에게 송금하는 기능이 필요하다면, (1) 기훈이형과 상우의 유저 상태를 조회하는 기능 (2) 기훈이형의 지갑 잔액을 조회하는 기능 (3) 기훈이형이 상우에게 송금하는 기능으로 나누어서 구현한다고 가정해보겠습니다. 각각의 기능은 송금이라는 기능을 완성시키기 위해 서로를 의존하고 있습니다. 먼저 개발을 시작하기 전에 Mainline의 코드를 로컬의 Main Branch로 동기화한 다음, 작업할 Feature Branch(`/feature/user`)를 생성합니다. (1)번 기능을 개발하고 커밋을 생성하여 Pull Request를 생성합니다. (1)번 기능에 대한 리뷰를 요청하고, `/feature/user` 브랜치에서 (2)번 기능을 위한 `/feature/balance` Feature Branch를 생성합니다. 그리고 (2)번 기능을 개발하고 커밋을 생성하여 Pull Request를 생성합니다. (2)번 기능에 대한 리뷰를 요청하고, 마지막으로 `/feature/balance` 브랜치에서 (3)번 기능을 위한 Feature Branch를 생성합니다. 이어서 작업을 하고 Pull Request를 생성합니다.

---

## Stacked Diffs Flow

같은 맥락의 작업을 이어서 진행하기 위해 위와 같이 작업한 경험이 있을 것입니다. 저도 마찬가지로 이런 방식으로 개발을 진행한 적이 있었지만, Feature Branch 코드를 Mainline으로 머지하고 각 브랜치를 관리하기 위한 일관된 전략이 없었기 때문에, 리뷰 중인 PR에서 코드 충돌(Conflict)이 발생했을 때 구체적인 해결 방법이나 동료에게 리뷰 순서를 알려줘야하는 문제 등의 불편한 점이 있었습니다. 이런 불편함에 대한 구체적인 전략과 가이드를 제공하는 것이 Stacked Diffs 입니다. 다소 거창하게 말한 것 같지만, 비슷한 맥락의 작업이라면 PR을 생성할 때 매번 현재 Feature Branch를 기준으로 생성하는 것이 전부입니다.

Stacked Diffs는 Stacked PR, Stacked Changes 라고도 불립니다. PR을 쌓는다고 해서 Stacking을 한다고 표현하기도 합니다. Stacked Diffs는 위에서 살펴본 예시처럼 Mainline에서 시작된 작업을 끊임없이 이어가고, 리뷰에 대해서는 나중에 걱정할 수 있게 도와줍니다. Main 브랜치에서 체크아웃한 다음 아주 작은 커밋으로 PR을 만듭니다. 그 다음 두 번째 브랜치를 만들고 PR을 만들고, 세 번째 브랜치를 만들고 PR을 하는 식으로 작업을 반복하는 것입니다. (위에서 아주 복잡하고 대단한 것처럼 이야기했는데.. 민망할 정도로) 아주 심플합니다.


![Stacked Diffs Flow](/images/2024/03/17/stacked-diff-flow.png "Stacked Diffs Flow"){: .center-image }

상황에 따라서는 리뷰를 기다리지 않고 현재 브랜치에서 작업을 계속 이어서 하는 이 방식이 별거 아닌 것처럼 보일 수 있습니다. 혼자서 작업을 한다던가 제품의 변화 주기가 다소 빠르지 않아서 천천히 리뷰를 기다려도 되는 상황이라던가, 아니면 대부분의 작업 단위가 아주 작고 독립적으로 이루어져있다면 이런 방식은 불필요하다고 생각합니다. 그러나 서론에서도 이야기한 것처럼 제품의 변화 주기가 매우 빠르고 코드 리뷰 병목이 발생할 수 있는 상황에서는 Stacked PR이 매우 큰 생산성을 제공할 수 있다고 생각합니다.

이제 Stacked와 Diffs 각 단어가 어떤 의미를 가지는지 이해할거라 생각합니다. Diffs는 코드의 변경 사항을 의미하면서도 동시에 커밋을 나타내는 용어이며, 코드 리뷰의 대상인 PR(Pull Request)를 나타내기도 합니다. 코드의 변경 사항을 쌓아 올린다는 의미에서 Stacked Diffs(또는 Stacked PR)라고 부르고, 커밋(Diff)을 만드는 과정을 Stacking이라고 합니다. 스택을 계속해서 쌓아 올리는건 엔지니어 입장에서 막힘 없이 계속 작업을 이어갈 수 있다는걸 표현하는것처럼 보이기도 합니다. 피쳐 하나를 개발하고 스태킹, 이어서 또다른 피쳐 하나를 개발하고 스태킹, 이 과정에서 리뷰가 완료되고 머지될 때까지 기다릴 필요 없이 작업을 계속 이어갈 수 있습니다.

---

## Resolve merge conflicts(Feat. Interactive Rebasing)

장점만 이야기하다보니 마치 은총알처럼 보입니다만, 여기서도 Merge Conflicts 는 피할 수 없습니다. 동일 코드 베이스를 여러 사람과 작업을 하다보면 빼놓을 수 없는 스트레스 중 하나가 코드 충돌 입니다.

Mainline 에서 체크아웃한 다음 3개의 Diff 를 만들었다고 가정해보겠습니다. 첫번째 Diff 에서 코드 리뷰 도중에 문제나 수정이 필요한 부분이 발견되었고 이 Diff 에 코드 변경이 발생했다면, 두번째 Diff 와 세번째 Diff 는 어떻게 되는걸까요? Diff 3은 Diff 2에서 시작되었고 Diff 2은 Diff 1에서 시작되었는데, Diff 2와 Diff 3은 리뷰 도중에 반영된 변경 사항이 없는 상태라서 코드 충돌이 발생하게 됩니다.

![Stacked Diffs Conflicts](/images/2024/03/17/stacked-diff-conflicts.png "Stacked Diffs Conflicts"){: .center-image }

또 다른 예시로, 저희 팀에서는 단일 PR에 포함된 여러 커밋들을 하나의 피쳐로 바라보고 Revert, Release Note 에서의 가시성 등을 위해 Mainline 으로 코드 병합시 Squash Merge 를 강제하고 있는데요. 위 예시처럼 Diff 1에 변경 사항이 발생하지 않더라도 Squash Merge 를 사용하고 있다면 Diff 1을 머지하는 순간, Mainline에 반영된 변경 사항을 다음 Diff 들이 모르는 상황이 발생해서 동일하게 Conflicts 가 발생합니다.

Diff 2와 Diff 3에 업데이트된 Diff 1의 내용이 없는 상태에서 Mainline 으로 머지할 수 없는 상황. 이럴땐 어떻게 해결하면 좋을까요? [Interactive Rebase](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History)를 해야 합니다. 저는 평소에 Merge Conflicts 가 발생하면 Interactive Rebase를 통해서 해결하고 있는데 여기서도 만나니 더 반가웠어요. rebase를 할 때 -i 옵션을 추가하면 Interactive Rebase를 수행할 수 있는데, 이 기능은 주로 현재 내 로컬의 Git History를 재구성할 때 사용합니다. 저는 여러개의 커밋을 하나의 커밋으로 합치려고 할 때에도 종종 사용합니다. Interactive Rebase를 위 상황에도 적용해보면, Diff 1의 변경 사항을 Diff 2에 리베이스하고, Diff 2의 변경 사항을 Diff 3에도 리베이스 하면 됩니다.

![Interactive Rebasing](/images/2024/03/17/stacked-diff-conflicts-interactive-rebase.png "Interactive Rebasing"){: .center-image }

그런데.. Diff가 하나만 있는게 아니다보니 리베이스 해야 할 경우도 덩달아 많아졌습니다. 뭐 리베이스는 필요할 때만 하면 되는것이지만, 위 상황에서는 Diff 1의 변경사항을 엮여있는 Diff 들에도 전부다 리베이스를 해줘야 합니다. 이런걸 보면 평소 하던 방식대로 Main에서 매번 새로운 PR을 만드는게 더 나은것 같기도 합니다. Stacked PR의 경우 전통적인 방법과 비교했을때 코드 충돌이 발생하면 Rebase 를 더 자주 해야하는 단점도 있지만, Rebase 해야 할 코드의 양(코드 변경 지점)이 전통적인 방법에서의 Conflict 와 비교했을때 아주아주 적고 가볍기 때문에 코드 충돌에서 오는 스트레스가 이전보다 낫다고 생각합니다(실제로도 그렇고요). 리베이스해야 할 코드가 수백 또는 수천 줄이거나 충돌이 수십개 발생한다고 생각하면 아찔하기만 합니다. 

![Headaches](/images/2024/03/17/merge-conflict-headaches.png "Headaches"){: .center-image }

아주 작고 가벼운 Diff는 코드 리뷰를 해야 하는 리뷰어 입장에서도 리뷰를 편하게 할 수 있게 도와주고, 코드 충돌이 발생했을때 해결해야 할 지점도 아주 작아져서 작업자에게도 편함을 더해줍니다. 그래서 Stacked PR을 사용하게 되면 리베이스를 습관처럼 자주 사용하게 됩니다.

---

## How to stack pull requests

코드 형상 관리에 Github을 사용하고 있다는 가정하에 여러 PR을 만들어보겠습니다. 먼저 main branch를 최신화 한 다음 첫번째 피쳐 브랜치를 체크아웃한 다음 커밋을 생성합니다.

```sh
$ git status
On branch main

$ git pull
Already up to date.

$ git checkout -b init-gradle
Switched to a new branch 'init-gradle'

$ gradle init
$ git add . && git commit -m 'Init gradle'
$ git push -u origin init-gradle
```

Github Repository 에서 `init-gradle` 브랜치의 Pull Request 생성 프롬프트를 클릭하고,

![stacked-pr](/images/2024/03/17/stacked-pr-1-1.png "stacked-pr"){: .center-image }

`main` 브랜치를 베이스로 설정해서 PR을 생성합니다. 별다른 설정을 하지 않으면 디폴트 브랜치가 베이스 브랜치로 설정되기 때문에 첫 Diff 는 그대로 생성하면 됩니다.

![stacked-pr](/images/2024/03/17/stacked-pr-1-2.png "stacked-pr"){: .center-image }

그 다음 두번째 브랜치를 체크아웃하고 커밋을 만듭니다.

```sh
$ git status
On branch init-gradle

$ git checkout -b init-gradle
$ git checkout -b setup-spring-boot
Switched to a new branch 'setup-spring-boot'

$ git add . && git commit -m 'Setup Spring Boot'
$ git push -u origin setup-spring-boot
```

여기까지 하면 `init-gradle`, `setup-spring-boot` 가 Stacked PR 형태로 만들어집니다. 마찬가지로 `setup-spring-boot` 브랜치의 Pull Request 생성 프롬프트를 클릭합니다.

![stacked-pr](/images/2024/03/17/stacked-pr-2-1.png "stacked-pr"){: .center-image }

여기서 주목할 만한 점은, 위에서도 언급했듯 별다른 설정을 하지 않으면 디폴트 브랜치가 베이스 브랜치로 설정되기 때문에 두번째 Diff 뿐만 아니라 첫번째 Diff 인 `init-gradle` 피쳐의 변경 사항도 포함되어서 보인다는 것입니다.

![stacked-pr](/images/2024/03/17/stacked-pr-2-2.png "stacked-pr"){: .center-image }

이건 우리가 `setup-spring-boot` 브랜치를 생성할 때 베이스를 `init-gradle` 브랜치로 했기 때문에, 마찬가지로 Pull Request 를 생성하기 전에 Base 브랜치를 `init-gradle` 로 변경해줍니다.

![stacked-pr](/images/2024/03/17/stacked-pr-2-3.png "stacked-pr"){: .center-image }

그럼 아래와 같이 이전 Diff 에 포함된 것은 현재 피쳐 브랜치에서 새롭게 생성한 Diff 만 표현됩니다.

![stacked-pr](/images/2024/03/17/stacked-pr-2-4.png "stacked-pr"){: .center-image }

---

## How to merge stacked pull requests

### Squash Merge 사용 제한

위에서 코드 충돌에 대해 이야기하면서 저희 팀에서는 Mainline으로 코드 병합시 Squash Merge를 사용했었다고 했는데요. Stacked PR을 사용하게 되면 [Squash and Merge](https://docs.github.com/ko/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/about-pull-request-merges#squash-and-merge-your-commits)와 [Rebase and Merge](https://docs.github.com/ko/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/about-pull-request-merges#rebase-and-merge-your-commits) 사용이 제한됩니다. Git은 Commit Hash를 통해 변경 사항을 추적하고, Squash Merge는 Commit Hash를 보존하지 않고 하나의 커밋으로 합쳐버리기 때문에 Mainline으로 코드를 머지하면 생성되었던 모든 커밋 히스토리가 덮어 씌워지게 됩니다. 그래서 위 예시를 보면, `init-gradle` 브랜치가 Main 브랜치에 Squash Merge 되면 Git은 모든 `init-gradle`의 커밋이 Main 브랜치에 있다는걸 인지하지 못하게 됩니다(그냥 하나의 큰 커밋이 있다는것만 알고 있음). 그런데 `setup-spring-boot` PR은 `init-gradle` 의 커밋들을 커밋 히스토리에서 가지고 있기 때문에 바로 머지할 수 없고 Interactive Rebase를 통해서 `setup-spring-boot` PR에서 `init-gradle` 의 모든 커밋들을 제거해야 합니다. 

- 이 때 `setup-spring-boot` PR와 `init-gradle` PR 간에 동기화 체크는 필요합니다. `init-gradle` PR의 모든 커밋이 `setup-spring-boot` RP에 들어있는지를요. 그렇지 않으면 Rebase 과정에서 충돌이 발생할 수 있습니다.

```sh
$ git checkout main
$ git pull
$ git checkout setup-spring-boot
$ git rebase -i main
```

그래서 지금은 Merge 옵션에 Merge Commit 을 활성화하고 Merge Commit 메시지에 PR 타이틀이 포함될 수 있도록 변경했습니다.

- 옵션 활성화시 Pull request title 로 변경하지 않으면 Default Message 가 출력되는데, `Merge pull request #1 from sungjk/init-gradle` 같은 커밋 메시지가 생성되어서 피쳐(커밋)의 변경사항을 한눈에 표현할 수 없는 단점이 있습니다.

![Github Merge Commit](/images/2024/03/17/github-merge-commit.png "Github Merge Commit"){: .center-image }

### PR Merge 순서

생성된 PR들을 머지할 때에 순서도 중요합니다. Squash Merge가 제한되기 때문에 Main에서 Merge Commit 들이 어떻게 보이기를 원하는지에 따라 다를 수 있지만 생성된 순서대로 머지할 것을 가이드 하고 있습니다.

Stacking을 하는 시점부터 어떤 PR을 먼저 생성할 건지 그리고 어떤 PR을 먼저 머지할건지는 전적으로 주관적이긴 합니다. 그런데 위에서 코드 리뷰 요청을 위해 Pull Reuqest를 생성할 때 Diff 표시를 위해 Base 브랜치를 이전 Diff로 변경하는걸 보았는데요. Github에서는 PR의 베이스 브랜치가 삭제되면 자동으로 이를 감지하고 디폴트 브랜치(여기서는 Main)로 변경해줍니다.

![Github Delete Branch](/images/2024/03/17/github-delete-branch.png "Github Delete Branch"){: .center-image }

예를 들어, 먼저 생성한 `init-gradle` PR을 Main에 머지하면 자동으로 `init-gradle` 브랜치가 삭제되고, `setup-spring-boot` PR의 베이스 브랜치가 `init-gradle` 에서 Main 으로 변경됩니다. 

![Github Base Branch](/images/2024/03/17/github-base-branch.png "Github Base Branch"){: .center-image }

만약 Main 브랜치에 별도 Branch Protection Rule 을 설정해두었다면, 베이스 브랜치가 Main으로 바뀌었을때 CI를 다시 수행할 수 있도록 Workflow Trigger 설정을 변경해두는것도 추천합니다(우리의 Main 브랜치는 소중하니까요).

---

## Tools for Stacking

만약 코드 리뷰를 Github, GitLab, Bitbucket 등에서 하고 있다면, 이 방식을 처음 사용했을때 조금은 어색한 부분이 보일거예요. 저 또한 처음 팀에 사용하자고 제안했을때 뭔가 불편했습니다. Stacked PR은 한마디로 얘기하면 피쳐 하나를 개발할 때 커밋마다 PR을 만드는건데, PR 간에 의존성은 어떠한 지, 쉽게 말해 리뷰어 입장에서 어떤 것부터 리뷰를 하면 좋을지 파악하기 어려운 문제도 있었습니다. 위에서 아주 잠깐 살펴본 기훈이형이 상우에게 송금하는 예시에서 (1) 기훈이형과 상우의 유저 상태 조회 (2) 기훈이형의 지갑 잔액 조회 (3) 기훈이형이 상우에게 송금  이렇게 3가지 PR이 각각 존재하다보니 리뷰어 입장에서 상황에 따라 (1) → (2) → (3) 순서로 리뷰를 하는게 효과적일 수 있습니다. 그런데 Github 같은 도구들은 태초부터 소셜 코딩이나 오픈소스 프로젝트에 적합하게 설계되어서 Stacked Diffs에 최적화되어 있지 않습니다. PR 하나가 전체 맥락을 다루기도 하고, 대개 코드의 변경 사항이 사용자향 제품 개발 만큼 빠르지 않은 경우도 있다보니 Stacked Diffs에 최적화된 도구들이 생겨났습니다.

빅테크 기업에서는 코드 리뷰를 위한 자체 Internal Tool을 개발해서 사용하고 있는데 대표적으로 Google의 Critique, Meta의 Phabricator 등이 있습니다. 이 도구들의 특징은 Stacked Diffs 를 아주 잘 지원한다는 것인데요. 이런 워크플로우를 개인도 사용할 수 있도록 Phabricator 는 오픈소스 프로젝트로도 만들어졌는데 지금은 유지보수가 되고 있지 않습니다. 대신 Graphite, Gerrit, ReviewStack 등의 Stacking 전용 도구들을 사용하면 전통적인 Git의 흐름을 아주 잘 표현해주고 리베이스도 훨씬 쉽게 할 수 있습니다. 

- Graphite: [https://graphite.dev/](https://graphite.dev/)
- Gerrit: [https://www.gerritcodereview.com/](https://www.gerritcodereview.com/)
- Phabricator: [https://www.phacility.com/phabricator/](https://www.phacility.com/phabricator/)

이런 툴들을 사용하면 Stack을 쉽게 만들 수 있고 생성된 PR들을 시각화해주는 등 Github 에서는 제공하지 않는 많은 불편함을 해소할 수 있습니다. 여기서 각 툴에 대한 자세한 소개는 하지 않겠습니다. 유료로 쓸만큼 아주 유용한 도구라서 관심 있으신 분에게는 Graphite, Gerrit를 강력 추천합니다!

![graphite](/images/2024/03/17/graphite.png "graphite"){: .center-image }

---

## 마치며

경제학과 심리학에 “The Sunk Cost Fallacy” 라는 아주 유명한 개념이 있습니다. 물건, 투자, 경험 등 이전에 이미 들였던 비용이나 자원에 대해 과하게 중요성을 부여해서 현재나 미래의 결정을 올바르게 판단하지 못하는 경향을 가리키는 용어입니다. 사람들은 더 가치 있는 대안이 있음에도 불구하고 자신이 투자했다고 생각하는 것을 선호하는 경향이 있다고 합니다. 이 이야기를 하는 이유는 이 글에서 다루었던 Stacking 에 대해 들었을때, 아주 짧게라도, 그동안 익숙하고 잘 사용해왔던 Pull Request가 있는데 굳이? 라는 생각이 들었기 때문입니다. 하지만 이것저것 찾아보고 지인들 이야기도 들어보면 실제로 사용해보니 작업의 효율이 많이 개선되었다는걸 느꼈습니다. 개인에게 새로울 수 있는 패러다임에 대해서 비판적으로 수용해야 할 부분도 있지만 열린 마음으로 비효율을 개선할 수 있지는 않을까 고민해야 한다는걸 한 번 더 깨닫게 되었습니다.

사용하면서 좋았던 점과 불편할 수 있는 점 몇 가지 적어보며 글을 마치겠습니다.

- 혼자가 아닌 팀으로 작업을 할 때에는 적응과 시행 착오가 항상 수반됩니다. 마찬가지로 Merge 옵션(Merge Commit 활성화), Rebase 전략, 커밋 메시지 그리고 충돌 해결을 위한 전략 등을 팀원들과 고민하는 시간을 많이 가졌고, 더 나은 코드 리뷰와 업무 프로세스 개선으로 이어졌다고 생각합니다.
- “이 PR 리뷰 좀 부탁드립니다.”, “아직 코드리뷰가 완료되지 않았습니다.” 등 리뷰가 완료되지 않아서 작업을 이어 하지 못하는 문제에서 벗어났습니다. 그리고 팀의 일하는 방식과 제품의 빠른 변화 주기에 맞춰서 개발을 할 수 있게 되었습니다.
- 1번 Diff 생성 → 2번 Diff 생성 → 3번 Diff 생성 까지 완료한 다음, 이어서 4번 Diff 를 만드려는데, 3번 Diff에서 개발한 방식보다 더 나은 방법이 떠올랐을때 이전보다 많이 자유로워졌어요. 2번 Diff에서 새로 체크아웃을 한 다음에 새로운 3-1번 Diff를 만들었습니다. 기존 3번 Diff도 잘 동작하는 코드지만 리뷰를 통해 팀원들의 이야기를 들어볼 수 있고 리뷰에 병목없이 새로운 방식으로 개발을 이어서 할 수 있었습니다. 작업 흐름이 끊기지 않고 체크아웃을 자유롭게 할 수 있다는 장점이 있습니다.
- PR이 엄청 쪼개져서 개별 커밋으로 Main에 머지되다보니 특정 피쳐를 Revert 해야 하는 상황에서는 이전에 Squash Merge를 사용할 때보다 아주 많이 불편해졌습니다. Squash Merge는 피쳐가 단일 커밋으로 Main에 머지되어서 Revert가 아주 수월한 장점이 있습니다. 다만 개발/테스트 환경에서의 Revert를 한 적은 거의 없었던것 같고 문제가 생기면 바로 대응하는 방식을 취했기 때문에 문제가 될거라는 생각은 다소 적었습니다. 반면 운영 환경에서의 Revert는 별다른 대안이 없으면 좀 불편할 수 있겠다 싶었지만, 인프라 수준의 롤백이 아주 잘 지원되어서 이것도 문제가 없다고 판단하였습니다. 만약 Revert 전략이 중요하다면 Squash Merge를 함께 사용해보는 방법을 고민해보시는것도 좋겠네요(사용할 수 있긴 합니다).

읽어주셔서 감사합니다.

---

### References

- [https://newsletter.pragmaticengineer.com/p/stacked-diffs](https://newsletter.pragmaticengineer.com/p/stacked-diffs)
- [https://graphite.dev/guides/topic/stacked-diffs](https://graphite.dev/guides/topic/stacked-diffs)
- [https://jg.gg/2018/09/29/stacked-diffs-versus-pull-requests/](https://jg.gg/2018/09/29/stacked-diffs-versus-pull-requests/)
- [https://stacking.dev/](https://stacking.dev/)
