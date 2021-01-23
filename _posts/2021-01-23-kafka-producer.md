---
layout: entry
post-category: kafka
title: Kafka Producer 알아보기
author: 김성중
author-email: ajax0615@gmail.com
description: 데이터 플랫폼의 최강자 Kafka의 Producer에 대해서 알아봅니다.
keywords: kafka, consumer
publish: true
---

Kafka는 비즈니스 소셜네트워킹 서비스인 [링크드인](https://www.linkedin.com/)에서 시스템 복잡도가 늘어나고 파이프라인이 파편화됨에 따라, 개발이 지연되고 데이터 신뢰도가 떨어지는 문제를 해결하기 위해 만들어진 데이터 처리 시스템이다. 초기 Kafka는 다음과 같은 목표를 가지고 만들어졌다.

- Producer와 Consumer의 분리
- 메시지 시스템과 같이 영구 메시지 데이터를 여러 Consumer에게 허용
- 높은 처리량을 위한 메시지 최적화
- 데이터가 증가함에 따라 Scale out이 가능한 시스템

![Apache Kafka](/images/2021/01/10/logo.png "Apache Kafka"){: .center-image }

Kafka의 여러 속성 중에서도 Producer에 대해 알아보기 위해 [Kafka, 데이터 플랫폼의 최강자](http://www.yes24.com/Product/Goods/59789254)을 읽고 정리하였다. Producer의 주요 기능은 각각의 메시지를 Topic 파티션에 맵핑하고 파티션의 Leader에 요청을 보내는 것이다. 키 값을 정해 해당 키를 가진 모든 메시지를 동일한 파티션으로 전송할 수 있고, 만약 키 값을 입력하지 않으면 파티션은 라운드 로빈 방식으로 파티션에 균등하게 분배된다.

---

# Producer의 주요 옵션
**bootstrap.servers**<br/>
Kafka 클러스터에 처음 연결을 하기 위한 호스트와 포트 정보로 구성된 리스터 정보이다. 정의된 포맷은 호스트명:포트 형식의 리스트이다. Kafka 클러스터는 살아있는 상태이지만 해당 호스트만 장애가 발생하는 경우 접속이 불가하기 때문에, 리스트 전체를 입력하는 것을 권장한다. 만약 주어진 리스트의 서버 중 하나에서 장애가 발생할 경우 클라이언트는 자동으로 다른 서버로 재접속을 시도한다.

**acks**<br/>
Topic의 Leader에게 메시지를 보낸 후 요청을 완료하기 전 ack의 수. 옵션의 수가 작으면 성능이 좋지만, 메시지가 손실될 수 있다. 수가 크면 성능은 떨어지지만 손실 가능성도 줄어든다.

**acks=0**<br/>
Producer는 자신이 보낸 메시지에 대한 ack를 기다리지 않는다. 서버가 데이터를 받았는지 보장하지 않고, 클라이언트는 전송 실패에 대한 결과를 알지 못하기 때문에 재요청 설정도 적용되지 않는다. 메시지가 손실될 수 있지만, 높은 처리량을 얻을 수 있다.

**acks=1**<br/>
Leader로부터 메시지를 잘 받았는지 ack를 기다린다. Follower들은 확인하지 않는다.

**acks=all 또는 -1**<br>
Leader와 Follower로부터 메시지를 잘 받았는지 ack를 기다린다. 최소 하나의 Follower가 있는 한 데이터는 손실되지 않으며, 데이터 무손실을 보장한다.

**buffer.memory**<br/>
Producer가 Kafka 서버로 데이터를 보내기 위해 잠시 대기 할 수 있는 전체 메모리 바이트.

**compression.type**<br/>
어떤 타입으로 압축할지를 결정.

**retries**<br/>
일시적인 오류로 인해 전송에 실패한 데이터를 다시 보내는 횟.

**batch.size**<br/>
Producer는 같은 파티션으로 보내는 여러 데이터를 함께 배치로 보내려고 시도한다. 정의된 크기보다 크기보다 큰 데이터는 배치를 시도하지 않는다. 만약 고가용성이 필요한 메시지의 경우라면 배치 사이즈를 주지 않는 것도 하나의 방법이다.

**linger.ms**<br>
배치 형태의 메시지를 보내기 전에 추가적인 메시지들을 위해 기다리는 시간을 조정. 0이 기본값(지연 없음)이며, 0보다 큰 값을 설정하면 지연 시간은 조금 발생하지만 처리량이 좋다.

---

# 메시지 전송 방법
acks 옵션 설정에 따라 메시지 손실 여부와 메시지 전송 속도 및 처리량 등이 달라진다.

### 메시지 손실 가능성이 높지만 빠른 전송이 필요한 경우
일부 메시지 손실을 감안하더라도 매우 빠르게 전송이 필요한 경우에 옵션을 acks=0로 설정하면 된다. Kafka로부터 응답을 기다리지 않고 Producer만 준비되면 즉시 보내기 때문에 매우 빠르게 메시지를 보낼 수 있다. Producer가 Kafka로부터 자신이 보낸 메시지에 대해 응답을 기다리지 않기 떄문에 메시지가 손실될 수 있다.

### 메시지 손실 가능성이 적고 적당한 속도의 전송이 필요한 경우
옵션을 akcs=1로 설정하면 된다. Producer가 Kafka로 메시지를 보낸 후 보낸 메시지에 대해 Kafka가 잘 받았는지 확인(acks)을 한다. 확인을 기다리는 시간이 추가되어 메시지를 보내는 속도는 약간 떨어지게 된다.

![Producer acks](/images/2021/01/23/producer-acks-1.png "Producer acks"){: .center-image }

1. Producer가 acks=1 옵션으로 Leader에게 메시지를 보낸다.
2. Leader는 메시지를 받은후 저장하고, Producer에게 메시지를 받았다고 acks를 보낸다.
3. Follower들은 Leader를 주기적으로 바라보고 있다가, Leader에 새로운 메시지가 있는 것을 확인하고 Follower들도 저장한다.

메시지 손실 등의 문제가 발생하는 경우는 바로 Leader에 장애가 발생하는 순간이다. Producer가 전송한 메시지가 한쪽의 브로커에만 저장되어 있는 상태이고 Follower들은 Leader가 급작스럽게 다운되면서 해당 메시지를 가지고 있지 않게 되면, Kafka에서는 Replication 동작 방식에 따라 Leader가 다운되었기 때문에 Follower 중 하나가 새로운 Leader가 되고 Producer의 요청을 처리하게 된다.

### 전송 속도는 느리지만 메시지 손실이 없어야 하는 경우
옵션을 akcs=all로 설정하면 Producer가 메시지를 전송하고 난 후 Leader가 메시지를 받았는지 확인하고 추가로 Follower까지 메시지를 받았는지 확인한다. acks=all을 완벽하게 사용하고자 한다면, Producer의 설정 뿐만 아니라 브로커의 설정도 같이 조정해야 한다(min.insync.replicas).

![Producer acks](/images/2021/01/23/producer-acks-all.png "Producer acks"){: .center-image }

1. Producer가 acks=all 옵션으로 Leader에게 메시지를 보낸다.
2. Leader는 메시지를 받은후 저장하고, Producer에게 메시지를 받았다고 acks를 보낸다.
3. Follower들은 Leader를 주기적으로 바라보고 있다가, Leader에 새로운 메시지가 있는 것을 확인하고 Follower들도 저장한다.
4. Leader와 Follower들은 Producer에게 메시지를 받았다고 acks를 보낸다.

위에서 언급한 min.insync.replicas 옵션은 Producer가 acks=all로 메시지를 보낼 때 write를 성공하기 위한 최소 Replication 수를 의미한다. min.insync.replicas=1로 설정되어 있으면 모든 Follower들이 Replication을 실패하더라도 파티션의 Leader는 Producer에게 acks를 보낼 수 있다. 즉, 브로커 노드 2대가 다운되더라도 Producer는 정상적으로 다음 메시지를 보낼 수 있는 상황이다.

![broker-replicas-1](/images/2021/01/23/broker-replicas-1.png "broker-replicas-1"){: .center-image }

min.insync.replicas=2로 설정되어 있으면 최소 Replication 수가 2인데, 아래 그림에서는 모든 Follower들이 다운된 상태이므로 Producer 입장에서 받은 acks 수가 최소 Replication 수보다 작기 때문에 정상적으로 다음 메시지를 보낼 수 없게 된다.

![broker-replicas-2](/images/2021/01/23/broker-replicas-2.png "broker-replicas-2"){: .center-image }

---

### References
- [Kafka, 데이터 플랫폼의 최강자](http://www.yes24.com/Product/Goods/59789254)
- [Kafka 운영자가 말하는 Producer ACKS](https://www.popit.kr/kafka-%EC%9A%B4%EC%98%81%EC%9E%90%EA%B0%80-%EB%A7%90%ED%95%98%EB%8A%94-producer-acks/)
- [10 Configs to Make Your Kafka Producer More Resilient](https://towardsdatascience.com/10-configs-to-make-your-kafka-producer-more-resilient-ec6903c63e3f)
