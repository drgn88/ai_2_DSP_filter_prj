% 1. 파일에서 데이터 불러오기
% test_input_vector.txt 파일 불러오기
test_input_vector = load('test_input_vector.txt');
test_input_vector = squeeze(test_input_vector); % 명시적으로 1차원 벡터로 변환

% my_result.txt 파일 불러오기
my_result = load('my_result.txt');
my_result = squeeze(my_result); % 명시적으로 1차원 벡터로 변환

% 2. RRC 필터 계수 정의
filter_coefficients = [0, -1, 1, 0, -1, 2, 0, -2, 2, 0, -6, 8, 10, -28, -14, 111, 196, 111, -14, -28, 10, 8, -6, 0, 2, -2, 0, 2, -1, 0, 1, -1, 0];
filter_coefficients = squeeze(filter_coefficients); % 명시적으로 1차원 벡터로 변환

% 3. FFT를 위한 설정
N_input = length(test_input_vector);
N_output = length(my_result);
N_filter = length(filter_coefficients);

max_len = max([N_input, N_output, N_filter]);
N_fft = 2^nextpow2(max_len); % FFT 포인트 수

% 주파수 벡터 생성 (normalized frequency)
f = (0:N_fft/2) / N_fft; % Normalized frequency (0 to 0.5)

% 4. FFT 수행 및 Magnitude Spectrum 계산

% 테스트 입력 벡터의 FFT
fft_input = fft(test_input_vector, N_fft);
fft_input = fft_input(:); % 명시적으로 열 벡터로 변환
magnitude_input = abs(fft_input(1:N_fft/2+1));

% RRC 필터 계수의 FFT (필터의 주파수 응답)
fft_filter = fft(filter_coefficients, N_fft);
fft_filter = fft_filter(:); % 명시적으로 열 벡터로 변환
magnitude_filter = abs(fft_filter(1:N_fft/2+1));

% 필터 출력 값의 FFT
fft_output = fft(my_result, N_fft);
fft_output = fft_output(:); % 명시적으로 열 벡터로 변환
magnitude_output = abs(fft_output(1:N_fft/2+1));

% 디버깅을 위한 변수 크기 확인 추가
disp(['Size of fft_input: ', mat2str(size(fft_input))]);
disp(['Size of fft_filter: ', mat2str(size(fft_filter))]);

% 5. 주파수 도메인 그래프 그리기

figure;

subplot(3,1,1);
plot(f, magnitude_input);
title('Magnitude Spectrum of Test Input Vector');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude');
grid on;

subplot(3,1,2);
plot(f, magnitude_filter);
title('Magnitude Response of RRC Filter');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude');
grid on;

subplot(3,1,3);
plot(f, magnitude_output);
title('Magnitude Spectrum of Filtered Output');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude');
grid on;

% 6. 필터링 결과 검증 (주파수 도메인에서)
% 주파수 도메인에서 컨볼루션은 곱셈과 동일합니다.
simulated_fft_output_freq = fft_input .* fft_filter; % 이 라인이 문제의 78번 라인이 될 것입니다.
simulated_magnitude_output_freq = abs(simulated_fft_output_freq(1:N_fft/2+1));

figure;
plot(f, magnitude_output, 'b', 'DisplayName', 'My Result Output Spectrum');
hold on;
plot(f, simulated_magnitude_output_freq, 'r--', 'DisplayName', 'Simulated Output Spectrum (Input FFT * Filter FFT)');
title('Comparison: Given Output Spectrum vs. Simulated Output Spectrum');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude');
legend('show');
grid on;
hold off;