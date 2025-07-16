% 주어진 필터 계수
filter_coefficients = [0, -1, 1, 0, -1, 2, 0, -2, 2, 0, -6, 8, 10, -28, -14, 111, 196, 111, -14, -28, 10, 8, -6, 0, 2, -2, 0, 2, -1, 0, 1, -1, 0];

% 1. 임펄스 응답 플롯
figure;
stem(0:length(filter_coefficients)-1, filter_coefficients);
title('Impulse Response of the RRC Filter');
xlabel('Sample Index (n)');
ylabel('Amplitude');
grid on;

% 2. 주파수 응답 플롯
% fftfreqz 함수를 사용하여 주파수 응답 계산
% [H, W] = freqz(b, a, nfft, Fs);
% b는 필터 계수 (분자 계수), a는 분모 계수 (FIR 필터이므로 1)
% nfft는 FFT 포인트 수 (주파수 해상도)
% Fs는 샘플링 주파수 (정규화 주파수를 위해 1로 가정)

nfft = 2048; % 주파수 해상도를 높이기 위해 충분히 큰 값 사용
Fs = 1;      % 정규화 주파수를 위해 1로 설정 (0 ~ 0.5)

[H, W] = freqz(filter_coefficients, 1, nfft, Fs);

% 주파수 응답의 크기 (Magnitude Response) 플롯 (dB 스케일)
figure;
plot(W/pi, 20*log10(abs(H))); % W/pi는 정규화 주파수 (\times \pi rad/sample)
title('Magnitude Response of the RRC Filter');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude (dB)');
grid on;
ylim([-80 10]); % Y축 범위 조정 (필요에 따라)
xlim([0 1]);    % 정규화 주파수 범위 (0 ~ 1.0)

% 주파수 응답의 위상 (Phase Response) 플롯
figure;
plot(W/pi, unwrap(angle(H))*180/pi); % 위상 응답 (도 단위)
title('Phase Response of the RRC Filter');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Phase (degrees)');
grid on;
xlim([0 1]);

disp('Filter Coefficients Length: ');
disp(length(filter_coefficients));