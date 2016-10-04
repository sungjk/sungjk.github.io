---
layout: entry
title: Edit distance 알고리즘
author: 김성중
author-email: ajax0615@gmail.com
description: 두 문자열의 유사도 판단에 사용되는 Edit distance 알고리즘에 대한 설명입니다.
publish: true
---

## Edit distance 알고리즘이란?
[위키피디아](https://en.wikipedia.org/wiki/Edit_distance)는 Edit distance에 대해 다음과 같이 정의하고 있습니다.

> Edit distance is a way of quantifying how dissimilar two strings (e.g., words) are to one another by counting the minimum number of operations required to transform one string into the other.

즉, Edit distance는 하나의 문자열을 다른 문자열로 변환하기 위해 필요한 연산의 최소 횟수를 말합니다. 두 문자열의 유사도를 판단하는 기준은 어떠한 문자열에 대해 삽입, 삭제, 변경을 몇 번에 걸쳐 바꿀 수 있는지 그 최소값을 계산하는 것입니다.

간단하게 예를 들어보겠습니다. 문자열 CAKE와 BAKE를 비교한다고 가정해 봅시다. 모든 연속 부분 집합에 대해서 비교를 해야 합니다.

먼저 두 문자열의 처음 비교 대상은 각각의 공집합입니다. 둘 다 같은 문자열이기 때문에 바꿀 것이 없는 경우 cost는 0입니다.

그 다음 순서에 C와 {}를 비교하면 하나를 추가 해야하므로 cost는 1이 됩니다. 이어서 CA와 {}를 비교하면 두 개를 추가해야 하므로 cost는 2가 됩니다. 이런식으로 테이블을 채워나가면 다음과 같은 형태가 됩니다.

| :---: | :---: | :---: | :---: | :---: | :---: |
|  | {} | B | A | K | E |
| {} | 0 | 1 | 2 | 3 | 4 |
| C | 1 |  |  |  |  |
| A | 2 |  |  |  |  |
| K | 3 |  |  |  |  |
| E | 4 |  |  |  |  |

테이블을 채워나가다 보면 다음과 같은 사실을 알 수 있습니다. 비교해야 할 두 문자가 일치할 경우, 이전의 cost를 가져오면 됩니다. 따라서, C[i] == B[j] 이면, cost(i, j) = cost(i - 1, j - 1)입니다. 만약 두 문자가 다를 경우, 이전의 cost에서 1을 증가 시키면 됩니다. 정리하면 다음과 같습니다.

1. **비교할 두 문자가 같으면, cost(i, j) = cost(i - 1, j - 1);**

2. **비교할 두 문자가 다르면, cost(i, j) = 1 + min(cost(i - 1, j), cost(i, j - 1), cost(i - 1, j - 1));**

따라서, 위 규칙에 따라 테이블을 완성하면 다음과 같습니다.

| :---: | :---: | :---: | :---: | :---: | :---: |
|  | {} | B | A | K | E |
| {} | 0 | 1 | 2 | 3 | 4 |
| C | 1 | 1 | 2 | 3 | 4 |
| A | 2 | 2 | 1 | 2 | 3 |
| K | 3 | 3 | 2 | 1 | 2 |
| E | 4 | 4 | 3 | 2 | 1 |

#### 코드

```
int getEditDistance(string& H, string& N) {
    int lenH = H.length(), lenN = N.length();
    vector<vector<int> > dist = vector<vector<int> >(lenH + 1, vector<int>(lenN + 1, 0));
    for (int i = 1; i <= lenN; ++i)
        dist[0][i] = i;
    for (int j = 1; j <= lenH; ++j)
        dist[j][0] = j;

    for (int i = 1; i <= lenN; ++i) {
        for (int j = 1; j <= lenH; ++j) {
            if (N[i - 1] == H[j - 1]) {
                dist[j][i] = dist[j - 1][i - 1];
            }
            else {
                dist[j][i] = 1 + min(dist[j - 1][i], min(dist[j][i - 1], dist[j - 1][i - 1]));
            }
        }
    }
    return dist[lenH][lenN];
}
```
