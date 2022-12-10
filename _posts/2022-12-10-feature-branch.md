---
layout: entry
title: Feature Branch
author: 김성중
author-email: ajax0615@gmail.com
description: Feature Branch의 장점과 단점 알아보기
keywords: Feature Branch, branching pattern
publish: true
---

Feature Branch는 개발자가 새 기능에 대한 작업을 시작할 때 만드는 브랜치로, [소스 코드 브랜칭 패턴](https://martinfowler.com/articles/branching-patterns.html)중 하나다. 개발자가 피쳐에 대한 모든 개발을 완료하면 나머지 팀의 변경 사항과 기능을 통합하는(integrates) 과정을 거친다.

Feature Branch에서 작업을 하는 동안에 다른 팀에서 먼저 기능 개발이 완료되면 통합(integration)에서 발생하는 문제를 줄이기 위해 다른 팀이 작성한 변경 사항을 우리 Feature Branch로 먼저 병합할(Merge) 수 도 있지만, 변경 사항을 공통 코드베이스에 통합하는 시점까지 미루기로 했다. 이로 인해, 서로 다른 Feature Branch에서 작업하는 두 사람이 있다면, 나중에 작업을 마무리 한 사람이 공통 코드베이스에 작업을 병합할 때까지 모든 작업이 통합되지 않는 결과를 가져온다.

Feature Branch는 많이 사용되는 기술이며 특히 오픈 소스 개발에 적합하다. Feature에 필요한 모든 작업이 완료될 때 까지 팀의 공통 코드베이스에서 분리할 수 있으며, Merge하면서 발생 할 수 있는 문제점을 통합하는 시점까지 미룰 수 있다. 그러나 이렇게 소스 코드를 격리하면 문제가 발생할 여지를 조기에 찾지 못한다. 그리고 리팩터링을 권장하지 않다보니 코드베이스의 상태가 나빠질 수도 있다.

Feature Branch의 사용 결과는 기능을 완료하는 데 걸리는 시간에 따라 크게 달라진다. 일반적으로 하루나 이틀 안에 기능을 개발하는 팀은 충분히 피쳐들을 자주 통합할 수 있기 때문에, 지연된 통합 문제(위에서 언급한 Merge 시점까지 미루는 것)를 피할 수 있다. 반면, 기능을 완료하는 데 몇 주 또는 몇 달이 걸리는 팀은 이런 어려움에 더 많이 직면하게 될 것이다.

---

### 참고
- [Feature Branch](https://martinfowler.com/bliki/FeatureBranch.html)
