---
layout: entry
post-category: cold-start-problem
title: 콜드 스타트(The Cold Start Problem)
author-email: ajax0615@gmail.com
description: 기업 가치를 결정짓는 네트워크의 과학(How to Start and Scale Network Effects)
keywords: 콜드 스타트, Cold Start, 창업, 네트워크, 제품
thumbnail-image: /images/profile/cold-start-problem.png
publish: true
---

> 소프트웨어 개발은 점점 쉬워지고 있지만, 새로운 제품과 서비스를 출시하고 확장하는 일은 여전히 어렵습니다. 스타트업은 기술 생태계에 진입할 때 치열한 경쟁, 카피캣, 비효율적인 마케팅 채널 등과 같은 어려운 도전에 직면합니다.<br/>
네트워크 효과(Network Effects)는 제품이나 서비스의 가치가 사용자가 많아질수록 증가하는 현상을 말하며, 새로운 제품이 돌파구를 마련하는 데 중요한 역할을 합니다. 이는 바이럴 성장과 입소문(viral growth and word of mouth)을 통해 새로운 사용자를 유치할 수 있도록 도와줍니다.<br/>
그러나 대부분의 창업가는 네트워크 효과를 설명할 수 있는 개념적 틀이나 맥락을 이해하지 못합니다. 네트워크 효과란 정확히 무엇이며, 어떻게 팀이 이를 구축하고 제품에 적용할 수 있을까요? 모든 플레이어가 네트워크 효과를 활용하는 시장에서 제품은 어떻게 경쟁해야 할까요?

콜드 스타트. 책 제목만 보면 `시작이 어렵다`는 느낌이 든다. 이는 맞는 말이다. 그런데 “시작” 중에서도 사용자 간 연결을 기반으로 한 제품을 만들려 할 때 겪게 될 어려움에 대해 이야기하는 책이다. 스타트업 팀이든 누군가 제품을 만들 때 겪게 될 이런 어려움과 해결 방법들에 대해서 사례 기반으로 알려준다. 

저자인 앤드류 첸(Andrew Chen)에 대해서도 알아두면 좋은데(워낙 유명한 분이라..), a16z(Andreessen Horowitz)에서 파트너로 활동하며 소셜, 마켓플레이스, 엔터테인먼트, 게임, AI 등 기술 산업 분야에 투자하고 있다. 앤드류가 운영하고 있는 뉴스레터는 20만 명 이상의 구독자가 있다고… 이 책에는 흔히 들어봤을 성공한 스타트업들 이야기가 굉장히 많이 나오는데, 그중에서도 Uber 이야기가 가장 많이 나온다. 앤드류 첸은 이전에 Uber에서 라이더 그로스 부분의 총 책임자(Head of Rider Growth)로 재직하며 플랫폼의 활성 사용자 수를 1,500만에서 1억 명까지 성장시키는데 기여했다. 앤드류 첸 본인의 성공과 실패 경험, 그리고 스타트업들의 유스케이스를 분석해서 다양한 제품과 산업에 적용할 수 있는 `콜드 스타트 이론` 이라는 프레임워크와 원칙을 만들었고, 그 중에서도 네트워크 효과를 활용하는 제품이 왜 그토록 중요한지 이야기해주고 있다.

---

# 네트워크 효과 Network Effects

> 네트워크를 사용하는 사람들이 늘어날수록 네트워크가 사용자들에게 더 가치 있어진다.

**네트워크 효과(Network Effects)**는 제품을 사용하는 사람들이 늘어날수록 제품의 가치가 높아지고, 네트워크가 사용자들에게 더 가치 있어진다고 설명할 때 쓰는 용어다. 이 문장만 봐서는 정확히 무슨 말인지 잘 모르겠다. 어떤 제품을 만드는 메이커 입장에서 네트워크란 무엇일까? 이를 사용자와 연관 지어 생각해 보면, 이런 답을 도출해 볼 수 있다. **연결된 사용자 간의 상호 작용**.

우리가 사용하는 많은 제품이나 서비스는 플랫폼 내 다른 사용자들과의 연결을 통해 가치를 만들어낸다. 예를 들어, Uber는 특정 도시에 운행할 기사와 승객을 연결해 주고, Airbnb는 특정 도시에 방을 제공할 호스트와 여행자를 연결해 준다. 이러한 제품에서는 네트워크 효과가 제품의 가치를 만들어낸다. 그래서 Uber에 특정 도시에 운행할 기사가 없으면 승객 입장에서는 제품이 쓸모없어지고, 이탈로 이어진다. 마찬가지로, Airbnb에 특정 도시에 방을 제공할 호스트가 없으면 사용자 입장에서는 아무리 제품을 잘 만들었더라도 가치가 떨어지고 만다.

> 네트워크 효과는 이 책의 처음부터 끝까지 빠지지 않고 등장하는 중요한 개념이다. 책의 제목인 Cold Start는 단어가 270번 나오는 것에 비해, Network Effect는 총 301번 등장한다.

제품을 만드는 사람들에게 네트워크 효과가 왜 중요할까? 정답은 **쉬워진 제품 출시와 치열한 경쟁 속에서 살아남기 위한 차별화**에 있다. 이제 AI 도구를 사용하지 않으면 바보가 되는 세상이 되었다. 간단한 프로토타이핑은 기본이고, 상용 제품도 Bolt, v0, Replit 같은 도구를 활용하면 쉽게 만들 수 있다. 또한, 잘 만들어진 SaaS, No Code(Low Code) 툴이 너무 많고, 클라우드 환경도 날이 갈수록 발전하고 있어 제품을 만드는 팀 입장에서는 제품 출시의 벽이 정말 낮아졌다. 그래서 이제는 제품 성공에서 속도가 중요한 시대는 지난 것 같다. 제품 출시는 쉬워졌고, 경쟁은 갈수록 치열해지고 있다. 그렇기 때문에 경쟁 제품으로부터 방어할 수 있는 차별화된 네트워크를 구축하는 것이 중요하다.

대부분의 새로운 제품은 첫 시장 진입에 실패하고 사라진다. 그리고 그들의 네트워크는 시작도 하기 전에 붕괴하고 만다. 네트워크 효과가 모두 강력하고 긍정적인 힘이라는 것은 근거 없는 믿음이며, 사실은 정반대다. 아래에서도 나오지만, 작은 규모의 네트워크는 자연적으로 자신을 파괴하려고 한다. 사람들이 어떤 제품을 보러 갔을 때, 그것을 사용하고 있는 지인이나 동료가 아무도 없다면 자연스럽게 떠나고 말 것이다.

이 문제를 어떻게 해결할 수 있을까? 다음 장에서 살펴볼 원자 네트워크(충분히 사람이 떠나지 않을 만큼의 최소한의 네트워크)가 답이 될 수 있다.

---

# 콜드 스타트 이론 Cold Start Theory

콜드 스타트 이론(Cold Start Theory)은 모든 제품을 만드는 팀이 네트워크 효과를 온전히 활용하기 위해 거쳐야 할 일련의 단계를 프레임워크로 정리한 것이다.

![The stages of the Cold Start framework](/images/2025/01/30/stages-cold-start-framework.png "The stages of the Cold Start framework"){: .center-image }

### 콜드 스타트 문제 The Cold Start Problem:

새로운 영상 공유 앱이 출시되었다. 그런데 앱에 다양한 콘텐츠가 없다 보니 사용자들은 오래 머물지 않는다. 마켓플레이스와 소셜 네트워크 등을 포함하여 B2B 서비스도 마찬가지다. 사용자가 자신이 원하는 사람이나 물건을 찾지 못하면 서비스에서 이탈한다. 이것이 바로 콜드 스타트 문제(The Cold Start Problem)이며, 초기 이탈 문제를 해결하기 위해 적절한 사용자와 콘텐츠를 동일한 네트워크에 동시에 모으는 것이 필수적이다.

> Anti-network effects; the network effects that startups love so much actually hurt them.

이 문장이 인상 깊었는데, 대부분의 경우 스타트업들이 그토록 사랑하는 네트워크 효과는 실제로 그들에게 해가 된다고 한다. 제품에 네트워크를 구축해야 살아남는 세계에서, 제대로 된 네트워크가 없으면 이는 자기 파괴적인 관계로 돌아선다는 것이다. 

누구나 거쳐가야 할 초기 콜드 스타트 문제를 해결하기 위해 Wikipedia의 콘텐츠 제작자, 신용카드의 발명 과정, Zoom의 제품 출시 과정 이야기가 자세하게 소개되었다. 여기서 강조된 개념이 **원자 네트워크(Atomic Network)** 였는데, **최소한의 규모로도 안정적으로 작동하고 스스로 성장할 수 있는 네트워크**를 의미한다. 예를 들어, Zoom의 화상회의 서비스는 단 2명의 사용자만으로도 작동할 수 있지만, Airbnb는 하나의 시장에 수백 개의 활성화된 숙소 리스트가 있어야 안정적인 네트워크가 형성된다. 그래서 이 단계에 있는 팀이나 제품에게는 우리 제품의 Atomic Network가 무엇인지(임계치가 얼마인지) 파악하는게 중요하다. 여기서 중요한 것 중 하나는 Atomic Network는 규모가 크지 않고 밀도가 높아야 한다는 것이다. 

- 가장 규모가 작은 집단을 구축하는 것을 목표로 해야 한다.
- 더 많은 사용자를 포함 시키려 할수록 원자 네트워크를 만드는 것은 어려워진다.

콜드 스타트 문제에 있어 원자 네트워크 보다 중요한 개념이 있다. 네트워크는 종종 쌍을 이룬 측면을 가지고 있다. Provider ↔ Consumer, Content Creator ↔ Consumer, Driver ↔ Passenger, Male ↔ Female 처럼 말이다. 

예를 들어, Uber에서는 운전 기사가 있어야 승객이 있고, Tinder에서는 여성 사용자가 있어야 남성 사용자가 있다. 이처럼 초기 원자 네트워크에는 특정한 역학 관계가 작용한다. 또한, 소수의 사용자가 지나치게 많은 가치를 창출하면서 강력한 권력을 차지하게 되는 현상도 발생할 수 있다.

- Uber: 상위 20% 드라이버가 전체 60% 승객을 태운다.
- Tinder: 여성은 5%의 남성을 선택하지만 평균 남성은 45% 여성을 선택한다.
- Wikipedia: 전체 사용자는 수억명, 월 활성 작성자가 10만명이지만, 100건 이상 글 편집자는 4,000명(0.02%). Steven Pruitt 라는 한 개인은 영문 위키피디아의 1/3을 작성함(35,000개 글, 300만번 이상 수정).

네트워크 내의 유저는 보통 한 쪽이 다른 한 쪽보다 데려오기 어렵다. 

- 소셜 네트워크: 모두가 소비하는 미디어를 만드는 콘텐츠 창작자
- 앱스토어: 제품을 제작하는 개발자
- 업무용 앱: 문서와 프로젝트를 작성하고 제작하며 동료들을 불러 모으는 관리자

그리고 이걸 네트워크의 **하드 사이드(Hard Side)**라고 부른다. 네트워크의 하드 사이드를 관리하고 이들을 만족시키는 것이 원자 네트워크보다 더 중요하다. 따라서 제품이 네트워크 기반으로 성장 하기를 원한다면, 하드 사이드부터 정의하는 것이 중요하다. Uber 와 Tinder도 마찬가지다. 위키피디아 사례를 보면, 고작 0.02%에 불과한 의욕 넘치는 사용자들이 나머지 네트워크를 위해 콘텐츠를 발행한다. 위키피디아의 콘텐츠 창작자들 역시 커뮤니티 자체에 매료되었을 가능성이 높다. 사회적 반응과 지위 등 커뮤니티의 역학 관계가 그들이 계속 콘텐츠를 발행하도록 동기를 부여하는 요소가 된다.

하드 사이드를 정의하고 원자 네트워크를 구축하다 보면 마법의 순간(Magic Moment)이 온다. 여기서는 클럽하우스를 예시로 들었는데, 네트워크가 충분히 채워지고 활성화되어 사람들이 올바른 방식으로 소통할 수 있다면, 그때 Magic Moment가 온다고 한다. 흔히 Magic Moment를 찾는 과정을 Product-Market Fit을 찾는 과정이라고 한다. 그렇다면 Magic Moment를 어떻게 측정할 수 있을까? 이는 반대로 접근해 보면 된다.

- 예시) 우버 ZERO: 승객이 우버 앱을 실행하여 주소를 선택한 후 승차하기로 했을 때 그 지역에 운전기사가 아무도 없는 상황. 네트워크에 있는 다른 사용자들과 상호작용하는 것이 그 상품의 핵심이라면 제로는 그것이 충족될 수 없다는 의미이며, 이는 사용자가 이탈하여 다시는 돌아오지 않을 수도 있다는 뜻이다.

만약 콜드 스타트 문제를 겪고 있다면, 초기 단계에서는 제품에서 빠진 기능을 인간의 노력으로 대체하는 것도 중요하다. 이 책에서는 이를 플린트스토닝(Flintstoning)이라고 표현한다. 초기 네트워크가 형성되면, 플린트스토닝 기법은 가속도를 얻으며 점점 자동화를 향해 진화한다. 네트워크가 스스로 일어설 수 있을 때까지, 중요한 부분을 수동으로 채워 넣는 것이 목표다.

마지막으로 Always Be Hustlin. 2012년, Uber는 앱에 등장하는 ‘ICE CREAM’ 버튼을 누르면 우버 블랙 차량을 통해 아이스크림이 배달되는 이벤트를 진행했다. ‘실제로 도움이 되었나요?’라는 질문에 대한 대답은 이렇다.

- 개별적인 볼거리로는 회사에 큰 영향을 미치지 않았을 수도 있다. 하지만 시장을 제로에서 티핑 포인트까지 끌어올리는 프레임워크 안에서, 이러한 재빠르고 영리한 전술은 시장이 이륙하는 데 핵심적인 역할을 했다고 생각한다. 가장 중요한 것은, 우버가 이런 개념을 빠르게 식별하고 실행하며 반복할 수 있는 시스템을 만들었다는 점이다. 이러한 시스템을 구축하는 데 도움을 준 것은 **진취적인 팀 문화, 강력한 소프트웨어 제작 도구, 그리고 각 도시마다 고유한 콜드 스타트 문제가 있다는 것에 대한 이해**다.

차량 공유 앱에서 아이스크림을 배달해준다? 이벤트만 보면 서비스 성장에 전혀 영향을 미칠것 같지 않다. 그런데 이런 이벤트들은 Uber 1.0 Cultural Values에 기반한 것이고 이걸 보니 정말 많은 시도를 했겠다는 생각이 들었다. 

- **Make Magic**: Seek breakthrough that will stand the test of time
- **Super pumped**: The world is a puzzle to be solved with enthusiasm
- **Inside Out**: Find the gap between popular perception and reality
- **Be an Owner, Not a Renter**: Revolutions are won by true believers
- **Optimistic Leadership**: Be inspiring
- **Be Yourself**: Each of us should be authentic
- **Big Bold Bets**: Take risks and plant seeds that are five to ten years out
- **Customer Obsession**: Start with what's best for the customer
- **Always Be Hustlin’**: Get more done with less, working longer, harder, and smarter, not just two out of three
- **Let Builders Build**: People must be empowered to build things
- **Winning**: Champion’s Mindset
- **Principled Confrontation**: Sometimes the world and institutions need to change in order for the future to be ushered in
- **Meritocracy and Toe-Stepping**: The best idea always wins. Don't sacrifice truth for social cohesion and don't hesitate to challenge the boss.
- **Celebrate Cities**: Everything we do make cities better.

여기서 잠깐 [Paul Graham의 Do things that don't scale](https://www.paulgraham.com/ds.html) 이야기가 나온다. 확장 가능하지 않은 일을 하라. 직접 고객을 한 명씩 찾아가 설득하는 것이 처음 시작할 때는 좋은 방법이라는 의미다. 창립자가 해야 하는 가장 흔한 확장되지 않는 일은 사용자를 직접 선발하는 것이다. 이는 거의 모든 스타트업이 반드시 거쳐야 하는 과정이다. 사용자가 오기를 기다려서는 안 된다. 밖으로 나가 직접 부딪쳐야 한다.

생각해볼만한 재미있는 질문:

- 초기 네트워크에 처음부터 있어야 할 가장 중요한 사용자들은 누구이고 그 이유는 무엇인가?
- 원하는 대로 성장할 수 있게 하려면 초기 네트워크의 씨앗을 어떻게 뿌려야 하는가?

### 티핑 포인트 The Tipping Point:

원자 네트워크가 잘 구축되어 콜드 스타트 문제를 극복하면, 네트워크는 어느 순간 폭발적인 성장을 맞이하게 된다. 네트워크가 성장하면서 새로운 네트워크들이 형성되는데, 이 과정이 점점 가속화되며 전체 시장을 훨씬 수월하게 공략할 수 있게 된다.

- LinkedIn: 초대 받은 사람만 사용할 수 있게 설계하여 연결을 통한 선순환을 만들어냄
- Instagram: 사진 보정 도구로 시작해서 팔로우와 공유를 통해 네트워크 효과를 만들어냄
- Uber: 특정 도시에서의 성공 경험을 바탕으로 수요와 공급을 맞춰나가는 전략을 계속해서 반복

네트워크를 론칭할 때마다, 다음 도미노를 쓰러뜨리는 일이 훨씬 수월해진다. 이 모든 것은 처음 시작된 하나의 작은 성공 덕분이다.

Instagram 처럼 도구와 네트워크가 쌍을 이루는 제품:

- 창작 + 사람들과 공유: Instagram, Youtube, Google Workspace, LinkedIn
- 구성 + 사람들과 협업: Pinterest, Asana, Dropbox
- 기록 체계 + 사람들과 최신 정보 유지: OpenTable, GitHub
- 검색 + 사람들과 함께 기부: Zillow, Glassdoor, Yelp

### 이탈 속도 Escape Velocity:

신제품이 성공적으로 확장하기 시작하면, 이탈 속도(Escape Velocity)에 도달했다고 표현한다. 각 네트워크가 어느 정도 자리를 잡기 시작하면, 네트워크 효과를 강화하고 성장을 지속하기 위해 미친 듯이 일에만 집중해야 하는 시기가 바로 이때다. 이 단계의 핵심은 재빠르게 높은 성장률을 유지하면서, 성공적인 제품의 네트워크 효과를 극대화하는 것이다. 그래서 이 시점에는 흔히 하키 스틱 커브(hockey stick curve)가 나타난다. 

이탈 속도에 대해 설명하면서, 네트워크 효과의 아래 세 가지 핵심 요소도 함께 소개했다. 네트워크 기반 제품은 자신의 사적인 네트워크에 있는 사람들에게 제품을 소개할 수 있는 능력을 지니고 있다. 이 능력 덕분에 획득 비용(Acquisition Cost)은 시간이 지나 시장 포화와 경쟁으로 인해 자연스럽게 상승하는 상황에서도 낮게 유지될 수 있다.

**획득 효과(Acquisition Effect)**:
- 사용자가 단순히 제품을 사용하면서도 자연스럽게 새로운 사용자를 유입시키는 효과
- 특정 제품의 사용자가 증가하면서, 사람들이 그 제품을 사용하는 시간이 길어지고 관심이 높아질 때 발생하는 현상
- 재활성화(Reactivation)는 일반적으로 신제품에는 큰 우려 사항이 아니다(탈퇴하는 사용자가 적기 때문). 따라서 초점은 신규 사용자 확보에 맞춰져야 한다. 그러나 이탈 속도(Escape Velocity) 단계에 도달한 제품이라면, 수백만 명의 사용자 풀을 활용할 수 있다. 기존 사용자를 다시 참여시키는 것은 신규 사용자를 획득하는 것만큼 중요한 성장 레버가 될 수 있다.

**참여 효과(Engagement Effect)**:
- 네트워크가 확장하면서 신규 고객을 끌어들이는 능력, 즉 바이럴 요소(Viral Factor)
- 제품이 더 많은 사용자를 확보할수록 점점 더 사용자 친화적이고 몰입도가 높아지는 현상
- 최근에는 리텐션 곡선(Retention Curves)과 참여 지표(Engagement Metrics)를 활용하여 효과를 측정

**경제 효과(Economic Effect)**:
- 네트워크 효과가 시간이 지남에 따라 비즈니스 모델을 더욱 발전시키는 방식
- 네트워크가 성장하면서 수익화 및 전환율(Conversion Rate)이 향상되는 현상
- 네트워크 효과가 단순히 사용자 증가뿐만 아니라 비즈니스의 경제적 가치도 향상시킬 수 있는지를 탐구
- 예시1: 피드 알고리즘 개선, 전환율 증가, 프리미엄 가격 책정(Premium Pricing) 등의 방식으로 수익성 향상
- 예시2: Uber 플랫폼에 운전자가 늘어나면 경쟁 플랫폼에 비해 승객 입장에서의 단가가 낮아지고 그만큼 수요가 즐어나서 수익화와 전환율이 올라간다.

### 천장 The Ceiling:

네트워크가 너무 커지고 포화 상태가 되면, 기존 사용자들은 피로를 느끼고 제품은 성장의 한계에 부딪히게 된다. 이는 네트워크가 최고점에 도달한 후 성장이 교착 상태에 빠지는 현상을 의미한다.

여기서 [엿 같은 클릭률의 법칙(The Law of Shitty Clickthroughs)](https://andrewchen.com/the-law-of-shitty-clickthroughs)에 대해서 소개했는데 인상 깊었다. 1994년, HotWired 웹사이트에서 최초의 배너 광고가 등장했을 때, 클릭률(CTR)은 무려 78%에 달했다. 그러나 2011년 Facebook에서의 배너 광고 클릭률은 0.05%로, 1500배나 낮아졌다. 이는 단순한 우연이 아니라, 시간이 지남에 따라 모든 마케팅 전략의 클릭률이 감소하는 법칙이 작용한 결과다. 배너 광고뿐만 아니라 이메일, 뉴스레터, 기타 온라인 채널의 성과도 시간이 지나면서 점점 감소한다.

클릭률 저하의 주요 원인:

1. 사용자는 새로움(신선함)에 반응하지만, 이건 금방 사라진다. 새로운 마케팅 기법이 처음 등장하면 사람들은 신기해서 반응하지만, 반복될수록 효과가 급격히 떨어진다.
2. 선점 효과는 오래가지 않는다. 만약 당신이 새로운 마케팅 기법을 개발하여 높은 성과를 거둔다면, 경쟁자들은 이걸 빠르게 모방할 것이다. 마케팅 채널이 퍼지면 경쟁으로 인해 성과가 점차 약화된다.
3. 규모가 커질수록 전환율이 낮아진다. 초기 시장(early adaopters)은 새로운 기술이나 제품에 열광하지만, 주류 시장(mainstream market)은 제품이 정말 유용한지를 따진다. 즉, 처음에는 적은 비용으로 높은 효과를 볼 수 있지만, 시간이 지날수록 광고비는 증가하고 전환율은 감소한다.

클릭률 저하의 법칙을 극복하는 방법:

1. 지속적인 개선과 최적화: 새로운 Creative(광고 소재) 테스트, 새로운 퍼블리셔와 광고 네트워크 탐색, 데이터 기반 최적화
2. 정보 전달형 마케팅 활용: 단순히 “광고”로 접근하는 것이 아니라, 사용자에게 유용한 정보를 제공하는 콘텐츠 마케팅 전략을 활용해야 한다.
3. 새로운 마케팅 채널 선점: 아직 경쟁이 치열하지 않은 새로운 마케팅 채널을 먼저 활용하는 것이 중요하다. 남들이 아직 시도하지 않은 마케팅 채널을 개척하면, 높은 성과를 낼 가능성이 크다.

이 장은 질문과 짧은 답변으로 마무리되었다.

마케팅 채널을 통해 주당 수백 건의 다운로드가 발생하고 있다면, 다운로드 수를 두 배로 늘리려면 어떻게 해야 할까? 또는 10배, 궁극적으로 1000배 늘리려면? 가장 좋은 방법은 네트워크 효과 여부와 관계없이 꾸준히 새로운 채널을 구축하는 것이다.

### 해자 The Moat:

성(안정적인 현금 흐름 혹은 이익)이 있으면 그걸 빼앗기 위해 달려드는 적군(경쟁자)이 있고, 그들로부터 방어하기 위해 구덩이를 파고 물을 채워 놓은 것을 해자(Moat)라고 부른다. 경쟁적 해자(Competitive Moat)에 대한 개념은 세계적인 투자자인 Warren Buffett이 인용하면서 유명해졌다. 이 용어는 경쟁 제품에 비해 경쟁 우위를 유지하여 장기적인 수익성과 시장 점유율을 보호할 수 있는 제품의 능력을 의미한다.

> The key to investing is not assessing how much an industry is going to affect society, or how much it will grow, but rather determining the competitive advantage of any given company and, above all, the durability of that advantage. The products or services that have wide, sustainable moats around them are the ones that deliver rewards to investors.<br/>
> 투자의 핵심은 어떤 산업이 사회에 얼마나 큰 영향을 미칠 것인지 또는 얼마나 성장할 것인지를 평가하는 것이 아닙니다. 오히려 중요한 것은, 개별 기업의 경쟁 우위를 평가하고, 그 경쟁 우위가 얼마나 지속될 수 있는지를 파악하는 것입니다. 넓고 지속 가능한 해자를 가진 제품이나 서비스만이 장기적으로 투자자들에게 높은 보상을 제공할 수 있습니다.

![The Moat](/images/2025/01/30/moat.png "The Moat"){: .center-image }

이 글의 도입부에서도 이야기했던 네트워크 제품의 차별점에 대한 내용이다. **차별화된 네트워크를 갖춘 제품은 경쟁자가 쉽게 진입할 수 없다**는 점에서 강력한 이점을 가진다. 이 시점부터는 네트워크를 기반으로 한 경쟁이 본격적으로 시작된다. 그리고 경쟁자를 물리치기 위한 네트워크 효과가 발동한다. 재미있는 점은, 여기서 경쟁은 단순히 더 좋은 기능이나 실행력에 관한 것만이 아니라, 한 제품의 생태계가 다른 제품의 생태계를 어떻게 위협하는가에 대한 문제로 확장된다는 것이다.

예를 들어, Airbnb가 시장에서 이탈 속도(Escape Velocity)에 도달하면, 콜드 스타트 문제(Cold Start Problem)는 새로운 진입자에 대한 방어책이 된다. 결국, 도시에 진입하는 경쟁 제품은 모두 콜드 스타트 문제를 해결하여 동일한 밀도를 구축해야 한다. 여러분이 0에서 티핑 포인트(Tipping Point)까지 가는 데 어려움을 겪었던 것처럼, 불리한 조건에서 시작하는 경쟁 업체에게는 더욱 큰 도전이 될 것이다.

해자(Moat)에 대해 설명하면서 선순환과 악순환(Cycle of Virtue and Doom)에 대한 이야기도 흥미로웠다. 콜드 스타트 이론(Cold Start Theory)에 따르면, 경쟁은 선순환과 동시에 악순환을 만들어 낸다. **네트워크 효과는 승자에게 강력한 이점을 제공하는 동시에, 패배한 네트워크에는 강력한 부정적인 영향을 미친다. 네트워크의 가치는 사용자가 많아질수록 기하급수적으로 증가하지만, 반대로 사용자가 이탈하면 네트워크의 가치도 기하급수적으로 붕괴한다.**

- 유저 획득(Acquisition) – 바이럴 성장(viral growth)이 둔화
- 사용자 참여(Engagement) – 사용자 활동 감소
- 경제성(Economics) – 수익화(monitization) 악화

즉, 네트워크 효과는 강력한 성장 촉진제지만, 동시에 사용자 이탈이 발생하면 네트워크 전체를 급격히 무너뜨리는 요인이 될 수도 있다는 것이다.

---

# 재밌었던 이야기들

여기까지가 책 전체에 나온 콜드 스타트 이론(Cold Start Theory)에 대한 정리다. 여기부터는 콜드 스타트 & 네트워크 효과에 대한 흥미로웠던 이야기들을 정리해놓았다.

### 알리 임계값 Allee Threshold:

미어캣은 아프리카 남부에 사는 극도로 사회적인 동물로, 보통 서른에서 쉰 마리 정도가 모여 무리를 지어 생활한다. 그 이유는 포식자가 접근하면 무리 중 한 마리가 두 발로 서서 경계를 서고 복잡한 경고음을 내어 다른 개체들에게 위험을 알리기 때문이다. 이들은 포식자가 공중인지 지상인지, 위험도가 낮은지, 중간인지, 높은지에 따라 다양한 방식으로 짖거나 휘파람 소리를 낸다. 이러한 경고 시스템 덕분에 무리는 안전을 유지할 수 있다. 이러한 동물의 집단 행동은 1930년대 시카고 대학교의 생태학자 워더 클라이드 알리(Warder Clyde Allee)에 의해 처음으로 연구되었다. 

그는 논문 [동물 집단 연구: 금붕어의 콜로이드 은에 대한 집단 보호(Studies in Animal Aggregations: Mass Protection Against Colloidal Silver Among Goldfishes)](https://onlinelibrary.wiley.com/doi/10.1002/jez.1400610202)를 통해 흥미로운 사실을 발견했다. 그에 따르면, 금붕어는 집단으로 있을 때 더 빠르게 성장하고, 물의 독성을 더 잘 견딜 수 있다. 이러한 개념은 생물학에서 중요한 개념이 되었으며, 집단 크기가 임계점을 넘어야 개체들이 더 안전해지고, 결국 개체군이 더 빠르게 성장할 수 있다는 `알리 임계값(Allee Threshold)` 개념이 탄생했다. 즉, 알리의 인구 성장 곡선은 생태학적 네트워크 효과(Network Effect)와 유사하다.

![Allee Threshold](/images/2025/01/30/allee-threshold.png "Allee Threshold"){: .center-image }

메시징 앱을 사용하는 사람이 적으면, 기존 사용자도 앱을 삭제한다:

- 사용자 수가 줄어들면, 네트워크의 가치가 감소 → 점점 더 많은 사람들이 앱을 떠남 → 네트워크 붕괴

반면, 건강한 미어캣 무리는 지속적으로 성장하며 새로운 무리를 형성할 가능성이 있다:

- 알리 임계값을 넘어서면 개체군은 지속적으로 증가
- 충분한 개체 수가 유지되는 한, 약간의 개체 손실이 있어도 전체 인구는 안정적으로 유지

하지만 이러한 성장은 영원히 지속될 수 없다. 결국, 환경이 제공할 수 있는 자원의 한계(예: 미어캣이 먹는 곤충과 과일의 양) 때문에 개체군이 어느 정도 이상으로 증가할 수 없다. 이것을 `수용력(Carrying Capacity)`이라고 한다.

우버(Uber)와 알리 곡선(Allee Curve) 예시:

- 도시 내에 운전자가 감소 → 차량 호출 시간이 길어짐 → 사용자 서비스 이탈 → 운전자도 플랫폼 이탈 → 우버 네트워크 붕괴

하지만 임계점을 넘어서면, 네트워크가 원활하게 작동한다.

- 운전자가 증가 → 대기 시간이 감소 → 사용자 증가 → 운전자 증가

그러나 네트워크가 너무 커지면 한계에 도달한다.

- 기다림 없이 차량을 이용하는 것은 편리하지만, 운전자가 너무 많으면 오히려 플랫폼 운영이 비효율적

즉, **네트워크가 성장하는 데는 적절한 균형점이 필요**하다. 알리 임계값은 단순한 생태학 개념이 아니라, 기술 제품의 네트워크 효과에도 그대로 적용된다.

- 초기에는 임계값을 넘을 수 있도록 사용자 확보가 필수적이다.
- 네트워크가 성장하면 최적의 수용력을 유지해야 한다.
- 그렇지 않으면 네트워크는 붕괴할 가능성이 크다.

네트워크 기반 제품이 성공하려면, 이러한 생태학적 법칙을 이해하고 적절한 성장 전략을 적용해야 한다.

### 수익성 부족에 대한 이야기:

티핑 포인트를 빠르게 거쳐가기 위해 수익이 나지 않는 것이 현명한 이유는 무엇일까? 수익성 부족이 네트워크가 티핑 포인트를 더 빠르게 지나게 하는 현명한 전략이 될 수 있는 이유를 다음과 같이 설명했다.

- 소수의 원자 네트워크를 구축한 후에는 돈을 지출하여 전체 시장에 진입하고 싶어질 것이다. 마켓플레이스의 경우, 구매자에게는 낮은 가격, 판매자에게는 높은 수익이 핵심적인 가치 제안이 된다. 사회적 제품에서도 마찬가지로, 커뮤니케이션이든 콘텐츠 공유든 중요한 요소가 된다. 여기서 콘텐츠 창작자에게 중요한 것은 청중 확보와 수익 창출 모두다.
- 일단 시장에서 승리하면, 거의 언제나 규모에 맞게 인센티브를 줄이는 것이 목표가 된다. 플랫폼에서 처리 가능한 전체 시장이 활성화되면, 더 이상 구매 비용에 지출할 필요가 없어진다.
- 단기간에는 수익이 나지 않을 것 같아도, 시장이 내게 유리한 티핑 포인트에 도달한다면 장기적으로 우위를 점할 수 있다.

### 인접 사용자 이론 Adjacent Users Theory:

- [The Adjacent User Theory](https://andrewchen.com/the-adjacent-user-theory/)

네트워크는 여러 개의 작은 네트워크로 이루어져 있으며, 일부 네트워크는 다른 네트워크보다 훨씬 더 활성화되어 있다. 일반적으로, 가장 먼저 형성된 핵심 네트워크(Core Network)가 가장 건강하고 활발하게 작동한다. 그러나 핵심 네트워크에서 멀어질수록 참여도가 낮은 사용자 그룹과 거의 활성화되지 않은 네트워크가 존재하게 된다. 즉, 제품을 인지하고 있으며 테스트해본 경험은 있지만, 여전히 참여형 사용자가 되지 못한 이들이다.

예를 들어, eBay의 초기 핵심 시장은 미국의 수집품(Collectibles) 커뮤니티였지만, 자동차 같은 고가품을 거래하는 사용자들에게는 적합하지 않았다. 또한, 결제 시스템이 원활하지 않은 국제 시장과 같은 완전히 비활성화된 네트워크도 존재했다.

이러한 인접 네트워크(Adjacent Networks)를 이해하고 하나씩 공략하는 것이 성장과 시장 확장의 핵심 전략이다.

책에 나온 Instagram 사례:

- 2016년, Instagram은 이미 4억 명 이상의 사용자를 보유하고 있었지만 성장이 지수적(exponential)이 아닌 선형적(linear)으로 진행되고 있었음. 이는 일반적인 제품이라면 큰 성공이지만, 소셜 네트워크 제품은 네트워크 효과를 통해 폭발적인 성장을 지속해야 하는 특성이 있음. 당시 Instagram의 VP Growth, Bangaly Kaba는 성장이 둔화된 이유를 분석하고, 이를 해결하기 위한 전략을 개발해 10억 명 이상의 사용자로 확장할 수 있도록 만듦.
- 2016년, Instagram은 이미 4억 명 이상의 사용자를 보유하고 있었지만, 성장이 지수적(exponential)이 아닌 선형적(linear)으로 진행되고 있었다. 일반적인 제품이라면 큰 성공이지만, 소셜 네트워크 제품은 네트워크 효과를 통해 폭발적인 성장을 지속해야 하는 특성이 있다.
- 당시 Instagram의 VP of Growth, Bangaly Kaba는 성장이 둔화된 원인을 분석하고, 이를 해결하기 위한 전략을 개발하여 사용자를 10억 명 이상으로 확장할 수 있도록 만들었다. 이 때 그가 접근한 방식은 인접 사용자(Adjacent User)에 대한 분석이었다. 이들이 제품을 정착하지 못한 이유는 현재 제품의 포지셔닝 이나 사용자 경험이 이들에게 적합하지 않기 때문이었다. 4억 명의 기존 사용자들에게는 Product-Market Fit이 있었지만, 수십억 명의 새로운 사용자들은 Instagram을 자신의 삶과 연결하지 못하고 있었음.
- 초기 인접 사용자는 미국의 35~45세 여성으로, Facebook은 사용하지만 Instagram의 가치를 이해하지 못하는 그룹. 이들을 위해 Facebook 프로필과 친구 관계 데이터를 활용하여 친구 및 가족을 쉽게 찾을 수 있도록 추천 알고리즘을 개선함.
- 후기 인접 사용자는 자카르타에서 저사양 3G 안드로이드폰을 사용하는 예비 사용자. 이들을 위해 낮은 데이터 소비를 지원하는 앱 최적화 작업을 진행함.
- Instagram은 총 8개의 주요 인접 사용자 그룹을 단계적으로 해결해 나가면서, 성장 정체를 극복하고 폭발적인 확장을 이루어냄.

### 컨텍스트의 붕괴 Context Collapse:

모든 네트워크는 초기에 특정 원자 네트워크(Atomic Network)를 중심으로 형성된다. 이 시기에는 네티켓(Netiquette), 즉 네트워크 내에서 허용되는 행동과 금기사항이 자연스럽게 정해지며, 특정 문화가 형성된다. 그러나 시간이 지나면서 이러한 문화는 점점 약화되기 쉬워지고, 결국 맥락 붕괴(Context Collapse)가 발생한다.

이러한 컨텍스트 붕괴는 서로 다른 사용자 그룹이 하나의 네트워크에서 충돌할 때 발생한다. 예를 들어, Facebook이 초기에는 친한 친구들끼리 사적인 이야기, 사진, 농담을 공유하는 공간으로 활용되었지만, 시간이 지나면서 친척, 가족, 선생님, 상사까지 유입되었다. 이로 인해 사용자는 콘텐츠를 자유롭게 게시하지 못하게 되고, 활동이 줄어들면서 네트워크 성장에도 부정적인 영향을 미치게 된다. 

컨텍스트 붕괴는 너무나도 많은 네트워크가 동시에 모였을 때 발생한다.

컨텍스트 붕괴의 문제점:

- 콘텐츠 제작자(Content Creators) 감소 → 새로운 콘텐츠 감소 → 네트워크 가치 하락
    - 예시: YouTube, Instagram의 크리에이터들이 특정 콘텐츠를 올리기 꺼려하는 현상
- 마켓플레이스에서의 매칭(Matchmaking) 저하 → 일반 사용자 유입(퀄리티 저하) → 초기 핵심 유저의 이탈 → 네트워크 가치 하락
    - 예시: 고급 스니커 거래 커뮤니티가 시간이 지나면서 일반 신발 판매 시장으로 변질되는 현상
- 기업 내 협업 도구에서의 문제
    - 초기: 소규모 팀 내에서는 자유로운 소통이 가능
    - 변화: 조직이 커지면서 상사, 임원, 외부 팀까지 유입되며 소통 위축
    - 예시: Slack에서 팀원이 자유롭게 농담을 주고받다가 임원이 참여하면서 분위기가 달라지는 현상

컨텍스트 붕괴를 극복하는 방법:

- 사용자를 세분화(Segmentation)하여 네트워크 분리
    - Facebook: 비공개 그룹(Facebook Groups) 활성화
    - Instagram: "Close Friends" 기능 도입
    - Slack: 팀별 채널 분리
- 콘텐츠 노출을 맞춤화(Algorithmic Personalization)
    - 사용자가 누구에게 어떤 콘텐츠를 노출할지 선택할 수 있도록 지원
    - 예: Twitter의 "Following" vs. "For You" 피드, LinkedIn의 "Private Mode"
- 초기 사용자 문화 보호
    - Airbnb;  "고유한 숙소" 강조하며 호텔과 차별화
    - Reddit; 특정 커뮤니티 문화 유지하도록 강력한 모더레이션 정책 운영
- 새로운 사용자와 기존 사용자 간 균형 유지
    - 마켓플레이스 모델: 초기에 고급 사용자층(Target Niche)을 형성한 후 점진적으로 새로운 사용자 유입
    - 소셜 네트워크 모델: 새로운 기능을 도입하여 기존 사용자가 떠나지 않도록 유도

### 그 외:

- 네트워크의 밀도는 총수보다 중요하다.
- 대규모 론칭으로 인해 생성된 네트워크가 취약한 이유는 분명하다. 존재하지 않는 다수의 네트워크보다, 밀도가 높고 참여도가 높은 소규모 원자 네트워크가 더 유리하다. 네트워크 제품의 유용성이 다른 사용자의 확보에 달려 있다면, 목표 수치에 집착하기보다 네트워크 내 개별 사용자 간의 관계를 확장하는 것이 더 중요하다.
- 스타트업은 작은 규모에서 시작하여 네트워크의 힘을 활용해 성장할 수 있는 장점이 있다.
- 거대한 규모의 네트워크 효과를 창출하려면, 우선 작은 규모의 원자 네트워크에서 시작해야 한다. 그리고 첫 번째 네트워크 집합에서의 성공을 발판 삼아, 그다음 네트워크 집합으로 확장해 나가야 한다.

---

# 마치며

예나 지금이나 스타트업의 성공과 실패 이야기를 들으면 설렘이 가득합니다. 그런데 제품을 만드는 사람으로서, 때로는 엔드 유저로서 네트워크 효과를 가진 서비스를 체험하면서 이 책에서 다루는 내용이 당연하게 느껴지기도 했습니다. 아마도 우리가 이미 경험하고 있는 현상들을 이 책이 체계적으로 정리해주어서 그런것 같습니다.

각 분야의 전문가들은 특정 문제나 현상을 설명하기 위해 개념에 이름을 붙이곤 합니다. Cold Start Theory, Network Effects, Adjacent Users Theory 등 우리가 이미 알고 있고 경험한 것들을 이 분야의 전문가들이 명명해놓으니, 현상에 대한 이해가 한결 쉬워졌습니다. 이 책을 읽으며 제품을 사용해보고 때로는 만들면서 배웠던 것들을 프레임워크를 통해 정리할 수 있는 좋은 기회가 되었습니다.

최근 1~2년 동안 회사에서 사용자와 거리가 먼 기술 중심의 업무를 하다 보니, 제품을 바라보는 시각이 점점 무뎌지고 있다는 걸 종종 느꼈습니다. 그럴 때마다 사용자의 목소리를 듣기 위해 고객 문의 채널을 살펴보거나 데이터를 분석하는 일을 틈틈이 해왔던 것 같아요. 그런데 마침 이 책이 그 갈증을 해소해 주었고, 읽는 내내 우리 제품에 빗대어 생각하며 다양한 영감을 얻을 수 있었습니다. 책을 읽으며 들었던 생각을 동료들과 나누며 발산 할 수 있는 기회도 되었습니다. 제로 단계에서 어떤 실패와 성공을 거쳐 글로벌 네트워크를 구축했는지를 다룬 책이니, 꼭 사용자 간 연결을 기반으로 한 제품을 만들지 않더라도 제품 성장에 대한 영감을 얻고 싶다면 일독을 권합니다. (번역이 아쉬워서 원서와 함께 봤던 점은 참고하시길...)

![The Cold Start Problem](/images/2025/01/30/cold-start-book.png "The Cold Start Problem"){: .center-image }

---

# References

- [콜드 스타트: 기업 가치를 결정짓는 네트워크의 과학](https://www.yes24.com/product/goods/118148684)
- [The Cold Start Problem: How to Start and Scale Network Effects](https://www.amazon.com/Cold-Start-Problem-Andrew-Chen/dp/0062969749)
- [andrewchen.com](https://andrewchen.com/)