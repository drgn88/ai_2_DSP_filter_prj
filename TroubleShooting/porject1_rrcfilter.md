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
```verilog
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

- Q1.8의 두 수를 곱하면
  - Q2.16의 결과가 나온다
- 그러면 출력은 18bit가 되야한다

### 2. Accumualate Sum

```verilog
	always_comb begin : accumulate_sum
		acc_sum = mul_sum[0] + mul_sum[1] + mul_sum[2] + mul_sum[3] + mul_sum[4] + 
		mul_sum[5] + mul_sum[6] + mul_sum[7] + mul_sum[8] + mul_sum[9] + 
		mul_sum[10] + mul_sum[11] + mul_sum[12] + mul_sum[13] + mul_sum[14] + 
		mul_sum[15] + mul_sum[16] + mul_sum[17] + mul_sum[18] + mul_sum[19] + 
		mul_sum[20] + mul_sum[21] + mul_sum[22] + mul_sum[23] + mul_sum[24] + 
		mul_sum[25] + mul_sum[26] + mul_sum[27] + mul_sum[28] + mul_sum[29] + 
		mul_sum[30] + mul_sum[31] + mul_sum[32];  
	end
```

- 곱셈의 결과: Q2.16
- Q2.16을 33개 더하면
  - 정수부 비트수 + $log_2(32)$
  - $2+log_2(32)=2+5=7$
  - Q7.16 + Q2.16(나머지 한개:mul_sum[32]) = Q8.16

### 3. Q1.8로 변환

### 소수부 - Truncation

```verilog
logic signed [15:0] trunc_frac_sum;
	assign trunc_frac_sum = acc_sum[23:8];
```

- ```trunc_frac_sum```: 소수부 최하위 8비트를 잘라냄
  - Q.16 --> Q.8
  - F[15:0] --> F[15:8]
  - truc_frac_sum = I[7:0].F[15:8]
  - 
///////////////////////////////////////////////////////////////////////
잘못된 부분
///////////////////////////////////////////////////////////////////////
<!-- ### 정수부 -  Saturation

```verilog
//변환할 정수부가 1bit라 가능함
//기존 정수부의 MSB로만 그대로 가져올 수 있음
	always_ff @( posedge clk or posedge rst) begin : out_sum
		if(rst) begin
			filter_out <=0;
		end
		else if(trunc_frac_sum[15] == 0) begin
			filter_out <= {1'b0, trunc_frac_sum[7:0]};
		end
		else begin
			filter_out <= {1'b1, trunc_frac_sum[7:0]};
		end
	end
```

```verilog
//일반적인 포맷
	always_ff @( posedge clk or posedge rst) begin : out_sum
		if(rst) begin
			filter_out <=0;
		end
		else if(trunc_frac_sum[15:7] > 변환정수부_MAX값) begin
			filter_out[정수부] <= 변환정수부_MAX값;
		end
		else if(trunc_frac_sum[15:7] < 변환정수부_MIN) begin
			filter_out[정수부] <= 변환정수부_MIN;
		end
		else begin
			filter_out <= 변환전_정수값;
		end
	end
```

- Q8.(기존)
  - 수의 표현범위: -128~127
- Q1.(변환)
  - 수의 표현범위: -1~0
- 기존 정수부의 수의 표현범위가 변환할 정수부의 수의 범위를 벗어나는 경우
  - 기존 정수부 > 0
    - 변환 정수부는 0으로 Saturation
  - 기존 정수부 < -1
    - 변환 정수부는 1로 saturation

### 내 경험상 추천 변환 방법

- 소수부를 먼저 변환해주고
- 그다음에 정수부만 saturation해주는게 이해와 연산이 편함
- 예를 들어, 011.1010[2진수: 3.625 Q3.4]를 Q2.2로 변환한다고 하면
  - 소수부 먼저
    - .1010 --> .10으로 truncation
    - 0.625 --> 0.5
      - 비트로 표현가능한 소수에서 제일 가까운 수로 변환 가능
  - 정수부
    - 011.: 3
    - Q2.가 표현할 수 있는 정수 범위: -2~1
    - 수의 범위를 벗어남
    - 변환할 정수부가 표현할 수 있는 최대 범위로 표현
    - 양수니까 MSB = 0
    - 따라서 0(MSB)1(최대 정수 범위)
 --><br>

///////////////////////////////////////////////////////////////////////


⚠️이렇게 하면 안됨 --> 내가 잘못 이해한거임
---

# 내가 잘못 이해하고 잘못 설계한 코드

```verilog
	always_ff @( posedge clk or posedge rst) begin : out_sum
		if(rst) begin
			filter_out <=0;
		end
		else if(trunc_frac_sum[15] == 0) begin
			filter_out <= {1'b0, trunc_frac_sum[7:0]};
		end
		else begin
			filter_out <= {1'b1, trunc_frac_sum[7:0]};
		end
	end
```

- 지금 정수부만 포화시킴
  - 소수부는 포화 안됨
  - 예를 들어, 127.123456을 정수 1자리, 소수 3자리로 바꾼다면
  - 나의 경우(error): 9.123 --> 소수부 포화가 안됨 --> 9.999가 정상 변환값임

# 수정한 코드

⭐HW 안에서 연산을 할 때는 integer형식임을 인지하고 연산을 수행하자 --> 소수는 나중에 2^(소수비트)로 나눠주면됨
---
> 정수로 연산을 수행하자

```verilog
	always_ff @( posedge clk or posedge rst ) begin : blockName
		if(rst) begin
			filter_out <= 0;
		end
		// trunc_frac_sum: Q8.8  -- 출력 Q1.8 : -256~255
		else if(trunc_frac_sum > 255) begin
			filter_out <= 255;
		end
		else if(trunc_frac_sum < -256) begin
			filter_out <= -256;
		end
		else begin
			filter_out <= trunc_frac_sum;
		end
	end
```
- 소수부를 Truncation하고 Q8.8인 상태 --> trunc_frac_sum
- 변환해야될 출력 Q1.8: filter_out --> 값의 표현범위 = -256~255
  - ```trunc_frac_sum``` > 255보다 크면
    - 출력 ```filter_out```을 255로 Saturation
  - ```trunc_frac_sum``` < -256보다 작으면
    - 출력 ```filter_out```을 -256으로 Saturation

## ⚠️주의할 사항(깨달은 점)
- 회로 안에서 연산할 때는 정수로서 연산을 수행하자
  - 정수부, 소수부 따로 나눠서 생각X
  - 소수부를 Truncation할 때만 고려
- 소수부를 먼저 Truncation을 하고
  - 이후 변환할 값의 비트 범위를 벗어나는지 확인

## 참고) 소수부 자리수와 Truncation
- 소수부 이하 2비트, 1비트로 줄이는 극단적 경우
  - 현실에선 거의 없음
- 따라서 대부분 truncation하는 경우 Truncation되는 소수의 값이 매우 작음
  - 대부분의 경우 truncation하는 경우 값의 오차가 그리 크지않음
- 특별한 case가 아닌 경우 round와 truncation의 성능 차이가 거의 없다
  - **교수님 피셜임**
