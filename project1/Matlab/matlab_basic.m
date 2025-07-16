clc;

A = [1 2;3 4]
B = [8 7;6 5]

C = A + B
D = A - B
E = A * B
F = A ^ 2
G = A'

E_1 = A .* B
E_2 = A ./ B
F_1 = A .^ B

[rows, cols] = size(A)
tot_sum = sum(A(:))
row_sum = sum(A,2)
col_sum = sum(A,1)
tot_mean = mean(A(:))
row_sum = mean(A,2)
col_sum = mean(A,1)