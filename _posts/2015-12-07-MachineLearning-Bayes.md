---
layout: entry
title: Machine Learning - Naive Bayes classifier
author: 김성중
author-email: ajax0615@gmail.com
description: 머신러닝에서 많이 사용되는 분류 알고리즘인 Naive Bayes classifier에 대한 설명입니다.
publish: true
---

**Naive Bayes classifier** 는 머신러닝 알고리즘 중 분류 알고리즘으로 많이 사용되는 알고리즘이다.

# 배경 지식

### Bayesian Theorem

매개 변수 x, y가 있을때, 분류 1에 속할 확률이 P1(x, y)이고, 분류 2에 속할 확률이 P2(x, y)일 때,

    - P1(x, y) > P2(x, y) 이면, 이 값은 분류 1에 속한다.
    - P2(x, y) > P2(x, y) 이면, 이 값은 분류 2에 속한다.
    - **Naive Bayes Algorithm** 은 이 베이스의 정리를 이용하여, 분류하고자 하는 대상의 각 분류별 확률을 측정하여, 그 확률이 큰 쪽으로 분류하는 방법을 취한다.

예를 들어, 이메일에 대해서 스팸과 스팸이 아닌 분류가 있을때, 이메일에 들어가 있는 단어들 w1, ..., wN 매개 변수("쇼핑", "비아그라", "보험", ...)에 대해서,
해당 이메일이 스팸일 확률과 스팸이 아닐 확률을 측정하여 확률이 높은 쪽으로 판단한다.

### 조건부 확률
**Naive Bayes classifier** 를 이해하기 위해서는 확률의 개념 중 조건부 확률이란 것을 이해해야 한다. 조건부 확률이란, 사건 A가 일어났을 때, 사건 B가 일어날 확률, 즉 "사건 A에 대한 사건 B의 조건부 확률"이라고 하며, `P(B|A)`로 표현한다.

예를 들어, 한 학교의 학생이 남학생인 확률이 P(A)이고, 학생의 키가 170이상인 확률을 P(B)라고 했을때, 남학생 중에서 키가 170 이상인 확률은 B의
조건부 확률이 되며 `P(B|A)`로 표현한다.

이 조건부 확률을 이용하면, 모르는 값에 대한 확률을 계산할 수 있다.

    - P(A|B) = P(A∩B) / P(B)    : 1
    - P(B|A) = P(A∩B) / P(A)    : 2

P(A∩B)를 통해 식을 정리하면,

    - P(A|B) * P(B) = P(B|A) * P(A)
    - P(A|B) = P(B|A) * P(A) / P(B)

앞의 남학생인 확률 P(A)와 키가 170이상인 확률 P(B)를 알고, 남학생 중 키가 170이상인 확률 `P(B|A)`를 알면, 키가 170이상인 학생 중 남학생인 확률
`P(A|B)`를 알 수 있다.

<br>

# **Naive Bayes Algorithm** 을 이용한 분류 예

다음과 같이 5개의 학습 문서가 존재하고, 분류가 comedy, action 두 개가 존재한다고 하자.

| movie | word | 분류 |
| :---: | :---: | :---: |
| 1 | fun, couple, love, love | comedy |
| 2 | fast, furious, shoot | action |
| 3 | couple, fly, fast, fun, fun | comedy |
| 4 | furious, shoot, shoot, fun | action |
| 5 | fly, fast, shoot, love | action |

이제 어떤 문서에 "fun, furious, fast" 라는 3개의 단어만 있는 문서가 있을 때, 이 문서가 comedy 인지 action 인지 분리를 해보자.

    해당 영화가 comedy인 확률은

    - P(comedy|word) = P(word|comedy) * P(comedy) / P(word)

    해당 영화가 action인 확률은

    - P(action|word) = P(word|action) * P(action) / P(word)

A1 > A2이면 comedy로 분류하고, A1 < A2이면 action으로 분류한다.

이 때, A1과 A2는 모두 P(word)로 나누는데, 대소 값만 비교하기 때문에 굳이 P(word)를 구해서 나눌 필요가 없으므로

    - P(comedy|word) = P(word|comedy) * P(comedy)       : B1
    - P(action|word) = P(word|action) * P(action)       : B2

로 구하면 된다. 먼저 각 단어의 빈도수를 계산하면,

    - Count(fast, comedy) = 1       : comedy 중에서 fast라는 단어가 나오는 횟수
    - Count(furious, comedy) = 0
    - Count(fun, comedy) = 3
    - Count(fast, action) = 2
    - Count(furious, action) = 2
    - Count(furious, action) = 1

P(word|comedy)는 comedy 영화 중에서 지정한 단어가 나타나는 확률로, 이를 개별 단어로 합치면 P(fast, furious, fun | comedy)으로,
각 단어가 상호 연관 관계가 없이 독립적이라면(conditional independence)

`P(fast|comedy) * P(furious|comedy) * P(fun|comedy)`

로 계산할 수 있다.

이를 계산하면 comedy 영화에서 총 단어의 갯수는 9번 나타났기 때문에 분모는 9가 되고, 그 중에서 각 단어별로 comedy에서 나타난 횟수는 위와 같이
comedy이면서 fast인 것이 1번, comedy이면서 furious인 것이 0번, comedy이면서 fun인 것이 3번이 되서,

`P(fast|comedy) * P(furious|comedy) * P(fun|comedy)` 는 (1/9) * (0/9) * (3/9) 가 된다.

P(comedy)는 전체 영화 5편 중에서 2편이 comedy이기 때문에 P(comedy) = 2/5 가 된다.

이를 B1에 대입하면,

`P(comedy|word) = (1/9) * (0/9) * (3/9) * 2/5 = 0` 이 된다.

같은 방식으로 B2를 계산하면 액션 영화에서 총 단어수는 11이고, 각 단어의 발생 빈도로 계산하면
`P(action|word) = (2/11) * (2/11) * (1/11) * 3/5 = 0.0018` 이 된다.

결과적으로, `P(action|word) = 0.0018 > P(comedy|word) = 0` 이기 때문에, 해당 문서는 액션 영화로 분류가 된다.

<br>

# Laplace smoothing
위의 **Naive Bayes Algorithm** 을 사용할 때, 하나의 문제점은 학습 데이터에 없는 단어가 나오는 것이다. 즉 분류를 계산할 문서에 "cars"라는 단어가
있다고 하자. 이 경우 학습 데이터를 기반으로 계산하면 "cars"는 없는 데이터라서 `P(cars|comedy)`와 `P(cars|action)`은 모두 0이 되고, `P(comedy|word)`와
`P(action|word)`도 결과적으로 모두 0이 되기 때문에 분류를 할 수 없다.

즉 문서가 "fun, furious, fast, cars")로 되면

    - P(comedy|word) = (1/9) * (0/9) * (3/9) * (0/9:cars 단어가 나온 확률) * 2/5 = 0
    - P(action|word) = (2/11) * (2/11) * (1*11) * (0/9:cars 단어가 나온 확률) * 3/5 = 0

이를 해결하기 위한 방법이 **Smoothing** 이라는 기법으로, 새로운 단어가 나오더라도 해당 빈도에 +1을 해줌으로써 확률이 0이 되는 것을 막는다.

<br>

출처: [조대협의 블로그](http://bcho.tistory.com/1010)
