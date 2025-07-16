% 1. 데이터 불러오기
% 파일의 실제 데이터 형식에 따라 'readmatrix' 또는 'dlmread' 사용법을 조정하세요.
% 예를 들어, 데이터가 공백으로 구분된 여러 열이거나 특정 구분자가 있다면 readmatrix 옵션을 조정해야 합니다.
try
    input_data = readmatrix('test_input_vector.txt');
    output_data = readmatrix('내_결과_파일.txt');
catch
    % readmatrix가 실패할 경우를 대비하여 dlmread 시도
    % dlmread는 더 단순한 구조의 파일에 적합합니다.
    warning('readmatrix 실패. dlmread 시도.');
    input_data = dlmread('test_input_vector.txt');
    output_data = dlmread('내_결과_파일.txt');
end


% !!! 이 부분에서 데이터 확인 !!!
disp('Input data preview:');
disp(input_data(1:min(10, end))); % 처음 10개 값 출력
disp(['Number of NaNs in input_data: ', num2str(sum(isnan(input_data(:))))]); % NaN 개수 확인

disp('Output data preview:');
disp(output_data(1:min(10, end))); % 처음 10개 값 출력
disp(['Number of NaNs in output_data: ', num2str(sum(isnan(output_data(:))))]); % NaN 개수 확인

% NaN이 있다면 제거 또는 대체
input_data(isnan(input_data)) = 0; % NaN 값을 0으로 대체 (혹은 다른 적절한 값)
% 또는 input_data = input_data(~isnan(input_data)); % NaN이 있는 행/요소 제거 (데이터 길이가 달라질 수 있음)

output_data(isnan(output_data)) = 0; % NaN 값을 0으로 대체
% 또는 output_data = output_data(~isnan(output_data)); % NaN이 있는 행/요소 제거

% 데이터가 복소수일 경우, pwelch는 실수 데이터만 받으므로 abs()를 취하거나 실수/허수부를 분리해야 할 수 있습니다.
% 만약 Verilog 시뮬레이션 결과가 signed 16-bit 등의 정수 형태라면 실수형으로 변환해주는 것이 좋습니다.
input_data = double(input_data);
output_data = double(output_data);

% 2. Welch PSD 계산 파라미터 설정
% 샘플링 주파수는 Verilog 설계의 클럭 주파수와 연관됩니다.
% 정확한 샘플링 주파수를 알지 못한다면, 'Normalized Frequency'로 표시하기 위해 1로 설정할 수 있습니다.
% 이 예시에서는 정규화 주파수를 사용하기 위해 Fs를 1로 가정합니다.
Fs = 1; % 샘플링 주파수 (Hz) - 정규화 주파수를 위해 1로 설정

% pwelch 파라미터 설정 (필요에 따라 조정)
% window: 윈도우 함수 (예: hamming, hanning)
% noverlap: 겹치는 샘플 수
% nfft: FFT 포인트 수 (길수록 주파수 해상도 증가)
% 'onesided': 단측 PSD (실수 신호에 적합)
window_len = 256; % 윈도우 길이 (데이터 길이에 따라 조정)
noverlap = window_len / 2; % 50% 오버랩
nfft = 256; % FFT 포인트 수 (window_len과 동일하게 설정하거나 2의 거듭제곱)

% 3. Input Data (test_input_vector)의 PSD 계산
[Pxx_input, F_input] = pwelch(input_data, window_len, noverlap, nfft, Fs, 'onesided');

% 4. Output Data (내_결과_파일)의 PSD 계산
[Pxx_output, F_output] = pwelch(output_data, window_len, noverlap, nfft, Fs, 'onesided');

% 5. 결과 플로팅
figure;

subplot(2,1,1); % 2행 1열의 첫 번째 서브플롯
plot(F_input, 10*log10(Pxx_input), 'b'); % 'b'는 파란색 선
grid on;
title('Welch PSD Estimate of Test Input Vector');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Power/Frequency (dB/rad/sample)');
ylim([-30 30]); % Y축 범위 조정 (원본 그래프와 유사하게)

subplot(2,1,2); % 2행 1열의 두 번째 서브플롯
plot(F_output, 10*log10(Pxx_output), 'r'); % 'r'은 빨간색 선
grid on;
title('Welch PSD Estimate of RRC Filter Output');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Power/Frequency (dB/rad/sample)');
ylim([-30 30]); % Y축 범위 조정 (원본 그래프와 유사하게)

% 두 그래프를 한 플롯에 같이 보고 싶다면:
figure;
plot(F_input, 10*log10(Pxx_input), 'b', 'DisplayName', 'Test Input');
hold on;
plot(F_output, 10*log10(Pxx_output), 'r', 'DisplayName', 'RRC Filter Output');
hold off;
grid on;
legend('show');
title('Welch PSD Estimate: Input vs. RRC Filter Output');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Power/Frequency (dB/rad/sample)');
ylim([-30 30]); % Y축 범위 조정
xlim([0 max(F_input)]); % X축 범위 조정 (0부터 최대 정규화 주파수까지)

% 선택 사항: 플롯 스타일을 원본 이미지와 유사하게 변경 (검은 배경 등)
% set(gca, 'Color', 'k'); % 현재 축의 배경색을 검정으로
% set(gcf, 'Color', 'w'); % 현재 그림의 배경색을 흰색으로 (기본값)
% set(get(gca, 'XLabel'), 'Color', 'w'); % X축 라벨 색상
% set(get(gca, 'YLabel'), 'Color', 'w'); % Y축 라벨 색상
% set(get(gca, 'Title'), 'Color', 'w'); % 제목 색상
% set(gca, 'XColor', 'w', 'YColor', 'w'); % 축 눈금 및 레이블 색상