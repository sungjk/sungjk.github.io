---
layout: entry
title: Mocks Aren't Stubs
author: 김성중
author-email: ajax0615@gmail.com
description: Mock 객체는 behavior verification을 도와주는 테스트 객체의 한 형태이다.
keywords: test, mock, stub, behavior verification
publish: true
---

### Regular Tests

```java
public class OrderStateTester extends TestCase {
  private static String TALISKER = "Talisker";
  private static String HIGHLAND_PARK = "Highland Park";
  private Warehouse warehouse = new WarehouseImpl();

  protected void setUp() throws Exception {
    warehouse.add(TALISKER, 50);
    warehouse.add(HIGHLAND_PARK, 25);
  }
  public void testOrderIsFilledIfEnoughInWarehouse() {
    Order order = new Order(TALISKER, 50);
    order.fill(warehouse);
    assertTrue(order.isFilled());
    assertEquals(0, warehouse.getInventory(TALISKER));
  }
  public void testOrderDoesNotRemoveIfNotEnough() {
    Order order = new Order(TALISKER, 51);
    order.fill(warehouse);
    assertFalse(order.isFilled());
    assertEquals(50, warehouse.getInventory(TALISKER));
  }
}
```

xUnit 테스트는 setup, exercise, verify, teardown 4단계로 이루어져 있다. 위 코드에서 setup 단계는 setUp 메서드에서 warehouse를 초기화하는 부분과 test 메서드에서 order를 초기화하는 부분으로 구성된다. exercise 단계에서는 `order.fill`을 호출하고, 테스트할 객체를 검사하는 부분이다. 그 다음 verification 단계에서는 assert 문을 사용해서 실행된(exercised) 메서드가 작업을 올바르게 수행했는지 확인한다. 위 코드에는 명시적인 teardown 단계가 없지만 garbage collector가 암시적으로 이를 수행한다.

테스트 과정을 셋팅하는 동안 두 가지 종류의 객체가 함께 제공된다. Order는 테스트하려는 클래스인데, `Order.fill`을 호출하려면 Warehouse 인스턴스도 필요하다. 테스트 지향적인 사람들(Testing-oriented people)은 테스트 대상 객체(object-under-test) 또는 테스트 대상 시스템(system-under-test)과 같은 용어를 사용한다. 여기서는 Meszaros가 언급한 System Under Test 또는 그 약어인 SUT를 사용하겠다.

이 테스트를 위해서는 SUT(`Order`)와 하나의 협력자(`warehouse`)가 필요하고, 다음 두 가지 이유 때문에 warehouse가 필요하다. 하나는 테스트된 동작이 작동하도록 하는 것이고(`Order.fill`이 warehouse의 메서드를 호출하기 때문에), 두 번째는 검증(verification)을 위해 필요하다(`Order.fill`의 결과 중 하나가 warehouse의 상태). 이 주제를 더 자세히 살펴보면 SUT와 협력자(collaborators)를 구분했음을 알 수 있다.

이 테스트 스타일은 **상태 검증(state verification)**을 사용한다. 즉, 메서드가 실행된 후 SUT와 해당 협력자의 상태를 검사하여 실행된 메서드가 올바르게 작동했는지 여부를 결정한다. 앞으로 살펴보겠지만, mock 객체는 검증(verification)에 대한 다른 접근 방법을 제공한다.

### Tests with Mock Objects

이제 mock 객체를 사용해서 같은 동작을 테스트해보겠다.

```java
public class OrderInteractionTester extends MockObjectTestCase {
  private static String TALISKER = "Talisker";

  public void testFillingRemovesInventoryIfInStock() {
    //setup - data
    Order order = new Order(TALISKER, 50);
    Mock warehouseMock = new Mock(Warehouse.class);
    
    //setup - expectations
    warehouseMock.expects(once()).method("hasInventory")
      .with(eq(TALISKER),eq(50))
      .will(returnValue(true));
    warehouseMock.expects(once()).method("remove")
      .with(eq(TALISKER), eq(50))
      .after("hasInventory");

    //exercise
    order.fill((Warehouse) warehouseMock.proxy());
    
    //verify
    warehouseMock.verify();
    assertTrue(order.isFilled());
  }

  public void testFillingDoesNotRemoveIfNotEnoughInStock() {
    Order order = new Order(TALISKER, 51);    
    Mock warehouse = mock(Warehouse.class);
      
    warehouse.expects(once()).method("hasInventory")
      .withAnyArguments()
      .will(returnValue(false));

    order.fill((Warehouse) warehouse.proxy());

    assertFalse(order.isFilled());
  }
}
```

우선 setup 단계가 다른데, data와 expectations 두 부분으로 나뉜다. data 부분에서는 작업과 관련 있는 객체를 셋팅한다. 그런 의미에서 기존 단계와 유사한데, 차이점이라고 하면 생성되는 객체가 다르다. SUT(Order)는 동일하고, 협력자(collaborator)는 warehousr 객체가 아니라 mock warehouse 이다. 기술적으로 `Mock` 클래스의 인스턴스입니다.

setup의 두 번째 부분에서는 mock 객체에 대한 기대값(expectations)을 생성한다. expectations는 SUT가 실행될 때 mock 객체에서 호출되어야 하는 메소드를 나타낸다.

모든 기대값을 설정했으면 SUT를 실행해보고, 실행 후에는 두 가지 검증(verification)을 수행한다. 이전과 마찬가지로 SUT에 대해 asserts을 실행하는데, mock 객체도 기대값에 맞게 호출되었는지 검증해야 한다.

여기서 주요 차이점은 order가 warehouse와 상호 작용할 때 작업을 올바르게 수행했는지 검증하는 방법이다. 상태 확인(state verification)을 할 때는 warehouse의 상태에 대해 assert를 사용해서 검증하는 반면에, Mock은 order가 warehouse에서 올바른 호출을 했는지 확인하는 **행동 검증(behavior verification)**을 사용한다. setup 단계에서 mock에 무엇을 기대해야 하는지 알려주고, verify 단계에서 mock에 스스로 검증하도록 요청한다. asserts로 order만 확인하고, 메서드가 order 상태를 바꾸지 않으면 asserts 자체가 없다.

두 번째 테스트에서는 몇 가지 다른 작업을 수행한다. 먼저 생성자가 아닌 MockObjectTestCase의 `mock` 메서드를 사용하여 mock을 만든다. 그리고 명시적으로 verify를 호출할 필요가 없이 테스트가 끝날 때 자동으로 검증된다. 첫 번째 테스트도 이렇게 작성할 수 있지만, mock 테스트가 작동하는 방식을 보여주기 위해 검증 단계를 보다 명시적으로 보여주고 싶었다.

두 번째 테스트 케이스에서 또 다른 점은 `withAnyArguments`를 사용하여 기대값에 대한 제약(constraints)을 완화했다는 것이다. 그 이유는 첫 번째 테스트에서 숫자가 warehouse로 전달되었는지 확인하므로 두 번째 테스트에서 해당 테스트를 반복할 필요가 없기 때문이다. 나중에 order의 로직을 변경해야 하는 경우, 하나의 테스트만 실패하므로 테스트를 마이그레이션하는 수고를 덜 수 있다.

### The Difference Between Mocks and Stubs

처음 도입되었을 때 많은 사람들이 stubs을 사용하는 일반적인 테스트 개념과 mock 객체를 쉽게 혼동했지만, 그 이후로 사람들이 차이점을 더 잘 이해한 것 같다. 사람들이 mock을 사용하는 방식을 완전히 이해하려면 mock과 다른 종류의 test doubles에 대해 이해하는 것이 중요하다.

이와 같은 테스트를 수행할 때 한 번에 소프트웨어의 한 요소에 초점을 맞추게 된다(일반적인 용어는 unit testing). 문제는 single unit을 작동시키려면 종종 다른 unit들이 필요한데, 위 예시에서는 order를 위해서 warehouse가 필요한 것처럼.

위에서 본 두 가지 테스트 스타일에서 첫 번째 경우는 실제 warehouse 객체를 사용하고, 두 번째 경우는 실제 warehouse 객체가 아닌 mock warehouse를 사용한다. mock을 사용하는 것은 테스트에서 실제 warehouse를 사용하지 않는 한 가지 방법이지만 이와 같이 테스트에 사용되는 다른 형태의 실재하지 않는(unreal) 객체가 있다.

이를 설명하는 단어가 많다 - stub, mock, fake, dummy. 이 아티클에서는 Gerard Meszaros 책의 어휘를 따른다(모두가 사용하는 것은 아니지만 좋은 어휘라고 생각하고 내가 쓰는 아티클이기 때문에 일단 사용할 단어를 선택함).

Meszaros는 실제 객체 대신 테스트 목적으로 사용되는 모든 종류의 가상 객체에 대한 일반적인 용어로 **Test Double**이라는 용어를 사용한다. 이름은 영화에서 사용하는 Stunt Double의 개념에서 비롯되었다. 그런 다음 Meszaros는 5가지 특정 종류의 double을 정의했다.

- **Dummy** 객체는 전달은 되지만 실제로 사용되지는 않는 것을 말한다. 일반적으로 매개변수 목록을 채우는 데만 사용된다.
- **Fake** 객체는 실제로 동작하는 구현을 가지고 있지만, 일반적으로 프로덕션에 적합하지 않은 몇 가지 shortcut을 사용한다([in memory database](https://martinfowler.com/bliki/InMemoryTestDatabase.html)가 좋은 예).
- **Stubs**은 테스트 중에 만들어진 호출에 미리 준비된 답변을 제공하며, 일반적으로 테스트를 위해 작성된 기능 외에는 전혀 응답하지 않는다.
- **Spies**은 어떻게 호출 되었는지에 따라 일부 정보를 기록하는 Stub이다. 예) 전송된 메시지 수를 기록하는 이메일 서비스
- **Mocks**은 호출 결과 받기로 한 기대값으로 미리 프로그래밍된 객체(objects pre-programmed with expectations)다.

이러한 doubles 종류 중에서 mocks만 행동 검증(behavior verification)을 주장한다. 다른 doubles는 상태 검증(state verification)을 사용할 수 있고 일반적으로도 그렇다. Mock은 실제로 SUT가 실제 협력자(real collaborators)와 대화하고 있다고 믿도록 해야 하기 때문에 exercise 단계에서 다른 doubles처럼 행동한다. 그러나 Mock은 setup 및 verification 단계에서 다르다.

test doubles을 조금 더 알아보려면 예제를 확장해야 한다. 많은 사람들은 실제 객체가 작업하기 불편한 경우에만 test doubles을 사용한다. 예제에서 test doubles에 대한 보다 일반적인 경우는 `order.fill`을 실패했을때 이메일을 보내고 싶은 경우다. 문제는 테스트 중에 고객에게 실제 이메일을 보내고 싶지 않다는 것이다. 그래서 우리가 제어하고 조작할 수 있는 이메일 시스템의 test doubles을 만들어 보겠다.

여기서 우리는 mock과 stub의 차이점을 볼 수 있다. 이 메일링 동작(behavior)에 대한 테스트를 작성하는 중이라면 이와 같은 간단한 stub을 작성할 수 있다.

```java
public interface MailService {
  public void send (Message msg);
}
public class MailServiceStub implements MailService {
  private List<Message> messages = new ArrayList<Message>();
  public void send (Message msg) {
    messages.add(msg);
  }
  public int numberSent() {
    return messages.size();
  }
}
```

그런 다음 이와 같이 stub에서 상태 검증(state verification)을 사용할 수 있다.

```java
class OrderStateTester...

  public void testOrderSendsMailIfUnfilled() {
    Order order = new Order(TALISKER, 51);
    MailServiceStub mailer = new MailServiceStub();
    order.setMailer(mailer);
    order.fill(warehouse);
    assertEquals(1, mailer.numberSent());
  }
```

물론 이것은 메시지가 전송되었다는 매우 간단한 테스트이다. 우리는 그것이 올바른 사람에게 또는 올바른 내용으로 전송되었는지 테스트하지 않았지만 요점을 설명하기 위해 테스트할 것이다. mock을 사용하면 이 테스트가 상당히 다르게 보일 것이다.

```java
class OrderInteractionTester...

  public void testOrderSendsMailIfUnfilled() {
    Order order = new Order(TALISKER, 51);
    Mock warehouse = mock(Warehouse.class);
    Mock mailer = mock(MailService.class);
    order.setMailer((MailService) mailer.proxy());

    mailer.expects(once()).method("send");
    warehouse.expects(once()).method("hasInventory")
      .withAnyArguments()
      .will(returnValue(false));

    order.fill((Warehouse) warehouse.proxy());
  }
}
```

두 경우 모두 실제 메일 서비스 대신 test double을 사용하고 있다. stub은 상태 검증(state verification)을 사용하고, mock는 행동 검증(behavior verification)을 사용한다는 차이점이 있다.

stub에서 상태 검증(state verification)을 사용하려면 검증을 돕기 위해 stub에서 몇 가지 추가 메서드를 만들어야 한다. 결과적으로 stub은 `MailService`를 구현하지만, 추가 테스트 방법을 더해야 한다.

Mock 객체는 항상 행동 검증(behavior verification)을 사용하며 stub은 어느 쪽이든 갈 수 있다. Meszaros는 Test Spy로 행동 검증(behavior verification)을 사용하는 stub을 언급한다.

### Classical and Mockist Testing

**classical TDD** 스타일은 가능하면 실제 객체를 사용하고, 실제 객체를 사용하는 것이 어색하면 double을 사용하는 것이다. 따라서 classical TDDer는 실제 warehouse를 사용하고 메일 서비스에는 double을 사용한다. double의 종류는 그다지 중요하지 않다.

그러나 **mockist TDD**를 실천하는 사람은 관련있는 동작을 하는 모든 객체에 대해 항상 mock을 사용한다. 이 경우 warehouse와 메일 서비스 모두에 해당된다.

다양한 mock 프레임워크가 mockist 테스팅을 염두에 두고 설계되었지만, 많은 classicists들은 이게 double을 만드는 데 유용하다고 생각한다.

mockist 스타일의 중요한 파생물은 BDD([Behavior Driven Development](http://dannorth.net/introducing-bdd/))이다. BDD는 원래 TDD가 설계 기술로 작동하는 방식에 초점을 맞춰 사람들이 테스트 주도 개발(Test Driven Development)을 더 잘 배울 수 있도록 돕는 기술이다. 이로 인해 TDD가 객체가 수행해야 하는 작업에 대해 생각하는 데 도움이 되는 부분을 더 잘 탐색하기 위해 테스트 이름을 behavior으로 변경했다. BDD는 mockist 접근 방식을 취하지만, naming 스타일과 기술 내에서 분석을 통합하려는 열망으로 가득하다. BDD가 mockist 테스팅을 사용하는 경향이 있는 TDD의 또 다른 변형이라는 것이 이 아티클의 유일한 관련성이기 때문에 여기서 더 자세히 다루지는 않겠다.

"classical"에 사용되는 "Detroit" 스타일과 "mockist"에 대해 "London"이 사용되는 경우가 있습니다. 이것은 XP가 원래 Detroit의 C3 프로젝트와 함께 개발되었고 mockist 스타일은 런던의 초기 XP 채택자들에 의해 개발되었다는 사실을 암시한다. 또한 많은 mockist TDDers가 그 용어를 싫어하고 실제로 classical과 mockist 테스팅 사이의 다른 스타일을 암시하는 모든 용어를 싫어한다는 점을 언급해야 한다. 그들은 두 스타일 사이에 유의미한 구분이 있다고 생각하지 않는다.

### Choosing Between the Differences

이 아티클에서 나는 한 쌍의 차이점을 설명했다. 상태(state) 또는 행동 검증(behavior verification) / classic 또는 mockist TDD. 이들 사이에서 선택을 할 때 염두에 두어야 할 주장은 무엇인가? state 대 behavior verification 선택부터 시작하겠다.

가장 먼저 고려해야 할 것은 context다. order와 warehouse처럼 쉬운 협업(easy collaboration)을 생각하고 있나요, 아니면 order와 메일 서비스처럼 어색한 협업(awkward collaboration)을 생각하고 있나요?

쉬운 협업이라면 선택은 간단하다. 내가 classic TDDer라면 mock, stub 또는 어떤 종류의 double도 사용하지 않겠다. 실제 객체와 상태 검증을 사용할 것이다. 내가 mockist TDDer라면 mock과 행동 검증(behavior verification)을 사용하겠다. 결정할게 없다.

어색한 협업(awkward collaboration)이고, mockist라면 따로 결정할게 없다. 그냥 mock을 사용하고 행동 검증(behavior verification)을 한다. 내가 classicist라면 선택의 여지가 있지만 어느 것을 사용해야 하는지는 그다지 중요하지 않다. 일반적으로 classicists들은 각 상황에 맞는 쉬운 방법으로 결정하면 된다.

따라서 state 대 behavior verification은 대부분 큰 결정이 아니다. 진짜 문제는 classic TDD와 mockist TDD 사이다. state 및 behavior verification의 특성이 해당 토론에 영향을 미치는 것으로 밝혀졌기 때문에 여기에서 대부분의 에너지를 집중할 것이다.

하지만 그 전에 극단적인 경우를 살펴보겠다. 가끔은 어색한 협업(awkward collaborations)이 아니더라도 상태 검증(state verification)을 사용하기 정말 어려운 일이 있는데, 좋은 예는 cache 다. cache의 요점은 cache의 hit 또는 missed 여부를 state에서 알 수 없다는 것이다. 이는 하드 코어 classical TDDer에 대해서도 behavior verification이 현명한 선택이 될 수 있는 경우다.

우리가 classic와 mockist을 알아볼 때 고려해야 할 많은 요소가 있으므로 대략적인 그룹으로 나누었다.

- Driving TDD
- Fixture Setup
- Test Isolation
- Coupling Tests to Implementations
- Design Style

### So should I be a classicist or a mockist?

이건 자신있게 대답하기 어려운 질문이라고 생각한다. 개인적으로 나는 항상 classic TDDer였으며 지금도 변경할 이유는 없다. mockist TDD의 장점을 보지 못했고, 테스트를 구현(implementation)에 결합(coupling)하는 것에 대해 우려하고 있다.

이건 내가 mockist 프로그래머를 관찰했을 때 충격을 받았던 부분이다. 테스트를 작성하는 동안 수행 방식(how it's done)이 아니라 behavior의 결과에 초점을 맞춘다는 사실. Mockist는 기대값을 작성하기 위해 SUT가 어떻게 구현될 것인지 끊임없이 생각하고 있었다. 이건 정말 부자연스럽게 느껴졌다.

또한 toy 이상으로 mockist TDD를 시도하지 않는 단점을 겪고 있다. Test Driven Development 자체에서 배웠듯이, 진지하게 시도하지 않고 기술을 판단하는 것은 종종 어렵다. 나는 매우 행복하고 확신에 찬 mockists 개발자들을 많이 알고 있다. 그래서 나는 여전히 확신에 찬 classicist이지만, 나는 당신이 스스로 결정할 수 있도록 가능한 한 공정하게 두 주장을 제시하고 싶다.

따라서 mockist 테스팅이 매력적으로 들린다면 시도해 볼 것을 제안한다. Mockist TDD가 개선하려는 일부 영역에서 문제가 있는 경우 특히 시도해 볼 가치가 있다. 여기 두 가지 주요 영역이 있다. 하나는 테스트가 제대로 중단되지 않고 문제가 있는 위치를 알려주기 때문에 테스트가 실패할 때 디버깅하는 데 많은 시간을 할애하는 경우다. (세밀한(finer-grained) 클러스터에서 classic TDD를 사용하여 이를 개선할 수도 있다.) 두 번째는 객체에 충분한 behavior이 포함되어 있지 않은 경우, mockist 테스팅을 통해 개발 팀이 behavior이 풍부한 객체를 생성하도록 권장할 수 있다.

### Final Thoughts

unit testing에 대한 관심이 높아지면서 xunit 프레임워크와 테스트 주도 개발(Test Driven Development)이 성장하면서 점점 더 많은 사람들이 mock 객체를 마주하게 되었다. 오랜 시간 동안 사람들은 그것을 뒷받침하는 mockist/classical 구분을 완전히 이해하지 못한 채 mock 객체 프레임워크에 대해 조금 배우게 된다. 그 구분의 어느 쪽에 기댈지 간에, 이러한 관점의 차이를 이해하는 것이 유용하다고 생각한다. mock 프레임워크를 찾기 위해 mockist가 될 필요는 없지만, 소프트웨어의 많은 디자인 결정을 안내하는 사고를 이해하는데에 도움된다.

이 아티클의 목적은 이러한 차이점을 지적하고 그들 사이의 절충안을 제시하는 것이었다. mockist적인 사고에는 내가 시간을 투자한 것보다 더 많고, 특히 디자인 스타일에 미치는 영향이 더 많다. 앞으로 몇 년 동안 이것에 대해 더 많이 쓰여진 것을 보고 코드 전에 테스트를 작성하는 것의 매혹적인 결과에 대한 우리의 이해를 심화할 수 있기를 바린다.

---

### 참고
- [Mocks Aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html#TestIsolation)
