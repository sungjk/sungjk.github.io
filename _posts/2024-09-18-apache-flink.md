---
layout: entry
post-category: flink
title: Apache Flink - Hello, World!
author-email: ajax0615@gmail.com
description: 실시간 데이터 처리를 위한 Apache Flink의 기본 개념과 간단한 예제를 살펴봅니다.
keywords: apache flink, flink, stream
thumbnail-image: /images/profile/flink.png
publish: true
---

Apache Flink를 처음 접하신 분이나 간단한 예제를 작성해보고 싶은 분들을 위해 작성한 글이에요. Architecture를 포함한 자세한 내부 동작 방식은 **[Apache Flink 공식 문서](https://flink.apache.org/)**를 참고해주시길 바랄게요.

# Apache Flink

### Stateful Computations over Data Streams

> Apache Flink is a framework and distributed processing engine for stateful computations over unbounded and bounded data streams. Flink has been designed to run in all common cluster environments, perform computations at in-memory speed and at any scale.

**[Apache Flink(이하 Flink)](https://flink.apache.org/)**는 데이터 스트리밍 및 배치 처리용 오픈 소스 프레임워크입니다. 비슷하게 데이터 스트리밍이나 배치 프로세싱을 위해 Kafka Streams, Spark, Kinesis 등이 있는데요, Flink 공식 홈페이지에 들어가면 먼저 Catchphrase가 눈에 들어옵니다. **Stateful Computations over Data Streams**. 왜 이 문구를 강조하고 있을까요?

![Apache Flink](/images/2024/09/18/apache-flink.png "Apache Flink"){: .center-image }

**스트림(Stream)**이란 **특정 시점에 일어난 이벤트의 연속**을 의미합니다. 예를 들어, 온도, 습도 등의 데이터를 실시간으로 수집하는 IoT 디바이스에서는 변화하는 온도와 습도가 스트림으로 구성될 수 있어요. 사용자가 앱에서 특정 버튼을 클릭한다던가 피드에서 스크롤을 하는 등의 행동 데이터들도 스트림으로 구성될 수 있습니다. 이처럼 스트림은 특정 시점에 일어나는 작고 독립된 변하지 않는 불변 객체입니다. 입력 데이터가 고정된 크기의 데이터 셋으로 제공되는 **배치 처리(Batch Processing)**와 다르게, 스트림 처리는(Stream Processing)은 입력 데이터가 지속적으로 발생하고 이걸 실시간으로 처리하는게 목표예요. Flink는 단순히 쏟아지는 데이터를 처리하는걸 목표로 하지 않고, 세션 윈도우(Session Window, 특정 시간 동안의 사용자 활동)나 집계(Aggregation, 평균, 총합 등) 등 **메모리 내에서 상태를 유지하고 관리**할 수 있는 강력한 기능을 제공합니다. 웹 애플리케이션에서 사용자가 다양한 페이지를 방문하는 동안 각 사용자의 세션을 실시간으로 추적한다던가, 결제 시스템에서 실시간으로 거래 데이터를 모니터링하고 특정 패턴을 찾아 이상 거래를 탐지하는 등 실시간으로 발생하는 스트림 데이터에서 상태를 유지하면서 연산을 수행할 수 있는 기능을 제공합니다. 그리고 Flink의 상태 관리 기능 덕분에 애플리케이션 개발자는 이 도구를 활용해서 다양한 실시간 애플리케이션을 구축하고 쉽게 운영할 수 있게 되었습니다.

도구를 잘 쓰려면 이 도구가 어떻게 돌아가는지, 그리고 어디에 쓰는 것이고 어떻게 쓰는 건지 아는게 중요하기 때문에 [Architecture](https://flink.apache.org/what-is-flink/flink-architecture/)와 [API](https://flink.apache.org/what-is-flink/flink-applications/)도 참고하시면 좋겠어요. Flink 학습을 위해 온라인 강의도 들어봤는데 아직까지는 공식 문서가 최고라 생각해요. 여기서 따로 설명은 하지 않겠습니다.

![Flink Task Manager](/images/2024/09/18/flink-task-manager.png "Flink Task Manager"){: .center-image }

<center>Flink Runtime Flow</center>

### Advantages

제가 서버 개발자니.. 개발자 관점에서 Flink의 가장 대표적인 특징을 꼽으라면 **Standalone**과 **Checkpoints**를 이야기하고 싶습니다. 일례로 데이터 스트리밍에 많이 활용되는 [Apache Kafka Streams](https://kafka.apache.org/documentation/streams/)은 애플리케이션의 일부로 실행되는 라이브러리인 반면, Flink는 자체 스트림 처리 엔진을 가지고 있는 프레임워크라서 독립적으로 배포와 실행이 가능합니다. IDEA에서 코드만 작성해서 실행하면 내장된 Mini Cluster를 기반으로 쉽게 디버깅까지 할 수 있습니다. 그리고 체크포인트(Checkpoints)를 통해 애플리케이션의 상태를 주기적으로 저장하여 장애 발생시 자동으로 복구해줍니다(Fault-tolerance). 정확히 한 번만(Exactly-Once) 처리한다던가 Two-Phase Commit 기반의 원자적 커밋을 통해 데이터 일관성을 보장할 수도 있습니다.

그리고 하나만 더 꼽으라면 데이터 프로세싱을 위한 고수준의 API에 대해서 이야기하고 싶어요. [Spark RDD](https://spark.apache.org/docs/latest/rdd-programming-guide.html)를 다뤄 보신 분들이라면 아주 쉽게 사용해볼 수 있을거라 생각해요.

![Flink Task Manager](/images/2024/09/18/spark-flink-operator.png "Flink Task Manager"){: .center-image }

이 Operator들은 Spark RDD를 모르더라도 Java나 Kotlin을 사용하거나 함수형 프로그래밍의 고차 함수(Higher-order Functions)에 익숙한 분들이라면 쉽게 접근할 수 있을거라 생각합니다. 쉴 새 없이 들어오는 데이터 스트림을 다른 형태로 변환하고 싶을때에는 `map`과 같은 함수를 이용해서 새로운 데이터 스트림으로 변환하고, 특정 조건에 만족하는 데이터만 필터링하고 싶다면 `filter` 함수를 사용하면 됩니다.

```kotlin
// 입력 데이터 스트림 생성
val input: DataStream<Int> = env.fromElements(1, 2, 3, 4, 5)

// Filter: 짝수인 요소만 필터링
val filtered: DataStream<Int> = input.filter(object : FilterFunction<Int> {
    override fun filter(value: Int): Boolean {
        return value % 2 == 0
    }
})

// Map: 필터링된 요소를 문자열로 변환
val stringified: DataStream<String> = filtered.map(object : MapFunction<Int, String> {
    override fun map(value: Int): String {
        return value.toString()
    }
})
```

### Use Cases

[Apache Flink Documentation](https://nightlies.apache.org/flink/flink-docs-stable/)을 살펴보면 Source와 Sink라는 용어가 많이 보이는데, Apache Flink 뿐만 아니라 데이터 엔지니어링에서 흔히 사용되는 용어입니다. **Source는 데이터 파이프라인의 시작 지점**으로, 데이터를 수집하여 시스템에 입력하는 역할을 합니다. **Sink는 데이터 파이프라인의 종료 지점**으로, 데이터를 외부 시스템으로 출력하여 저장하거나 전송하는 역할을 합니다. 데이터 소스(Source)와 데이터 싱크(Sink)로서 외부 시스템과 데이터를 주고 받을 수 있도록 여러 Connector를 제공하고 있어요. 현재(2024.09.18) 기준으로 아래와 같은 Source, Sink Connector를 제공하고 있습니다. 이 내용은 [Flink Project Connectors](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/datastream/overview/#flink-project-connectors)에서 확인할 수 있어요.

- [Apache Kafka](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/datastream/kafka/) (source/sink)
- [Amazon DynamoDB](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/datastream/dynamodb/) (sink)
- [Amazon Kinesis Data Streams](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/datastream/kinesis/) (source/sink)
- [Elasticsearch](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/datastream/elasticsearch/) (sink)
- [Opensearch](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/datastream/opensearch/) (sink)
- [FileSystem](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/datastream/filesystem/) (source/sink)
- [JDBC](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/datastream/jdbc/) (sink)
- [MongoDB](https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/datastream/mongodb/) (source/sink)
- [Redis](https://bahir.apache.org/docs/flink/current/flink-streaming-redis/) (sink)
- [Netty](https://bahir.apache.org/docs/flink/current/flink-streaming-netty/) (source)

**데이터 소스(source)에서 실시간으로 데이터를 읽어서, 새로운 형태로 변환하거나 로컬 스토리지에 저장해놓고 SQL 쿼리를 통해 유의미한 결과를 만들고, 데이터 싱크(sink)에 데이터를 출력**합니다. 이런 기능이 있다면 우리는 어떤 문제를 효과적으로 해결할 수 있을까요? [공식 문서의 대표적인 유스케이스](https://flink.apache.org/what-is-flink/use-cases/)에서는 이벤트 드리븐 애플리케이션 개발과 데이터 분석 그리고 데이터 파이프라인에 구축의 기반을 다지는데 사용될 수 있다고 말하고 있습니다.

![Event-driven Applications](/images/2024/09/18/flink-usecases-eventdrivenapps.png "Event-driven Applications"){: .center-image }

<center>Flink support event-driven applications</center>

![Data Analytics Applications](/images/2024/09/18/flink-usecases-analytics.png "Data Analytics Applications"){: .center-image }

<center>Flink support data analytics applications</center>

![Data Pipeline Applications](/images/2024/09/18/flink-usecases-datapipelines.png "Data Pipeline Applications"){: .center-image }

<center>Flink support data pipelines</center>

잠깐 아주 간단한 예시 하나를 살펴볼게요. 사용자의 요청을 받아서 처리하는 웹 서버가 Database(DB)에 쓰기를 하면서 동시에 검색을 위해 Elastic Search(ES)에도 데이터를 적재한다고 가정해볼게요. 이 때 DB의 쓰기 연산과 ES로의 쓰기 연산이 서로 원자적으로 묶일 수 없다면 어떤 문제가 생길까요? DB에 쓰기는 성공하고 ES에 쓰기는 실패했으면, 사용자가 게시글을 쓰는데에 성공했지만 검색에는 노출이 안되는 문제가 발생할거에요. 그래서 이런 문제를 해결하기 위해 DB 쓰기와 ES 쓰기를 Kafka와 같은 이벤트 브로커를 활용해서 분리하는 전략을 취할 수 있어요. 이런 문제를 해결하기 위해 다양한 방법이 존재하는데, Flink로는 어떻게 해결할 수 있는지 살펴볼게요.

![Sync Elastic Search](/images/2024/09/18/sync-es.png "Sync Elastic Search"){: .center-image }

<center>별도 Worker를 통해 ES 데이터 적재</center>

Flink 생태계에서 인기 있는 것 중 하나는 **[Flink CDC](https://nightlies.apache.org/flink/flink-cdc-docs-release-3.2/)**입니다. Flink CDC는 [Debezium](https://debezium.io/)을 기반으로 데이터베이스의 변경 로그를 실시간으로 캡쳐해서 타겟 시스템으로 반영할 수 있게 도와주는 도구입니다. **사용자가 DB에 쓰기 연산을 실행하면 Flink CDC가 변경 사항을 캡쳐해서 Kafka에 데이터 변경점을 기록하고, Flink 앱에서 변경점을 받아 변환을 한 다음 ES에 데이터를 적재**합니다.

![Flink CDC Usage](/images/2024/09/18/flink-cdc-usage.png "Flink CDC Usage"){: .center-image }

<center>Flink CDC 기반 ES 데이터 적재</center>

Kafka와 같은 이벤트 브로커를 중심으로 ES 쓰기를 실행하니, 언뜻 보기엔 바로 위에서 이야기한 'ES 적재를 이벤트 기반으로 분리'와 별반 다르지 않아 보입니다. 그런데 Flink 기반으로 문제를 해결할 때 취할 수 있는 장점은 위에서 잠깐 이야기한 체크포인트(Checkpoint)를 활용할 수 있다는 것입니다. 장애 복구 관점에서 Worker에서 ES 쓰기를 어디까지 했는지 별도 저장소에 관리를 해야 할 필요가 있는데, Flink 기반의 데이터 처리는 체크포인트와 상태 관리를 통해 장애 복구 뿐만 아니라 데이터의 일관성 보장을 높일 수 있습니다. 복잡한 상태 관리와 장애 복구 등의 작업은 플랫폼(라이브러리나 프레임워크)에 적절히 위임하고, 엔지니어는 이런 도구를 잘 활용하여 어떤 가치를 창출할 수 있을지에 집중하는게 중요합니다. 이런 고민과 선택은 사용자에게 일관된 최상의 경험을 제공하는 길로 이어질 수 있습니다. 

여기서 살펴본 건 하나의 예시일 뿐, 중요한 건 **\'흐르는 데이터에 어떤 빨때를 꽂아서 어디에 활용해 볼 수 있을까?\'**라는 질문을 가지고 계속해서 고민하는 것입니다. 관습적으로 배치 잡을 사용해 처리하던 작업들을 스트리밍 애플리케이션으로 전환해서 처리할 수는 없을까요? 만약 데이터 처리를 위해 Spring Batch 부터 떠올린다면 Stream Processing도 함께 살펴보시길 추천할게요.

---

# Quickstart

Apache Flink 애플리케이션을 실행하기 위해서는 먼저 Flink Cluster 환경 구축이 필요합니다. 클러스터를 통해 데이터를 병렬 처리하거나 내결함성을 제공해 데이터를 효율적으로 처리할 수 있습니다. 그리고 애플리케이션을 실행한다는 말은 Flink에 정의한 Job을 실행한다는 의미이기도 합니다. Cluster에는 실행 가능한 Jar 파일을 제출하면 되는데, 자바 애플리케이션 코드를 작성해서 빌드한 결과로 나온 Jar 파일을 제출하면 됩니다.

Production 환경에서 Flink 애플리케이션을 실행하려면 [Amazon Managed Service for Apache Flink](https://aws.amazon.com/managed-service-apache-flink/) 같은 솔루션을 써도 되고, [Flink Kubernetes Operator](https://nightlies.apache.org/flink/flink-kubernetes-operator-docs-stable/docs/try-flink-kubernetes-operator/quick-start/)를 이용해서 Kubernetes 위에서 Flink Cluster와 Job을 배포하고 관리할 수 있습니다. 여기서는 Mac OS 환경의 로컬 PC에서 Apache Flink 애플리케이션을 실행하는 여러 방법을 살펴보겠습니다.

### 1. IDEA에서 프로그램 실행

가장 편하고 유용한 방법은 IntelliJ IDEA에서 main 함수를 바로 실행하는 것입니다. Flink 애플리케이션을 실행하려면 Cluster에 실행 가능한 Jar 파일을 제출해야 되는데, IDEA에서 버튼만 누르면 바로 실행이 되고 디버깅까지 되니 신기할 따름입니다. 그 이유는 Apache Flink에서는 로컬 환경에서 Flink Cluster를 에뮬레이션할 수 있게끔 [MiniCluster](https://github.com/apache/flink/blob/master/flink-runtime/src/main/java/org/apache/flink/runtime/minicluster/MiniCluster.java)를 제공하기 때문입니다. 그래서 Flink 애플리케이션을 만드는 개발자는 실제 클러스터를 구축할 필요 없이 로컬 환경에서 Flink Cluster에 앱을 실행하는 것처럼 시뮬레이션을 할 수 있습니다.

![IDEA Run Application](/images/2024/09/18/idea-flink-run-application.png "IDEA Run Application"){: .center-image }

### 2. Local Flink Cluster 구축

또 다른 방법은 직접 Flink Cluster를 로컬 환경에 구축해서 사용하는 것입니다. [Apache Flink 공식 문서](https://nightlies.apache.org/flink/flink-docs-release-1.20/docs/try-flink/local_installation/)에서 Local Cluster를 구축할 수 있는 가이드를 제공하고 있습니다. Binary Release를 다운 받아서 압축을 푼 다음 아래 명령어를 실행해서 Flink Cluster를 시작하고 Jar 파일을 실행시켜서 Job을 제출할 수 있습니다.

```
# Flink Cluser 중지
$ ./bin/stop-cluster.sh

# Flink Cluser 시작
$ ./bin/start-cluster.sh

# Flink Cluster에 Flink Job 제출(실행)
$ ./bin/flink run examples/streaming/WordCount.jar

# Flink Cluster 로그 확인
$ tail -f log/flink-*
```

### 2-1. IDEA에 Flink Plugin 설치

IntelliJ IDEA에서 Big Data Tools 플러그인 번들로 함께 사용할 수 있는 [Flink Plugin](https://plugins.jetbrains.com/plugin/21702-flink)을 제공합니다. 이 플러그인을 사용하면 Flink Cluster를 모니터링하거나 직접 Flink Job을 제출할 수 있는 기능을 제공합니다.

![IDEA Settings](/images/2024/09/18/idea-settings-flink.png "IDEA Settings"){: .center-image }

![IDEA Test Connection](/images/2024/09/18/idea-settings-flink-test-connection.png "IDEA Test Connection"){: .center-image }

### 2-2. Local Cluster에 Jar 제출

IDEA에 생성된 Flink Console에서 Submit New Job 클릭후 + 버튼을 누르면 빌드된 Jar 파일을 선택할 수 있습니다. Jar 파일을 선택하고 나서 실행(Run) 버튼을 클릭하면 Flink Cluster에 Jar 파일이 제출되고 정상이라면 Job이 실행됩니다.

![IDEA Submit New Job](/images/2024/09/18/idea-flink-submit-new-job.png "IDEA Submit New Job"){: .center-image }

![IDEA Run Jar](/images/2024/09/18/idea-flink-run-jar.png "IDEA Run Jar"){: .center-image }

![IDEA Run Jar](/images/2024/09/18/idea-flink-run-jar-2.png "IDEA Run Jar"){: .center-image }


### 2-3. Local Cluster 모니터링

Console에서 Open in Browser 버튼을 클릭하면 현재 모니터링으로 연결된 Cluster의 상태를 확인할 수 있는 대시보드가 열립니다. 이 대시보드에서는 현재 실행중인 Job을 포함하여 Flink Cluster의 Task Manager, Job Manager 그리고 Clsuter logs 등을 확인할 수 있습니다.

![IDEA Cluster Web](/images/2024/09/18/idea-flink-cluster-web.png "IDEA Cluster Web"){: .center-image }

![IDEA Cluster Dashboard](/images/2024/09/18/idea-flink-cluster-dashboard.png "IDEA Cluster Dashboard"){: .center-image }

---

# Hello, World!

이제 Flink 애플리케이션 실행 환경이 구축되었으니 모든 프로그래밍의 시작인 Hello, World를 만들어보겠습니다. 프로그래밍 언어의 첫 시작은 콘솔에 `Hello, World!` 문자열을 출력하는 것인데, 데이터 프로세싱에서는 단어 개수를 세는 Word Count를 입문용 예제로 다루고 있습니다. 여기서는 Flink를 활용해 문자열에 포함된 특정 단어들의 개수를 출력하는 Word Count Job을 만들어보겠습니다. 전체 코드는 [Github - flink-hello-world](https://github.com/sungjk/flink-hello-world)에서 확인할 수 있어요.

```kotlin
import org.apache.flink.api.common.functions.FlatMapFunction
import org.apache.flink.api.common.typeinfo.TypeHint
import org.apache.flink.api.common.typeinfo.TypeInformation
import org.apache.flink.api.java.tuple.Tuple2
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment
import org.apache.flink.util.Collector

internal class WordCounterJob {
    // 데이터 소스로 사용할 문자열
    private val words = """
            The quick brown fox jumps over the lazy dog.
            The quick blue fox jumps over the lazy dog.
            The quick brown cat jumps over the lazy dog.
            The quick blue cat jumps over the lazy dog.
        """.trimIndent()

    fun execute(args: Array<String>) {
        // 스트리밍 실행 환경 생성
        val env = StreamExecutionEnvironment.getExecutionEnvironment()
        // 문자열 데이터 소스 생성
        val source = env.fromData(words).name("in-memory-source")
        val counts = source
            .flatMap(object : FlatMapFunction<String, Tuple2<String, Int>> {
                override fun flatMap(value: String, out: Collector<Tuple2<String, Int>>) {
                    // 입력 문자열을 소문자로 변환하고, 정규식을 사용하여 단어로 분리
                    val tokens = value.lowercase().split("\\W+".toRegex())
                    for (token in tokens) {
                        if (token.isNotEmpty()) {
                            // 각 단어와 그 단어의 개수를 나타내는 튜플(Tuple2<String, Int>)로 수집
                            out.collect(Tuple2(token, 1))
                        }
                    }
                }
            })
            // 반환 타입 정보 지정(Generic 타입의 한계를 해결하기 위해 TypeInformation을 사용)
            .returns(TypeInformation.of(object : TypeHint<Tuple2<String, Int>>() {}))
            .name("tokenizer")
            // 단어별로 그룹핑
            .keyBy { it.f0 }
            // 각 그룹별로 두번째 필드인 단어의 개수를 합산
            .sum(1)
            .name("counter")
        // 최종 결과를 표준 출력에 출력하는 싱크 연산 추가
        counts.print().name("print-sink")
        // 스트리밍 작업 실행
        env.execute("JeremyWordCount")
    }
}
```

아마 95% 이상의 Flink 애플리케이션은 Java 언어로 작성되어 있을거라 생각합니다(샘플 예제를 몇가지 찾아봤지만 코틀린 코드는 발견하지 못했어요). 저는 자바 언어를 썩 즐겨 쓰지는 않아서 Flink 애플리케이션도 Kotlin으로 작성하고 있습니다. 그러다보니 아주 간혹 타입 때문에 귀찮을 때가 있는데 크게 불편할 정도는 아닙니다.

---

# Troubleshootings

실행 환경 구축부터 스스로 Word Count 앱을 작성하기까지 몇가지 우여곡절이 있었습니다. 코드는 정말 몇 줄 안되는데 빌드 과정, Jar 파일 생성 문제, Java의 Type Erase 현상 등 여러 문제들을 겪고 해결하는 과정을 거쳤습니다.

### Jar 내에 Main class 찾을 수 없음

에러 로그:

```java
Neither a 'Main-Class', nor a 'program-class' entry was found in the jar file.
```

(해결 방법) Jar file에 Main class name 명시:

```kotlin
// application(main)
class Main {
    fun execute(args: Array<String>) {
        ...
    }

    // entry point is not a method inside the class
    // use @JvmStatic annotation inside the companion object
    companion object : Logger {
        @JvmStatic
        fun main(args: Array<String>) {
            val main = Main()
            main.execute(args)
        }
    }
}

// build.gradle.kts
tasks.jar {
    archiveFileName.set("hello-world.jar")
    manifest {
        // add main class name
        attributes["Main-Class"] = "io.sungjk.flink.Main"
    }
}
```

### Jar 내에 Flink Job 찾을 수 없음

```java
Could not get job jar and dependencies from JAR file: JAR file does not exist: ...
```

(해결 방법) Main Class 내에 테스트할 Job 추가:

```java

internal class WordCounterJob {
    ...
    fun execute(args: Array<String>) {
        val env = StreamExecutionEnvironment.getExecutionEnvironment()
        ...
        env.execute("JeremyWordCount")
    }
}
```

### gradle 모듈 의존성 찾지 못함

에러 로그:

```java
org.apache.flink.client.program.ProgramInvocationException: An error occurred while invoking the program's main method: io/sungjk/flink/common/utils/Logger
	at org.apache.flink.client.program.PackagedProgram.callMainMethod(PackagedProgram.java:378)
	at org.apache.flink.client.program.PackagedProgram.invokeInteractiveModeForExecution(PackagedProgram.java:223)
	at org.apache.flink.client.ClientUtils.executeProgram(ClientUtils.java:113)
	at org.apache.flink.client.cli.CliFrontend.executeProgram(CliFrontend.java:1026)
```

(해결 방법) Shadow Plugin 사용해서 모든 의존성을 단일 JAR 파일로 패키징한 후 shadowJar task 실행:

```java
plugins {
    ...
    id("com.github.johnrengelman.shadow") version "7.1.2"
}

tasks.shadowJar {
    archiveFileName.set("hello-world.jar")
    manifest {
        attributes["Main-Class"] = "io.sungjk.flink.Main"
    }
}
...
```

### Flink Cluster에서 타입 추론 불가(Type Erasure)

에러 로그:

```java
The return type of function 'execute(Main.kt)' could not be determined automatically, due to type erasure. You can give type information hints by using the returns(...) method on the result of the transformation call, or by letting your function implement the 'ResultTypeQueryable' interface.
	org.apache.flink.api.dag.Transformation.getOutputType(Transformation.java:557)
	org.apache.flink.streaming.api.datastream.DataStream.getType(DataStream.java:193)
	org.apache.flink.streaming.api.datastream.KeyedStream.<init>(KeyedStream.java:118)
	org.apache.flink.streaming.api.datastream.DataStream.keyBy(DataStream.java:293)
	...
```

(해결 방법) Flink의 TypeInformation 클래스를 사용하여 반환 타입 명시:

```java
...
val counts = source
    .flatMap(object : FlatMapFunction<String, Tuple2<String, Int>> {
        ...
    })
    // Flink의 TypeInformation 클래스를 사용하여 반환 타입 명시
    .returns(TypeInformation.of(object : TypeHint<Tuple2<String, Int>>() {}))
    .name("tokenizer")
...
```

---

# 마치며

쏟아지는 데이터를 실시간으로 활용할 수 있는 환경이 갖추어지니 할 수 있는게 정말 많아졌습니다. 단순히 Apache Flink라는 새로운 도구에 익숙해진 건 단편적인 예시일 뿐, 데이터에 대해 눈이 떠졌다랄까요. 데이터 엔지니어 동료와 처음 티타임을 할 때 데이터에 무지한 저의 모습을 스스로 제 3자의 시각에서 바라보고 있는 느낌이 들었고, 머릿속에서는 새로운 터널에 들어서는 것만 같았습니다. 짧게는 3개월, 길게는 1년 뒤에 달라져 있을 제 모습이 상상되기도 했어요. 멋진 동료 덕분에 성장하고 있다는걸 느낄 수 있었고 도움이 필요하면 저도 많이 도와주고 싶다는 생각이 들었습니다. 

이제 백엔드 엔지니어로서 다룰 수 있는 연장이 하나 더 늘어났습니다. 경계해야 할 건 모든게 다 못으로 보이지 않게 만드는 것. 실시간으로 데이터를 처리할 수 있는 능력이 생겼으니 모든 곳에 다 스트림 앱을 갖다 붙이고 싶을 수 있습니다. 그래서 이 도구로 해결하기에 적당한 문제가 무엇인지 알고 있는게 중요한데요. 처리할 데이터 소스와 싱크를 지원하는지 알아보고, 실시간성(Real-time) 그리고 Window 기반으로 이벤트를 처리해야 할 문제에 Flink를 추천하고 싶습니다. 실시간으로 발생하는 거래 데이터가 정상인지, 이상거래는 아닌지 [State](https://flink.apache.org/what-is-flink/flink-applications/#state)와 [Time](https://flink.apache.org/what-is-flink/flink-applications/#time)을 활용해서 판단할 수 있습니다.

마지막으로, 한국에도 Flink를 사용하는 회사들이 점점 많아지고 있는것 같은데, 기술 교류와 레퍼런스가 많아졌으면 좋겠다는 생각이 들었습니다. 생태계는 계속해서 발전하고 있다는 느낌이 드는데, 대부분 비슷하겠지만 구체적으로 어떤 니즈를 가지고 이 기술을 도입해서 사용하고 있는지가 궁금했습니다. 자주, 더 많은 기술 공유가 있기를!

---

# References
- [Apache Flink](https://flink.apache.org/)
- [What is Apache Flink?](https://www.confluent.io/learn/apache-flink/)
