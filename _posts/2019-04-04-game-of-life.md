---
layout: entry
title: Scala로 라이프 게임(Game of Life) 풀어보기
author: 김성중
author-email: ajax0615@gmail.com
description: 영국의 수학자 존 호턴 콘웨이(Conway)가 고안해낸 세포 자동자의 일종인 라이프 게임을 풀어보는 과정입니다.
keywords: 라이프 게임, Game Of Life, Life game, 스칼라, Scala
publish: true
---

라이프 게임(Game of Life)는 영국의 수학자 존 호턴 콘웨이(John Conway)가 고안해낸 세포 자동자의 일종입니다. 라이프 게임은 컴퓨터 과학에서도 의미가 있는데, 왜냐하면 라이프 게임이 범용 튜링 기계와 동등한 계산능력을 가진 세포 자동자이기 때문이다. 즉, 어떤 알고리즘에 의해 계산될 수 있는 것이라면 모두 이를 이용하여 계산할 수 있다.

![game_of_life](/images/2019/04/04/game_of_life.gif "game_of_life"){: .center-image }

[콘웨이가 직접 설명해주는 영상](https://youtu.be/E8kUJL04ELA)을 봐도 도움이 많이 될 것이다.

# 규칙
라이프 게임은 몇 가지 규칙(패턴)에 의해 진행되기 때문에 입력된 초기값이 게임의 모든 진행을 좌우하게 된다. 세포가 진화하는 과정처럼 다음 단계를 하나의 세대로 표현한다. 그리고 다음 세대로 넘어갈 때 세포들의 생사(生死)는 인접한 8개의 세포들을 기준으로 아래의 규칙을 통해 결정된다.

1. 살아 있는 세포에 살아 있는 이웃이 2개 미만이면 인구 부족(underpopulation)으로 죽는다.
2. 살아 있는 세포에 살아 있는 이웃이 2개나 3개이면 다음 세대에도 살아있는다.
3. 살아 있는 세포에 살아 있는 이웃이 3개 초과이면 인구 과잉(overpopulation)으로 죽는다.
4. 죽어 있는 세포에 살아 있는 이웃이 정확히 3개이면 번식(reproduction)으로 다음 세대에 살아난다.

# 그려보기
초기에 살아있는 세포가 세로 일자(ㅣ) 모양을 하고 있다고 가정하고 그려보자.

![game_of_life_draw_2](/images/2019/04/04/game_of_life_draw_2.jpeg "game_of_life_draw_2"){: .center-image }

연하게 색칠한 부분이 현재 살아있는 세포를 표현한 것이고, 숫자는 살아있는 세포의 갯수를 표시한 것이다. 그리고 다음 세대에 죽을지 살지 여부는 현재 살아있는지의 여부(색칠되어 있는지)와 살아있는 이웃 세포의 수(숫자)를 가지고 판단한다.

도입부에서도 설명하였듯이 라이프 게임에서는 입력된 초기값이 게임의 모든 진행을 좌우하게 되는데, 일자 모양으로 주어졌을때 다음 세대에는 가로 일자(ㅡ) 모양을 하게 되고 그 다음 세대에는 세로 일자(ㅣ) 모양이 된다. 계속 이 패턴을 반복한다.

그럼 이번에는 초기에 살아있는 세포가 십자(十) 모양을 하고 있다고 가정하고 그려보자.

![game_of_life_draw](/images/2019/04/04/game_of_life_draw.jpeg "game_of_life_draw"){: .center-image }

8번째 세대에서는 어떤 모양을 하고 있을까 생각해보면, 처음에 그려봤던 세로 일자(ㅣ) 모양을 생각해보면 쉽다. 세로 일자(ㅣ) 모양은 가로 일자(ㅡ) 모양으로 바뀔 것이고, 가로일자 모양은 세로일자 모양으로 바뀔 것이다. 정리하자면 6, 7번째에서 나왔던 패턴이 세대를 거듭할 수록 반복된다.

# 구현해보기
위에서 본 규칙은 4가지가 복잡해 보일 수 있는데 그리 복잡하지 않다. 현재 세포가 살아있으면서(AND) 주위에 살아있는 이웃의 갯수가 2개이면 되고 또는(OR) 죽어있던 살아있던 상관없이 주위에 살아있는 이웃의 갯수가 3개이면 다음 세대에 살아난다. 그럼 이 규칙을 바탕으로 코드를 작성해보자.

```java
class GameOfLife {
  // 현재 살아있는 세포들을 기준으로 인접한 모든 세포들을 구하는 함수
  private def candidates(cells: Set[Cell]): Set[Cell] =
    cells flatMap { cell =>
      for {
        x <- cell.x - 1 to cell.x + 1
        y <- cell.y - 1 to cell.y + 1
      } yield Cell(x, y)
    }

  // 현재 살아있는 세포들을 기준으로 인접한 이웃들 중 살아있는 세포들을 구하는 함수
  private def alives(cells: Set[Cell], candidate: Cell): Set[Cell] =
    cells filter { cell =>
      cell != candidate &&
      math.abs(cell.x - candidate.x) <= 1 &&
      math.abs(cell.y - candidate.y) <= 1
    }

  // 현재 살아있는 세포를 기준으로 다음 세대에 살아있는 세포를 구하는 함수
  def evolve(cells: Set[Cell]): Set[Cell] =
    candidates(cells) filter { candidate =>
      val alivesCount = alives(cells, candidate).size
      (cells contains candidate) && alivesCount == 2 || alivesCount == 3
    }
}
```

---

# Reference
- [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)
