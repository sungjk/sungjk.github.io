---
layout: entry
title: Feature Toggles (aka Feature Flags)
author: 김성중
author-email: ajax0615@gmail.com
description: 코드를 수정하지 않고 시스템 동작을 바꾸는 기술인 Feature Toggle에 대해서 알아봅니다.
keywords: feature toggle, feature flag
publish: true
---

Feature Toggles은 코드를 수정하지 않고 시스템 동작을 바꾸는 기술이다. \"Feature Toggling\"은 사용자에게 새로운 기능을 빠르고 안전하게 제공하는데 도움을 주는 패턴이다. Feature Toggles은 Feature Flags, Feature Bits 또는 Feature Flippers 라고도 불리운다.

---

# 토글링 이야기

팀이 도시 계획 시물레이션 게임을 개발한다고 가정해보자. 팀 내 몇몇은 새로운 알고리즘의 효율성을 높이는 작업을 하고, 다른 몇몇은 코드베이스의 관련 영역에서 지속적인 개선 작업을 진행하고 있다.

이 상황에서 오랫동안 통합되지 않은 브랜치를 머지한다고 했을때, 다들 이 고통스러운 경험은 피하고 싶을 것이다. 그래서 팀은 trunk 기반으로 작업을 하기로 결정하고, 알고리즘을 개선하는 개발자들은 Feature Toggle을 사용해서 작업이 나머지 사람들에게 영향을 미치거나 코드가 불안정해지는 것을 방지하기로 했다.

### 피쳐 플래그의 탄생

알고리즘 개선 코드에서 사용중인 방법은 다음과 같다.

```javascript
function reticulateSplines(){
  var useNewAlgorithm = false;
  // useNewAlgorithm = true; // UNCOMMENT IF YOU ARE WORKING ON THE NEW SR ALGORITHM

  if( useNewAlgorithm ){
    return enhancedSplineReticulation();
  }else{
    return oldFashionedSplineReticulation();
  }
}

function oldFashionedSplineReticulation(){
  // current implementation lives here
}

function enhancedSplineReticulation(){
  // TODO: implement better SR algorithm
}
```

현재 알고리즘 구현을 oldFashionedSplineReticulation 함수로 이동하고 reticulateSplines를 **Toggle Point**로 수정했다. 이제 누군가가 새 알고리즘을 작업 중이면 `useNewAlgorithm = true` 주석을 제거해서 useNewAlgorithm **Feature**를 사용할 수 있다.

### 동적인 플래그 만들기

팀은 몇 시간이 지나고 통합 테스트를 통해서 새로운 알고리즘을 실행하려는데, 동시에 이전에 사용하던 알고리즘도 실행하고 싶어한다. 그러려면 피쳐를 동적으로 활성화하거나 비활성화할 수 있어야 하는데, `useNewAlgorithm = true` 라인에 주석을 달거나 제거하는 방식에서 벗어나야 한다.

```javascript
function reticulateSplines(){
  if( featureIsEnabled("use-new-SR-algorithm") ){
    return enhancedSplineReticulation();
  }else{
    return oldFashionedSplineReticulation();
  }
}
```

그래서 이제 어떤 CodePath가 라이브중인지 동적으로 컨트롤할 수 있는 **Toggle Router**인 `featureIsEnabled` 함수를 도입했다. Toggle Router를 구현하는 방법은 간단한 인메모리 저장소부터 나이스한 UI가 있는 분산 시스템에 이르기까지 다양하다. 간단한 것부터 알아보자.

```javascript
function createToggleRouter(featureConfig){
  return {
    setFeature(featureName,isEnabled){
      featureConfig[featureName] = isEnabled;
    },
    featureIsEnabled(featureName){
      return featureConfig[featureName];
    }
  };
}
```

설정 파일을 읽거나 기본 설정값을 이용해서 Toggle Router를 만들 수 있고, 이걸로 피쳐를 동적으로 켜거나 끌 수 있다. 이를 통해 테스트에서 토글된 피쳐의 양쪽 모두를 확인할 수 있다.

```javascript
describe( 'spline reticulation', function(){
  let toggleRouter;
  let simulationEngine;

  beforeEach(function(){
    toggleRouter = createToggleRouter();
    simulationEngine = createSimulationEngine({toggleRouter:toggleRouter});
  });

  it('works correctly with old algorithm', function(){
    // Given
    toggleRouter.setFeature("use-new-SR-algorithm",false);

    // When
    const result = simulationEngine.doSomethingWhichInvolvesSplineReticulation();

    // Then
    verifySplineReticulation(result);
  });

  it('works correctly with new algorithm', function(){
    // Given
    toggleRouter.setFeature("use-new-SR-algorithm",true);

    // When
    const result = simulationEngine.doSomethingWhichInvolvesSplineReticulation();

    // Then
    verifySplineReticulation(result);
  });
});
```

### 출시 준비 중

시간이 좀 더 흐르고 팀은 새로운 알고리즘이 잘 동작한다고 믿어서, 정말 잘 동작하는지 확인하기 위해 피쳐를 끄거나 켠 상태로 시스템을 실행하고, 모든게 예상대로 작동하는지 확인하기 위해 수동 테스트도 실행할 수 있기를 원했다. 

아직 검증되지 않은 피쳐를 프로덕션 환경에서 수동 테스트로 확인하고 싶으면, 프로덕선 환경에서 일반 유저를 대상으로는 피쳐를 끄고 내부 유저 대상으로는 켤 수 있어야 한다. 이걸 위한 다양한 방법이 있다.

- Toggle Router가 **토글 설정(Toggle Configuration)**을 기반으로 결정(decisions)을 내리게 하고, 해당 설정을 환경에 맞게 만든다. 그리고 Pre-production 환경에서만 새 피쳐를 켠다.
- 어드민 UI를 통해 런타임에 토글 설정(Toggle Configuration)을 수정할 수 있도록 만들고, 테스트 환경에서 새 피쳐를 켠다.
- Toggle Router가 요청 전에 HTTP 헤더나 쿠키 같은 **Toggle Context**를 고려해서 토글링 결정을 동적으로 하게 만든다. 여기서 Toggle Context는 요청하는 사용자를 식별하기 위한 프록시 역할을 한다.

![toggle-router](/images/2022/10/15/toggle-router.png "toggle-router"){: .center-image }

팀은 높은 유연성을 가져가기 위해 요청당 Toggle Router를 사용하기로 결정했다. 이를 통해 별도의 테스트 환경 없이 새로운 알고리즘을 테스트할 수 있었다. 대신에 프로덕션 환경에서 내부 사용자에게만 알고리즘을 켤 수 있다(특수한 쿠키를 사용). 이 쿠키를 이용해서 새로운 피쳐가 원하는대로 잘 동작하는지 확인할 수 있었다.

### 카나리 릴리즈

새로운 알고리즘이 좋아보이지만, 알고리즘은 엔진의 매우 중요한 부분이라서 모든 사용자에게 이 피쳐를 켜는데 약간의 주저함이 생겼다. 팀은 피쳐 플래그 인프라를 사용하여 [**Canary Release**](https://martinfowler.com/bliki/CanaryRelease.html)를 수행하기로 결정하고, 전체 사용자 대비 아주 작은 비율인 \"Canary\" 그룹에 대해서만 새로운 피쳐를 적용하기로 했다.

팀은 항상 켜진 피쳐나 꺼진 피쳐를 지속적으로 경험하는 사용자 그룹의 개념을 알게 되면서 Toggle Router를 강화시켰다. Canary 그룹은 UserId를 modulo 연산한 결과인 사용자 1%를 무작위로 샘플링하여 생성했다. 이 Canary 그룹은 지속적으로 피쳐가 켜진 상태로 있고, 나머지 99%의 사용자는 이전 알고리즘이 적용된다. 새 알고리즘이 사용자 액션에 부정적인 영향을 미치지 않는다는걸 확인하기 위해 두 그룹을 모니터링하고, 새 피쳐가 영향이 없다고 판단되면 전체 사용자를 대상으로 피쳐를 켜기 위해 토글 설정을 수정한다.

### A/B 테스팅

팀의 Product Manager가 이 메커니즘을 사용해서, 범죄율 알고리즘과 게임 플레이 능력의 증감 관계에 대한 A/B 테스트를 해보면 어떻겠냐고 제안했다. 그 결과 데이터를 기반으로 논쟁을 해결할 수 있게 되었다. 피쳐 플래그로 아이디어의 본질을 찾는 계획도 생각해내고, 많은 유저 그룹에 대해 피쳐를 켠 다음 해당 사용자가 다른 그룹과 비교해서 어떻게 행동하는지도 연구했다. 이런 접근 방식을 통해 팀은 [HiPPO](https://www.forbes.com/sites/derosetichy/2013/04/15/what-happens-when-a-hippo-runs-your-company/?sh=3741443540cf)가 아닌 데이터를 기반으로 제품에 대한 토론을 이어갈 수 있었다.

이 간단한 시나리오는 Feature Toggling 컨셉의 기본 개념을 설명할 뿐만 아니라, 다양한 사례를 강조하기 위한 것이다. 이제 이런 애플리케이션의 몇 가지 예를 봤으니, 다양한 토글 카테고리를 살펴보고 무엇이 다른지 살펴보자. 유지 보수가 좋은 토글 코드를 작성하는 방법을 다루고, 마지막으로 Feature Toggle 시스템의 합정을 피하기 위한 방법도 공유하겠다.

---

# 토글 카테고리

피쳐 토글이 제공하는 기본적인 기능을 살펴보았다. 하나의 배포 단위 내에서 취할 수 있는 서로 다른 CodePath를 제공하고, 런타임에 둘 중 하나를 선택할 수 있었다. 위에서 살펴본 시나리오는 이 기능이 다양한 컨텍스트에서 다양한 방식으로 사용될 수 있음을 보여주었다. 모든 피쳐 토글을 동일한 버킷으로 묶고 싶을 수 있지만, 이건 위험한 방법이다. 다양한 토글 카테고리에 작용하는 설계 요소는 상당히 다르며, 모두 같은 방식으로 관리하면 어려움을 겪을 수 있다.

### 릴리즈 토글(Release Toggles)

> 릴리즈 토글을 사용하면 불완전하고 테스트되지 않은 코드를 절대 켜지지 않는, 숨어있는 코드 상태로 프로덕션에 배포할 수 있다.

이는 Continuous Delivery를 실행하는 팀을 위해 Trunk 기반 개발을 활성화하는데 사용되는 피쳐 플래그다. 이를 통해 진행 중인 피쳐를 통합 브랜치(예. main, trunk, master)에 체크인 할 수 있으며 해당 브랜치를 언제든지 프로덕션에 배포할 수 있다. 릴리즈 토글을 사용하면 불완전하고 테스트되지 않은 코드를 절대 켜지지 않는, 숨어있는 코드 상태로 프로덕션에 배포할 수 있다.

같은 방법으로 이제 Product Manager는 절반만 완성된 피쳐를 최종 사용자에게 노출되는걸 방지할 수 있다. 예를 들어, 전자 상거래 사이트에서 배송 파트너 중 하나에 대해서만 동작하는 새로운 예상 배송 날짜 기능을 사용자에게 표시하지 않고, 모든 배송 파트너에 대해 해당 기능이 구현될 때까지 기다리는걸 선호할 수 있다. 아니면 기능이 완전히 구현되고 테스트도 되었는데 노출을 원하지 않는 다른 이유가 있을 수 있다. 예를 들어, 릴리즈가 마케팅 캠패인과 함께 엮여있다던지. 이런 방식으로 릴리즈 토글을 사용하는게 \"[코드] 배포에서 [피쳐] 릴리즈를 분리\" 하는 Continuous Delivery 원칙을 구현하는 가장 일반적인 방법이다.

![release-toggles](/images/2022/10/15/release-toggles.png "release-toggles"){: .center-image }

Product에서 사용되는 릴리즈 토글이면 좀 더 오랜 기간동안 유지되어야 할 수도 있지만, 일반적으로 릴리즈 토글은 1~2주 이상 지속되지 않아야 한다. 그래서 릴리즈 토글은 본질적으로 과도기적이다. 릴리즈 토글에 대한 토글 결정은 일반적으로 매우 정적이다. 주어진 릴리즈 버전에 대한 모든 토글 결정은 같고, 새 릴리즈를 출시하려면 토글 설정을 변경해서 해당 토글 결정도 변경하면 된다.

### 실험 토글(Experiment Toggles)

실험 토글은 독립된 몇 개의 변수나 A/B 테스트를 수행하는데 사용된다. 시스템의 각 사용자는 그룹(cohort)에 배치되고, 런타임에 토글 라우터는 사용자를 그들이 속한 그룹에 따라 특정 코드 또는 다른 코드로 일관되게 분기시킨다. 다른 그룹의 집계 동작을 추적함으로써 다른 CodePath의 효과를 비교할 수 있다. 일반적으로 전자상거래 시스템의 구매 흐름이나 버튼의 클릭 유도문과 같은 항목에 대한 데이터 기반 최적화를 수행하는데 사용된다.

![experiment-toggles](/images/2022/10/15/experiment-toggles.png "experiment-toggles"){: .center-image }

실험 토글은 통계적으로 유의미한 결과를 생성할 수 있을 만큼 오랫동안 동일한 설정으로 유지되어야 한다. 트래픽 패턴에 따라 몇 시간 또는 몇 주가 걸릴 수 있다. 시스템에 대한 다른 변경으로 인해 실험 결과가 무효화될 수 있기 때문에 장기간은 유용하지 않을 수 있다. 각 요청은 다른 사용자를 대신할 수 있으므로 마지막 요청과 다르게 라우팅될 수 있다. 그래서 실험 토글은 본질적으로 매우 동적이다.

### 운영 토글(Ops Toggles)

이 플래그는 시스템 동작의 운영 측면을 제어하는데 사용된다. 시스템 운영자가 성능을 저하시키거나 문제가 있을만한 피쳐를 Degrade 시키거나 비활성화할 수 있는 기능이다.

대부분의 Ops 토글은 상대적으로 수명이 짧다. 새로운 피쳐의 운영에 대한 확신이 생기면 플래그를 삭제한다. 그러나 시스템에 수명이 긴 \"Kill Switches\" 수가 적은 것은 드문 일이 아니다. 예를 들어, 홈페이지에 로드가 많을때 생성 비용이 많이 드는 추천 패널을 비활성화할 수 있다. 수요가 많은 제품을 출시하기 직전에, 웹사이트의 주요 구매 흐름에서 중요하지 않은 기능을 의도적으로 비활성화할 수 있는 Ops 토글을 유지하는 온라인 소매 업체와도 상담했었다. 이런 수명이 긴 Ops 토글은 수동으로 관리되는 [Circuit Breaker](https://martinfowler.com/bliki/CircuitBreaker.html)라고도 볼 수 있다.

![ops-toggles](/images/2022/10/15/ops-toggles.png "ops-toggles"){: .center-image }

이미 언급했듯이 이러한 플래그 중 다수는 잠시 동안만 사용되지만, 몇 가지 주요 제어 기능은 운영자를 위해 거의 무기한으로 남아 있을 수 있다.이 플래그의 목적은 관리자가 프로덕션 문제에 신속하게 대응할 수 있도록 하는 것이므로 매우 빠르게 재설정될 필요가 있다. Ops 토글을 다루기 위해 새 릴리즈를 배포해야 되는건 관리자 입장에서 행복하지 않은 일이다.

### 권한 토글(Permissioning Toggles)

이 플래그는 특정 사용자가 받는 피쳐나 Product 경험을 바꾸는게 사용된다. 예를 들어, 유료 고객에 대해서만 토글하는 "Premium" 피쳐 세트를 가지고 있을 수 있다. 또는 내부 사용자만 사용할 수 있는 “Alpha” 피쳐 셋트와 내부 사용자와 베타 사용자만 사용할 수 있는 “Beta” 피쳐 세트가 있을 수 있다. 내부 또는 베타 사용자 그룹만을 위해 새로운 피쳐를 켜는 기술을 샴페인 브런치(Champagne Brunch)라고 한다(“자신의 샴페인을 마실 수 있는” 초기 기회). 

샴페인 브런치는 카나리 릴리즈(Canary Release)와 비슷한 면이 많다. 둘의 차이점은 카나리 릴리즈 피쳐는 무작위로 선택된 사용자 그룹에 노출되는 반면, 샴페인 브런치 피쳐는 특정 사용자 그룹에 노출된다.

![permissioning-toggles](/images/2022/10/15/permissioning-toggles.png "permissioning-toggles"){: .center-image }

프리미엄 사용자에게만 노출시키기 위해 사용하는 경우, 권한 토글은 피쳐 토글의 다른 카테고리에 비해 수명이 매우 길 수 있다(여러 해의 규모로). 권한은 사용자별로 다르기 때문에 권한 토글 결정은 항상 요청 별로 이루어지고, 매우 동적인 토글이다.

### 다양한 토글 카테고리 관리

이제 토글 분류 체계가 있으므로 동적임(Dynamism)과 수명(Longevity)이 서로 다른 카테고리의 피쳐 플래그를 사용하는 방식에 어떤 영향을 미치는지 이야기할 수 있다.

**static vs dynamic toggles**

![static-dynamic-toggles](/images/2022/10/15/static-dynamic-toggles.png "static-dynamic-toggles"){: .center-image }

런타임 라우팅 결정을 내리는 토글에는 해당 라우터에 대한 보다 복잡한 구성과 함께 더 정교한 토글 라우터가 필요하다.

단순한 정적 라우팅 결정의 경우, 토글 설정은 토글 라우터가 있는 각 기능에 대해 단순한 On/Off가 될 수 있으며, 토글 라우터는 해당 정적 On/Off 상태를 토글 포인트로 릴레이하는 역할만 한다. 앞서 논의한 것처럼 다른 토글 카테고리는 더 동적이고 더 정교한 토글 라우터를 필요로 한다. 예를 들어, 실험 토글의 라우터는 해당 사용자의 ID를 기반으로 하는 일관된 코호트 알고리즘을 사용하여 주어진 사용자에 대해 동적으로 라우팅 결정을 내린다. 설정에서 정적 토글 상태를 읽는 대신, 이 토글 라우터는 실험 집단 및 비교 집단이 얼마나 커야 하는지와 같은 것을 정의하는 일종의 코호트 설정을 읽어야 한다. 이 설정은 코호트 알고리즘에 대한 입력으로 사용된다.

**Long-lived toggles vs transient toggles**

![long-lived-transient-toggles](/images/2022/10/15/long-lived-transient-toggles.png "long-lived-transient-toggles"){: .center-image }

또한 토글 카테고리를 일시적인 것과 오래 지속되고 몇 년 동안 제자리에 있을 수 있는 것으로 나눌 수 있다. 이 구분은 피쳐의 토글 포인트를 구현하는 방법에 영향을 미친다. 며칠 후 제거될 릴리즈 토글을 추가하는 경우, 토글 라우터에서 간단한 if/else 토글 포인트로 가능하다. 이건 이전에 이건 이전에 reticulation 예제에서 본 방법이다.

```javascript
function reticulateSplines(){
  if( featureIsEnabled("use-new-SR-algorithm") ){
    return enhancedSplineReticulation();
  }else{
    return oldFashionedSplineReticulation();
  }
}
```

그러나 권한 토글처럼 오랫동안 유지될 것으로 예상되는 토글 포인트를 만든다면, 무차별적으로 if/else 구문을 뿌려서 구현하고 싶지는 않다. 유지 보수가 좋은 다른 구현 기술을 더 사용해야 한다.

---

# 구현 기법

피쳐 플래그는 지저분한 토글 포인트 코드를 만드는 걸로 보이고, 이러한 토글 포인트도 코드 베이스 전체에 확산되는 경향이 있다. 코드베이스의 피쳐 플래그에 대해 이런 경험을 확인하는건 중요하며, 플래그가 오래 지속되는 경우에는 더 중요하다. 이런 문제를 줄이는데 도움되는 몇 가지 구현과 관행이 있다.

### 결정 로직에서 결정 지점 분리하기(De-coupling decision points from decision logic)

피쳐 토글을 사용하면서 겪는 일반적인 실수 중 하나는 토글 결정이 내려지는 위치(Toggle Point)와 결정 뒤에 있는 로직(Toggle Router)에 결합(Couple)을 만드는 것이다. 차세대 전자 상거래 시스템을 개발한다고 가정 해보자. 사용자가 주문 확인 이메일(invoice email) 내의 링크를 클릭하여 주문을 쉽게 취소할 수 있는 새롤운 피쳐를 추가하려고 한다. 피쳐 플래그를 사용해서 모든 차세대 기능의 배포를 관리하고 있고, 초기 피쳐 플래그 구현은 다음과 같다.

```javascript
// ivoiceEmailer.js
const features = fetchFeatureTogglesFromSomewhere();

function generateInvoiceEmail(){
  const baseEmail = buildEmailForInvoice(this.invoice);
  if( features.isEnabled("next-gen-ecomm") ){ 
    return addOrderCancellationContentToEmail(baseEmail);
  }else{
    return baseEmail;
  }
}
```

인보이스 이메일을 생성하는 동안 InvoiceEmailer는 `next-gen-ecomm` 피쳐가 활성화되어 있는지 확인한다. 활성화 되어 있다면 InvoiceEmailer는 이메일에 주문 취소 콘텐츠를 추가한다. 

이건 괜찮은 방법처럼 보이는데 사실 매우 취약하다. 인보이스 이메일에 주문 취소 기능을 포함할지 여부에 대한 결정은 매직 스트링(`next-gen-ecomm`)을 통해 피쳐에 직접 연결된다. 인보이스 메일링 코드 입장에서 주문 취소 콘텐츠가 차세대 피쳐의 일부임을 알아야 하는 이유는 뭘까? 주문 취소를 노출하지 않고 차세대 피쳐의 일부를 켜고 싶다면 어떻게 할까? 혹은 그 반대로? 아니면 특정 사용자에게만 주문 취소 기능을 적용하기로 결정하면 어떻게 할까? 이런 종류의 \"토글 범위(Toggle Scope)\" 수정은 기능이 개발될 때 발생하는 것이 일반적이다. 또한 이러한 토글 포인트는 코드 베이스 전반에 걸쳐 확산되는 경향이 있음을 명심하자. 토글 결정 로직은 토글 포인트의 일부이기 때문에, 현재 접근 방식을 사용했을때 결정 로직을 변경하려면 코드베이스를 통해 퍼진 모든 토글 포인트를 트롤링해야 한다.

다행히 소프트웨어의 모든 문제는 간접 계층을 추가하여 해결할 수 있다. 다음과 같이 결정 뒤에 있는 로직에서 토글 결정 포인트를 분리할 수 있다.

```javascript
// featureDecisions.js
function createFeatureDecisions(features){
  return {
    includeOrderCancellationInEmail(){
      return features.isEnabled("next-gen-ecomm");
    }
    // ... additional decision functions also live here ...
  };
}

// invoiceEmailer.js
const features = fetchFeatureTogglesFromSomewhere();
const featureDecisions = createFeatureDecisions(features);

function generateInvoiceEmail(){
  const baseEmail = buildEmailForInvoice(this.invoice);
  if( featureDecisions.includeOrderCancellationInEmail() ){
    return addOrderCancellationContentToEmail(baseEmail);
  }else{
    return baseEmail;
  }
}
```

피쳐 토글 결정 로직을 수집하는 역할을 하는 FeatureDecisions 객체를 도입했다. 그리고 각 토글링 결정에 대한 결정 메서드를 이 객체에 추가한다. 이 경우 \"인보이스 이메일에 주문 취소 기능을 포함해야 하나요?\"는 includeOrderCancellationInEmail 결정 메서드로 표현된다. 현재 \"로직\" 이라는 결정은 `next-gen-ecomm` 피쳐의 상태를 확인하기 위한 사소한 절차이지만, 이제 해당 로직이 발전함에 따라 이를 관리할 단일 저장소가 생겼다. 특정 토글 결정의 로직을 수정하고 싶을 때마다 참고해야 할 곳은 한 곳이다. 예를 들어, 결정을 제어하는 특정 피쳐 를래그와 같이 결정의 범위를 수정할 수 있다. 또는 정적 토글 설정에서 A/B 테스트로 바꾸거나, 일부 주문 취소 인프라의 중단과 같은 운영상의 문제로 인해 결정 이유를 수정해야 할 수도 있다. 모든 경우에 InvoiceEmailer는 토글링 결정이 내려지는 방법 또는 이유를 전혀 모르고 있을 수 있다.

### Inversion of Decision

이전 예제에서 InvoiceEmailer는 피쳐 플래그 인프라가 어떻게 동작하는지 알아야 했다. 이건 InvoiceEmailer가 추가 개념인 “피쳐 플래그”와 이에 연결된 추가 모듈이 결합되어 있음을 의미한다. 이로 인해 InvoiceEmailer 테스트를 더 어렵게 만드는 것에 더해, 격리된 환경에서 작업하고 생각하기가 더 어려워졌다. 피쳐 플래깅(Feature Flagging)은 시간이 지남에 따라 시스템에 점점 더 널리 퍼지는 경향이 있으므로, 점점 더 많은 모듈이 피쳐 플래그 시스템에 종속적으로 결합되는걸 보게 될 것이다. 이건 이상적인 시나리오가 아니다.

소프트웨어 설계에서 우리는 종종 Inversion Of Control을 적용하여 이런 결합 문제를 해결한다. 피쳐 플래그 인프라에서 InvoiceEmailer를 분리하는 방법은 다음과 같다.

```javascript
// invoiceEmailer.js
function createInvoiceEmailler(config){
  return {
    generateInvoiceEmail(){
      const baseEmail = buildEmailForInvoice(this.invoice);
      if( config.includeOrderCancellationInEmail ){
        return addOrderCancellationContentToEmail(email);
      }else{
        return baseEmail;
      }
    },

    // ... other invoice emailer methods ...
  };
}

// featureAwareFactory.js
function createFeatureAwareFactoryBasedOn(featureDecisions){
  return {
    invoiceEmailler(){
      return createInvoiceEmailler({
        includeOrderCancellationInEmail: featureDecisions.includeOrderCancellationInEmail()
      });
    },

    // ... other factory methods ...
  };
}
```

이제 InvoiceEmailer가 FeatureDecisions에 접근하는 대신, Construction time에 주입된 Config 객체를 통해 결정을 한다. InvoiceEmailer는 이제 피쳐 플래그 지정에 대해 전혀 알지 못한다. 동작의 일부가 런타임에 설정될(configured) 수 있다는 것만 알고 있다. 이렇게 하면 InvoiceEmailer의 동작을 더 쉽게 테스트할 수 있다. 테스트 중에 다른 설정 옵션을 전달함으로써, 주문 취소 콘텐츠가 있거나 없는 이메일 생성 방식을 테스트할 수 있다.

```javascript
describe( 'invoice emailling', function(){
  it( 'includes order cancellation content when configured to do so', function(){
    // Given 
    const emailler = createInvoiceEmailler({includeOrderCancellationInEmail:true});

    // When
    const email = emailler.generateInvoiceEmail();

    // Then
    verifyEmailContainsOrderCancellationContent(email);
  };

  it( 'does not includes order cancellation content when configured to not do so', function(){
    // Given 
    const emailler = createInvoiceEmailler({includeOrderCancellationInEmail:false});

    // When
    const email = emailler.generateInvoiceEmail();

    // Then
    verifyEmailDoesNotContainOrderCancellationContent(email);
  };
});
```

주입된 객체로 결정을 만드는걸 중앙 집중화하기 위해 FeatureAwareFactory를 추가했다. 일반적인 Dependency Injection 패턴을 응용한 것이다. 만약 DI 시스템이 코드베이스에서 작동하고 있다면, 이 방식을 구현하기 위해 이 시스템을 사용할거다.

### 조건문 피하기

지금까지 예제에서 토글 포인트는 if문을 사용하여 구현했다. 이것은 간단하고 수명이 짧은 토글에 적합하다. 그러나 피쳐에 여러 토글 포인트가 필요하거나 토글 포인트가 오래 지속될 것으로 예상되는 곳에서는 포인트 조건(Point Conditional)을 권장하지 않는다. 좀 더 유지 보수가 좋은, 일종의 전략 패턴(Strategy Pattern)을 사용하여 대체할 수 있는 CodePath를 구현한 예제다.

```javascript
// invoiceEmailler.js
function createInvoiceEmailler(additionalContentEnhancer){
  return {
    generateInvoiceEmail(){
      const baseEmail = buildEmailForInvoice(this.invoice);
      return additionalContentEnhancer(baseEmail);
    },
    // ... other invoice emailer methods ...

  };
}

// featureAwareFactory.js
function identityFn(x){ return x; }

function createFeatureAwareFactoryBasedOn(featureDecisions){
  return {
    invoiceEmailler(){
      if( featureDecisions.includeOrderCancellationInEmail() ){
        return createInvoiceEmailler(addOrderCancellationContentToEmail);
      }else{
        return createInvoiceEmailler(identityFn);
      }
    },

    // ... other factory methods ...
  };
}
```

여기에서는 인보이스 이메일을 콘텐츠 enhancer 함수를 설정할 수 있도록 전략 패턴을 적용하고 있다. FeatureAwareFactory는 FeatureDecision에 따라 InvoiceEmailer를 생성할 때 전략을 선택합니다. 주문 취소가 이메일에 있어야 하는 경우 해당 콘텐츠를 이메일에 추가하는 enhancer 함수를 전달하고, 그렇지 않으면 효과가 영향(Effect)이 없고 수정 없이 이메일을 발송하는 `identityFn` enhancer를 전달한다.

---

# 토글 설정(Toggle Configuration)

### 동적 라우팅 vs. 동적 설정

코드 배포를 통한 정적인 플래그와 런타임에 동적으로 결정하는 두 가지로 피쳐 플 나누어 보았다. 플래그의 결정이 런타임에 변경될 수 있다는 두 가지 방법이 있다는 점에 유의해보자. 첫째, Ops Toggle과 같은건 시스템 중단에 대한 대응으로 ON에서 OFF로 동적으로 재설정될 수 있다. 둘째, 권한 토글(Permissioning Toggle)과 실험 토글(Experiment Toggle) 같은건 요청하는 사용자와 같은 일부 요청 컨텍스트를 기반으로 각 요청에 대한 라우팅 결정을 동적으로 한다. 전자는 재설정(re-configuration)을 통한 동적이고, 후자가 본질적으로 동적이다. 본질적으로 동적인 토글은 동적인 **결정(decisions)**을 내릴 수 있지만, 여전히 정적이며 재배포(re-deploymeny)를 통해서만 변경할 수 있는 **설정(configuration)**을 가지고 있다. 실험 토글이 이런 유형의 피쳐 플래그다. 런타임에 실험 매개변수를 수정할 필요가 없다. 실제로 그렇게 하면 실험이 통계적으로 무효가 될 수 있습니다.

### 정적인(static) 설정을 선호

피쳐 플래그의 특성이 허용한다면, Source Control 및 재배포를 통해서 토글 설정을 관리하는게 나을 수 있다. Source Control을 통해 토글 설정을 관리하면 IaC(Infrastructure As Code)처럼 Source Control를 사용하여 얻는 것과 동일한 이점을 얻을 수 있다. 토글 설정이 퇴글 되는 코드베이스와 함께 유지될 수 있어서 좋다. 토글 설정은 코드 변경이나 인프라 변경과 똑같은 방식으로 Continuous Delivery 파이프라인을 통해 이동한다. 이를 통해 모든 환경 전반에 걸쳐 일관된 방식으로 검증되는 반복 가능한 빌드인 CD의 모든 이점도 누릴 수 있다. 또한 피쳐 플래그의 테스트 부담을 덜어준다. 해당 시점의 상태가 릴리즈로 나오고(baked) 변경되지 않기 때문에, 토글 ON/OFF 상태에서 릴리즈가 어떻게 동작할 지 고민을 덜 해도 된다. Source Control에서 나란히 있는 토글 설정의 또 다른 이점은 이전 릴리즈에서 토글 상태를 쉽게 볼 수 있고, 필요한 경우 이전 릴리즈를 쉽게 다시 만들 수 있다는 점이다.

### 토글 설정을 관리하기 위한 방법

정적인 설정이 나을 수 있지만, 더 동적인 접근 방식이 필요한 Ops Toggle과 같은 경우가 있다. 단순하지만 덜 동적인 접근 방식부터 고도로 정교하면서 많은 복잡성이 수반되는 방법에 이르기까지 토글 설정을 관리하기 위한 몇 가지 옵션을 살펴보겠다.

### 하드코딩된 토글 설정

피쳐 플래그로 간주되지 않을 정도로 기본적인 가장 기본적인 기술은 단순히 코드 블록에 주석을 달거나 주석을 해제하는 것이다. 예를 들어,

```javascript
function reticulateSplines(){
  //return oldFashionedSplineReticulation();
  return enhancedSplineReticulation();
}
```

주석 처리 방식보다 약간 더 정교한 것은 가능한 경우 전처리기의 \#ifdef 기능을 사용하는 것이다.

이런 유형의 하드코딩은 토글의 동적 재설정을 허용하지 않기 때문에 플래그를 재설정하기 위해 코드 배포 패턴을 따르려는 피쳐 플래그에만 적합하다.

### 매개변수화된 토글 설정

하드코딩 설정의 빌드 타임 설정(build-time configuration)은 테스트 시나리오를 포함하여 다양한 UseCase에 대해 유연하지 않다. 앱이나 서비스를 다시 빌드하지 않고도 피쳐 플래그를 다시 설정할 수 있는 간단한 방법은 커맨드 라인 인자(command-line argument) 또는 환경 변수(environment variables)를 통해 토글 설정을 지정하는 것이다. 이건 Feature Toggling 또는 Feature Flagging 이라는 기술을 언급한 사람이 있기 훨씬 이전부터 사용되어 온 토글링에 대한 간단한 방법인데, 한계가 있다. 수많은 프로세스에 걸쳐 설정을 조정하는 것이 어려울 수 있고, 토글 설정을 변경하려면 재배포 또는 최소한 프로세스 재시작이 필요하다.

### 토글 설정 파일

또 다른 옵션은 일종의 구조화된 파일에서 토글 설정을 읽는 것이다. 토글 설정에 대한 이 접근 방식은 애플리케이션 설정 파일의 일부로 시작하는 것이 일반적이다.

토글 설정 파일을 사용하면 애플리케이션 코드 자체를 다시 빌드하지 않고 해당 파일을 변경하여 피쳐 플래그를 다시 설정할 수 있다. 그러나 대부분의 경우 피쳐를 토글하기 위해 앱을 다시 빌드할 필요는 없지만, 플래그를 다시 설정하기 위해 다시 배포해야 할 수도 있다.

### DB에 토글 설정

특정 규모에 도달하면 정적 파일을 사용하여 토글 설정을 관리하는 것이 번거로울 수 있다. 파일을 통해 설정을 수정하는 것은 까다로운 편이다. 서버 플릿 전체에서 일관성을 보장하는 것은 어려운 일이고, 일관되게 변경하는 것은 훨씬 더 어렵다. 이를 위해 많은 조직에서는 토글 설정을 중앙 집중화된 저장소(애플리케이션 DB)로 옮겼다. 일반적으로 시스템 운영자, 테스터 및 Product Manager가 피쳐 플래그와 해당 설정을 보고 수정할 수 있도록 하는 관리 UI 빌드가 필요하다.

### 분산된 토글 설정

시스템 아키텍처의 일부인 DB에 토글 설정을 저장하는건 일반적인 방법이다. 피쳐 플래그가 도입되고 관심을 끌기 시작하면 분명히 선택할 것이다. 그러나 요즘에는 계층적인 Key-Value 저장소를 제공하는 서비스인 Zookeeper, etcd 또는 Consul 등을 이용해서 애플리케이션 설정 값을 관리할 수 있다. 이러한 서비스는 클러스터에 연결된 모든 노드에 대한 환경 설정을 제공하는 분산 클러스터를 형성한다. 설정은 필요할 때마다 동적으로 수정할 수 있으며, 클러스터의 모든 노드에 변경 사항이 자동으로 통보된다. 이건 매우 편리한 기능이다. 이런 시스템을 사용하여 토글 설정을 관리한다는 것은 전체 플릿에 걸쳐 조정된 토글 설정을 기반으로 결정을 내리는 플릿의 모든 노드에서 토글 라우터를 가질 수 있음을 의미한다.

이런 시스템 중 일부(Consul 같은)는 토글 설정을 관리할 수 있는 어드민 UI도 함께 제공한다. 그러나 어느 시점에 토글 설정을 관리하기 위한 커스텀한 어드민용 앱이 만들어질거다.

### 설정 오버라이딩

지금까지 모든 설정이 단일 매커니즘에 의해 제공된다고 가정했다. 현실의 많은 시스템은 다양한 소스에서 오는 설정 계층을 오버라이딩하면서 더 정교해진다. 토글 설정을 사용하면 환경별 오버라이딩과 함께 기본 설정을 갖는 것이 일반적인 방법이다. 일반적으로 토글 설정은 환경별 오버라이딩과 함께 기본 설정을 가진다. 이런 오버라이딩은 추가 설정 파일과 같은 단순한 것 또는 Zookeeper 클러스터와 같은 정교한 것으로부터 될 수 있다. 환경별 오버라이딩은 delivery pipeline 전체에 걸쳐 정확히 동일한 비트와 configuration flow를 유지하는 Continuous Delivery 이상에 반하는 동작이다. 종종 실용주의에서는 환경별 오버라이딩이 사용되도록 가이드 하지만, 배포 가능한 단위와 설정을 가능한 한 환경에 구애받지 않는 상태로 유지하려고 노력하면 더 간단하고 안전한 파이프라인으로 이어질 것이다. 피쳐 토글 시스템 테스트에 대해 이야기할 때 이 주제를 살펴보겠다.

**사전 요청 오버라이딩**

환경별 설정 오버라이딩에 대한 다른 접근 방법은 쿠키, 쿼리 파라미터 또는 HTTP 헤더를 통해 요청 별로 토글의 ON/OFF 상태를 오버라이딩 하는 것이다. 이건 전체 설정 오버라이딩에 비해 몇 가지 장점이 있다. 서비스가 로드 밸런싱된 경우 히트된 서비스 인스턴스에 관계없이 오버라이딩이 적용되는걸 확신할 수 있다. 또한 다른 사용자에게 영향을 주지 않고 프로덕션 환경에서 피쳐 플래그를 오버라이딩 할 수 있으며, 실수로 한 오버라이딩을 롤백할 가능성이 적다. 요청별 오버라이딩 메커니즘이 persistent cookie를 사용하는 경우, 시스템을 테스트하는 누군가가 자신의 브라우저에 일관되게 적용된 상태로 유지되는 고유한 토글 오버라이딩 세트를 설정할 수 있다. 

이 요청별 접근 방식은 악의적인 사용자가 피쳐 토글 상태를 스스로 수정할 수 있는 위험이 있다. 일부 조직에서는 출시하지 않은 기능이 충분히 결정된 당사자가 공개적으로 액세스할 수 있다는 생각에 꺼려 할 수 있다. 오버라이딩 설정에 암호로 서명하는 것은 이 문제를 완화하는 한 가지 옵션이지만, 이 방법과 관계없이 피쳐 토글 시스템의 복잡성이 증가한다.

---

# Working with feature-flagged systems

피쳐 토글은 유용한 기술인데 추가적인 복잡성도 가져온다. 피쳐 플래그가 지정된 시스템으로 작업할 때 더 쉽게 하는 데 도움이 되는 몇 가지 기술이 있다.

### 현재 피쳐 토글 설정을 표현하기

빌드/버전 번호를 배포된 아티팩트에 포함하고 해당 메타데이터를 어딘가에 표시해서 개발자, 테스터 또는 운영자가 주어진 환경에서 실행 중인 특정 코드를 찾게 도와주는건 유용한 예시다. 피쳐 플래그에도 동일한 아이디어가 적용되어야 한다. 피쳐 플래그를 사용하는 모든 시스템은 운영자가 토글 설정의 현재 상태를 발견할 수 있는 방법을 표시해야 한다. HTTP-oriented SOA 시스템에서 이건 종종 메타데이터 API endpoint 또는 다른 Endpoint를 통해 이루어진다. 예를 들어, Spring Boot의 [Actuator endpoints](http://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-endpoints.html)를 살펴봐라.

### 구조화된 토글 설정 파일을 활용하기

일반적으로 Source Control을 통해 관리되는 구조화되고 사람이 읽을 수 있는 파일(YAML 등)에 기본 토글 설정을 저장한다. 이 방법에는 몇 가지 이점이 있다. 각 토글에 대해 사람이 읽을 수 있는(human-readable) 설명을 포함하는 것은 특히 core delivery team 보다 다른팀이 관리하는 토글일 때 유용하다. 프로덕션 중단 이벤트 중에 Ops 토글을 활성화할지 여부를 결정할 때 보고 싶은 것은 무엇인가요? 또한 일부 팀은 생성 날짜, 개발자 연락처 또는 기간이 짧은 토글의 만료 날짜와 같은 토글 구성 파일에 추가 메타데이터를 포함하도록 선택한다.

### 토글을 다르게 관리하기

앞서 살펴본 것처럼, 특징이 다른 다양한 카테고리의 피쳐 토글이 있다. 이런 다양한 토글이 같은 기술로 제어된다고 하더라도, 차이점을 알고 토글을 다른 방식으로 관리해야 한다.

이전에 살펴본, 홈페이지에 추천 제품 섹션이 있는 전자 상거래 사이트를 다시 살펴보자. 초기 개발 단계에 릴리즈 토글 뒤에 해당 섹션을 배치했을 수 있다. 그런 다음 수익 창출에 도움이 되는지 알아보기 위해 실험 토글(Experiment Toggle) 뒤에 배치할 것이다. 마지막으로 극도의 부하를 받았을 때 피쳐를 끌 수 있도록 Ops Toggle 뒤로 옮길 것이다. 토글 포인트에서 결정 로직을 디커플링하는 조언을 따랐다면, 토글 카테고리에서의 이러한 차이가 토글 포인트 코드에 전혀 영향을 미치지 않았을 것이다.

그러나 피쳐 플래그 관리 관점에서 이러한 전환(transitions)은 영향을 미친다. 릴리즈 토글에서 실험 토글로 전환하는 과정에서 토글이 설정되는 방식이 변경되고, Source Control의 yaml 파일이 아닌 어드민 UI로 이동할 가능성이 높다. 이제 개발자가 아닌 제품 담당자가 설정을 관리할 것이다. 마찬가지로 실험 토글에서 Ops Toggle로의 전환은 토글이 설정되는 방식, 설정이 어디에 있는지, 설정을 관리하는 사람이 누구인지 등 또다른 변화를 의미한다.

### 피쳐 토글은 유효성 검사에 복잡성을 가져온다

피쳐 플래그가 지정된 시스템을 사용하면 특히 테스트와 관련하여 Continuous Delivery 프로세스가 더 복잡해진다. CD 파이프라인을 통해 이동할 때 동일한 아티팩트에 대해 여러 코드 경로를 테스트해야 하는 경우가 많다. 이유를 설명하기 위해, 토글이 켜져 있는 경우 최적화된 새로운 세금 계산 알고리즘을 사용하고, 꺼져있는 경우에 기존 알고리즘을 사용하는 시스템을 출시한다고 상상해보자. 배포 가능한 아티팩트가 CD 파이프라인을 통해 이동할 때 우리는 토글이 프로덕션의 어느 시점에서 ON/OFF로 설정될 지 알 수 없다. 이게 피쳐 플래그의 요점이다. 따라서 프로덕션 환경에서 모든 코드 경로의 유효성을 검사하려면 토글을 ON/OFF로 전환한 상태에서 아티팩트 테스트를 해야 한다.

![feature-toggles-testing](/images/2022/10/15/feature-toggles-testing.png "feature-toggles-testing"){: .center-image }

하나의 토글을 사용하면 최소한 테스트를 두 배로 늘려야 할 수 있다. 여러 토글을 사용하면 각 토글 상태가 조합적으로 증가한다. 이런 동작을 검증하는건 엄청난 작업이 될거다. 이건 테스트에 중점을 둔 사람들로부터 피쳐 플래그에 대한 회의론으로 이어질 수 있다.

다행히 상황은 일부 테스터가 처음에 상상하는 것만큼 나쁘지 않다. 피쳐 플래그가 지정된 릴리즈 후보는 몇 가지 토글 설정으로 테스트해야 하지만, 모든 가능한 조합을 테스트할 필요는 없다. 대부분의 피쳐 플래그는 서로 상호작용 하지 않으며, 대부분의 릴리즈에는 둘 이상의 피쳐 플래그 설정 변경이 포함되지 않는다.

> 좋은 컨벤션은 피쳐 플래그가 꺼져 있을 때 기존 또는 레거시 동작을 활성화하고, 켜져 있을 때 새로운 동작을 활성화하는 것이다.

그렇다면 팀에서 테스트해야 하는 피쳐 토글 설정은 뭘까? 프로덕션에서 라이브 될 것으로 예상되는 토글 설정을 테스트하는게 가장 중요하다. 즉, 현재 프로덕션 토글 설정과 해제하려는 모든 토글이 켜짐 상태임을 의미한다. 해제하려는 토글이 꺼진 상태에서 Fallback 설정을 테스트하는 것도 좋다. 향후 릴리즈에서 예기치 않은 회귀(Regression)을 방지하기 위해 많은 팀에서 모든 토글을 켜고 몇 가지 테스트를 수행한다. 이 조언은 피쳐가 꺼져 있을 때 기존 또는 레거시 동작이 활성화되고, 피쳐가 켜져 있을때 새 동작이 활성화되는 토글 시멘틱 컨벤션을 고수하는 경우에만 의미가 있다.

피쳐 플래그 시스템이 런타임 설정을 지원하지 않는 경우, 토글을 뒤집거나 더 나쁘게는 아티팩트를 테스트 환경에 다시 배포하기 위해 테스트 중인 프로세스를 다시 시작해야 할 수도 있다. 이건 검증 프로세스의 cycle time에 나쁜 영향을 미칠 수 있으며, 이는 CI/CD가 제공하는 모든 피드백 루프에도 영향을 미친다. 이 문제를 피해야 되는데, 피쳐 플래그의 동적 인메모리를 재설정할 수 있는 Endpoint를 추가하라. 이런 오버라이딩은 토글의 두 경로를 모두 실행하는 것이 훨씬 더 까다로운 실험 토글과 같은 것을 사용할 때 필요하다.

특정 서비스 인스턴스를 동적으로 재설정하는 이 기능은 매우 날카롭다. 부적절하게 사용하면 공유 환경에서 많은 고통과 혼란을 일으킬 수 있다. 이 기능은 자동화된 테스트에서만 사용해야 하며 수동 탐색 테스트 및 디버깅의 일부로 사용할 수 있다. 프로덕션 환경에서 사용하기 위한 보다 일반적인 목적의 토글 제어 메커니즘이 필요한 경우, 위의 Toggle Configuration 섹션에서 설명한 대로 실제 distributed configuration system을 사용하여 구축하는 것이 가장 좋다.

## 토글을 어디에 배치할까

**끝부분(Edge)에 토글하기**

요청별 컨텍스트(실험 토글, 권한 토글)가 필요한 토글 카테고리의 경우, 서비스의 끝 부분에 토글 포인트를 배치하는게 좋다. 즉, 엔드 유저에게 기능을 제공하는 공개적으로 노출된 웹 앱인 경우. 이건 사용자의 개별 요청이 먼저 도메인에 입력되는 곳이므로, 토글 라우터는 사용자와 그들의 요청을 기반으로 토글 결정을 내리는 데 사용할 수 있는 가장 많은 컨텍스트를 가지고 있다. 토글 포인트를 시스템의 끝부분에 배치할 때 추가적인 이점은 다루기 힘든 조건부 토글 로직을 시스템의 코어에서 벗어나게 한다는 것이다. 다음 Rails 예제와 같이 HTML을 렌더링하는 위치에 토글 포인트를 배치할 수 있다.

```ruby
// someFile.erb
<%= if featureDecisions.showRecommendationsSection? %>
  <%= render 'recommendations_section' %>
<% end %>
```

아직 출시할 준비가 되지 않은 새로운 기능에 대한 엑세세를 제어할 때도 끝부분에 토글 포인트를 배치하는게 의미가 있다. 이 컨텍스트에서 단순히 UI 요소를 표시하거나 숨기는 토글을 사용하여 액세스를 다시 제어할 수 있다. 예를 들어 Facebook을 사용하여 애플리케이션에 로그인하는 기능을 구축 중이지만 아직 사용자에게 롤아웃할 준비가 되지 않았을 수 있다. 이 기능의 구현에는 아키텍처의 다양한 부분이 변경될 수 있지만, \"Facebook으로 로그인\" 버튼을 숨기는 UI 레이어에서 간단한 피쳐 토글을 사용하여 기능의 노출을 제어할 수 있다.

이런 피쳐 플래그 중 일부를 사용하면 릴리즈 되지 않은 기능 자체의 대부분이 실제로 공개적으로 노출될 수 있지만 사용자가 검색할 수 없는 URL에 위치할 수 있다는 점에 주목하는 것이 흥미로웠다.

**코어에 토글하기**

아키텍처 내에서 더 깊숙이 배치해야 하는 다른 유형의 low-level 토글이 있다. 이런 토글은 일반적으로 기술적이며 일부 기능이 내부적으로 구현되는 방식을 제어한다. 예를 들어, 타사 API 앞에서 새로운 캐싱 인프라를 사용할지 아니면 요청을 해당 API로 직접 라우팅할지 여부를 제어하는 릴리즈 토글이 있다. 기능이 토글되는 서비스 내에서 이러한 토글 결정을 현지화하는 것은 이러한 경우에 유일한 합리적인 옵션이다.

## 피쳐 토글의 유지 비용 관리

피쳐 플래그는 특히 처음 도입될 때 빠르게 늘어나는 경향이 있다. 유용하고 큰 비용을 들이지 않고 만들 수 있는데, 유지 비용이 따른다. 코드에 새로운 추상화나 조건부 로직을 추가해야 한다. 그리고 테스트 부담도 초래한다. [Knight Capital Group의 4억 6,000만 달러 실수](https://dougseven.com/2014/04/17/knightmare-a-devops-cautionary-tale/)는 피쳐 플래그를 올바르게 관리하지 않을 때(무엇보다도) 무엇이 잘못될 수 있는지에 대한 경고의 역할을 한다.

잘 아는 팀은 코드베이스의 피쳐 토글을 유지 비용이 수반되는 항목으로 보고, 해당 항목을 가능한 한 낮게 유지하려고 한다. 피쳐 플래그의 수를 관리 가능한 상태로 유지하려면 팀은 더 이상 필요하지 않은 피쳐 플래그를 사전에 제거해야 한다. 일부 팀에는 릴리즈 토글이 처음 도입될 때마다 항상 팀의 백로그에 토글 제거 작업을 추가하는 규칙이 있다. 다른 팀은 토글에 "만료 날짜"를 표시한다. 일부는 피쳐 플래그가 만료 날짜 이후에도 여전히 존재하는 경우, 테스트에 실패하는(또는 애플리케이션 시작을 거부하는) \"시한 폭탄\"을 만들기까지 한다. 또한 이런 항목들을 줄이기 위해 Lean 접근 방식을 적용하여 시스템이 한 번에 가질 수 있는 피쳐 플래그 수를 제한할 수 있다. 누군가가 새 토글을 추가하려는 경우 해당 제한에 도달하면 먼저 기존 플래그를 제거하는 작업을 수행해야 한다.

---

### 참고
- [Feature Toggles (aka Feature Flags)](https://martinfowler.com/articles/feature-toggles.html)
