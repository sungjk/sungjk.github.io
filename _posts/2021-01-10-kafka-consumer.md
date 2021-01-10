---
layout: entry
post-category: kafka
title: Kafka Consumer 알아보기
author: 김성중
author-email: ajax0615@gmail.com
description: 데이터 플랫폼의 최강자 Kafka의 Consumer에 대해서 알아봅니다.
keywords: kafka, consumer
publish: true
---

Kafka는 비즈니스 소셜네트워킹 서비스인 [링크드인](https://www.linkedin.com/)에서 시스템 복잡도가 늘어나고 파이프라인이 파편화됨에 따라, 개발이 지연되고 데이터 신뢰도가 떨어지는 문제를 해결하기 위해 만들어진 데이터 처리 시스템이다. 초기 카프카는 다음과 같은 목표를 가지고 만들어졌다.

- Producer와 Consumer의 분리
- 메시지 시스템과 같이 영구 메시지 데이터를 여러 Consumer에게 허용
- 높은 처리량을 위한 메시지 최적화
- 데이터가 증가함에 따라 Scale out이 가능한 시스템

![Apache Kafka](/images/2021/01/10/logo.png "Apache Kafka"){: .center-image }

Kafka의 여러 속성 중에서도 Consumer에 대해 알아보기 위해 [Kafka, 데이터 플랫폼의 최강자](http://www.yes24.com/Product/Goods/59789254)을 읽고 정리하였다. Consumer의 주요 기능은 특정 Partition을 관리하고 있는 Partition 리더에게 메시지 가져오기 요청을 하는 것이다. 각 요청은 로그의 Offset을 명시하고 그 위치로부터 로그 메시지를 수신한다.

---

# Consumer의 주요 옵션
**bootstrap.servers**<br/>
Kafka 클러스에 처음 연결하기 위한 호스트와 포트 정보로 구성된 리스트 정보이다. 정의된 포맷은 호스트명:포트 형식의 리스트로 구성

**fetch.min.bytes**<br/>
한 번에 가져올 수 있는 최소 데이터 사이즈. 만약 지정한 사이즈보다 작은 경우, 요청에 대해 응답하지 않고 데이터가 누적될 때까지 기다린다.

**group.id**<br/>
Consumer가 속한 Consumer 그룹을 식별하는 식별자

**enable.auto.commit**<br/>
백그라운드로 주기적으로 offset을 커밋한다.

**auto.offset.reset**<br/>
Kafka에서 초기 offset이 없거나 현재 offset이 더 이상 존재하지 않은 경우(데이터가 삭제)에 다음 옵션으로 리셋한다.
- earliest: 가장 초기의 offset 값으로 설정
- latest: 가장 마지막의 offset 값으로 설정
- none: 이전 offset 값을 찾지 못하면 에러

**fetch.max.bytes**<br/>
한 번에 가져올 수 있는 최대 데이터 사이즈

**request.timeout.ms**<br/>
요청에 대해 응답을 기다리는 최대 시간

**session.timeout.ms**<br/>
Consumer와 Broker 사이의 Session Timeout 시간. Broker가 Consumer가 살아있는것으로 판단하는 시간(기본값 10초).

**heartbeat.interval.ms**<br/>
그룹 coordinator에게 얼마나 자주 poll() 메서드로 heartbeat를 보낼 것인지 조정. session.timeout.ms와 밀접한 관계가 있으며 session.timeout.ms보다 낮아야 한다. 일반적으로 1/3 정도로 설정(기본값은 3초)

**max.poll.records**<br/>
단일 호출 poll()에 대한 최대 레코드 수를 조정. 이 옵션을 통해 애플리케이션이 폴링 루프에서 데이터 양을 조절할 수 있다.

**max.poll.interval.ms**<br/>
Consumer가 살아있는지를 체크하기 위해 heartbeat를 주기적으로 보내는데, Consumer가 계속해서 heartbeat만 보내고 실제로 메시지를 가져가지 않는 경우가 있을 수 있다. 이러한 경우 poll을 호출하지 않으면 무한정 해당 Partition을 점유할 수 없도록 장애라고 판단하고 Consumer 그룹에서 제외한 후 다른 Consumer가 해당 Partition에서 메시지를 가져갈 수 있게 한다.

**auto.commit.interval.ms**<br/>
주기적으로 offset을 커밋하는 시간

**fetch.max.wait.ms**<br/>
fetch.min.bytes에 의해 설정된 데이터보다 적은 경우 요청에 응답을 기다리는 최대 시간

---

# Partition과 메시지 순서
Consumer가 Topic에서 메시지를 가져올 때, Consumer는 Producer가 어떤 순서대로 메시지를 보냈는지 알 수 없다. Consumer는 오직 **Partition의 offset 기준**으로만 메시지를 가져온다. 따라서 Kafka에서는 Topic의 Partition이 여러개인 경우, 메시지의 순서를 보장할 수 없다. Kafka Consumer에서의 메시지 순서는 동일한 Partition 내에서는 Producer가 생성한 순서와 동일하게 처리하지만, Partition과 Partition 사이에서는 순서를 보장하지 않는다.

Kafka의 Topic으로 메시지를 보내고 받을때 메시지의 순서를 정확하게 보장받기 위해서는 Topic의 Partition 수를 1로 지정해야 한다.

Consumer는 Partition의 offset 기준으로만 메시지를 가져오기 때문에 Producer가 보낸 메시지 순서와 동일하게 메시지를 가져올 수 있는 것이다. 하지만 Partition 수가 하나이기 때문에 분산해서 처리할 수 없고, 하나의 Consumer에서만 처리할 수 있기 때문에 처리량이 높지 않다. 즉 처리량이 높은 Kafka를 사용하지만 메시지 순서를 보장해야 한다면 Partition 수를 하나로 만든 Topic을 사용해야 하며, 어느 정도 처리량이 떨어지는 부분은 감안해야 한다.

---

# Consumer 그룹
Consumer 그룹은 하나의 Topic에 여러 Consumer 그룹이 동시에 접속해 메시지를 가져올 수 있다. 이건 기존의 다른 메시징큐에서 Consumer가 메시지를 가져가면 큐에서 삭제되어 다른 Consumer가 가져갈 수 없는 것과는 다른 방식인데, 이 방식이 좋은 이유는 최근에 하나의 데이터를 다양한 용도로 사용하는 요구가 많아졌기 때문이다.

동일한 Topic에 대해 여러 Consumer가 메시지를 가져갈 수 있도록 Consumer 그룹이라는 기능을 제공한다. Consumer가 메시지를 가져가는 속도보다 Producer가 메시지를 보내는 속도가 더 빠르다면, Topic에는 시간이 지남에 따라 Consumer가 아직 읽어가지 못한 메시지들이 점점 쌓이게 된다. 이런 문제를 해결하기 위해서는 Consumer를 충분히 확장해야 하며, Kafka에서는 이와 같은 상황을 해결할 수 있도록 Consumer 그룹이라는 기능을 제공한다.

![Consumer Group](/images/2021/01/10/consumer-group-1.png "Consumer Group"){: .center-image }

동일한 Consumer 그룹 내 Consumer가 추가되면 각 Consumer가 가지는 Partition의 소유권이 바뀌게 된다. 이렇게 소유권이 이동하는 것을 리밸런스 *rebalance* 라고 한다. Consumer 그룹의 리밸런스를 통해 Consumer 그룹에는 Consumer를 쉽고 안전하게 추가할 수 있고 제거할 수도 있어 높은 가용성과 확장성을 확보할 수 있다. 리밸런스를 하는 동안 일시적으로 Consumer는 메시지를 가져올 수 없다는 단점이 있다.

![Consumer Group](/images/2021/01/10/consumer-group-2.png "Consumer Group"){: .center-image }

Consumer 수를 늘리더라도 Topic에는 계속 메시지가 쌓일 수 있다. Topic의 Partition에는 하나의 Consumer만 연결할 수 있기 때문이다. 결국 Topic의 Partition 수만큼 최대 Consumer 수가 연결할 수 있다. 만약 하나의 Partition에 두개의 Consumer가 연결된다면 안정적으로 메시지 순서를 보장할 수 없게 된다. 그래서 Kafka에서는 **하나의 Partition에 하나의 Consumer만 연결**할 수 있다.

![Consumer Group](/images/2021/01/10/consumer-group-3.png "Consumer Group"){: .center-image }

Topic의 Partition 수와 동일하게 Consumer 수를 늘렸는데도 Producer가 보내는 메시지의 속도를 따라가지 못한다면, Topic의 Partition 수를 늘려주고 Consumer 수도 같이 늘려줘야 한다.

Consumer가 Consumer 그룹 안에서 멤버로 유지하고 할당된 Partition의 소유권을 유지하는 방법은 heartbeat를 보내는 것이다. heartbeat는 Consumer가 poll할 때와 가져간 메시지의 offset을 커밋할 때 보내게 된다. 만약 Consumer가 오랫동안 heartbeat를 보내지 않으면 세션은 타임아웃되고 해당 Consumer가 다운되었다고 판단하여 리밸런스가 시작된다.

이러한 상황을 지속적으로 내버려두면 일부 메시지를 늦게 가져오는 현상이 발생할 수 있기 때문에 모니터링을 통해 Consumer의 장애 상황을 인지하고, 새로운 Consumer를 추가해 정상적인 운영 상태를 만드는 편이 좋다.

Kafka가 다른 메시지 큐와 차별화되는 특징은 하나의 Topic(큐)에 대해 여러 용도로 사용할 수 있다는 점이다. 일반적인 메시지 큐는 특정 Consumer가 메시지를 가져가면 큐에서 메시지가 삭제되어 다른 Consumer는 가져갈 수 없는데 Kafka는 Consumer가 메시지를 가져가도 삭제하지 않는다. 이런 특징을 이용해서 **하나의 메시지를 여러 Consumer가 다른 용도로 사용할 수 있도록 시스템을 구성**할 수 있다.

여러 Consumer 그룹들이 하나의 Topic에서 메시지를 가져갈 수 있는 이유는 Consumer 그룹마다 각자의 offset을 별도로 관리하기 때문에 하나의 Topic에 두개의 Consumer 그룹 뿐만 아니라 더 많은 Consumer 그룹이 연결되어도 다른 Consumer 그룹에게 영향 없이 메시지를 가져갈 수 있기 때문이다. 이렇게 여러 개의 Consumer 그룹이 동시에 하나의 Topic의 메시지를 이용하는 경우, Consumer 그룹 아이디는 서로 중복되지 않게 해야 한다.

---

# 커밋과 offset
Consumer가 poll()을 호출할 때마다 Consumer 그룹은 Kafka에 저장되어 있는 아직 읽지 않은 메시지를 가져온다. Consumer 그룹의 Consumer들은 **각각의 Partition에 자신이 가져간 메시지의 위치 정보(offset)을 기록**하고 있다. 각 Partition에 대해 현재 위치를 업데이트하는 동작을 commit이라고 한다.

![Offset](/images/2021/01/10/offset.png "offset"){: .center-image }

만약 커밋된 offset이 Consumer가 실제 마지막으로 처리한 offset보다 작으면 마지막 처리된 offset과 커밋된 offset 사이의 메시지는 중복으로 처리되고, 커밋된 offset이 Consumer가 실제 마지막으로 처리한 offset보다 크면 마지막 처리된 offset과 커밋된 offset 사이의 모든 메시지는 누락된다.

### 자동 커밋
자동 커밋을 사용하고 싶을 때는 Consumer 옵션 중 enable.auto.commit=true로 설정하면 5초마다 Consumer는 poll()을 호출할 때 가장 마지막 offset을 커밋한다. 5초 주기는 기본값이며, auto.commit.interval.ms 옵션을 통해 조정이 가능하다. 자동으로 offset을 커밋하는 방법은 매우 편리하지만, 중복 등이 발생할 수 있기 때문에 동작에 대해 완벽하게 이해하고 사용하는 것이 중요하다.

![Commit](/images/2021/01/10/commit.png "commit"){: .center-image }

### 수동 커밋
메시지 처리가 완료될 때까지 메시지를 가져온 것으로 간주되어서는 안 되는 경우에 사용한다.

예를 들어, Consumer가 메시지를 가져와서 데이터베이스에 메시지를 저장한다고 가정해보자. 만약 자동 커밋을 사용하는 경우라면 자동 커밋의 주기로 인해 poll하면서 마지막 값의 offset으로 자동 커밋이 되었고, 일부 메시지들은 데이터베이스에는 저장하지 못한 상태로 Consumer 장애가 발생한다면 해당 메시지들은 손신될 수도 있다. 이런 경우를 방지하기 위해 Consumer가 메시지를 가져오자마자 커밋을 하는 것이 아니라, 데이터베이스에서 메시지를 저장한 후 커밋을 해야만 안전하다.

하지만 수동 커밋의 경우에도 중복이 발생할 수 있다. 메시지들을 데이터베이스에 저장하는 도중에 실패하게 된다면, 마지막 커밋된 offset부터 메시지를 다시 가져오기 때문에 일부 메시지들은 데이터베이스에 중복으로 저장될 수 있다. 이렇게 Kafka에서 메시지는 한 번씩 전달되지만 장애 등의 이유로 중복이 발생할 수 있기 때문에 Kafka는 적어도 한 번(**중복은 있지만 손실은 없다**)을 보장한다.

---

### References
- [Kafka, 데이터 플랫폼의 최강자](http://www.yes24.com/Product/Goods/59789254)
- [Kafka Documentation](https://kafka.apache.org/documentation/)
- [Understanding Kafka Topics and Partitions](https://stackoverflow.com/a/51829144)
- [Apache Kafka Data Access Semantics: Consumers and Membership](https://www.confluent.io/blog/apache-kafka-data-access-semantics-consumers-and-membership/)
