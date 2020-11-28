---
layout: entry
title: 암호화 알고리즘과 Spring Boot Application에서 Entity 암호화
author: 김성중
author-email: ajax0615@gmail.com
description: 암호화 알고리즘과 Spring Boot Application에서 Entity를 암호화하는 방법에 대해서 알아봅니다.
publish: true
---

![제28조(개인정보의 보호조치)](/images/2020/11/28/1.png "제28조(개인정보의 보호조치)"){: .center-image }

하루가 멀다 하고 개인정보 유출 사고가 터지고 있다. 처음에는 충격적으로 받아들여졌지만 사고가 거듭될수록 반응도 둔감해졌다. 그래서 잇따른 정보 유출 사고에 \"개인정보는 이미 공공재\"라는 자조 섞인 말까지 나왔다. 그래서 보안으로 제시되는 것들에 대한 관심 또한 높아지는것 같다. 과거에 한창 핫했던 [종단간 암호화(End-to-End Encryption)](https://en.wikipedia.org/wiki/End-to-end_encryption)나 [SSL/TLS 프로토콜](https://en.wikipedia.org/wiki/Transport_Layer_Security)이 대표적인 예이다. 그리고 **\"우리는 SSL 통신을 하니까 안전합니다(무적 SSL).\"** 라는 말도 오르내리곤 한다. [전송 계층(Transport Layer)](https://en.wikipedia.org/wiki/Transport_layer)까지의 안전성을 보장하니까 괜찮을것 같기도 한데.. 확신이 들지 않았다. 그래서 이번에 회사에서 사용자로부터 입력받은 정보를 암호화하는 작업을 하면서 좀 더 잘 알고 가자는 취지에서 파헤쳐 보았다.

# TLS(SSL)
위에서 SSL과 TLS 프로토콜을 하나로 묶어서 얘기를 했다. 많은 사람들이 SSL(Secure Socket Layer)에 대해서는 어느정도 알지만, TLS(Transport Layer Security)에 대해서는 들어본정도(?)라고 생각한다. TLS와 SSL은 다른 것이지만, 보통 SSL이라고 통칭해서 불리운다. 과거에 모 회사 인턴 면접을 봤을때 SSL에 대해서 알고 있냐는 질문을 받았던게 생각난다. 정확히는 SSL이 OSI 7계층 중 어느 계층까지의 안전을 보장하는지 아냐는 질문이었다. 정답은 위에서 말했듯이, 4계층인 **전송 계층(Transport Layer)까지의 안전을 보장**한다.

우리 실생활에 존재하는 복잡한 시스템들을 바깥에서 보면 나름의 계층 구조를 가지고 있다. 누군가가 항공 시스템을 설명해 달라고 요청한다면 어떻게 설명을 해야할까? 난 항공 전문가도 아닌데 말이다. 티켓 에이전트, 수하물 검색대, 탑승구 요원, 조종사, 비행기, 관제소 그리고 비행기를 라우팅하는 전 세계 시스템등을 설명하기 위해 구조를 어떻게 찾을 수 있을까? 이 시스템을 설명하는 한 방법은 우리가 비행기를 탈 때 취하는 일련의 행동을 생각해보면 된다. 일단 티켓을 사고.. 가방을 검사하고.. 탑승구로 가고.. 비행기에 타면, 비행기는 이륙하고 목적지로 향한다. 비행기가 착륙한 후, 탑승구를 통해 내리고 짐을 찾는다. 내 가방이 사라졌으면? 항공사에 문의를 한다. 네트워크 계층도 이와 유사하게 하나의 계층이 그 다음 계층에 제공하는 서비스에 관심을 갖고, 이러한 것들이 모여 7계층이 되었다.

![OSI 7 계층](/images/2020/11/28/osi.png "OSI 7 계층"){: .center-image }

4계층인 전송 계층은 주고 받은 패킷을 데이터 형태로 서로 변환하는 일을 맡는다. 패킷을 데이터로, 데이터를 패킷으로. 네트워크의 기본 전송 단위인 '패킷'을 다루기 때문에 보안상 가장 중요한 계층이라고 볼 수 있다. 그리고 이 계층에서 **패킷과 데이터를 암호화하는데 사용되는 프로토콜**이 [TLS 프로토콜](https://en.wikipedia.org/wiki/Transport_Layer_Security)이다. TLS는 SSL을 기반으로한 프로토콜이다. 쉽게 이야기하면 보안 취약점이 있는 SSL 프로토콜의 업그레이드된 버전이 나오면서 TLS 프로토콜이 출시된 것이다.

![ssl1](/images/2016/10/06/ssl1.jpg "ssl1"){: .center-image }

![ssl2](/images/2016/10/06/ssl2.jpg "ssl2"){: .center-image }

TLS를 사용해 암호화된 연결을 하는 HTTP가 [HTTPS](https://en.wikipedia.org/wiki/HTTPS)이다. 그리고 HTTPS 기반의 페이지에 접속하면 브라우저와 웹 서버는 다음과 같은 동작을 수행한다.

1. [브라우저] SSL로 암호화된 페이지를 요청한다(https://example.com).
2. [웹 서버] 공개키(Public key)를 인증서와 함께 전송한다.
3. [브라우저] 인증서가 CA(Certification Authority)로부터 서명된 것인지, 날짜가 유효한 그리고 접속하려는 사이트와 관련이 있는지 등을 확인한다.
4. [브라우저] 공개키(Public key)를 사용해서 대칭키(Symmetric key)를 비롯한 URL, http 데이터들을 암호화해서 전송한다.
5. [웹 서버] 개인키(Private key)를 이용해서 대칭키와 URL, http 데이터를 복호화한다.
6. [웹 서버] 요청받은 URL에 대한 응답을 브라우저로부터 받은 대칭키를 이용하여 암호화해서 브라우저로 전송한다.
7. [브라우저] 대칭키를 이용해서 http 데이터와 HTML document를 복호화하고, 화면에 그려준다.

---

# 암호화 알고리즘
위에서 언급한 것처럼 HTTPS 기반의 페이지에 접속할 때에는 공개키, 개인키, 대칭키를 사용하여 데이터를 암호화하고 복호화한다. 암호화 알고리즘에는 크게 [대칭키 암호화 알고리즘](https://en.wikipedia.org/wiki/Symmetric-key_algorithm)과 [공개키 암호화 알고리즘](https://en.wikipedia.org/wiki/Public-key_cryptography)으로 구분된다.

### 대칭키 암호화 알고리즘
대칭키 암호화 알고리즘은 암호화와 복호화에 **서로 같은 키를 사용**하는 알고리즘이다. 다음과 같은 장점 때문에 주로 데이터 통신의 암호화에 사용된다.

![symmetric](/images/2016/09/30/symmetric.png "symmetric"){: .center-image }

- 암호화/복호화 속도가 공개키 암호화 알고리즘보다 빠르다(최소10~최대1000배).
> 암호화/복호화 속도는 통신 속도에 많은 영향을 끼치므로 당연히 속도가 빠른 것이 통신에 유리하다.

- 암호문의 크기가 평문보다 크지 않다(암호화 시 데이터 증가가 없다).
> 크기가 증가하지 않는다는 것은 암호화된 데이터의 크기가 평문과 같다는 것이고, 네트워크 대역폭을 추가적으로 필요로 하지 않는다는 것이므로 통신에 적합하다.

그런데... 대칭키 암호화 알고리즘은 데이터를 보내는 A와 데이터를 받는 B가 동일한 키를 갖고 있어야 되는데, A와 B가 어떻게 같은 키를 가질 수 있게 할까? A가 키를 만들고 이 키를 네트워크를 통해 B에게 전달하는 식의 방법은 해커가 중간에서 키를 가로챌 수 있기 때문에 부적절하다. 이를 Key bootstrapping 또는 Key agreement problem 이라고 한다.

이 문제를 해결하는 일반적인 방법은 두 가지가 있다. 첫번째는 키를 뒤에서 설명할 공개키 암호화 알고리즘을 이용하여 암호화해서 전송하는 방법이다. 두번째는 실제 키를 전송하지 않고도 A와 B가 동일한 키를 생성할 수 있도록 하는 알고리즘을 사용하는 것인데, 대표적으로 Diffie-Hellman 알고리즘이 있다. 추가로 대칭키 알고리즘의 예로는 AES, DES, DES3, SEED 등이 있다.

### 공개키 암호화 알고리즘
공개키 암호화 알고리즘은 암호화와 복호화에 **서로 다른 키를 사용** 해서 *비대칭키 암호화 알고리즘* 이라고도 한다. 주로 **데이터 암호화**(평문 또는 대칭키 등)나 **인증**에 사용된다. 대표적인 알고리즘으로는 RSA 알고리즘이 있다. 먼저 공개키 암호화 알고리즘을 이용하여 데이터를 암호화하는 방식을 살펴보자.

![asymmetric](/images/2016/09/30/asymmetric.png "asymmetric"){: .center-image }

1. A는 **공개키(Public key)와 개인키(Private key)**를 생성한다.
> 공개키 암호화: A의 공개키를 이용하여 암호화된 데이터는 A의 개인키로만 복호화가 가능하다.<br>
  개인키 암호화: A의 개인키를 이용하여 암호화된 데이터는 A의 공개키로만 복호화가 가능하다.

2. B는 A의 공개키를 조회하고, A의 공개키를 이용하여 데이터를 암호화한 후 전송한다.

3. A는 개인키로 암호화된 데이터를 복호화한다.
> 해커는 개인키를 알지 못하므로 복호화할 수 없다.

그리고 인증에 사용되는 예시를 A라는 고객이 은행에서 인터넷 뱅킹을 하는 상황으로 알아보자.

1. A는 은행에 자신의 공개키를 보낸다.
2. 은행은 대칭키(비밀키)를 A의 공개키를 이용하여 암호화한 다음 전송한다.
> 해커가 암호화된 값을 탈취해도 A의 개인키를 알지 못하므로 복호화할 수 없다.

3. A는 자신의 개인키로 복호화하여 은행의 대칭키를 추출한다.
4. A와 은행 사이의 통신은 대칭키를 통해 암호화된다.

그런데 여기에는 한 가지 문제점이 있다. 만약 해커 Z가 은행에 접속해서 마치 자신이 A인 것처럼 위장하고 자신의 공개키로 전송하면 어떻게 될까? 만약 은행이 속는다면, 은행은 Z의 공개키를 이용하여 비밀키를 암호화한 후 전송할 것이고 Z는 자신의 개인키로 이를 복호화하여 비밀키를 획득할 수 있게 된다.

이러한 공격을 막기 위해서는 은행이 **A의 공개키를 인증할 수 있는 방법**(인증서) 이 필요한데, 이 때 사용되는게 **개인키 암호화** 이다. A의 개인키로 암호화를 하고 공개키와 함께 전달하면, 은행은 A의 공개키로 복호화해서 데이터 제공자(A)의 신원을 확인 할 수 있게 된다. 해커가 공개키와 암호화된 데이터를 탈취하여 복호화가 가능하다는 위험성이 있지만, 이러한 인증 방식은 **데이터 보호가 아닌 데이터 제공자(A)의 신원을 보장하는 용도**로 사용된다. 이러한 인증 방법이 공인인증체계의 기본 바탕이 되는 전자서명이다.

---

# Spring Boot Application에서 Entity 암호화하기
사용자의 개인정보가 포함된 데이터를 안전하게 저장하기 위해 암호화가 필요하다. 입력받은 데이터가 많은 상황에서 암호화가 필요한 데이터를 하나씩 하나씩 처리한다면 작업량이 산더미가 될 것이다. 그래서 Entity 레벨에서 데이터 변환을 시도해보면 수고를 조금이라도 덜 수 있겠다고 생각했다.

### JPA Attribute Converter 사용하기
프로젝트에서 JPA를 사용하고 있다면, [컨버터(Converter)](https://docs.jboss.org/hibernate/jpa/2.1/api/javax/persistence/AttributeConverter.html)가 암호화하기에 좋은 옵션이라고 생각한다. 컨버터를 사용하면 엔티티의 데이터를 변환해서 데이터베이스에 저장할 수 있다. 컨버터를 사용하려면 AttributeConverter 인터페이스를 구현해야 한다. 그리고 제네릭에 현재 타입과 변환할 타입을 지정해야 한다.

```java
public interface AttributeConverter<X, Y> {
    public Y convertToDatabaseColumn(X attribute);
    public X convertToEntityAttribute(Y dbData);
}
```

- convertToDatabaseColumn(): 엔티티의 데이터를 데이터베이스 컬럼에 저장할 데이터로 변환한다.
- convertToEntityAttribute(): 데이터베이스에서 조회한 컬럼 데이터를 엔티티의 데이터로 변환한다.

 예를 들어, 유저 엔티티의 신용카드(creditCardNumber) 필드를 저장할 때에는 암호화하고, 조회할 때에는 복호화하고 싶다면 다음과 같이 작성하면 된다.

```java
@Converter
public class CryptoConverter implements AttributeConverter<String, String> {
    @Override
    public String convertToDatabaseColumn(String plainText) {
      return Optional.ofNullable(plainText)
        .map(CryptoHelper::encrypt)
        .orElse(null);
    }

    @Override
    public String convertToEntityAttribute(String encrypted) {
      return Optional.ofNullable(encrypted)
        .map(CryptoHelper::decrypt)
        .orElse(null);
    }
}

@Entity
public class User {
    ...
    @Convert(converter = CryptoConverter.class)
    @Column(name = "credit_card_number")
    private String creditCardNumber;
    ...
}
```

### R2DBC Converter 사용하기
하지만... 프로젝트에서 JPA가 아닌, R2DBC를 구현한 Spring Data R2DBC를 사용하고 있다는 얘기가 조금? 달라진다. JPA Attribute Converter를 사용하면 원하는 컬럼에 @Converter 를 사용해서 뚝딱 만들 수 있지만, R2DBC는 컬럼 기반의 컨버터를 지원하지 않아서 무언가를 새로 만들어줘야 한다. 그래서 또 어떻게 하면 쉽고, 간편하게, 수고를 덜 수 있을까 고민을 하다가 커스텀 Annotation 기반으로 R2DBC에서 제공하는 [R2dbcConverter](https://docs.spring.io/spring-data/r2dbc/docs/current/api/org/springframework/data/r2dbc/convert/R2dbcConverter.html)를 만들어 사용하면 좋겠다는 생각이 들었다.

먼저, 데이터베이스에 저장할 **특정 컬럼에 암호화가 필요**하다는 것을 명시해주기 위해 @Encrypted 을 만들어준다. 이 Annotation은 아래에서 설명할 Converter 안에서 자바 리플랙션을 통해 해당 컬럼이 암호화, 복호화 대상임을 식별하는 용도로 사용된다.

```java
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD, ElementType.METHOD, ElementType.ANNOTATION_TYPE})
@Documented
public @interface Encrypted {
}
```

@Encrypted 을 사용해서 컬럼 필드에 암호화, 복호화 대상임을 표시해준다. JPA를 사용할 때와 다른점은 Entity와 관련된 어노테이션을 javax.persistence 패키지가 아니라 **org.springframework.data.relational.core.mapping** 에 있는 Annotation을 사용해야된다는 점이다.


```java
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Entity;
import org.springframework.data.relational.core.mapping.Table;

@Entity
@Table(name = "user")
public class User {
    ...
    // 암호화/복호화 대상임을 나타내기 위해 Encrypted Annotation 명시
    @Encrypted
    @Column(value = "credit_card_number")
    private String creditCardNumber;
    ...
}
```

다음으로, R2DBC 인터페이스에서 제공하는 Converter 구현해서 나만의 Custom Entity 컨버터를 만들어줘야 된다. JPA Attribute Converter는 read와 write가 하나의 클래스안에 메서드로 존재하지만, 이녀석은 **읽기 전용 컨버터인 ReadingConverter**와 **쓰기 전용인 WritingConverter**를 각각 만들어줘야된다. Converter 인터페이스에서 제공하는 convert 메서드를 각각 오버라이딩하면 된다. 이 예제에서는 특정 Entity용으로 ReadingConverter와 WritingConverter를 만들었는데, 추상 클래스를 만들어서 재사용성을 높이면 사용하기에 편리해진다.

- ReadingConverter: 데이터베이스에서 조회한 Row를 대상 Entity로 변환한다.
- WritingConverter: 데이터베이스에 저장할 Entity를 인자로 받아서 OutboundRow로 변환한다.

```java
@ReadingConverter
public class UserReadingConverter extends Converter<Row, User> {
    @Override
    public User convert(Row source) {
        User user = new User();
        // User 엔티티에서 @Column이 포함된 필드만 추출
        List<Field> fields = Arrays.stream(source.getClass().getDeclaredFields())
            .filter(it -> it.isAnnotationPresent(Column.class))
            .collect(Collectors.toList());
        for (Field field : fields) {
            field.setAccessible(true);
            // @Column에 명시된 컬럼명을 가져와서 Row의 해당 컬럼에 저장된 값을 읽어온다.
            String column = field.getAnnotation(Column.class).value();
            Object value = source.get(column);
            if (value != null && field.isAnnotationPresent(Encrypted.class)) {
                // @Encrypted이 선언되어 있으면 복호화
                String decrypted = CryptoHelper.decrypt(value);
                ...
            }
            ...
        }
        return user;
    }
}

@WritingConverter
public class UserWritingConverter extends Converter<User, OutboundRow> {
    @Override
    public OutboundRow convert(User source) {
        OutboundRow row = new OutboundRow();
        // User 엔티티에서 @Column이 포함된 필드만 추출
        List<Field> fields = Arrays.stream(source.getClass().getDeclaredFields())
            .filter(it -> it.isAnnotationPresent(Column.class))
            .collect(Collectors.toList());
        for (Field field : fields) {
            field.setAccessible(true);
            // User 엔티티의 해당 변수에 저장된 값을 읽어온다.
            Object value = field.get(source);
            if (value != null && field.isAnnotationPresent(Encrypted.class)) {
                // @Encrypted이 선언되어 있으면 암호화
                String encrypted = CryptoHelper.encrypt(value);
                ...
            }
            ...
        }
        return row;
    }
}
```

![R2dbcCustomConversions](/images/2020/11/28/r2dbcCustomConversions.png "R2dbcCustomConversions"){: .center-image }

그리고 이 컨버터들을 사용하려면 R2dbcMappingContext에 등록해줘야 되는데, 방법은 간단하다. R2DBC 설정에 필요한 AbstractR2dbcConfiguration를 상속받아서 [R2dbcCustomConversions](https://docs.spring.io/spring-data/r2dbc/docs/1.0.0.RELEASE/api/org/springframework/data/r2dbc/convert/R2dbcCustomConversions.html) 빈을 아래와 같이 생성해주면 된다.

```java
@Configuration
@EnableR2dbcRepositories
public class CustomR2dbcConfiguration extends AbstractR2dbcConfiguration {
    ...
    @Bean
    @Override
    public R2dbcCustomConversions r2dbcCustomConversions() {
        return new R2dbcCustomConversions(Arrays.asList(
            new UserReadingConverter(),
            new UserWritingConverter()
        ));
    }
    ...
}
```

---

# 그리고
![RedisSerializer](/images/2020/11/28/redis-serializer.png "RedisSerializer"){: .center-image }

Redis에 저장된 데이터도 암호화가 필요했는데 훌륭한 팀원의 아이디어 덕분에 DB 저장보다 더 쉽게 할 수 있었다. Spring Data Redis나 Spring Data Reactive Redis 둘 다 내부적으로 데이터를 저장할 때에는 binary 형태로 Serialization해서 저장한다. 나는 그냥 **값을 저장하기 전에 암호화하고, 값을 조회할 때에는 복호화하는 커스텀 Serializer**를 만들어 주기만 하면 된다.

```java
public class CustomSerializer implements RedisSerializer<Data> {
    @Override
    public byte[] serialize(Data t) throws SerializationException {
        String serialized = mapper.writeValueAsString(t);
        String encrypted = CryptoHelper.encrypt(serialized);
        return encrypted.getBytes(StandardCharsets.UTF_8);
    }

    @Override
    public Data deserialize(byte[] bytes) throws SerializationException {
        String deserialized = new String(bytes, StandardCharsets.UTF_8);
        String decrypted = CryptoHelper.decrypt(deserialized);
        return mapper.readValue(decrypted, Data.class)
    }
}
```

---

### References
- [정보통신망 이용촉진 및 정보보호 등에 관한 법률](https://glaw.scourt.go.kr/wsjo/lawod/sjo192.do?contId=2232475&jomunNo=28&jomunGajiNo=0)
- [Transport Layer](https://en.wikipedia.org/wiki/Transport_layer)
- [How to use a JPA Attribute Converter to encrypt your data](https://thorben-janssen.com/how-to-use-jpa-type-converter-to/)
- [Spring Data R2DBC - Reference Documentation](https://docs.spring.io/spring-data/r2dbc/docs/current-SNAPSHOT/reference/html/#r2dbc.core)
- [Spring Data Redis - Reference Documentation](https://docs.spring.io/spring-data/redis/docs/current/api/org/springframework/data/redis/serializer/package-summary.html)
