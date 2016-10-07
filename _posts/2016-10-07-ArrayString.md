---
layout: entry
title: 인터뷰 - 배열과 문자열
author: 김성중
author-email: ajax0615@gmail.com
description: 인터뷰에서 다룰만한 배열과 문자열에 대한 설명입니다.
publish: true
---

## 해시 테이블
해시 테이블 *hash table* 은 효율적인 탐색을 위한 자료구조로서 키 *key* 를 값 *value* 에 대응시킵니다. 해시 테이블을 아주 간단히 구현하는 경우, 배열과 해시 함수 *hash function* 만 있으면 됩니다. 객체와 키를 해시 테이블에 넣게 되면 우선 해시 함수가 키를 정수값 *integer* 으로 대응시키는데, 이 정수값이 배열의 첨자 *index* 로 쓰입니다. 객체는 배열의 해당 첨자 위치에 저장됩니다.

하지만 이렇게 구현해서는 제대로 동작하지 않을 것입니다. **모든 가능한 키에 대해서 해시 함수가 계산해 내는 정수값이 유일 *unique* 해야 하기 때문입니다.** 유일성이 보장되지 않을 경우 데이터가 덮어 쓰일 수 있습니다. 그런 충돌 *collision* 을 피하려면 가능한 모든 키 값을 전부 고려해서 배열을 극도로 크게 만들어야 합니다.

그렇게 큰 배열을 할당하고 객체를 hash(key) 위치에 저장하는 대신, 배열은 더 작게 만들고 **객체는 hash(key)%array_length 위치에 연결 리스트 *linked list* 형태** 로 저장하는 방법을 쓸 수 있습니다. 그 경우, 특정한 키 값을 갖는 객체를 찾아내려면 해당 키에 대한 연결 리스트를 탐색해야 합니다.

대신, 이진 탐색 트리 *binary search tree* 를 사용해 해시 테이블을 구현할 수도 있습니다. 그렇게 하면 O(logN) 시간 안에 탐색이 완료되도록 보장할 수 있습니다. 트리의 균형 *balance* 을 유지할 수 있기 때문입니다. 처음에 배열을 크게 잡아둘 필요도 없기 때문에 저장 공간도 절약됩니다.

해시 테이블은 면접 때 가장 보편적으로 물어보는 자료구조이므로, 실제 면접 때에도 관련된 질문을 받을 확률이 높습니다. 아래는 해시 테이블을 구성하는 간단한 Java 예제입니다.

```
public HashMap<Integer, Student> buildMap(Student[] students) {
    HashMap<Integer, Student> map = new HashMap<Integer, Student>();
    for (Student s : students) map.put(s.getId(), s);
    return map;
}
```

## ArrayList(동적 배열)
ArrayList는 동적으로 크기가 조정되는 배열로서, 그러면서도 O(1)의 접근시간 *access time* 을 유지합니다. 통상적으로는 배열이 가득 차는 경우, 그 크기가 두 배 늘어나도록 구현됩니다. 크기를 두 배 늘리는 시간은 O(n)이지만 자주 일어나는 일이 아니라 대체적으로 O(1) 시간이 유지된다고 보는 것이 맞습니다.

```
public ArrayList<String> merge(String[] words, String[] more) {
    ArrayList<String> sentence = new ArrayList<String>();
    for (String w : words) sentence.add(w);
    for (String w : more) sentence.add(w);
    return sentence;
}
```

## StringBuffer
아래의 코드와 같이 문자열 배열을 하나로 합치려 한다고 생각해 봅시다. 이 코드의 실행 시간은 어떨 것 같나요? 간단하게 그냥 문자열 길이는 전부 x로 똑같고, 문자열 개수는 n이라고 합시다.

```
public String joinWords(String[] words) {
    String sentence = "";
    for (String w : words) {
        sentence = sentence + w;
    }
    return sentence;
}
```

**문자열을 연결할 때마다 새로운 문자열 객체가 만들어지고, 연결할 문자열의 값이 문자 단위로 복사됩니다.** 그러므로 첫 루프에서는 x개의 문자가 복사될 것이고, 두 번째 루프에서는 2x, 세 번째 루프에서는 3x개의 문자열이 복사됩니다. 이런 식으로 하다 보면 결국 소요되는 시간은 O(x + 2x + ... + nx)가 될 것이니, 최종적으로는 (xn^2)만큼의 시간이 걸릴 것입니다.

StringBuffer는 이런 문제를 피할 수 있도록 해 줍니다. 간단히 말하자면 StringBuffer는 **모든 문자열의 배열을 만들어 두고, 문자열 객체로의 복사는 필요할 때만 수행** 합니다.

```
public String joinWords(String[] words) {
    StringBuffer sentence = new StringBuffer();
    for (String w : words) {
        sentence.append(w);
    }
    return sentence.toString();
}
```
