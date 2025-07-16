clc;

fixed_mode = 1;

[FileName, PathName] = uigetfile('*.txt', 'select the capture binary file');
[FID, message] = fopen(FileName, "r");

if (fixed_mode)
    waveform = fscanf(FID, '%d', [1 Inf]);
else
    waveform = fscanf(FID, '%f', [1 Inf]);
end

Iwave = waveform(1,:);

figure;
pwelch(double(Iwave));