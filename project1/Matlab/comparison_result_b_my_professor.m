% 파일 이름 정의
file1_name = '교수님_제시_정답_결과.txt';
file2_name = '내_결과_파일.txt';

% 비교할 줄 수 정의
lines_to_compare = 78992;

% 파일에서 데이터 불러오기
% load 함수는 텍스트 파일의 숫자를 열 벡터로 불러옵니다.
% 만약 파일에 숫자가 아닌 다른 내용(예: 문자열)이 포함되어 있다면 문제가 발생할 수 있습니다.
% 이 경우 textscan 또는 readmatrix/readtable을 사용하는 것이 더 견고합니다.
try
    data1 = load(file1_name);
    data2 = load(file2_name);
catch ME
    fprintf('파일을 불러오는 데 오류가 발생했습니다: %s\n', ME.message);
    return; % 오류 발생 시 스크립트 종료
end

% 불러온 데이터의 차원 확인 및 필요시 열 벡터로 변환
% load 함수는 기본적으로 열 벡터를 반환하지만, 혹시 모를 경우를 대비하여 squeeze 처리
data1 = squeeze(data1);
data2 = squeeze(data2);

% 데이터 길이 확인
len1 = length(data1);
len2 = length(data2);

fprintf('파일 1 (%s)의 길이: %d\n', file1_name, len1);
fprintf('파일 2 (%s)의 길이: %d\n', file2_name, len2);
fprintf('비교할 최대 줄 수: %d\n', lines_to_compare);

% 비교할 실제 최소 줄 수 결정 (두 파일 중 짧은 길이와 lines_to_compare 중 최소값)
actual_compare_limit = min([len1, len2, lines_to_compare]);
fprintf('실제로 비교될 줄 수: %d\n', actual_compare_limit);


% 두 파일의 데이터 비교
diff_found = false; % 차이점을 찾았는지 여부를 나타내는 플래그

for i = 1:actual_compare_limit
    % 숫자가 정확히 일치하는지 비교
    % 부동소수점 오차를 고려해야 한다면 abs(data1(i) - data2(i)) > tolerance 와 같이 비교해야 합니다.
    % 여기서는 정수 또는 정확한 부동소수점 일치를 가정합니다.
    if data1(i) ~= data2(i)
        fprintf('%d번째 줄에서 값이 다릅니다: %s의 값은 %.4f, %s의 값은 %.4f\n', ...
                i, file1_name, data1(i), file2_name, data2(i));
        diff_found = true;
        % 첫 번째 차이점을 찾으면 바로 종료하거나, 모든 차이점을 보고 싶다면 break를 제거합니다.
        % break; % 첫 번째 차이점 발견 시 비교 중지
    end
end

% 모든 줄이 같았는지 여부에 따라 메시지 출력
if ~diff_found
    fprintf('All Same! %d 줄까지 모든 값이 동일합니다.\n', actual_compare_limit);
end

% 만약 비교할 줄 수 이상으로 파일 길이가 다르다면 메시지 추가
if len1 > actual_compare_limit || len2 > actual_compare_limit
    fprintf('참고: 지정된 %d줄 이후로는 파일 길이가 다르거나 비교되지 않았습니다.\n', actual_compare_limit);
end

if len1 ~= len2
    fprintf('경고: 두 파일의 총 길이가 다릅니다 (%d vs %d).\n', len1, len2);
end