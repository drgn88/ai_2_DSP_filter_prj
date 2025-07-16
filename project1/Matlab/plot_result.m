% 1. 파일에서 데이터 불러오기
% test_input_vector.txt 파일 불러오기
test_input_vector = load('test_input_vector.txt');

% my_result.txt 파일 불러오기
my_result = load('my_result.txt');

% 2. RRC 필터 계수 정의
% 제공된 테이블에서 필터 계수를 그대로 입력합니다.
% MATLAB 배열 인덱스는 1부터 시작하므로 num 1이 h(1)에 해당합니다.
filter_coefficients = [0, -1, 1, 0, -1, 2, 0, -2, 2, 0, -6, 8, 10, -28, -14, 111, 196, 111, -14, -28, 10, 8, -6, 0, 2, -2, 0, 2, -1, 0, 1, -1, 0];

% 3. 그래프 그리기

% Figure 1: 테스트 입력 벡터
figure;
plot(test_input_vector);
title('Test Input Vector');
xlabel('Sample Index');
ylabel('Amplitude');
grid on;

% Figure 2: RRC 필터 계수
figure;
stem(0:length(filter_coefficients)-1, filter_coefficients); % 0부터 시작하는 인덱스로 표시
title('RRC Filter Coefficients (h[n])');
xlabel('Coefficient Index (n)');
ylabel('Coefficient Value');
grid on;

% Figure 3: 필터 출력 값
figure;
plot(my_result);
title('Filtered Output (my_result)');
xlabel('Sample Index');
ylabel('Amplitude');
grid on;

% 4. 필터링 결과 검증 (선택 사항)
% 실제 test_input_vector에 filter_coefficients를 적용하여 my_result와 비교
% (단, my_result는 이미 필터링된 값이라고 가정합니다. 이 부분은 단순 확인용입니다.)
% conv 함수는 선형 컨볼루션을 수행합니다.
% filter_coefficients는 33개의 계수를 가지고 있으므로, 이 필터의 차수는 32입니다.
% conv 결과는 (N_input + N_filter - 1) 길이를 가집니다.
simulated_output = conv(test_input_vector, filter_coefficients);

% 실제 출력과 시뮬레이션된 출력의 일부를 비교 (길이가 다르므로 전체 비교는 어려움)
% 일반적으로 필터링된 출력은 입력과 같은 길이를 갖도록 처리하지만,
% 여기서는 conv 함수의 기본 동작을 따릅니다.
figure;
plot(my_result, 'b', 'DisplayName', 'My Result (Given Output)');
hold on;
% simulated_output의 길이가 my_result보다 길 수 있으므로, my_result 길이만큼만 플로팅
plot(simulated_output(1:length(my_result)), 'r--', 'DisplayName', 'Simulated Output (conv)');
title('Comparison: Given Output vs. Simulated Output');
xlabel('Sample Index');
ylabel('Amplitude');
legend('show');
grid on;
hold off;

% 두 결과 간의 오차 계산 (선택 사항)
if length(my_result) <= length(simulated_output)
    error_signal = my_result - simulated_output(1:length(my_result));
    figure;
    plot(error_signal);
    title('Error between My Result and Simulated Output');
    xlabel('Sample Index');
    ylabel('Error');
    grid on;
    fprintf('Mean Absolute Error: %f\n', mean(abs(error_signal)));
else
    fprintf('Warning: my_result is longer than simulated_output. Cannot compute error directly.\n');
end