# Problem

## ⚠️문제 상황: 고정 소수점 Format 변환

- 프로젝트의 경우
  - 누적합 Q8.16 --> Q1.8로 변환해야했음
- 곱셈기에서 매번 Q1.8로 변환
 - multiplication 모듈에 Q1.8로 변환하는 과정도 포함

## 🤔문제
- 곱셈기가 33개가 사용됨
- 그럼 33번의 변환과정을 거쳐야함
- 근데 마지막 누적합에서 또 변환과정을 거쳐야함
- 그러면 변환과정 34번 해야함
  - 변환과정 --> 정밀도 저하
  - 여러번 거친다 --> 정밀도 저하도 ⬆️
- ⚠️코드 및 회로도 복잡해지고 정밀도도 저하됨


## 🚀해결

- 마지막 누적합에서만 포맷 변환 수행
  - 변환 1번만 수행
  - 코드 및 회로 복잡도 감소
  - 정밀도 저하율 감소
    - 변환을 한번만 수행하니까

## 👨‍💻해결과정

[소스코드 참고:rrc_filter.sv](../project1/success/source_code/rrc_filter.sv)

- 입력: Q1.8
- 필터 계수: Q1.8
- 출력: Q1.8

### 1. 곱셈기
```systemverilog
module multiplier_9b #(
	parameter WIDTH = 9
)(
	input logic signed [WIDTH-1:0] mul_in,
	input logic signed [WIDTH-1:0] coefficient,

	output logic signed [2*WIDTH-1:0] mul_out
);
	

	assign mul_out = mul_in * coefficient;

endmodule
```