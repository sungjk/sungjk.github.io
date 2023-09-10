---
layout: entry
title: 효율적인 테스트를 위한 Stub 객체 사용법
author-email: ajax0615@gmail.com
description: Stub 객체를 활용하는 방법을 알아봅니다.
keywords: Test, Testing, Stub, Mock, Test Double, 테스트
publish: true
---

요즘 회사에서 테스트 코드를 작성하는 재미가 쏠쏠하다. 예전엔 정말 귀찮은 시간이었는데 지금은 나름의 노하우가 생겨서 그런 것 같다. 구체적으로 무엇이 달라졌을까? 그동안 테스트 코드를 작성하는 건 왜 힘들었을까? 크든 작든 오랜 시간 계속해서 새로운 시도와 개선을 반복하다 보니 딱 이거 때문이라고 생각나는 건 없다. 다만 확실히 큰 도움이 되었던 게 있다. 대부분의 비즈니스 로직들이 구체 클래스가 아닌 인터페이스 기반으로 동작하고 있는 것과 테스트 코드에서 Mocking 사용을 가급적 지양하고 Stubbing을 통한 테스트 코드를 작성하는 것.

맨 처음 Stub 개념을 접했을 때가 생각난다. 정의를 보니 Mock과 다를게 없어 보이는데. 그냥 Mock 쓰는 거랑 별 차이 없어 보이는데. Stub 객체를 사용하는 예시를 봐도 잘 이해가 가질 않았다. 오히려 Stub을 사용하면 코드양이 더 많아져서 Mock을 사용하는게 나아 보였다. 그동안 작성한 테스트 코드는 Mock 객체(자바는 Mockito, 코틀린은 MockK)를 활용해서 아주 잘 동작하고 있다. 그런데 귀찮았던건, 운영 코드(테스트할 대상)에 변경이 생기면 Mock 객체가 사용되는 부분도 함께 변경해줘야 했다. 그때 문뜩 이런 생각이 들었다. “Mock 객체를 사용하지 않고 테스트 코드 어떻게 작성할 수 있을까?” Stub에 대해서 좀 더 알아봐야겠다.

> 예제에 포함된 코드 구조나 사례는 테스트를 작성함에 있어 Stub을 활용하기 위한 단순 사례일 뿐, 특정 서비스를 대표하거나 특정 아키텍처를 반영하지 않았으므로 어색함이 있을 수 있음을 밝힙니다.

이 글에서 작성된 예시 코드들은 [Github - sungjk/asdf](https://github.com/sungjk/asdf/tree/master/kotlin-test/src)에서 확인할 수 있어요.

---

## Test Doubles

Mocking과 Stubbing의 차이를 이해하려면 먼저 Test Double에 대해서 알아볼 필요가 있다. Test Double이란, **실제 객체 대신 테스트 목적으로 사용되는 모든 종류의 가상 객체**를 통칭하는 용어다. 영화나 드라마를 촬영할 때 무술 장면이나 실제 배우가 출연하기 힘든 위험한 장면을 촬영할 때 그 분야에 전문적으로 숙달된 사람으로 대신하는걸 Stunt Double 이라고 하는게 여기서 비롯되었다고 한다. 예를 들어, 은행에 송금하는 기능을 만든다고 가정해보자. 은행에 송금을 요청하는 인터페이스가 있을 것이고, 매번 테스트할 때마다 송금 요청 인터페이스를 구현한 실제 객체를 사용하게 되면 테스트가 실행될 때마다 내 돈이 어딘가로 송금 되는 아찔한 경험을 하게 된다(돈이 무한히 많다면 문제가 없겠지만). 이때 우리가 원하는건 실제로 은행에 송금을 요청하지는 않고 송금을 요청한 것처럼 행동한 뒤 성공이나 실패 응답만 주는 객체다. 이 객체를 통칭해서 Test Double이라고 부르고, 어떤 방식으로 이 객체를 구현하고 어떤 상황에서 사용하는지에 따라 Test Double의 종류가 나뉜다.

[xUnit Test Patterns의 저자인 Gerard Meszaros](http://xunitpatterns.com/gerardmeszaros.html)는 위에서 이야기한 Test Double을 5가지 종류로 분류했다. 각각 어떤 용도로 사용되는지 은행으로 송금을 수행하는 인터페이스를 정의하고 예시 코드를 만들어보며 살펴보자(코드에 오류가 많은데 테스트를 설명하기 위함이니 이런건 스킵).

```kotlin
// 은행으로 송금을 수행하는 인터페이스
interface TransferBankUseCase {
    fun invoke(from: BankAccount, to: BankAccount, amount: Long): Result

    data class BankAccount(val bankCode: String, val accountNumber: String)
    sealed interface Result {
        data class Success(val transferHistoryId: Long) : Result
        data class Failure(val throwable: Throwable) : Result
    }
}

// 실제로 프로덕션에서 은행으로 송금하기 위해 사용되는 구체 클래스
class TransferBank(
    private val transferHistoryRepository: TransferHistoryRepository,
    private val bankPort: BankPort,
    private val emailPort: EmailPort,
) : TransferBankUseCase {
    override fun invoke(from: TransferBankUseCase.BankAccount, to: TransferBankUseCase.BankAccount, amount: Long): TransferBankUseCase.Result {
        if (from.bankCode == to.bankCode && from.accountNumber == to.accountNumber) {
            return TransferBankUseCase.Result.Failure(RuntimeException("동일 계좌로 송금 불가"))
        }
        // FROM 계좌의 잔액이 충분한지 검사
        val balanceOfFromBankAccount = bankPort.getBalance(from.bankCode, from.accountNumber)
        if (amount > balanceOfFromBankAccount) {
            return TransferBankUseCase.Result.Failure(RuntimeException("잔액 부족"))
        }

        // FROM 계좌에서 송금액만큼 출금
        bankPort.withdraw(bankCode = from.bankCode, accountNumber = from.accountNumber, amount = amount)

        // TO 계좌로 송금액만큼 입금
        val response = bankPort.deposit(bankCode = to.bankCode, accountNumber = to.accountNumber, amount = amount)
        return when (response.isSuccess()) {
            true -> {
                val transferHistory = transferHistoryRepository.save(
                    TransferHistory(
                        id = System.currentTimeMillis(),
                        fromBankCode = from.bankCode,
                        fromBankAccountNumber = from.accountNumber,
                        toBankCode = to.bankCode,
                        toBankAccountNumber = to.accountNumber,
                        amount = amount,
                    ),
                )
                emailPort.sendEmail(content = "송금 성공")
                TransferBankUseCase.Result.Success(transferHistoryId = transferHistory.id)
            }
            false -> {
                emailPort.sendEmail(content = "송금 실패")
                TransferBankUseCase.Result.Failure(throwable = RuntimeException(response.message))
            }
        }
    }
}

// 송금 기록을 관리하기 위한 인터페이스
interface TransferHistoryRepository {
    fun findById(id: Long): TransferHistory?
    fun save(history: TransferHistory): TransferHistory
}

data class TransferHistory(
    val id: Long,
    val fromBankCode: String,
    val fromBankAccountNumber: String,
    val toBankCode: String,
    val toBankAccountNumber: String,
    val amount: Long,
)

// 송금 기록을 관리하기 위해 Exposed 기반으로 구현한 구체 클래스
class TransferHistoryRepositoryImpl : TransferHistoryRepository {
    override fun findById(id: Long): TransferHistory? {
        return TransferHistoryTable.select {
            TransferHistoryTable.id.eq(id)
        }.map {
            TransferHistory(
                id = it[TransferHistoryTable.id].value,
                fromBankCode = it[TransferHistoryTable.fromBankCode],
                fromBankAccountNumber = it[TransferHistoryTable.fromBankAccountNumber],
                toBankCode = it[TransferHistoryTable.toBankCode],
                toBankAccountNumber = it[TransferHistoryTable.toBankAccountNumber],
                amount = it[TransferHistoryTable.amount],
            )
        }.firstOrNull()
    }

    override fun save(history: TransferHistory): TransferHistory {
        TransferHistoryTable.insert {
            it[TransferHistoryTable.id] = history.id
            it[fromBankCode] = history.fromBankCode
            it[fromBankAccountNumber] = history.fromBankAccountNumber
            it[toBankCode] = history.toBankCode
            it[toBankAccountNumber] = history.toBankAccountNumber
            it[amount] = history.amount
        }
        return history
    }
}

object TransferHistoryTable : LongIdTable("transfer_history", "id") {
    val fromBankCode = varchar("from_bank_code", 3)
    val fromBankAccountNumber = varchar("from_bank_account_number", 50)
    val toBankCode = varchar("to_bank_code", 3)
    val toBankAccountNumber = varchar("to_bank_account_number", 50)
    val amount = long("amount")
}

// 은행 계좌를 다루기 위한 인터페이스
interface BankPort {
    // 계좌 잔액 조회
    fun getBalance(bankCode: String, accountNumber: String): Long

    // 계좌에서 금액을 출금
    fun withdraw(bankCode: String, accountNumber: String, amount: Long): Result

    // 계좌에 금액을 입금
    fun deposit(bankCode: String, accountNumber: String, amount: Long): Result

    data class Result(val resultCode: String, val message: String? = null) {
        fun isSuccess(): Boolean {
            return this.resultCode == "success"
        }
    }
}

// 은행에 각 기능을 요청하기 위해 HTTP 기반으로 구현한 구체 클래스
class BankHttpPort(private val httpClient: HttpClient) : BankPort {
    override fun getBalance(bankCode: String, accountNumber: String): Long {
        return httpClient.getBalance(bankCode, accountNumber)
    }

    override fun withdraw(bankCode: String, accountNumber: String, amount: Long): BankPort.Result {
        return httpClient.withdraw(bankCode, accountNumber, amount)
    }

    override fun deposit(bankCode: String, accountNumber: String, amount: Long): BankPort.Result {
        return httpClient.deposit(bankCode, accountNumber, amount)
    }
}

// 이메일을 발송하기 위한 인터페이스
interface EmailPort {
    fun sendEmail(content: String)
}

// 이메일을 발송하기 위해 SMTP 기반으로 구현한 인터페이스
class EmailSmtpPort(private val smtpClient: SmtpClient) : EmailPort {
    override fun sendEmail(content: String) {
        smtpClient.send(content)
    }
}
```

Test Double의 종류를 알아보기에 앞서 여기서 우리가 테스트하고 싶은 건, 실제로 프로덕션에서 송금하기 위해 사용되는 구체 클래스인 TransferBank(위에서 TransferBankUseCase 인터페이스를 구현한 클래스)다. BankPort의 잔액 조회와 출금, 입금 요청 결과에 따라서 이메일을 발송한 다음 성공했는지 실패했는지 결과를 리턴한다. 이러한 테스트할 대상(TransferBank)을 테스트 코드에서는 System Under Test 라고 부르며, 줄여서 SUT라고 부른다. 아래 예시에서도 sut 라고 줄여서 사용하겠다.

### 1. Dummy

**객체 전달은 하지만 실제로 사용되지 않는 것**을 말한다. 일반적으로 테스트할 대상을 구성하기 위해 값을 채우는 용도로만 사용한다.

FROM 계좌의 잔액이 부족한 상황을 테스트하기 위해서는 BankPort의 getBalance 구현과 sut.invoke의 인자로 주어진 amount 가 중요하다. sut을 구성하기 위해 전달해야 할 transferHistoryRepository와 emailPort는 사용되지 않기 때문에 어떤 값이 입력되든 상관 없다. 따라서 여기서는 [Kotlin Mock 라이브러리인 MockK](https://mockk.io/)를 사용해서 아무 값이나 전달했는데 이 때 `mockk()`를 사용해서 생성된 객체가 Dummy 객체다.

```kotlin
test("FROM 계좌의 잔액이 부족하면 Failure 리턴") {
  // arrange
  val sut = TransferBank(
      transferHistoryRepository = mockk(), // Dummy 객체
      bankPort = object : BankPort {
          override fun getBalance(bankCode: String, accountNumber: String): Long {
              return 1000L
          }
          override fun withdraw(bankCode: String, accountNumber: String, amount: Long): BankPort.Result = TODO("Not yet implemented")
          override fun deposit(bankCode: String, accountNumber: String, amount: Long): BankPort.Result = TODO("Not yet implemented")
      },
      emailPort = mockk(), // Dummy 객체
  )

  // act
  val actual = sut.invoke(
      from = TransferBankUseCase.BankAccount("088", "1212121212"),
      to = TransferBankUseCase.BankAccount("088", "4242424242"),
      amount = 100_000L,
  )

  // assert
  (actual is TransferBankUseCase.Result.Failure) shouldBe true
}
```

### 2. Fake

**실제로 동작하는 구현을 가지고 있지만 일반적으로 프러덕션에서 적합하지 않은 몇 가지 shourtcut을 사용하는 객체**다.

예를 들어, 프러덕션에서는 실제로 mysql 서버에 접속해서 데이터를 저장하고 조회하는 기능을 구현했다면, 테스트 코드에서는 in-memory database를 사용해서 런타임에만 메모리에 데이터를 저장하고 조회하는 기능을 구현할 수 있다. 여기서 in-memory database가 Fake 객체에 해당한다. jdbc driver를 사용한다면 mysql 서버에 직접 접속할건지 h2 데이터베이스를 사용할건지 드라이버 수준에서 설정할 수 있다.

```kotlin
import org.jetbrains.exposed.sql.Database

// H2 In-memory database에 접속
val h2Database = Database.connect("jdbc:h2:mem:test;DB_CLOSE_DELAY=-1", driver = "org.h2.Driver")

// mysql database에 접속
val mysqlDatabase = Database.connect("jdbc:mysql://localhost/test", driver = "com.mysql.jdbc.Driver")

```

### 3. Stub

**테스트에 필요한 호출에 대해 미리 준비된 답을 제공하는 객체**다. 일반적으로 테스트를 위해 작성된 기능 외에 다른 행동은 하지 않는다.

위에서 Dummy 객체를 설명하면서 살펴본 예시 코드에서 Stub 객체가 사용되었는데, BankPort 구현체가 Stub에 해당한다. FROM 계좌의 잔액이 부족한지를 테스트하기 위해 입력된 계좌번호에 상관없이 미리 준비해 놓은 잔액(1000원)을 리턴하고, withdraw나 deposit 등 테스트에 필요하지 않은 행동은 정의하지 않았다. Stub에 대한 내용은 아래에서 더 자세하게 살펴볼 것이다.

```kotlin
test("FROM 계좌의 잔액이 부족하면 Failure 리턴") {
  // arrange
  val sut = TransferBank(
      transferHistoryRepository = mockk(), // Dummy 객체
      bankPort = object : BankPort {
          override fun getBalance(bankCode: String, accountNumber: String): Long {
              return 1000L
          }
          override fun withdraw(bankCode: String, accountNumber: String, amount: Long): BankPort.Result = TODO("Not yet implemented")
          override fun deposit(bankCode: String, accountNumber: String, amount: Long): BankPort.Result = TODO("Not yet implemented")
      },
      emailPort = mockk(), // Dummy 객체
  )

	...
}
```

### 4. Spy

**어떤 기능이 어떻게 호출되었는지에 따라 일부 정보를 기록하는 Stub의 일종**이다.

예를 들어, 송금을 성공하고 나면 이메일이 한 번만 발송된다는걸 검증하고 싶다면 아래 예시 코드처럼 sendEmail 함수 안에서 전역으로 제공하는 emailCount 값을 증가시키고, assert 구문에서 변수의 값을 검증하면 된다. Spy는 내가 확인하고자 하는 대상(emailCount)을 기록하는 것이 핵심이고 검증 단계에서 이 정보를 활용한다.

```kotlin
test("송금을 성공하면 이메일을 한 번 발송") {
    // arrange
    val transferHistoryRepositoryStub = object : TransferHistoryRepository {
        override fun findById(id: Long): TransferHistory = TODO("Not yet implemented")
        override fun save(history: TransferHistory): TransferHistory {
            return history
        }
    }
    val bankPortStub = object : BankPort {
        override fun getBalance(bankCode: String, accountNumber: String): Long {
            return 100_000L
        }
        override fun withdraw(bankCode: String, accountNumber: String, amount: Long): BankPort.Result {
            return BankPort.Result("success")
        }
        override fun deposit(bankCode: String, accountNumber: String, amount: Long): BankPort.Result {
            return BankPort.Result("success")
        }
    }
    val emailPortSpy = object : EmailPort {
        var emailCount = 0

        override fun sendEmail(content: String) {
            emailCount++
        }
        fun countSentEmail(): Int {
            return emailCount
        }
    }
    val sut = TransferBank(
        transferHistoryRepository = transferHistoryRepositoryStub,
        bankPort = bankPortStub,
        emailPort = emailPortSpy,
    )

    // act
    val actual = sut.invoke(
        from = TransferBankUseCase.BankAccount("088", "1212121212"),
        to = TransferBankUseCase.BankAccount("088", "4242424242"),
        amount = 100_000L,
    )

    // assert
    check(actual is TransferBankUseCase.Result.Success)
    emailPortSpy.countSentEmail() shouldBe 1
}
```

### 5. Mock

Mock을 뭐라고 표현하면 좋을까? \"**예상된 동작을 가진 객체**\" 라고 표현하며 괜찮을까? Mock을 사용하면 내가 어떤 호출을 기대하고 그 호출에 대한 결과가 무엇인지 명세(specification)를 만들어놔야 한다.

여기서는 [코틀린용 Mocking 라이브러리인 MockK](https://mockk.io/)를 사용해서 송금을 성공하는 테스트를 작성해보겠다. 우리가 테스트할 대상인 sut(TransferBank)는 잔액을 조회하고 계좌에 출금/입금을 실행한 뒤 송금 결과를 저장한 다음 이메일을 발송하면 성공 값을 리턴한다. 그리고 성공 값을 리턴받기 위해 행동(behavior)에 대한 명세(specification)를 MockK에서 제공하는 every - returns 구문을 이용해서 정의했다.

```kotlin
test("송금 성공") {
    // arrange
    val transferHistoryRepositoryMock = mockk<TransferHistoryRepository>()
    val bankPortMock = mockk<BankPort>()
    val emailPort = mockk<EmailPort>()
    val sut = TransferBank(
        transferHistoryRepository = transferHistoryRepositoryMock,
        bankPort = bankPortMock,
        emailPort = emailPort,
    )
    every { bankPortMock.getBalance(any(), any()) } returns 100_000L
    every { bankPortMock.withdraw(any(), any(), any()) } returns BankPort.Result("success")
    every { bankPortMock.deposit(any(), any(), any()) } returns BankPort.Result("success")
    every { transferHistoryRepositoryMock.save(any()) } returns TransferHistory(
        id = 1L,
        fromBankCode = "088",
        fromBankAccountNumber = "1212121212",
        toBankCode = "088",
        toBankAccountNumber = "4242424242",
        amount = 100_000L,
    )
    every { emailPort.sendEmail(any()) } returns Unit

    // act
    val actual = sut.invoke(
        from = TransferBankUseCase.BankAccount("088", "1212121212"),
        to = TransferBankUseCase.BankAccount("088", "4242424242"),
        amount = 100_000L,
    )

    // assert
    (actual is TransferBankUseCase.Result.Success) shouldBe true
}

```

---

## Classical vs. Mockist

5가지 Test Double에 대한 정의를 살펴봤으니 다시 돌아와서, Mocking과 Stubbing의 차이를 알아보겠다. 바로 위에서 정의한 Stub과 Mock을 다시 살펴보면, 둘 다 의미하는 바가 같아 보인다. 테스트 코드에서도 실제로 호출될 함수들에 대해 미리 준비해 놓은 답을 리턴한다는 의미에서 비슷해 보인다. 그래서 정의만 놓고 보면 Stub과 Mock이 이름만 다르지 같아 보이고 뭐가 다른지 잘 모르겠다.

- Stub: 테스트에 필요한 호출에 대해 미리 준비된 답을 제공하는 객체
- Mock: 예상된 동작을 가진 객체

그런데 의미만 놓고 보면 같아 보이지만, 테스트 코드를 작성하는 관점에서 바라보면 크게 2가지 차이가 있다고 생각한다.

**서로 다른 스타일로 작성:**

- Stub: 실제 객체처럼 동작하는 클래스를 직접 구현하는데, 테스트에 필요한 구현에 집중하고 부가적인 기능은 구현하지 않는다.
- Mock: 다양한 Mock Framework를 통해서 Mock 객체를 생성하고 특정 액션에 대한 출력을 정의한다.

**상태 검증(state verification)과 행동 검증(behavior verification)의 차이:**

- Stub: 상태 검증을 사용한다. 어떤 입력에 대해서 어떤 출력이 발생하는지 검증한다.
- Mock: 행동 검증을 사용한다. 입력과 상관없이 출력을 어떻게 만들어 내는지에 집중한다. (위에 Mock 예시 코드에서 every - returns 구문을 사용한 부분 참고)

위에서 Stub을 이용해서 작성한 예시 테스트 코드들은 전부다 Mock을 사용하도록 바꿀 수 있다. 아래는 코드는 위에서 Dummy 예시를 위해 사용한 테스트 코드를 Mock을 이용해서 다시 작성한 내용이다.

```kotlin
test("FROM 계좌의 잔액이 부족하면 Failure 리턴(Using Mock)") {
    // arrange
    val bankPortMock = mockk<BankPort>()
    every { bankPortMock.getBalance(any(), any()) } returns 1000L
    val sut = TransferBank(
        transferHistoryRepository = mockk(),
        bankPort = bankPortMock,
        emailPort = mockk(),
    )

    // act
    val actual = sut.invoke(
        from = TransferBankUseCase.BankAccount("088", "1212121212"),
        to = TransferBankUseCase.BankAccount("088", "4242424242"),
        amount = 100_000L,
    )

    // assert
    (actual is TransferBankUseCase.Result.Failure) shouldBe true
}
```

그렇다면 어떤 경우에 Stub을 사용하고 어떤 경우에 Mock을 사용하면 좋을까? Stub을 사용해야 하는 곳과 Mock을 사용해야 하는 곳을 분명하게 나눌 수 있을까? 이 질문에 대한 정답은 없다고 생각한다. 어떤 경우에는 Stub만 사용해야 하고 어떤 경우에는 Mock만 사용해야 한다는 제약이 없다. 다만 개인의 취향과 각각의 장단점, 그리고 검증할 대상에 따라 조금 더 적절한 방법이 존재할 뿐이다. 재밌는건 Mock을 선호하는 사람들(Mockist)과 그렇지 않은 사람들(Classical)을 표현하는 단어까지 있다는 점.

**Classical Testing:**

- 가능하면 실제 객체를 사용하고 실제 객체를 사용하는 것이 어색할 때 Mock이나 Test Double을 사용하고, 되도록 Mock 사용을 지양한다.
- 예를 들어, TransferBank를 테스트 하기 위해 실제 프러덕션에서 사용되는 TransferHistoryRepository를 사용하고 이메일 발송에는 Test Double을 사용한다.

**Mockist Testing:**

- 동작하는 모든 객체에 대해 항상 Mock을 사용한다.
- 예를 들어, TransferBank를 테스트하기 위해 송금 결과 저장과 이메일 발송 모두 Mock 객체를 만들어서 사용한다.

취향 차이는 그렇다 치고, 내가 검증하고 싶은 대상에 따라 Stub과 Mock을 구분해서 사용한다는건 무슨 말일까? 위에서 Stub은 상태 검증(state verification)을 사용하고, Mock은 행동 검증(behavior verification)을 사용한다고 했다. **만약 내가 검증하고 싶은 대상이 입력과 관계 없이 어떤 행동을 했을때 내가 원하는 출력이 나오기만 해도 상관없다면 Mock을 사용하면 된다.** 아래 예시처럼 내가 검증하고 싶은건 `이메일을 한 번만 발송한다` 는 행동을 검증하는 것이고, 이걸 달성하기 위해 호출되는 함수들은 내가 원하는 `성공` 이라는 출력만 해주면 된다. 그리고 `이메일이 한 번만 발송됐다`는 행동을 MockK에서 제공하는 verify times 기능을 이용해 검증한다.

```kotlin
test("송금을 성공하면 이메일을 한 번 발송(Using Mock)") {
    val transferHistoryRepositoryMock = mockk<TransferHistoryRepository>()
    every { transferHistoryRepositoryMock.save(any()) } returns TransferHistory(
        id = 1L,
        fromBankCode = "088",
        fromBankAccountNumber = "1212121212",
        toBankCode = "088",
        toBankAccountNumber = "4242424242",
        amount = 100_000L,
    )
    val bankPortMock = mockk<BankPort>()
    every { bankPortMock.getBalance(any(), any()) } returns 100_000L
    every { bankPortMock.withdraw(any(), any(), any()) } returns BankPort.Result("success")
    every { bankPortMock.deposit(any(), any(), any()) } returns BankPort.Result("success")
    val emailPort = mockk<EmailPort>()
    every { emailPort.sendEmail(any()) } returns Unit
    val sut = TransferBank(
        transferHistoryRepository = transferHistoryRepositoryMock,
        bankPort = bankPortMock,
        emailPort = emailPort,
    )

    // act
    sut.invoke(
        from = TransferBankUseCase.BankAccount("088", "1212121212"),
        to = TransferBankUseCase.BankAccount("088", "4242424242"),
        amount = 100_000L,
    )

    // assert
    verify(exactly = 1) {
        emailPort.sendEmail(any())
    }
}
```

그런데 내가 검증하고 싶은 대상이 `저장된 송금 결과` 라면 위에서 살펴본 행동 검증과 달리 송금 결과가 저장되는지 확인할 수 있도록 상태 검증이 필요하다. 이를 위해 송금 결과를 저장하는 TransferHistoryRepository 인터페이스를 구현한 Stub 객체를 사용하는데, 여기서는 실제로 데이터베이스에 저장되는 것과 유사하게 메모리에 송금 결과를 저장하고 조회할 수 있는 기능을 제공한다. 그리고 `송금 결과가 저장된 상태`를 검증할 수 있도록 TransferHistoryRepository에서 제공하는 조회 기능을 사용해서 검증한다.

```kotlin
test("송금을 성공하면 송금 결과 저장(Using Stub)") {
    // arrange
    val transferHistoryRepositoryStub = object : TransferHistoryRepository {
        var historyMap: MutableMap<Long, TransferHistory> = mutableMapOf()

        override fun findById(id: Long): TransferHistory? {
            return historyMap[id]
        }
        override fun save(history: TransferHistory): TransferHistory {
            historyMap[history.id] = history
            return history
        }
    }
    val bankPortStub = object : BankPort {
        override fun getBalance(bankCode: String, accountNumber: String): Long {
            return 100_000L
        }
        override fun withdraw(bankCode: String, accountNumber: String, amount: Long): BankPort.Result {
            return BankPort.Result("success")
        }
        override fun deposit(bankCode: String, accountNumber: String, amount: Long): BankPort.Result {
            return BankPort.Result("success")
        }
    }
    val emailPortSpy = object : EmailPort {
        override fun sendEmail(content: String) {}
    }
    val sut = TransferBank(
        transferHistoryRepository = transferHistoryRepositoryStub,
        bankPort = bankPortStub,
        emailPort = emailPortSpy,
    )

    // act
    val actual = sut.invoke(
        from = TransferBankUseCase.BankAccount("088", "1212121212"),
        to = TransferBankUseCase.BankAccount("088", "4242424242"),
        amount = 100_000L,
    )

    // assert
    check(actual is TransferBankUseCase.Result.Success)
    val transferHistory = transferHistoryRepositoryStub.findById(actual.transferHistoryId)
    transferHistory shouldNotBe null
}
```

---

## Mocking 보다는 Stubbing 을 선호

여기부터는 흔히 알려진 사실과 개인적인 경험을 바탕으로 Mock 보다 Stub을 선호하는 이유에 관해서 이야기하려 한다.

Mocking을 사용했을때 가장 큰 문제는, **테스트할 대상(SUT)과 의존성(SUT 구성을 위한 인터페이스)이 어떻게 상호작용을 하는지 알아야 한다**는 것이다. 이건 Mock을 사용해서 작성한 **테스트 코드가 SUT의 구현에 의존한다**는 말과 같다. 위에서 살펴본 예시 중에서 Mock을 이용해서 작성한 송금 성공 테스트를 다시 살펴보자.

```kotlin
test("송금 성공(Using Mock)") {
    // arrange
    val transferHistoryRepositoryMock = mockk<TransferHistoryRepository>()
    every { transferHistoryRepositoryMock.save(any()) } returns TransferHistory(
        id = 1L,
        fromBankCode = "088",
        fromBankAccountNumber = "1212121212",
        toBankCode = "088",
        toBankAccountNumber = "4242424242",
        amount = 100_000L,
    )
    val bankPortMock = mockk<BankPort>()
    every { bankPortMock.getBalance(any(), any()) } returns 100_000L
    every { bankPortMock.withdraw(any(), any(), any()) } returns BankPort.Result("success")
    every { bankPortMock.deposit(any(), any(), any()) } returns BankPort.Result("success")
    val emailPort = mockk<EmailPort>()
    every { emailPort.sendEmail(any()) } returns Unit
    val sut = TransferBank(
        transferHistoryRepository = transferHistoryRepositoryMock,
        bankPort = bankPortMock,
        emailPort = emailPort,
    )

    // act
    val actual = sut.invoke(
        from = TransferBankUseCase.BankAccount("088", "1212121212"),
        to = TransferBankUseCase.BankAccount("088", "4242424242"),
        amount = 100_000L,
    )

    // assert
    (actual is TransferBankUseCase.Result.Success) shouldBe true
}
```

여기서 우리가 테스트할 대상(SUT)은 TransferBank, 의존성(SUT 구성을 위한 인터페이스)은 각각 TransferHistoryRepository, BankPort, EmailPort 인데 이 의존성들을 Mock을 이용해서 객체를 만들어 주입했다. 그리고 SUT가 실행되면 성공이 리턴되도록 각 Mock 객체가 어떤 일을 해야 하는지 정의했다. SUT와 Mock 객체들이 어떻게 상호작용을 하는지 알아야 성공 테스트를 작성할 수 있고, 테스트 코드를 보면 SUT가 어떤 흐름으로 성공을 리턴하는지 구현 사항이 한 눈에 보인다. 작성된 테스트 코드를 보면 SUT가 어떤 경우에 성공하는지 한눈에 볼 수 있어서 좋은 것 같기도 하다.

한 번 작성된 코드가 영원히 그대로 있으면 상관없겠지만, 우리의 코드는 계속해서 개선되며 요구사항에 따라 변화한다. 그렇다면 변화하는 테스트 대상(SUT, 여기서는 TransferBank)에 따라 작성된 Mocking 기반의 테스트 코드는 어떻게 될까? 깨진다. SUT의 의존성(BankPort, EmailPort 같은 것들)이 바뀔 수도 있고, SUT 구현체 안에서 호출되는 Mock 객체들의 함수가 바뀔 수도 있다. 변화에 대응하기 위해 요구사항을 추가하고 코드나 구조를 개선하기 위해 리팩터링을 할 때마다 사용되는 Mock 객체를 바꿔야 하는 일도 생긴다.

**흔히 테스트를 경제적 관점에서 해석하곤 한다. 장기적인 생산성과 변화에 대한 유연성을 확보한다는 측면과 테스트를 전적으로 비용 관점에서 바라봐야 한다**는 점에 동의하는 바이다. 잘 작성된 테스트는 발생할 수 있는 버그를 사전에 차단해 주고 변화에 대한 기록이 되기도 하며 협업을 위한 도구가 되기도 한다. 이 관점에서 봤을때 운영 코드(SUT)의 변화에 테스트 코드가 취약해져서는 안되고 그 결합이 다소 완만해야 한다. 그래서 SUT의 구현에 의존해서 발생할 수 있는 변화에 최대한 유연하게 대응하기 위해 Mocking 보다 Stubbing을 선호한다(물론 Stub을 이용한 테스트 코드 작성 자체를 Mocking 보다 좋아하긴 함).

그런데 지금까지 작성된 테스트 코드를 보면 \'Stub도 SUT 구현에 의존해 있는것 같은\' 의문이 생긴다. 맞는 말이다. 지금까지 작성된 예시만 보면 그렇다. 저렇게 매번 테스트 상황에 필요한 Stub 객체를 만드는건 Mock 객체를 사용하는 것처럼 구현에 의존되어 있고 비슷한 동작을 하는 Stub 객체를 만들어야 하는 불편한 점도 존재한다. Mock 객체를 사용할 때 어떤 동작을 해야 하는지 매번 정의하는 것처럼 Stub 객체도 매번 어떤 동작을 하는지 정의해줘야 한다면 그냥 Mock 객체를 쓰는만 못하는것 같다(오히려 Stub 클래스 정의를 선언해야 하는 불편함이 더해진다). 그럼 이런 중복 작성으로 인한 불편함과 구현에 의존한 Stub 객체를 어떻게 해결할 수 있을까?

---

## 재사용 가능한 Stub 클래스 정의하기

다시 처음으로 돌아가서 Stub 객체는 어떠한 Test Double 인지 살펴보자.

- 테스트에 필요한 호출에 대해 미리 준비된 답을 제공하는 객체다.
- 실제 객체처럼 동작하는 클래스를 직접 구현하는데, 테스트에 필요한 구현에 집중하고 부가적인 기능은 구현하지 않는다.
- 상태 검증을 사용한다. 어떤 입력에 대해서 어떤 출력이 발생하는지 검증한다.

그럼 매번 테스트를 작성할 때마다 테스트에 맞는 Stub Class를 정의하는게 아니라, 모든 테스트에서 일관되게 사용할 수 있으면서 실제 객체처럼 동작하는 클래스를 구현하면 된다. 우리가 테스트할 대상의 의존성은 TransferHistoryRepository, BankPort, EmailPort 이므로 각각 실제 객체처럼 동작하는 Stub 클래스를 구현해 보자.

```kotlin
open class TransferHistoryRepositoryStub : TransferHistoryRepository {
    private var historyMap: MutableMap<Long, TransferHistory> = mutableMapOf()

    override fun findById(id: Long): TransferHistory? {
        return historyMap[id]
    }
    override fun save(history: TransferHistory): TransferHistory {
        historyMap[history.id] = history
        return history
    }
}

open class BankPortStub : BankPort {
    // 은행 계좌별 잔액
    private var bankAccountMap: MutableMap<Pair<String, String>, Long> = mutableMapOf()

    override fun getBalance(bankCode: String, accountNumber: String): Long {
        return bankAccountMap[Pair(bankCode, accountNumber)] ?: 0L
    }

    override fun withdraw(bankCode: String, accountNumber: String, amount: Long): BankPort.Result {
        val currentBalance = bankAccountMap[Pair(bankCode, accountNumber)] ?: 0L
        if (amount > currentBalance) {
            return BankPort.Result("failure", "잔액 부족")
        }
        bankAccountMap[Pair(bankCode, accountNumber)] = currentBalance - amount
        return BankPort.Result("success")
    }

    override fun deposit(bankCode: String, accountNumber: String, amount: Long): BankPort.Result {
        val currentBalance = bankAccountMap[Pair(bankCode, accountNumber)] ?: 0L
        bankAccountMap[Pair(bankCode, accountNumber)] = currentBalance + amount
        return BankPort.Result("success")
    }
}

class EmailPortStub : EmailPort {
    private var emailCount = 0

    override fun sendEmail(content: String) {
        emailCount++
    }

    fun countSentEmail(): Int {
        return emailCount
    }
}
```

테스트에 사용할 Stub 클래스를 구현했으니 위에서 작성했던 테스트 코드에 각각 Stub 클래스를 적용해보자.

```kotlin
val givenFromBankAccount = TransferBankUseCase.BankAccount("088", "1212121212")
val givenToBankAccount = TransferBankUseCase.BankAccount("088", "4242424242")

test("FROM 계좌의 잔액이 부족하면 Failure 리턴") {
    // arrange
    val sut = TransferBank(
        transferHistoryRepository = TransferHistoryRepositoryStub(),
        bankPort = BankPortStub(),
        emailPort = EmailPortStub(),
    )

    // act
    val actual = sut.invoke(
        from = givenFromBankAccount,
        to = givenToBankAccount,
        amount = 100_000L,
    )

    // assert
    (actual is TransferBankUseCase.Result.Failure) shouldBe true
}

test("송금을 성공하면 이메일을 한 번 발송") {
    // arrange
    val bankPortStub = BankPortStub()
    bankPortStub.deposit(givenFromBankAccount.bankCode, givenFromBankAccount.accountNumber, 100_000L)
    val emailPortSpy = EmailPortStub()
    val sut = TransferBank(
        transferHistoryRepository = TransferHistoryRepositoryStub(),
        bankPort = bankPortStub,
        emailPort = emailPortSpy,
    )

    // act
    val actual = sut.invoke(
        from = givenFromBankAccount,
        to = givenToBankAccount,
        amount = 100_000L,
    )

    // assert
    check(actual is TransferBankUseCase.Result.Success)
    emailPortSpy.countSentEmail() shouldBe 1
}

test("송금을 성공하면 송금 히스토리 저장") {
    // arrange
    val bankPortStub = BankPortStub()
    bankPortStub.deposit(givenFromBankAccount.bankCode, givenFromBankAccount.accountNumber, 100_000L)
    val transferHistoryRepositorySpy = TransferHistoryRepositoryStub()
    val sut = TransferBank(
        transferHistoryRepository = transferHistoryRepositorySpy,
        bankPort = bankPortStub,
        emailPort = EmailPortStub(),
    )

    // act
    val actual = sut.invoke(
        from = givenFromBankAccount,
        to = givenToBankAccount,
        amount = 100_000L,
    )

    // assert
    check(actual is TransferBankUseCase.Result.Success)
    val transferHistory = transferHistoryRepositorySpy.findById(actual.transferHistoryId)
    transferHistory shouldNotBe null
}

test("송금 성공") {
    // arrange
    val bankPortStub = BankPortStub()
    bankPortStub.deposit(givenFromBankAccount.bankCode, givenFromBankAccount.accountNumber, 100_000L)
    val sut = TransferBank(
        transferHistoryRepository = TransferHistoryRepositoryStub(),
        bankPort = bankPortStub,
        emailPort = EmailPortStub(),
    )

    // act
    val actual = sut.invoke(
        from = givenFromBankAccount,
        to = givenToBankAccount,
        amount = 100_000L,
    )

    // assert
    (actual is TransferBankUseCase.Result.Success) shouldBe true
}
```

이전에 작성했던 테스트 코드와 비교해 보면 테스트 코드가 SUT 구현에 의존하지 않는다. 송금을 하기 위해서 FromBankAccount 계좌에 잔액이 충분해야 하므로 Arrange 하는 과정이 필요하지만 이건 SUT 구현과 상관없이 테스트 데이터를 셋업하기 위한 과정이라고 보면 된다. 

새로운 요구사항이 추가되어서 테스트 대상(SUT, TransferBank)의 의존성이 변경되면 어떨까? 예를 들어, 송금을 실행하기 전에 이상거래를 탐지하는 인터페이스가 추가된다고 가정해보자. 일단 의존성이 추가됐으니 SUT 객체를 생성하기 위해 `FraudDetectionPort` 같은 생성자를 추가로 전달해줘야 한다. 그다음 위에서 했던 것과 마찬가지로 FraudDetectionPort 인터페이스를 실제 객체처럼 동작하는 `FraudDetectionPortStub` 클래스를 정의하고 SUT 생성자로 전달해주면 된다. \"송금 성공\"이라는 테스트에 FROM 계좌의 잔액을 조회하고, FROM 계좌에서 출금하고, TO 계좌로 송금하고, 송금 결과를 저장하는 등의 행위가 드러나지 않기 때문에(구현에 의존적이지 않다) 테스트 코드를 수정할 일이 Mocking을 사용했을 때보다 현저히 줄어든다. 

테스트 대상(SUT) 코드를 리팩터링 한다면 어떨까? 마찬가지로 의존성과 구체적인 동작이 바뀌지 않는 이상 테스트 코드에는 자잘한 변화만 생길 것이다.

---

## 효율적인 Stubbing을 위한 모듈화

코드의 복잡도가 조금씩 올라가다 보면 우리는 결합도(Coupling)와 응집도(Cohesion)를 고려해서 모듈화를 선택하게 된다. 모듈화를 통해 결합도는 낮추고 응집도는 높일 수 있는 효과가 생기는데, 테스트 코드에도 모듈화를 적용하면 동일한 효과를 누릴 수 있다.

테스트에서의 모듈화가 어떤 장점을 가져다줄 수 있는지 살펴보기 위해 다시 상황을 가정해보자. 위에서 테스트했던 TransferBankUseCase를 통해 사용자가 자신의 계좌에서 다른 계좌로 실시간 송금할 수 있는 기능을 제공했다. 이제 사용자에게 새로운 가치를 제공하기 위해 예약된 시간에 송금을 할 수 있도록  ScheduledTransferBankUseCase 기능을 만들어 보려고 한다(이 코드 또한 오류가 많지만, 테스트를 위한 예시이므로 디테일한건 스킵).

```kotlin
// 예약한 시간이 되면 은행으로 송금으로 수행하는 인터페이스
interface ScheduledTransferBankUseCase {
    fun invoke(from: BankAccount, to: BankAccount): Result

    data class BankAccount(val bankCode: String, val accountNumber: String)

    data class Result(val data: List<TransferResult>)

    sealed interface TransferResult {
        data class Success(val transferHistoryId: Long) : TransferResult
        data class Failure(val throwable: Throwable) : TransferResult
        data object Ignore : TransferResult
    }
}

// 실제로 프로덕션에서 은행으로 예약 송금을 하기 위해 사용되는 구체 클래스
class ScheduledTransferBank(
    private val scheduledTransferRepository: ScheduledTransferRepository,
    private val transferBankUseCase: TransferBankUseCase,
) : ScheduledTransferBankUseCase {
    override fun invoke(from: ScheduledTransferBankUseCase.BankAccount, to: ScheduledTransferBankUseCase.BankAccount): ScheduledTransferBankUseCase.Result {
        val now = System.currentTimeMillis()
        // 예약된 송금이 있는지 검사
        val result = scheduledTransferRepository.findAllByFromBankAccount(from.bankCode, from.accountNumber)
            .map {
                // 예약 시간이 지났는지 검사
                when (it.scheduledAt > now) {
                    true -> ScheduledTransferBankUseCase.TransferResult.Ignore
                    false -> {
                        val result = transferBankUseCase.invoke(
                            from = TransferBankUseCase.BankAccount(from.bankCode, from.accountNumber),
                            to = TransferBankUseCase.BankAccount(from.bankCode, from.accountNumber),
                            amount = it.amount,
                        )
                        when (result) {
                            is TransferBankUseCase.Result.Success -> ScheduledTransferBankUseCase.TransferResult.Success(result.transferHistoryId)
                            is TransferBankUseCase.Result.Failure -> ScheduledTransferBankUseCase.TransferResult.Failure(result.throwable)
                        }
                    }
                }
            }
        return ScheduledTransferBankUseCase.Result(result)
    }
}
```

TransferBankUseCase 코드는 사용자에게 제공될 기능이므로 api라는 모듈에 있고, ScheduledTransferBankUseCase 코드는 시스템에서 스케쥴링을 통해서 실행되는 기능이므로 scheduler라는 모듈에 있다고 가정해보자. 마찬가지로 TransferBank 테스트 코드도 api 모듈에 존재한다면, ScheduledTransferBank 구현체를 테스트하기 위해 필요한 TransferHistoryRepository, BankPort, EmailPort 클래스에 대한 Stub 클래스를 새로 정의해야 할까? 이때 동일한 Stub 클래스를 재사용하기 위해 모듈화가 필요하다. 아래처럼 정의한 Stub 클래스를 모아놓은 `test-stub` 모듈을 분리하고, Stub 클래스가 필요한 모듈에서 `testImplementation`을 이용해서 임포트한 다음, 각 유스케이스 구현체를 테스트할 때 Stub 객체를 재사용하면 된다.

```kotlin
.
├── api              # TransferBankUseCase, TransferBank
│   └── test         # TransferBankTest. testImplementation 통해서 `core:test-stub`, `core:test-fixture` 주입
├── scheduler        # ScheduledTransferBankUseCase, ScheduledTransferBank
│   └── test         # ScheduledTransferBankTest. testImplementation 통해서 `core:test-stub`, `core:test-fixture` 주입
├── core
├────── src          # TransferHistoryRepository, BankPort, EmailPort, 각 구현체
│   └── test         # TransferHistoryRepositoryImplTest, BankHttpPortTest, EmailSmtpPortTest
│   └── test-stub    # TransferHistoryRepositoryStub, BankPortStub, EmailPortStub
│   └── test-fixture # TransferHistoryFixture, BankAccountFixture
```

---

## 마치며
테스트 커버리지를 100% 달성했다는 이야기라든가, 무슨 무슨 이유 때문에 테스트를 작성해야 한다든가. 이런 이야기들을 보면 나에겐 아직도 테스트는 이상(ideal)의 세계처럼 느껴진다. 테스트를 작성하면 좋다는건 누구나 다 아는 사실(fact)이다. 하지만 잘 작성된 테스트 코드란 뭘까. 테스트를 쉽고 효과적으로 작성하려면 어떻게 하면 좋을까. 글 중간에도 잠깐 나오는 내용인데 \'테스트를 전적으로 비용 관점으로 바라봐야 한다\'는 말이 굉장히 인상 깊었다. 테스트를 통해 지금 구현된 로직의 문제를 찾고 방지하는 것도 중요하고, 변화하는 요구사항에 테스트 코드도 유연하게 대응할 수 있어야 하고, 가장 중요한 건 지루하지 않고 조금이라도 재밌어야 한다는 점이다. 테스트 대상의 구현이 바껴서 테스트 Mock 코드를 수정하고 있으면 짜증이 나고 귀찮다. 많은 오픈소스들은 어떻게 테스트를 작성하고 있는지 살펴보고 내 테스트 코드에는 어떤 문제가 있는지 생각해보는 시간을 오래 가졌다. 효율적인 테스트를 작성하기 위해 Stub과 Fixture를 잘 활용하는 방법도 터득하게 되었다. 지금 작성된 코드나 방법이 최선일까? 그럴 수도 있고 아닐 수도 있다. 해결사가 와서 이거 이렇게 하면 된다라고 알려주지 않는 이상, 항상 더 나은 방법을 찾기 위해 이것 저것 시도해보고 이상(ideal)이라고 생각했던 것이 더이상 이상(ideal)이 아님을 깨닫는게 중요한 것 같다.
