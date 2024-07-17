# lora-sd
LoRA(Low Rank Adaptation), Stable-Diffusion(Model), Packer


## LoRA(Low-Rank Adaptation) 개요

Low-Rank Matrix Aproximation을 활용하여 기존 LLM을 특정 목적에 맞게 미세조정(fine-tuning)하기 위한 기법이다.

### LoRA를 fine-tuning에 쓰는 이유

- 기존 모델의 본질적인 기능&성능을 유지하면서 fine-tuning 가능
- 기존 모델을 재학습하는 시간과 비용을 줄임

### LoRA를 일반 LLM 학습에 안쓰는 이유

- ※ LoRA는 비용이 낮은데 왜 fine-tuning에만 사용되는가?
- 자유도가 낮은만큼,  정밀하고 최적화되어야 하는 초기 모델 학습에는 적절치 않았기 때문

### Low-Rank Matrix Aproximation

- `고차원 행렬을 저차원(Low-Rank) 행렬의 곱(dot)으로 근사`시키는 수학적 기법
- 효과: 데이터의 차원 축소, 노이즈 제거, 압축 등
- 주어진 `m*n` 행렬을  `m*r` 과 `r*n`로 분해함. (값은 근사치)
- 이러면 처리할 행렬 요소 개수는 `m*n` 에서 `r*(m+n)`으로 대폭 감소하게 됨 (r은 하이퍼파라미터로 작은 수)

### LoRA의 핵심 아이디어

- Low-Rank Matrix Approximation으로 LLM 가중치 행렬을 저랭크행렬로 분해 후 분해된 행렬로만 학습
  1. 처리할 파라미터 감소
      - => 비용감소
  2. 자유도(DOF) 감소
      - => 분해된 행렬을 아무리 업데이트해도, 기존 가중치 행렬을 직접 학습시키는 것에 비해 변화의 범위가 제한적
      - => 기존 LLM 성능 유지
  3. 학습 진행 중 고정된 LLM 가중치
      - => 전체 LLM 가중치는 고정된 값으로 저랭크행렬 학습에 사용되며, 학습 종료 후 한번만 최종 업데이트
      - => 기존 LLM 성능 유지

### LoRA 학습 절차

1. LLM의 가중치 행렬을 저랭크 행렬로 분해($W=A\cdot B$) 후, 분해된 행렬들을 대상으로 학습하고 업데이트 한다.
$$W_0=A_0\cdot B_0$$
$$\Delta W_t=A_t\cdot B_t$$
$$W_t=W_0+\Delta W_t$$
2. 최종적으로 업데이트된 저랭크 행렬들은 곱해진 후, 기존 LLM의 가중치 행렬에 더해진다.

- 전체 LLM 가중치($W_0$)는 $A,B$의 학습 진행 동안 고정된 상태이고, 학습 완료 후 한 번만 업데이트($W_{final}$)된다.
- $W_t$는 $A,B$ 학습을 위해 Gradient Decent할 때만 이용된다.
$$W_{final}=W_0+\Delta W_{final}$$

## SD(Stable Diffusion) 개요

모델 중 하나.


https://coconuts.tistory.com/1034
