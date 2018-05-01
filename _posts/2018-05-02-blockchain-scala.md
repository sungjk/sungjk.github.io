---
layout: entry
post-category: blockchain
title: 스칼라로 블록체인 구현하기
description: 블록체인을 구성하는 블록과 해시함수 등을 정리하였고, 스칼라로 간단한 구현 코드를 작성하였습니다.
thumbnail-image: /images/2018/05/02/blockchain3.png
keywords: 블록체인, 스칼라, blockchain, scala
publish: true
---

# 해시캐시
2008년 미국의 조사에 따르면, 스팸메일은 대략 천만 개당 하나 정도 효과가 있다고 한다. 천만 개 스팸메일을 보내서 그 중 한명만 걸려들어도 스팸메일을 보낼 만하다는 것이다. 천만 개 중 하나가 아니라 백만 개 중 하나라고 해도 누군가는 25년에 한 번 스팸에 넘어가면 스팸메일을 보내는 입장에서는 쓸 만한 광고 전략인 셈이다. 전 세계에서 수백, 수천명이 스팸메일에 속아 소액의 돈을 부쳤으면 짭짤한 사업이라 할 수 있다. 왜냐하면 스팸메일을 보내는 비용이 매우 싸기 때문이다.

그런데 여기서, 이메일을 보낼 때 한 사람당 1초쯤 걸린다면 어떨까? 일상적으로 메일을 보낼 때 1초 후에 전송되는 것은 문제가 되지 않을 것이다. 하지만 스팸메일을 보내는 입장에서는 큰일이다. 1명당 1초씩 걸린다면 한 시간에 3,600명이고, 하루에 86,400명, 한 달에 260만명 꼴이다. 위에서 나온 통계대로라면 4개월에 1명 정도의 효과가 있는 것이다. 이런 스팸메일은 가치가 없다.

**해시캐시** 는 이메일을 보낼 때 보내는 사람이 메일을 보내기 위해 노력했다는 증거(*작업 증명*)를 함께 보내서 내 메일은 스팸이 아니라고 알리는 방법이다. 작업 증명은 제약을 완화한 해시를 쓰면 된다.

우리가 이메일을 주고 받을 때, 이메일 헤더에는 보내는 사람의 이메일, 받는 사람의 이메일, 본문의 형식, 기타 이메일을 구성하고 전송하기 위한 각종 정보가 규정된 형식에 맞게 적혀 있다. 해시캐시를 써서 스팸메일 필터링을 할 때는 이메일 헤더에 *X-Hashcash* 라는 항목을 1개 추가해서 함께 보낸다.

*X-Hashcash* 헤더 항목의 값 전체를 해시의 X값이라고 생각해 보자. 이것이 해시함수의 입력인 X값이라고 하면 메일을 받은 사람은 이 값을 입력으로 하여 미리 해시함수를 계산할 수 있다. 계산 결과로 나온 Y값에서 앞쪽 20비트가 모두 0이면, 보낸 사람은 이 메일을 보내기 위해 자신의 시간을 써서 값을 계산해 냈다고 판단할 수 있는 것이다. 중요한 점은 받은 사람이 검증할 때 보낸 사람의 메일 주소를 확인하는 등 부수적인 정보를 이용하지 않고 판단할 수 있다는 것이다. 해시캐시로 검증하는 단계에서는 단지 헤더 항목 *X-Hashcash* 의 값만 보고 판단한다. 이것이 해시캐시의 핵심이다.

그런데 받는 사람 입장에서 이렇게 믿을 수 있는 근거는 뭘까? 해시캐시로 앞의 20비트를 0으로 만드는 결과가 나왔으니 계산에서 시간을 들인 건 확실하다. 여기에 입력된 X값은 나에게 보내는 메일을 위해서만 만들어졌다는 것을 알 수 있는 내용이 포함되어야 할 것이다. 그렇지 않으면 미리 이 값을 계산해놓고 여러번 반복해서 사용 할 수도 있을테니까. 나에게 보내기 위해 계산했다는 것은 X값에 내 이메일 주소가 포함돼 있는지 확인한다.

### Sender
그렇다면 보내는 쪽에서는 뭘 해야 할까?
메일을 작성할 때 새로 계산했다는 것을 랜덤 필드로 표현한다. 이 사람이 나에게 보낸 메일 중 같은 날짜와 시간에 같은 랜덤필드를 갖는 메일이 있으면 이미 받은 메일이라고 취급한다. 보내는 쪽에서는 X값을 해시함수에 넣어서 조건을 만족하는 결과가 나오도록 보내야 한다.

1. X에 들어갈 내용 중 버전, 날짜, 받는 사람 등은 메일을 작성할 때 자동으로 채워진다.
2. 랜덤값을 새로 만들어 랜덤 필드를 채운다.
3. 모든 내용을 채우고 나면 빈 자리는 카운터 밖에 없다.
4. 여러 번의 시도 끝에 조건을 만족하는 카운터 값을 찾았으면 그 값을 넣어 메일을 보낸다.

### 해시캐시에서의 작업증명 요약
- 해시를 역으로 계산하면서 결과값 Y가 일정 범위에 들어가도록 결과의 범위를 넓혀 주면서 X값을 찾는다.
- 이메일 헤더에 X값을 포함하여 보내면 보내는 사람이 받는 사람에게 메일을 보내기 위해 노력했다는 작업증명이 된다.
- 메일을 받는 사람은 해시함수를 한 번만 계산하면 값을 확인할 수 있다.
- 검증할 떄 누구에게 물어볼 필요 없이 헤더값만으로 검증할 수 있다(제 3자의 검증이 필요 없음).

---

# 블록의 구성
블록은 블록체인의 기본 요소다. 해시캐시 메일 헤더를 쓰면 메일을 보낸 사람이 일정한 노력을 들였다는 것을 받는 사람이 알 수 있다고 했다. 해시캐시에서는 메일 헤더에 이 내용을 적어 두어 메일을 보내는 데 노력을 들였다는 증거로 이용했다. 해시 결과값에서 앞의 20비트가 0이면 이메일을 보내기 위해 노력했다는 것을 인정했다.

![blockchain3](/images/2018/05/02/blockchain3.png "blockchain3"){: .center-image }
<center><a href="https://esotera.eu/clients-explorers/" target="\_blank">The basic structure of a Block</a></center>

해시캐시에서 값이 바뀌는 부분이 있고 바뀌는 값에 따라 해시를 계산해서 찾아내야 하는 값이 있다고 했다. 해시캐시에서 카운터라고 했던 부분은 블록체인에서 Nonce라는 용어로 바뀌었다(위 그림에서 Random nonce). Nonce는 일시적이고 임시방편인 것을 표현하는 말로, 이 블록만을 위해 일회용으로 찾아낸 값이란 의미다. 이 블록을 만드는 사람은 SHA(바뀌는 값 + Nonce)를 계산해서 앞의 20비트가 0인 값이 나올 때까지 계산하는 것이다. 그리고 이 블록을 보는 사람은 그냥 전체를 SHA 해시로 계산해서 앞의 20비트가 0이면 진짜인지 가짜인지 알아볼 수 있다.

누군가 일정한 노력을 들여 Nonce를 계산해서 하나의 블록을 완성하면 다른 사람은 블록만 보고 원 저자가 노력을 들인 것을 알게 된다. Nonce는 블록의 다른 내용이 결정된 후에 계산된 것이 분명하다. 블록의 내용이 무엇이든 이것을 계산해 낸 사람은 블록 내용이 결정된 후에 많은 노력을 들여 Nonce를 계산했다. 블록에 들어가는 내용은 응용분야에 따라 달라질 수 있는데 비트코인에서는 거래 기록이 들어간다.

# 블록의 연결
모든 정보를 한 덩어리의 블록으로 만드는 것은 답이 아니다. 쓰면 쓸수록 점점 커지는 블록은 금세 관리와 계산능력의 한계에 다다를 것이므로 쓸모가 없어진다. 뭔가 하나만 고치려 해도 너무 많은 일을 해야 한다. 블록체인에서는 이 문제를 블록을 연결하여 해결했다. 블록의 체인을 만드는 것이다.

```
00000000   01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
00000010   00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
00000020   00 00 00 00 3B A3 ED FD  7A 7B 12 B2 7A C7 2C 3E   ....;£íýz{.²zÇ,>
00000030   67 76 8F 61 7F C8 1B C3  88 8A 51 32 3A 9F B8 AA   gv.a.È.ÃˆŠQ2:Ÿ¸ª
00000040   4B 1E 5E 4A 29 AB 5F 49  FF FF 00 1D 1D AC 2B 7C   K.^J)«_Iÿÿ...¬+|
00000050   01 01 00 00 00 01 00 00  00 00 00 00 00 00 00 00   ................
00000060   00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
00000070   00 00 00 00 00 00 FF FF  FF FF 4D 04 FF FF 00 1D   ......ÿÿÿÿM.ÿÿ..
00000080   01 04 45 54 68 65 20 54  69 6D 65 73 20 30 33 2F   ..EThe Times 03/
00000090   4A 61 6E 2F 32 30 30 39  20 43 68 61 6E 63 65 6C   Jan/2009 Chancel
000000A0   6C 6F 72 20 6F 6E 20 62  72 69 6E 6B 20 6F 66 20   lor on brink of
000000B0   73 65 63 6F 6E 64 20 62  61 69 6C 6F 75 74 20 66   second bailout f
000000C0   6F 72 20 62 61 6E 6B 73  FF FF FF FF 01 00 F2 05   or banksÿÿÿÿ..ò.
000000D0   2A 01 00 00 00 43 41 04  67 8A FD B0 FE 55 48 27   *....CA.gŠý°þUH'
000000E0   19 67 F1 A6 71 30 B7 10  5C D6 A8 28 E0 39 09 A6   .gñ¦q0·.\Ö¨(à9.¦
000000F0   79 62 E0 EA 1F 61 DE B6  49 F6 BC 3F 4C EF 38 C4   ybàê.aÞ¶Iö¼?Lï8Ä
00000100   F3 55 04 E5 1E C1 12 DE  5C 38 4D F7 BA 0B 8D 57   óU.å.Á.Þ\8M÷º..W
00000110   8A 4C 70 2B 6B F1 1D 5F  AC 00 00 00 00            ŠLp+kñ._¬....
```

<center><a href="https://en.bitcoin.it/wiki/Genesis_block" target="\_blank">The raw hex version of the Genesis block</a></center>

블록체인에서는 생성된 첫번째 블록을 *Genesis Block* 이라고 부른다. Genesis Block의 경우 누군가가 이미 Nonce를 계산하여 만들어 놨기 때문에 Genesis Block의 해시값을 계산하는 것은 쉽다. Genesis Block의 Nonce를 포함하여 계산한 해시값은 조건을 만족하고 있을 테니 2^140보다 작은 값이다. 블록1(그 다음 블ㄹ록)을 만드는 사람은 이 해시값을 블록의 내용에 넣고 블록1의 Nonce를 계산한다. Genesis Block의 해시값이 블록1에서는 내용의 일부로 사용되고 블록1의 Nonce를 새로 찾아내야 한다. 즉 반드시 Genesis Block를 가지고 있어야만 블록1을 만들 수 있다.

만약 100번째 블록을 누군가가 만드렬 한다면 이 사람은 정당한 해시값이 나오는 정상적인 99번째 블록을 가지고 있어야 100번째 블록을 만들 수 있다. 단순히 다음 블록에 이전 블록의 해시값을 넣어 준 것만으로 한 무리의 블록체인이 단계별로 순차적으로 만들어진 것을 검증하고 믿을 수 있게 된 것이다.

![blockchain1](/images/2018/05/02/blockchain.svg "blockchain1"){: .center-image }
<center><a href="https://bitcoin.org/en/developer-guide#block-chain" target="\_blank">Block Chain Overview</a></center>

여기에서 블록을 연결하는 체인은 프로그래밍 용어인 포인터, 즉 데이터의 주소나 파일명 같은 컴퓨터 내의 위치 정보가 아니다. 여기서 얘기하는 것은 그런 주소가 아니다. Nonce와 이를 포함해서 계산한 해시값이 블록을 이어주는 체인이자 연결고리이다.

비트코인은 응용분야에서 암호화폐로 사용되기 때문에 해시캐시보다 더 조건을 강화해야 한다. 컴퓨터 속도가 빨라도 금방 계산되지 않는 해시, 즉 최대한 믿을 수 있도록 하기 위해 SHA가 고안되었다. 해시캐시에서는 SHA-160 함수를 사용했고, 비트코인에서는 SHA256 함수를 이용하고 앞자리도 20비트가 아닌 40비트가 0이 돼야 하는 조건으로 강화했다.

SHA-256은 어떤 입력이 들어가든 해시 결과가 256비트 크기의 출력이 나온다는 의미다. 앞자리 40비트가 0이란 의미는 256비트 중 40비트를 제외한 나머지 216비트는 아무 값이어도 상관없다는 뜻이다. 한 비트가 늘었을 떄 두 배로 어려워지는 것이므로 20비트가 늘면 2^20배, 대략 백만 배만큼 어려워지는 것이다.

### 블록체인 구조의 요약
- 하나의 블록은 이전 블록의 해시값을 포함하여 구성된다. 이전 블록의 해시값은 미리 만들어 놓을 수 없으므로 이전 블록을 가지고 있지 않으면 새 블록을 만들 수 없다.
- 블록을 직접 만들지 않고 전달받은 사람도 블록이 정당한지 이전 블록에서 쉽게 계산할 수 있어 검증하기가 쉽다.
- 체인이 길어지면 아래에 놓은 블록은 신뢰도가 점점 더 높아진다.

---

# 블록체인 구현

```
case class Block(
  index: Long,
  previousHash: String,
  timestamp: Timestamp,
  messages: List[BlockMessage],
  nonce: Long
)
```

블록은 크게 이전 블록의 해시값, 블록에 담길 데이터(messages) 그리고 블록 생성을 위해 계산해야할 Nonce 값으로 이루어져 있다. BlockMessage에는 블록에 담길 데이터가 포함되는데, 가상화폐의 경우 각 블록에 작성된 Transaction 데이터가 포함된다. 블록체인에서 첫번째 블록은 Genesis Block이라고 부른다. Genesis Block은 블록체인의 0번째 블록을 말하며, 이전 블록이 존재하지 않으므로 해시는 임의의 값으로 할당해준다.

```
sealed trait Chain {
  val size: Int
  val hash: String
  val block: Block
  val nonce: Long

  def ::(block: Block): Chain = ChainLink(this.size + 1, block, hash, this)

  override def toString: String = s"$size:$hash:${block.toContentString}:$nonce"
}

case class ChainLink(
  index: Int,
  block: Block,
  previousHash: String,
  tail: Chain,
  timestamp: Timestamp = Timestamp.current
) extends Chain {
  val size = 1 + tail.size
  val hash = StringUtils.sha256Hex(this.toString)
  val nonce = block.nonce
}

case object EmptyChain extends Chain {
  val size = 0
  val hash = "1"
  val block = null
  val nonce = 100L
}

object Chain {
  def apply(blocks: ChainLink*): Chain = {
    if (blocks.isEmpty) EmptyChain else {
      val chainLink = blocks.head
      ChainLink(chainLink.index, chainLink.block, chainLink.previousHash, apply(blocks.tail: _*))
    }
  }
}

```

Chain은 블록과 블록을 이어서 BlockChain을 만들어주는 연결고리 역할을 한다. 위에서 설명하였듯이 블록을 연결하는 체인은 포인터와 같은 데이터의 주소가 아니라, Nonce와 이를 포함해서 계산한 해시값으로 다음 블록을 이어주는 역할을 한다고 하였다. 그래서 ChainLink는 이전 해시값과 새로 계산된 해시값을 가지고 있고, 이는 블록을 서로 연결하고 있다는 것을 의미한다. 만약 새로운 Chain을 만들때 주어진 ChainLink 없다면 EmptyChain을 반환하고, 그렇지 않으면 새로운 체인을 생성한다.

```
class BlockChain(chain: Chain = EmptyChain) {
  val messages : ArrayBuffer[BlockMessage] = ArrayBuffer.empty
  val nodes : ArrayBuffer[URL] = ArrayBuffer.empty

  def registerNode(address: String): Unit = nodes += new URL(address)

  def addMessage(data: String) : Int = {
    messages += BlockMessage(data)
    chain.size + 1
  }

  def checkPoWSolution(lastHash: String, proof: Long) : Boolean =
    ProofOfWork.validateProof(lastHash, proof)

  def addBlock(nonce: Long, previousHash: String = "") : BlockChain = {
    val block = Block(chain.size + 1, previousHash, Timestamp.current, messages.toList, nonce)
    messages.clear()
    new BlockChain(block :: chain)
  }

  def findProof() : Long = ProofOfWork.proofOfWork(getLastHash)

  def getLastBlock: Block = chain.block

  def getLastHash: String = chain.hash

  def getLastIndex: Int = this.chain.size

  def getChain: Chain = this.chain
}
```

전체 코드는 [Github](https://github.com/sungjk/s-blockchain)에서 확인하실 수 있습니다.

---


# Reference
- [블록체인 펼쳐보기](http://www.yes24.com/24/goods/56887730)
- [Bitcoin Developer Guide](https://bitcoin.org/en/developer-guide#block-chain)
