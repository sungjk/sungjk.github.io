---
layout: entry
title: 인터뷰 - 트리와 그래프
author: 김성중
author-email: ajax0615@gmail.com
description: 인터뷰에서 다룰만한 기본적인 트리와 그래프에 대한 설명입니다.
publish: true
---

## 유의해야 할 이슈들
트리와 그래프에 관한 질문들은 그 세부사항이 모호하거나 가정이 틀린 경우 잘못 풀기 쉽습니다. 그러니 아래의 이슈들에 대해 유의하고, 필요하면 면접관에게 명확하게 해 줄 것을 요구해야 합니다.

#### 이진 트리 vs. 이진 탐색 트리
이진 트리에 대한 질문을 받으면, 많은 사람들은 면접관이 이진 '탐색 트리' *binary search tree* 에 대한 질문을 했다고 믿습니다. 이진 탐색 트리인지 아닌지 확실히 묻도록 합시다. **이진 탐색 트리는 모든 노드에 대해서 그 왼쪽 자식들의 값이 현재 노드 값보다 작거나 같도록 하고, 그리고 오른쪽 자식들의 값은 현재 노드의 값보다 크도록 강제합니다.**

![binary-tree-vs-binary-search-tree](/images/2016/10/07/binary-tree-vs-binary-search-tree.jpg "binary-tree-vs-binary-search-tree"){: .center-image }

#### 균형 vs. 비균형
많은 트리가 균형 트리 *balanced tree* 이긴 하지만, 전부 그런 것은 아닙니다. 면접관에게 어느 쪽인디 묻도록 합시다. **비균형 트리라면 여러분의 알고리즘을 평균 수행 시간과 최악 수행 시간 관점에서 설명할 필요** 가 있습니다. 트리의 균형을 맞추는 데는 여러 가지 방법이 있으며, 트리의 균형을 맞춘다는 것은 하위 트리의 깊이가 지정된 값 이상으로 달라지지 않는다는 것을 의미한다는 점에 유의해야 합니다. 왼쪽 하위 트리와 오른쪽 하위 트리의 깊이가 정확하게 일치함을 의미하지는 않습니다.

![BalancedTree-Example](/images/2016/10/07/BalancedTree-Example.png "BalancedTree-Example"){: .center-image }

#### 포화 이진 트리와 완전 이진 트리
포화 이진 트리 *full binary tree* 와 완전 이진 트리 *complete binary tree* 의 경우 모든 말단 노드 *leaf node* 가 트리 바닥에 위치하고, 모든 비말단 노드들은 정확히 두 개의 자식을 갖습니다. 포화 이진 트리와 완전 이진트리는 굉장히 드문데, 그 조건을 만족하는 **트리에 정확히 2^n-1개의 노드가 존재** 해야 하기 때문입니다.

![full-and-complete-binary-tree](/images/2016/10/07/full-and-complete-binary-tree.png "full-and-complete-binary-tree"){: .center-image }

#### 트리의 균형: Red-Black 트리와 AVL 트리
균형 트리를 어떻게 만드는지 배워두면 보다 나은 소프트웨어 엔지니어가 되긴 하겠지만, 면접 시에 그와 관계된 질문이 나오는 일은 별로 없습니다. 어쨌든, 균형 트리에 관해서라면 균형 트리에 대한 연산 시간에 대해서도 잘 알고 있어야 하고, 트리를 균형 잡는 방법에 대해서도 어렴풋이나마 알고 있어야 합니다. 면접 시에는 구체적인 내용까지 알고 있을 필요는 아마 없을 것입니다.

#### 트라이
트라이 *trie* 는 n-차 트리 *n-ary tree* 의 변종으로, 각 노드에 문자가 저장됩니다. 따라서 트리를 아래쪽으로 순회하면 단어 하나가 나오게 됩니다. 간단한 트라이 하나를 살표보면 다음과 같습니다.

![trie](/images/2016/10/07/trie.jpg "trie"){: .center-image }
