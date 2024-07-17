# lora-sd
LoRA(Low Rank Adaptation), Stable-Diffusion(Model), Packer


## LoRA(Low-Rank Adaptation) 개요

Low-Rank Matrix Aproximation을 활용하여 기존 LLM을 특정 목적에 맞게 미세조정(fine-tuning)하기 위한 기법이다.

### LoRA를 fine-tuning에 쓰는 이유

- 기존 모델의 본질적인 기능&성능을 유지하면서도 특수목적에 맞게 fine-tuning 가능
- 기존 모델을 재학습하는 시간과 비용을 줄임

### LoRA 일반 LLM 학습에 안쓰는 이유

- ※ LoRA는 비용이 낮은데 왜 fine-tuning에만 사용되는가?
- 자유도가 낮은만큼, 정밀하고 최적화되어야 하는 초기 모델 학습에는 적절치 않았기 때문

### Low-Rank Matrix Aproximation

- `고차원 행렬을 저차원(Low-Rank) 행렬의 곱(dot)으로 근사`시키는 수학적 기법
- 효과: 데이터의 차원 축소, 노이즈 제거, 압축 등
- 주어진 `m*n` 행렬을  `m*r` 과 `r*n`로 분해함. (값은 근사치)
- 이러면 처리할 행렬 요소 개수는 `m*n` 에서 `r*(m+n)`으로 대폭 감소하게 됨 (r은 하이퍼파라미터로 작은 수)

### LoRA 학습 절차

- LLM의 가중치 행렬을 저랭크 행렬로 분해($W=A\cdot B$) 후, 분해된 행렬들을 대상으로 학습하고 업데이트 한다.
$$W_0=A_0\cdot B_0$$
$$\Delta W_t=A_t\cdot B_t$$
$$W_t=W_0+\Delta W_t$$
- 최종적으로 업데이트된 저랭크 행렬들은 곱해진 후, 기존 LLM의 가중치 행렬에 더해진다.(이 때 스케일링 처리 들어감)
- 기존 LLM 가중치는 최종적으로 한 번만 업데이트된다.
$$W_{final}=W_0+\Delta W_{final}$$
$$()$$


<!-- 기존 모델 파라미터 값은 유지하면서, `분해된 두 행렬을 대상으로 학습(업데이트)`한다.
기존 파라미터 값은 업데이트 된 두 행렬의 곱에 따라 `미세한 근사치 수준으로만 변경`된다.
이에 따라 미세 조정이 구현된다. -->

### LoRA의 핵심 아이디어

- 기존 LLM 가중치 행렬을 저랭크행렬로 분해
  - 처리할 파라미터 감소: 비용감소
  - 자유도 감소: 분해된 행렬을 아무리 업데이트해도, 기존 가중치 행렬을 직접 학습시키는 것에 비해 변화의 범위가 제한적




## SD(Stable Diffusion) 개요

모델 중 하나.


https://coconuts.tistory.com/1034
