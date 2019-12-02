thr = -18; % dB
ratio = 10; % ratio:1
knee = 0; % dB
attMs = 0.03;
holdMs = 50;
relMs = 250;
rmsMs = 0;
wavBaseName = "test";
wavFile = sprintf("%s%s", wavBaseName, ".wav");

[n, fs] = audioread(wavFile);

if (ndims(n) == 2)
    y = n(:, 1);
else
    y = n;
end

len = length(y);
x = 0:(len - 1);

[cs, cd, stages] = comp(y, fs, thr, ratio, knee, attMs, holdMs, relMs, rmsMs);

y_dB = mag2db(y);
cs_dB = mag2db(cs);

y_rms = rms(y);
cs_rms = rms(cs);

printf("\nBefore          : %f RMS\n", y_rms);
printf("After           : %f RMS\n", cs_rms);

y_norm = normalise(y);
cs_norm = normalise(cs);
y_norm_rms = rms(y_norm);
cs_norm_rms = rms(cs_norm);

printf("\nBefore (norm)   : %f RMS\n", y_norm_rms);
printf("After (norm)    : %f RMS\n", cs_norm_rms);

figure, plot(x, y_norm), title("y norm");
figure, plot(x, cs_norm), title("cs norm");
figure, plot(x, cd), title("gr");
figure, plot(x, stages), title("stages");
figure, plot(x, cs_norm, x, cd, x, stages), title("Debug");

audiowrite(sprintf("%s%s", wavBaseName, "_norm.wav"), y_norm, fs);
audiowrite(sprintf("%s%s", wavBaseName, "_comp.wav"), cs_norm, fs);

