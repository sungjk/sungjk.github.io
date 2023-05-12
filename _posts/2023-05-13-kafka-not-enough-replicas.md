---
layout: entry
title: Kafka의 ACKS, ISR 설정에 따른 NOT_ENOUGH_REPLICAS 에러 원인 살펴보기
author-email: ajax0615@gmail.com
description: Kafka의 Broker(replication.factor, min.insync.replicas), Producer(acks) 옵션들을 살펴보면서 NOT_ENOUGH_REPLICAS 에러가 발생했던 원인을 분석해봅니다.
keywords: kafka, NOT_ENOUGH_REPLICAS, acks, replication.factor, min.insync.replicas
publish: true
---

운영중인 서비스에서 카프카로 이벤트 메시지를 발행하고 있다. 그런데 어느날 갑자기 개발 환경에서 아래와 같은 에러가 발생하면서 Producer의 메시지 발행이 실패하고 있었다.

![publish-error](/images/2023/05/13/publish-error.png "publish-error"){: .center-image }

그리고 위 에러와 관련 있어 보이는 아래 메시지도 발견하였다.

```
org.springframework.kafka.core.KafkaProducerException: Failed to send; nested exception is org.apache.kafka.common.errors.TimeoutException: Expiring 1 record(s) for (...):120001 ms has passed since batch creation
	...
Caused by: org.apache.kafka.common.errors.TimeoutException: Expiring 1 record(s) for (...):120001 ms has passed since batch creation
```

첫번째 에러 메시지를 보면 `NOT_ENOUGH_REPLICAS` 라는 키워드가 눈에 들어온다. 이거 어디서 봤던거 같은데... 기억은 안나고.  Replication? 메시지를 발행하는 Producer의 문제는 아닌것 같아서 ChatGPT에게 물어봤다.

![chatgpt-answers](/images/2023/05/13/chatgpt-answers.png "chatgpt-answers"){: .center-image }

에러가 발생한 원인은 Broker가 Producer의 요청은 받았지만 내부적으로 설정된 **In-Sync Replica(ISR)**가 충분치 않기 때문이라고 한다. 이 에러를 방지하려면 `min.insync.replicas` 옵션을 조정해서 최소 ISR 수를 설정하면 된다고 한다. 이 내용만 가지고는 속이 시원하지 않아서 `NOT_ENOUGH_REPLICAS` 키워드를 가지고 검색해보았는데, 기초적인 내용이지만 카프카의 Resilient 전략을 아주 잘 이해할 수 있었다.

> 이 내용은 무려.. 2년전에 공부하면서 작성한 [Kafka Producer 알아보기](https://sungjk.github.io/2021/01/23/kafka-producer.html) 글에도 있는 내용인데 카프카와 가깝게 지내지 않다보니 잊고 살았던거 같다..

이 에러가 정확히 왜 발생한건지 이해하기 위해서는 카프카의 Replication, Acks, ISR에 대해서 이해하고 있어야 한다. 아래에서 이어서 살펴보자.

---

### Replication

카프카는 하나의 토픽에 여러 개의 파티션이 존재할 수 있고, 각 파티션에는 여러 개의 복제본(Replicas)으로 나누어져 있다. 그리고 카프카 그 자체라고 부를 수 있는 Broker는 특정 파티션에 대한 읽기와 쓰기 작업을 처리하는 역할을 한다. 이 때 각 파티션에는 Leader와 Follower라는 역할로 나누어져 있다. 

![leader-follower](/images/2023/05/13/leader-follower.png "leader-follower"){: .center-image }

Leader는 해당 파티션의 모든 읽기와 쓰기 요청을 처리하는데, 모든 Replication에 대한 업데이트를 책임지는 역할을 한다. 즉, 클러스터의 모든 요청은 해당 파티션의 Leader에게 전달되고 Leader는 Replication에 업데이트를 전파한다.

그리고 Follower는 Leader의 복제본(Replication)이다. Leader에서 전파된 업데이트를 동기화해서 최신 상태로 유지한다. 이 때, Leader와 Follower 간의 동기화는 비동기적으로 처리되기 때문에, 일시적으로 데이터의 일관성이 떨어질 수 있다. 그래서 카프카에는 일관성을 유지하기 위해 Replication의 동기화 및 상태 변화를 체크하는 **ISR(In-Sync Replicas)**라는 개념이 도입되었다.

만약 Leader가 어떤 이유에 의해서 죽게 되면, 카프카는 자동으로 새로운 Leader를 선택한다(Leader Election). 데이터 일관성을 유지하기 위해, 가장 최신 상태를 유지하고 있는, ISR 목록 중 가장 마지막에 업데이트된 복제본을 새로운 Leader로 선택한다. 이런 Leader 선출 과정은 모두 자동으로 이루어지기 때문에, 이 과정에서 일시적으로 데이터 일관성이 떨어지는걸 방지하기 위해 카프카 클러스터의 구성과 설정을 신중하게 선택해야 한다.

토픽의 Replication 수를 설정하기 위해서는 `replication.factor` 속성을 이용하면 된다([Broker Configs > default.replication.factor](https://kafka.apache.org/documentation/#brokerconfigs_default.replication.factor)). 토픽의 Replication을 여러 대의 Broker에 분산 저장함으로써 데이터의 안정성과 가용성을 보장할 수 있는데, `replication.factor` 값은 Broker의 수보다 크면 안된다. 예를 들어, `replication.factor=3` 으로 설정하면, 각 파티션은 3개의 Replication을 가지게 되고, 3개의 Replication 중 1개를 Leader로 선택하고 나머지 2개를 Follower로 지정한다. 이 때, 하나의 복제본이 실패하더라도 다른 복제본에서 데이터를 읽을 수 있다(안정성/가용성 보장). 하지만 `replication.factor` 을 무작정 높이면 데이터 동기화 시간이 더 오래 걸리게 되어 처리에 지연이 발생할 수 있고, 클러스터의 용량에도 영향을 미칠 수 있다. 

더 자세한 내용은 고승범님의 [Kafka 운영자가 말하는 Topic Replication](https://www.popit.kr/kafka-%EC%9A%B4%EC%98%81%EC%9E%90%EA%B0%80-%EB%A7%90%ED%95%98%EB%8A%94-topic-replication/)에서 더 확인할 수 있다.

### Acks(acknowledgments)

그리고 다음으로 알아야 할 내용인 Ack. Ack는 메시지를 발행하는 Producer가 해당 메시지가 성공적으로 커밋이 되어서 Broker가 잘 받았는지 확인하기 위한 과정(방법)이다. 즉, 메시지의 안전성을 보장하기 위해 도입된 개념이라고 볼 수 있다. Ack에는 아래 내용처럼 다양한 값을 설정할 수 있다([Producer Configs > acks](https://kafka.apache.org/documentation/#producerconfigs_acks)).

| acks | description |
| :---: | :---: |
| `0` | Producer가 메시지를 보내면 응답이 바로 리턴되며, Broker가 메시지를 잘 수신하고 처리했는지 확인하지 않는다. 따라서 메시지가 손실될 수는 있지만 반대로 Producer 입장에서는 높은 처리량을 얻을 수 있다. |
| `1` | Producer가 메시지를 보내면 Leader가 메시지를 수신하고 처리한 다음 ISR 중에서 최소 1개의 Follower가 메시지를 복제하고 처리했는지 확인한다. 메시지 손실 가능성은 적지만 모든 ISR의 처리를 거치기 않기 때문에 Broker 장애 등으로 인해 메시지가 유실될 가능성이 있다. |
| `all` or `-1` | Producer가 메시지를 보내면 Leader와 모든 Follower가 메시지를 수신하고 처리한 후 응답이 리턴된다. 이 경우 메시지 손실 가능성은 매우 적지만, 네트워크 지연 등으로 인해 처리량이 떨어질 수 있다. |

![broker-acks](/images/2023/05/13/broker-acks.png "broker-acks"){: .center-image }

위 그림을 보면, `acks=all`로 설정되어 있으면, Leader로부터 ack 응답을 받는 것에 더해 모든 Replication으로의 동기화까지 잘 이루어져야만 Producer는 성공적인 커밋으로 처리할 수 있다.

### ISR(In Sync Replicas)

마지막으로, ISR(In-Sync Replica)은 위에 Replication 얘기할 때에도 잠깐 나왔었는데, **Leader와 동기화된 상태를 유지하고 있는 복제본(replicas)의 집합**을 의미한다. 파티션에 메시지를 안전하게 보내기 위한 전략이라고 볼 수 있다(fault tolerance).

ISR의 크기는 바로 위에서 살펴본 Producer의 akcs 설정 값에 따라 결정된다. 예를 들어, `acks=all` 또는 `acks=-1` 로 설정하면, 모든 복제본이 메시지를 처리하고 ISR에 포함되어야 한다. 반면, `acks=1` 로 설정하면, 최소한 하나의 복제본만이 ISR에 포함되면 된다.

그리고 이 ISR의 크기(최소 복제본 수)는 Broker의 옵션 중 하나인 `min.insync.replicas` 속성을 통해서 설정할 수 있다([Broker Configs > min.insync.replicas](https://kafka.apache.org/documentation/#brokerconfigs_min.insync.replicas)). 예를 들어, `min.insync.replicas=2` 로 설정하면, 메시지를 복제하는 동안 Leader와 동기화된 Follower가 최소 2개 이상 있어야 한다. 이 설정은 ISR의 크기를 결정하는데 사용되며, 위에서도 말했듯 메시지 전송 안정성을 높이기 위해 사용된다. 하지만.. 이 값을 무작정 높이게 되면 ISR 크기는 커지고 Producer 입장에서는 메시지 전송 대기 시간이 길어질 수 있다. 따라서 이 값을 적절히 설정하는게 중요하다.

### 추측해보기

그럼 다시 돌아와서. ChatGPT가 알려주기를, `NOT_ENOUGH_REPLICAS` 에러는 ISR이 충분치 않기 때문이라고 했다. 위에서 알아본 Replication, Acks, ISR에 대한 개념을 정리하면서 원인을 추측해보자. 

Replicas가 충분치 않다.. 부족하다.. Broker의 `min.insync.replicas` 옵션은 Producer가 보낸 메시지를 성공적으로 처리하기 위해 동기화가 필요한(확인이 필요한) 최소 크기를 나타낸다고 했다. 그리고 만약 Producer의 `acks` 옵션이 `all` 로 설정되어 있다면, Leader와 모든 Follower의 동기화가 필요하고, `min.insync.replicas`에 설정된 값 이상의 Replication이 동기화가 되어 있을 때에만 Producer는 성공적으로 메시지를 발행했다는 응답을 받을 것이다. 만약 그렇지 않고 `min.insync.replicas`에 설정된 값보다 **적은 수의 복제본이 ISR에 속해 있으면 Producer는 메시지 전송에 실패한 응답**을 받을 것이다(동기화 확인 실패로 인해).

그리고 에러가 발생했던 코드의 흐름을 추적해서 들어가보면 [org.apache.kafka.common.errors.NotEnoughReplicasException](https://kafka.apache.org/31/javadoc/org/apache/kafka/common/errors/NotEnoughReplicasException.html), [org.apache.kafka.common.protocol.Errors.NOT_ENOUGH_REPLICAS](https://archive.apache.org/dist/kafka/0.8.2-beta/java-doc/org/apache/kafka/common/protocol/Errors.html#NOT_ENOUGH_REPLICAS) 클래스에는 아래와 같이 파티션의 ISR 수가 `min.insync.replicas`에 설정된 값보다 적을때 발생한다는 메시지를 확인할 수 있다.

![exception-code](/images/2023/05/13/exception-code.png "exception-code"){: .center-image }

![exception](/images/2023/05/13/exception.png "exception"){: .center-image }


### 정확한 원인은?

그럼 지금 서비스중인 Producer의 `acks` 설정과 Broker의 `replication.factor`, `min.insync.replicas` 설정 값을 확인해보면 에러의 정확한 발생한 원인을 찾을 수 있을것 같다. 확인해보니 아래와 같이 설정되어 있었다.

- Producer: `acks=all`
- Broker: `default.replication.factor=3`, Broker > `min.insync.replicas=2`

위 옵션들을 기반으로 Producer가 메시지를 보내고 Broker가 처리하는 과정은 다음과 같다.

1. Producer가 메시지를 보내면 먼저 Leader 파티션에게 메시지를 보낸다. 
2. `acks=all` 설정으로 인해 Leader 파티션은 메시지를 모든 Replication에게 동기화할 때까지 대기한다. 더 자세히는, 자신의 로컬 디스크에 저장한 후 동기화가 필요한 Follower 파티션들에게 메시지를 전송한다. 이 때, `replication.factor=3` 설정으로 인해 각 파티션은 3개의 복제본 중 2개 이상의 복제본이 동기화된 후에만 데이터를 저장하게 된다.
3. `min.insync.replicas=2` 설정은 Producer가 메시지를 보내기 위해 동기화되어야 하는 최소한의 복제본 수가 2개임을 의미한다. 따라서 Producer가 메시지를 보내기 위해서는 적어도 2개 이상의 Replication이 동기화되어야 한다. 만약 동기화된 Replication 수가 2개 미만이면 Producer는 메시지 전송 실패 응답을 받게 된다.

이 과정에서 에러가 발생할 수 있는 케이스는 이정도가 있을거 같다. 

![ack-isr](/images/2023/05/13/ack-isr.png "ack-isr"){: .center-image }
<center>acks=all인 경우 min.insync.replicas에 따른 차이점</center>

1. **Broker 중 하나 이상이 다운된 경우**. 3개의 Replication이 존재해야 하고(`replication.factor=3`), 최소한 2개의 Replication이 동기화되어야 하므로(`min.insync.replicas=2`), 2개 이상의 Broker가 정상 동작하고 있어야 한다. 만약 Broker 중 하나 이상이 다운되면 Replication의 수가 2개 미만이 될 수 있으므로 에러가 발생할 것이다.
2. **모든 Replication이 동기화되지 않은 경우**. 3개의 Replication이 존재하면 이 중에서 최소 2개의 Replication이 동기화되어야 한다(`min.insync.replicas=2`). 만약 1개의 Replication만 동기화되었다면 에러가 발생할 것이다.
3. 그리고. `min.insync.replicas` > `replication.factor` 인 경우에도 동일한 에러가 발생할 것 같은데, 위 설정된 값은 여기에 해당되지 않으므로 이 경우는 해당되지 않는다. 모든 Replication이 동기화되어도 `min.insync.replicas` 에 맞는 수의 Replication을 동기화하지 못하므로 에러가 발생할 것이다. 바보 같은 설정값...

마침 SRE 팀에서 Broker 하나가 클러스터 내에서 조회가 안되고 있다는 공유를 해주었다. Broker의 `replication.factor=3` 설정으로 인해 각 파티션은 최소한 3개의 복제본을 가져야하고, 클러스터 내에 3개 이상의 Broker가 존재해야 한다. 이 때 3개의 복제본 중에서 적어도 `min.insync.replicas` 설정된 값만큼의 복제본이 ISR에 존재해야 하는거고. 그런데 ISR에 포함된 복제본이 3개 미만이기 때문에 해당 파티션의 모든 복제본은 동기화가 되지 않은 상태가 되었다. 그리고 이 현상으로 인해 `acks=all` 설정을 사용하여 메시지를 전송하는 Producer 입장에서는 `NOT_ENOUGH_REPLICAS` 에러를 받게 되었다.

![broker-nodes](/images/2023/05/13/broker-nodes.png "broker-nodes"){: .center-image }
<center>SRE팀에서 공유해 준 Broker 노드 상태</center>

실제로 Broker 하나가 왜 클러스터 내에서 조회가 안되었는지는 SRE팀에서 인프라 담당자에게 문의를 해놨다. 이와 별개로 매번 클라이언트 코드만 작성하는 입장에서, Broker의 다양한 옵션들과 Kafka 내부의 Replication 전략, 그리고 Producer의 옵션이 어떠한 영향을 미치는지까지, 자세히 알아보고 학습할 수 있는 기회가 되었다.

### 참고
- [Kafka - Producer Configs](https://kafka.apache.org/documentation/#producerconfigs)
- [Kafka 운영자가 말하는 Topic Replication](https://www.popit.kr/kafka-%EC%9A%B4%EC%98%81%EC%9E%90%EA%B0%80-%EB%A7%90%ED%95%98%EB%8A%94-topic-replication/)
- [Kafka 운영자가 말하는 Producer ACKS](https://www.popit.kr/kafka-%EC%9A%B4%EC%98%81%EC%9E%90%EA%B0%80-%EB%A7%90%ED%95%98%EB%8A%94-producer-acks/)
- [10 Configs to Make Your Kafka Producer More Resilient](https://towardsdatascience.com/10-configs-to-make-your-kafka-producer-more-resilient-ec6903c63e3f)
- [Hands-Free Kafka Replication: A Lesson in Operational Simplicity](https://www.confluent.io/blog/hands-free-kafka-replication-a-lesson-in-operational-simplicity/)
- [The default Amazon MSK configuration](https://docs.aws.amazon.com/msk/latest/developerguide/msk-default-configuration.html)