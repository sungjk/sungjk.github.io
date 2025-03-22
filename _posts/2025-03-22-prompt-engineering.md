---
layout: entry
title: 프롬프트 엔지니어링(Prompt Engineering)
author-email: ajax0615@gmail.com
keywords: Prompt Engineering, 프롬프트 엔지니어링
publish: true
---

### Introduction

LLM Settings

- `temperature`: 토큰의 선택 비중을 결정. 높을수록 창의적인 결과 생성. 낮을수록 사실을 기반한 결과 생성
- `top_p`: 낮으면 사실적인 결과 생성.
- 일반적으로 temperature 나 top_p 둘 중 하나만 변경
- `max length`: 모델이 생성하는 토큰 수 관리. 결과 연관성 및 비용 관리.
- `Stop Sequence`
    - 특정 문자열을 만나면 출력을 멈추기 위해 사용
    - 모델이 불필요하게 길거나 중복된 응답을 생성하지 않게 만들기 위해 사용함
    - 코드, 목록, 대화 스타일 같은 특정 형식을 강제할 때 유용함
    
    Example: 
    
    1. **리스트 제한**:
        - "10개의 아이템으로 이루어진 리스트"를 생성하고 싶다면, Stop Sequence로 `"11."`을 지정
        - 모델이 "11."을 생성하지 못하게 해서 10개의 아이템으로만 리스트를 제한
        
        **예시**:
        
        ```markdown
        Input: Generate a list of fruits:
        Output:
        1. Apple
        2. Banana
        ...
        3.  Kiwi
        4.  (멈춤)  --> "11."이 Stop Sequence라면 여기서 중단됨.
        ```
        
    2. **대화 종료**:
        - 챗봇이 `"[End]"`를 만나면 대화를 끝내도록 설정
        
        ```
        Input: End the conversation after the farewell.
        Output:
        User: Thank you!
        Bot: You're welcome. Have a great day! [End]
        ```
        
- Max Length vs. Stop Sequence
    - Max Length:
        - 응답 길이의 상한선. 모델이 토큰을 생성하다가 이 길이에 도달하면 무조건 멈춤.
        - 예) Max Length가 50이면 50개 토큰까지만 생성
    - Stop Sequence:
        - 특정 문자열을 생성하는 순간 멈춤
        - 예) "###"라는 Stop Sequence가 있으면, 모델이 20번째 토큰에서 "###"를 생성하면 즉시 멈춤
- Frequency Penalty vs. Presence Penalty
    - Frequency Penalty:
        - 특정 토큰(단어)가 반복적으로 등장할수록 그 토큰을 선택할 확률을 낮추는 패널티
        - 사용 목적: 단어 중복 방지, 정확성, 간결함
        - 예시: FAQ 답변, 정보 요약 등
        
        ```
        입력: Write a sentence about cats.
        결과 (Frequency Penalty 낮음): "Cats are cute. Cats are playful. Cats love to sleep."
        결과 (Frequency Penalty 높음): "Cats are cute, playful, and love to sleep."
        ```
        
    - Presence Penalty:
        - 특정 토큰이 한 번이라도 등장했다면 그 토큰을 선택할 확률을 낮추는 패널티
        - 사용 목적: 컨텐츠 다양성 확보(같은 단어를 여러 번 쓰는 대신 새로운 단어를 사용하도록 유도), 다양성
        - 예시: 창의적 글쓰기, 스토리 생성, 광고 카피 작성 등
        
        ```
        입력: Write a sentence about cats.
        결과 (Presence Penalty 낮음): "Cats are cute. Cats are playful. Cats love to sleep."
        결과 (Presence Penalty 높음): "Cats are cute. They are playful and love to sleep."
        ```
        
    
    | **특징** | **Frequency Penalty** | **Presence Penalty** |
    | --- | --- | --- |
    | **기준** | 등장한 토큰의 **반복 횟수**에 따라 적용 | 등장한 토큰의 **존재 여부**에 따라 적용 |
    | **페널티 적용 방식** | 반복 횟수가 많을수록 페널티가 더 커짐 | 한 번이라도 등장하면 동일하게 페널티 부과 |
    | **목적** | 특정 단어의 **중복 사용을 줄임** | 더 **다양한 표현**을 유도 |
    | **적용 효과** | 깔끔하고 중복 없는 텍스트 | 창의적이고 다양한 텍스트 |

### General Tips for Designing Prompts

- The more descriptive and detailed the prompt is, the better the results.
- Need to experiment with a lot.
- Encourage a lot of experimentation and iteration to optimize prompts.
- Avoid saying what not to do but say what to do instead.

### Examples of Prompts

- Text Summarization
- Information Extraction
- Question Answering
- Text Classification
- Conversation(Role prompting)
- Code Generation
- Reasoning

---

### Zero-Shot Prompting

- the prompt used to interact with the model won't contain examples or demonstrations.

---

### Few-Shot Prompting

> the label space and the distribution of the input text specified by the demonstrations are both important (regardless of whether the labels are correct for individual inputs).

### Label Space와 Few-shot prompting

- `Label Space`: 주어진 문제에서 가능한 출력값(라벨)의 집합
    - ex) 영화 리뷰 감성 분석에서는 출력값이 `Positive`, `Negative` 같은 감정 라벨 사용
    - Label Space는 모델이 어떤 선택지를 예상해야 하는지 알려주는 역할
- 모델이 학습을 잘 하려면 input & label 쌍이 일관된 구조를 가져야 함.
- 라벨이 실제로 맞는지 틀린지는 덜 중요하고, 예시들 사이에서 입력과 출력의 관계(패턴)와 라벨 공간의 정의가 중요한 역할
- Input Text Distribution(입력 텍스트의 분포): 프롬프트에 포함된 예시가 특정 스타일이나 패턴을 유지해야 모델이 더 잘 학습함.
- 라벨의 정확성은 덜 중요: 라벨이 틀렸더라도 형식과 구조가 명확하면 모델이 작업의 맥락을 이해할 수 있음.
- Few-shot Prompting 한계: 모델이 학습한 지식으로 충분하지 않은 경우
    - 복잡한 수학적 추론, 다단계 논리 문제, 세부적인 도메인 지식이 필요한 작업 등.
    - Few-shot prompting은 모델이 이미 학습한 지식을 기반으로 동작하므로, 모델의 학습 데이터에 없는 복잡한 작업에서는 한계에 부딪힐 수 있음.

### 대안:
- Fine-tuning: 모델을 특정 작업에 맞게 추가 학습시키는 과정
    - 특정 작업에서 더 나은 성능을 발휘할 수 있도록 모델의 파라미터를 조정
    - 특정 도메인(예: 의학, 법률, 금융)에서 높은 정확도가 필요한 경우에 유용
- Chain-of-Thought (CoT) Prompting: 복잡한 추론 문제를 단계별로 나누어 해결하는 방식
    - ex) 모델이 수학 문제를 풀 때 답을 바로 생성하도록 요청하는 대신, 문제를 단계적으로 해결하는 과정을 먼저 보여주도록 설정
    - 장점: 모델이 단계적이고 논리적 사고를 통해 더 정확한 답을 생성할 가능성이 높아짐.

---

### Chain-of-Thought Prompting

> Let's think step by step 

- 문장 하나 추가했는데 결과가 달라지는게 신기
- Demonstrations: 모델이 작업을 수행하는 방식을 학습하도록 도와주는 예시

---

### Meta Prompting

- Structure-oriented: 특정 내용보다는 문제 해결의 전반적인 구조/형식/패턴에 초점을 맞춤
- Syntax-focused: 문법적 템플릿으로 응답의 형식을 유도(ex. Let's think step by step.)
- Abstract examples: 구체적인 내용 대신 구조를 보여주는 추상적 예시를 사용하여 다양한 작업에 적용 가능
- Versatile: 수학, 프로그래밍, 이론적 질문 등 여러 도메인에서 사용

---

### Self-Consistency

- Greedy Decoding: 가장 높은 확률의 답변을 한 번만 생성
- 모델이 다양한 추론 경로(reasoning paths)를 통해 여러 답변을 생성하고, 가장 일관성 있는 답변을 선택
- 산술적 문제나 상식 추론 문제에서 효과적

---

### Generate Knowledge Prompting

- 모델이 답변을 생성하기 전에 문제와 관련된 지식을 먼저 생성
- 이 지식은 이후 예측 과정에서 프롬프트로 통합되어 모델의 이해와 예측 정확도를 높이는 데 사용

---

### Prompt Chaining

- Divide and Conquer
- 복잡한 작업을 여러 단계로 나누어 한 번에 하나씩 해결.
- 하위 작업의 결과를 다음 작업의 입력으로 사용
- ex. 텍스트 요약 → 주요 정보 추출 → 답변 생성

---

### Tree of Thoughts (ToT)

- CS 알고리즘 나와서 반가웠음.
- 복잡한 문제를 해결하기 위해 트리 구조를 사용하여 여러 사고 과정(thoughts)을 탐색
- Thoughts: 문제 해결을 위한 중간 단계의 사고 과정(언어 시퀀스).
    - 예: 산수 문제에서 각 중간 계산 과정
- 각 노드: 중간 단계의 사고 과정.
- 루트 노드: 초기 문제 진술.
- 리프 노드: 최종 답변.
- DFS, BFS 또는 Beam Search 알고리즘을 사용하여 탐색.
- 사고 과정이 트리 구조로 나타나므로 각 단계에서 무엇이 잘못되었는지 추적 가능

---

### Retrieval Augmented Generation (RAG)

- 정보 검색 (Retrieval): 외부 데이터베이스(예: Wikipedia)에서 관련 문서를 검색하여 입력과 함께 사용
- 텍스트 생성 (Generation): 검색된 문서를 컨텍스트로 사용하여 최종 응답을 생성
- 모델의 내부 지식(parametric knowledge)이 고정된 문제를 해결

---

### Automatic Reasoning and Tool-use (ART)

- LLM이 새로운 작업을 수행하기 위해 `스스로` 중간 추론 단계를 생성하고 `외부 도구`를 사용하는 방법
- [Youtube - 프롬프트 엔지니어링 - Automatic Reasoning and Tool-use (ART, 자동추론&도구사용)](https://youtu.be/6KEnz_Bdmcs?si=Yf5eV132YtXAvsJ_)
- 스스로 CoT 생성
- 외부 도구: 추론 과정들이 데이터셋으로 만들어져 있는 것(라이브러리, 패키지)
    - 예) GSM8K(초등 수학 단어 문제 8,500개 세트), AQuA(딥러닝 기술의 상태를 시험하기 위한 객관식 대수 단어 문제)
- 예시
    - 사용자의 질문을 분석한다.
    - 사용자의 요청을 해결할 최적의 추론 경로와 외부 도구가 무엇인지 탐색한다.
    - 필요에 따라 사용자가 외부 도구 라이브러리를 추가하거나 수정한다.

---

### Automatic Prompt Engineer (APE)

- automatic instruction generation and selection
- 사람이 설계한 CoT Prompt 보다 더 나은 Zero-shot Cot Prompt 발견
    - 예) 사람이 작성한 "Let's think step by step" 프롬프트보다 "Let's work this out in a step by step way to be sure we have the right answer.” 라는 프롬프트가 더 나은 성능
- instruction 설계 과정에서 사람의 개입을 줄이고 최적화하게 도와주는 프레임워크

---

### Active-Prompt

불확실한 답변에 사람이 피드백을 주고 모델 학습을 강화하는 방식. 모든 질문에 피드백을 주지 않아도 되므로 효율적임.

1. Uncertainty Estimation: 불확실성은 답변이 얼마나 일관되었는지로 평가. 답변이 모두 동일하면 불확실성이 낮고, 답변이 다양하면 불확실성 높음.
2. Selection: 모든 질문의 불확실성 점수를 정렬해서 가장 불확실한 질문 선택
3. Annotation: 불확실한 질문에 대해 사람이 정확한 답변 작성. 모델이 더 나은 추론을 할 수 있도록 새로운 학습 예제 추가
4. Inference: 새로 추가된 예제를 학습한 후 질문에 대해 추론을 수행

![Active Prompt](/images/2025/03/22/active-prompt.png "active-prompt"){: .center-image }

---

### Directional Stimulus Prompting

- DSP: 프롬프트에 힌트를 명시적으로 제공해서 중요한 요소를 더 쉽게 식별할 수 있게 도와주는 방식

Black-box Frozen LLM:

- Black-box: 내부 동작을 알거나 수정할 수 없는 시스템
- Frozen LLM: LLM이 사전 학습된 상태로 고정되어 있는것. Fine-tuning이 이루어지지 않는 상태
- 모델의 파라미터나 학습 방식에 접근하거나 변경할 수 없어서 프롬프트 엔지니어링이 중요
- 장점:
  - 사전 학습된 모델을 그대로 사용해서 추가적인 학습이나 리소스 필요하지 않음.
  - 모델 파라미터가 고정되어 있어서 예측 가능한 동작을 수행함.
- 한계:
  - 특정 작업에 대해 최적화 되어 있지 않을 수 있음. 특정 도메인에 맞는 성능을 보장하기 어려움(Fine-tuning 불가)
  - 프롬프트와 라이브러리에 의존이 높음.

---

### PAL (Program-Aided Language Models)

프로그래밍 지원 모델. 코드나 수식을 사용해 논리적인 작업을 수행하는 방식

```python
import openai
import os
from langchain_openai import OpenAI
from datetime import datetime
from dateutil.relativedelta import relativedelta

def main():
    llm = OpenAI(model_name='gpt-3.5-turbo-instruct', temperature=0)
    question = "Today is 27 February 2023. I was born exactly 25 years ago. What is the date I was born in MM/DD/YYYY?"
    DATE_UNDERSTANDING_PROMPT = """
    # Q: 2015년이 36시간 후에 옵니다. 오늘로부터 1주일 후의 날짜는 MM/DD/YYYY 형식으로 무엇인가요?
    # 2015년이 36시간 후에 오므로, 오늘은 36시간 전입니다.
    today = datetime(2015, 1, 1) - relativedelta(hours=36)
    # 오늘로부터 1주일 후,
    one_week_from_today = today + relativedelta(weeks=1)
    # %m/%d/%Y 형식으로 표시된 답은
    one_week_from_today.strftime('%m/%d/%Y')
    # Q: 2019년의 첫 번째 날은 화요일이고, 오늘은 2019년의 첫 번째 월요일입니다. 오늘 날짜는 MM/DD/YYYY 형식으로 무엇인가요?
    # 2019년의 첫 번째 날이 화요일이고, 오늘이 첫 번째 월요일이라면, 오늘은 6일 후입니다.
    today = datetime(2019, 1, 1) + relativedelta(days=6)
    # %m/%d/%Y 형식으로 표시된 답은
    today.strftime('%m/%d/%Y')
    # Q: 콘서트가 06/01/1943에 예정되어 있었지만 하루 늦게 오늘로 연기되었습니다. 오늘로부터 10일 전의 날짜는 MM/DD/YYYY 형식으로 무엇인가요?
    # 콘서트가 06/01/1943에 예정되었지만 하루 연기되었으므로 오늘은 하루 뒤입니다.
    today = datetime(1943, 6, 1) + relativedelta(days=1)
    # 오늘로부터 10일 전,
    ten_days_ago = today - relativedelta(days=10)
    # %m/%d/%Y 형식으로 표시된 답은
    ten_days_ago.strftime('%m/%d/%Y')
    # Q: 오늘은 1969년 4월 19일입니다. 24시간 후의 날짜는 MM/DD/YYYY 형식으로 무엇인가요?
    # 오늘은 1969년 4월 19일입니다.
    today = datetime(1969, 4, 19)
    # 24시간 후,
    later = today + relativedelta(hours=24)
    # %m/%d/%Y 형식으로 표시된 답은
    today.strftime('%m/%d/%Y')
    # Q: 제인은 오늘이 2002년 3월 11일이라고 생각했지만, 사실 오늘은 하루 후인 3월 12일입니다. 24시간 후의 날짜는 MM/DD/YYYY 형식으로 무엇인가요?
    # 제인이 오늘이 2002년 3월 11일이라고 생각했지만, 실제로 오늘은 하루 후인 3월 12일입니다.
    today = datetime(2002, 3, 12)
    # 24시간 후,
    later = today + relativedelta(hours=24)
    # %m/%d/%Y 형식으로 표시된 답은
    later.strftime('%m/%d/%Y')
    # Q: 제인은 2001년 2월의 마지막 날에 태어났습니다. 오늘은 제인의 16번째 생일입니다. 어제의 날짜는 MM/DD/YYYY 형식으로 무엇인가요?
    # 제인이 2001년 2월의 마지막 날에 태어났고 오늘이 16번째 생일이라면, 오늘은 16년 후입니다.
    today = datetime(2001, 2, 28) + relativedelta(years=16)
    # 어제,
    yesterday = today - relativedelta(days=1)
    # %m/%d/%Y 형식으로 표시된 답은
    yesterday.strftime('%m/%d/%Y')
    # Q: {question}
    """.strip() + '\n'
    
    llm_out = llm(DATE_UNDERSTANDING_PROMPT.format(question=question))
    print("LLM output:", llm_out)
    
    cleaned_output = '\n'.join(line.strip() for line in llm_out.splitlines())
    local_vars = {}
    exec(cleaned_output, globals(), local_vars)
    
    if 'today' in local_vars:
        print("Birth date:", local_vars['today'].strftime('%m/%d/%Y'))
    else:
        print("Error: Could not calculate the birth date")

if __name__ == "__main__":
    openai.api_key = ""
    os.environ["OPENAI_API_KEY"] = ""
    main()
```

---

### ReAct Prompting

추론(Reasoning) + 행동(Acting) + 관찰(Observation) 반복적으로 수행

- Reasoning: 문제 해결을 위해 단계별 논리적 과정 생성(CoT)
- Acting: 모델이 외부에 필요한 정보 검색
- Observation: 외부 결과를 바탕으로 추론 또는 행동 결정
- 외부 정보의 품질에 따라 모델 추론이 방해받을 수 있음

```python
import openai
import os
from langchain_openai import OpenAI
from langchain.agents import load_tools
from langchain.agents import initialize_agent

    
def main():
    # temperature=0: 더 결정론적이고 일관된 답변을 생성
    llm = OpenAI(model_name='gpt-3.5-turbo-instruct', temperature=0)
    
    # tools: 에이전트가 사용할 라이브러리 로드용
    # google-serper: Google 검색 도구 https://serper.dev/
    # llm-math: 수학 계산을 수행하는 도구
    tools = load_tools(["google-serper", "llm-math"], llm=llm)
    
    # 위 도구와 LLM을 결합한 에이전트 생성
    # zero-shot-react-description: ReAct 프롬프팅 방식으로 질문 처리
    agent = initialize_agent(tools, llm, agent="zero-shot-react-description", verbose=True)
    import sys
    try:
        while True:
            if len(sys.argv) > 1:
                user_input = ' '.join(sys.argv[1:])
                sys.argv = [sys.argv[0]]
            else:
                user_input = input("Please enter your query (or type 'exit' to quit): ")
                if user_input.lower() == 'exit':
                    break
            # 입력이 한국어인 경우 에이전트에게 한국어로 답변하도록 지시
            if any('\u3131' <= char <= '\u3163' or '\uac00' <= char <= '\ud7a3' for char in user_input):
                user_input = f"답변을 한국어로 해주세요: {user_input}"
            agent.run(user_input)
    except KeyboardInterrupt:
        print("\nExiting...")


if __name__ == "__main__":
    openai.api_key = ""
    os.environ["OPENAI_API_KEY"] = ""
    os.environ["SERPER_API_KEY"] = ""
    main()
```

---

### Reflexion

- self-reflection 을 통해 LangChain Agent가 과거 실수를 학습하고 성과를 개선할 수 있도록 설계된 프레임워크
- Verbal feedback을 활용하여 에이전트가 작업을 반복적으로 개선
- Actor:
    - LLM이 Environment(에이전트가 목표를 달성하기 위해 상호작용하는 외부 시스템)에서 행동하고 관찰 결과를 통해 추론과 작업을 수행
    - 행동 결과와 관찰이 단기 메모리(short-term memory)로 저장
- Evaluator:
    - Actor가 생성한 경로(trajectory)를 평가하여 성과 점수(reward)를 제공
    - 평가 방식: 규칙 기반(heuristic) 평가. LLM을 활용한 질적 평가.
- Self-Reflection:
    - Actor의 행동과 평가 결과를 기반으로 언어적 피드백을 생성
    - 피드백은 장기 메모리(long-term memory)에 저장되고, Actor가 다음 반복에서 더 나은 행동을 하도록 도움
- Define a task → Generate a trajectory → Evaluate → Perform reflection → Generate the next trajectory


![Reflexion](/images/2025/03/22/reflexion.png "Reflexion"){: .center-image }

When to Use Reflexion?

(전통적인 강화학습의 대체제, 세밀한 피드백, 메모리 활용)

1. An agent needs to learn from trial and error: 
    - 로봇이 물체를 이동시키기 위해 최적의 경로를 찾는 과정
    - 잘못된 괄호 매칭 코드를 수정하며 올바른 코드를 도출
2. Traditional reinforcement learning methods are impractical: 
    - 전통적인 RL은 대규모 학습 데이터와 긴 훈련 시간이 필요하며, 종종 비용이 많이 든다.
    - HotPotQA와 같은 다단계 추론 작업에서 빠르고 효율적인 해결 방식을 제공
3. Nuanced feedback is required: 
    - 괄호의 개수는 맞지만 순서가 잘못되었습니다"와 같은 피드백
    - 숫자 보상이 제공하지 못하는 세부 사항까지 전달 가능
4. Interpretability and explicit memory are important:
    - 에이전트가 이전 시도에서 잘못된 행동을 한 이유를 기록하고, 이를 기반으로 새로운 계획을 세움
    - 예: 의사결정 작업에서 잘못된 경로를 선택한 이유를 문서화

---

### Multimodal CoT Prompting

Text & Vision 결합된 상황에서 모델이 논리적 추론 과정을 통해 답변을 도출하는 방식

---

### GraphPrompts

Graph 기반의 논리적 추론

- 사용자와 항목 간의 관계를 그래프로 표현하고, GraphPrompts를 사용해 개인화된 추천 생성: A 사용자가 좋아할 만한 영화는 무엇인가요?
- 그래프에서 최단 경로나 특정 경로를 탐색하는 작업: Node A에서 Node B로 가는 최단 경로를 알려주세요.
- 노드 간 연결 관계를 분석하여 네트워크의 특징 추출: 이 네트워크에서 가장 영향력 있는 노드는 누구인가요?


---

# Reference

- [Prompt Engineering Guide](https://www.promptingguide.ai/)
