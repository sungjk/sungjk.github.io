---
layout: post
title: [C언어] 문자열 파싱 - strtok
---

# strtok
strToken 변수에 문자열의 주소가 명시되면 해당 문자열의 처음 위치에 존재하는 토큰(token)을 찾아서 해당 주소를 반환하고, strToken에 NULL이 명시되면 
토큰 찾기가 진행중이라는 뜻이고 현재 진행상태에서 다음에 해당하는 토큰을 찾아서 그 주소를 반환한다.

`char *strtok(char *strToken, const char *strDelimit);`

* strToken : 한 개 이상의 토큰을 포함하고 있는 문자열의 시작 주소를 명시한다. 만약, 이미 호출한 문자열에서 다음 위치에 해당 하는 토큰을 찾는 경우, 
NULL로 명한다.

* strDelimit : 구분문자(delimiter)들로 구성된 문자열의 시작 주소를 명시한다. 구분문자는 각각의 토큰을 구별하는 기준 문자이다. 예) "Hello-World"
  라는 문자열에서 "Hello"와 "World"를 각각 토큰으로 구분하고 싶은 경우에 '-'을 구분문자로 사용하면 된다.

<br>

# 함수의 반환값
토큰을 포함하는 문자열에서 이전에 찾은 토큰의 다음 위치에 존재하는 토큰의 시작 주소를 반환한다.

예) "Hello-World+Github"라는 문자열에서 '-'와 '+'를 구분문자로 사용하여 "Hello", "World", "Github"를 각각 토큰으로 얻고 싶다면 다음과 같이 
사용하면 된다.

    char string[] = "Hello-World+Github";
    
    // string 문자열 매열에서 H에 해당하는 주소가 반환된다
    char *p_token = strtok(string, "-+");
    
    // "Hello" 토큰을 찾은 상태에서 호출했고 strToken에 NULL을 사용했으므로 다음 토큰 위치에 해당하는 "World"를 찾는다.
    p_token = strtok(NULL, "-+");

<br>

# 함수 사용 예제

    #include <stdio.h>
    #include <string.h>
    
    int main() {
        char str[] = "Hello World,This is\tTest Program\n";
        char delim[] = " ,\t\n";
        char *token = NULL;
         
        token = strtok(str, delim);
        while(token != NULL) {
            printf("token = %s\n", token);
            token = strtok(NULL, delim);
        }
    }
