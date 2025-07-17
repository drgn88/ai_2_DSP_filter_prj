# 🙋‍♂️Who Made?

|                                             Hyenwoo Choi                                             |
| :--------------------------------------------------------------------------------------------------: |
| [<img src="./img/백곰카페.jpg" width=200 height=150> </br> @HyenWoo Choi](https://github.com/drgn88) |

# 🏕️Development Environment

Language
- System Verilog(Design & Verification)
- Verilog
- Matlab(Algorithm Verification)


Tool
- VCS & Verdi
- Matlab
- Vivado(Verification)
  - Verdi랑 차이 비교해볼려고 여기서도 돌려봄

# 🤔필요한 지식

- [Fixed_point_Number란?](./Study/1.Fixed_Point_Number.md)
- [Matlab 기본연산](./Study/2.Matlab_Basic.md)


# 📆WorkFlow(Today What I Do?)

- [250715](#250715)

# 250715

RRC_filter Design
---

## 🏛️Architecture

> FIR filter

<img src="./img/스크린샷 2025-07-16 083202.png"><br>

> RRC filter coefficient (floating)

|  num   |    1    |    2    |   3    |    4    |    5    |   6    |   7    |    8    |   9    |   10    |   11    |   12   |   13   |   14    |   15    |   16   |   17   |   18   |   19    |   20    |   21   |   22   |   23    |   24    |   25   |   26    |   27   |   28   |   29    |   30    |   31   |   32    |   33    |
| :----: | :-----: | :-----: | :----: | :-----: | :-----: | :----: | :----: | :-----: | :----: | :-----: | :-----: | :----: | :----: | :-----: | :-----: | :----: | :----: | :----: | :-----: | :-----: | :----: | :----: | :-----: | :-----: | :----: | :-----: | :----: | :----: | :-----: | :-----: | :----: | :-----: | :-----: |
| &nbsp; | -0.0006 | -0.0021 | 0.0036 | -0.0013 | -0.0047 | 0.0061 | 0.0013 | -0.0077 | 0.0084 | -0.0013 | -0.0234 | 0.0318 | 0.0400 | -0.1086 | -0.0530 | 0.4351 | 0.7651 | 0.4351 | -0.0530 | -0.1086 | 0.0400 | 0.0318 | -0.0234 | -0.0013 | 0.0084 | -0.0077 | 0.0013 | 0.0061 | -0.0047 | -0.0013 | 0.0036 | -0.0021 | -0.0006 |

> RRC filter coefficient (fixed_point Q1.8)

|  num   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |   8   |   9   |  10   |  11   |  12   |  13   |  14   |  15   |  16   |  17   |  18   |  19   |  20   |  21   |  22   |  23   |  24   |  25   |  26   |  27   |  28   |  29   |  30   |  31   |  32   |  33   |
| :----: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| &nbsp; |   0   |  -1   |   1   |   0   |  -1   |   2   |   0   |  -2   |   2   |   0   |  -6   |   8   |  10   |  -28  |  -14  |  111  |  196  |  111  |  -14  |  -28  |  10   |   8   |  -6   |   0   |   2   |  -2   |   0   |   2   |  -1   |   0   |   1   |  -1   |   0   |


## 🌟설계 및 검증 내용

### 결과 파일

- 코드: [rrc_filter_src](./project1/success/source_code/rrc_filter.sv)
- 결과 파일(출력 벡터): [내가 만든 회로 출력 결과](./project1/success/내_결과_파일.txt)

<img src="./img/스크린샷 2025-07-16 181430.png"><br>

- 내가 설계한 출력의 결과와 교수님이 설계하신 출력의 결과가 동일하다
  - [텍스트파일 비교 스크립트.m](./project1/Matlab/comparison_result_b_my_professor.m)

## Design Compiler
> 만든 rrc_filter.sv를 바탕으로 Synthesis도 수행함

### 합성 결과
> sdc에서 period 1000으로 줬을 때
|timing_max.rpt|
|:---:|
|<img src="./img/스크린샷 2025-07-16 182912.png">|
- Positive Slack
  - slack이 0.09로 Setup-Violation이 발생하지 않음
  - 근데 tight함

|timing_min.rpt|
|:---:|
|<img src="./img/스크린샷 2025-07-16 183100.png">|
- ⚠️Negative Slack
  - Hold time violation 발생
  - 이 부분은 설계자가 건드릴 수 없음
    - 아직 P&R 전임
    - Pre-Layout에선 Setup Violation만 수정 가능

|rrc_filter_0.rpt|
|:---:|
|<img src="./img/스크린샷 2025-07-16 183301.png">|
- Total Area는 아직 안나옴
  - Pre-Layout이라 아직 wire routing안된 상황


## 🚀Trouble Shooting

### Fixed Point Number - Saturation
> 여기에 자세히 정리돼있음
> > [필터설계: 고정소수점 연산 해결](./TroubleShooting/porject1_rrcfilter.md)

- 누적합에서만 고정소수점 포맷을 변환하면 될 걸 매 곱셈마다 수행
  - 누적합에서만 수행하도록 바꿈
- 전체 변환 비트를 Saturation해야되는데 정수부만 포화시킴
  - ⚠️회로 내에서 연산할 때는 정수(integer) 연산으로 수행
  - 회로 연산의 결과를 해석자가 실수로 변환할 때 소수부 비트수만큼 2의 지수승으로 나눠주기만 하면됨

# 250716

