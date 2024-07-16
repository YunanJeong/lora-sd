# lora-sd
LoRA(Low Rank Adaptation), Stable-Diffusion(Model), Packer

https://coconuts.tistory.com/1034

## LoRA(Low-Rank Adaptation) 개요

Low-Rank Matrix Aproximation을 활용하여 LLM의 특정부분을 미세조정하기 위한 기법이다.

### Low-Rank Matrix Aproximation

- `고차원 행렬을 저차원(Low-Rank) 행렬의 곱(dot)으로 근사`시키는 것을 의미
- 효과: 데이터의 차원 축소, 노이즈 제거, 압축 등
- 주어진 `m*n` 행렬을  `m*r` 과 `r*n`로 분해함. (값은 근사치)
- 이러면 처리할 행렬 요소 개수는 `m*n` 에서 `r*(m+n)`으로 대폭 감소하게 됨 (r은 하이퍼파라미터로 작은 수)

### LoRA의 핵심 아이디어

- LLM 파라미터 행렬을 저랭크행렬로 분해시, `분해된 행렬은 LLM의 feature를 나눠가졌다`고 볼 수 있다.
- 이 중 일부 행렬만을 주로 업데이트하여 LLM의 특정 부분을 미세조정한다는 아이디어임.
- ※ 분해된 행렬 모두를 다이나믹하게 업데이트시, 특정부분을 미세조정하는 것이 아니게 됨. 전체 모델을 차원 축소만해서 업데이트하는 것과 다를 바가 없어짐.

<!-- LoRA는 LLM의 가중치 행렬을 저랭크 행렬로 분해 후, 분해된 행렬들을 대상으로 학습하고 업데이트 한다. 이 때  -->

<!-- 기존 모델 파라미터 값은 유지하면서, `분해된 두 행렬을 대상으로 학습(업데이트)`한다.
기존 파라미터 값은 업데이트 된 두 행렬의 곱에 따라 `미세한 근사치 수준으로만 변경`된다.
이에 따라 미세 조정이 구현된다. -->

## SD(Stable Diffusion) 개요

모델 중 하나.


