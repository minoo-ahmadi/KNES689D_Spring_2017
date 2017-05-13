w09ex6; % Loading Exercise 6 from week 9.

%% Creating the Smoothed envelope
y2h_rec = abs(y2h); % Full-wave rectify the signal by taking its absolute value.

n2 = 2; % Butterworth filter order for low-pass forward-reverse filter.
fc2  = 12.5;    % Cutoff frequency for low-pass forward-reverse filter (Hz).
fcs2 = fc2*((sqrt(2) - 1)^(1/(2*n))); % New cutt-off frequency, fc* (Hz).

[b a] = butter(n, fcs2/fN2); % Design low-pass Butterworth filter.
y2h_env   = filtfilt(b, a, y2h_rec); % Low-pass forward-reverse filtering.

%% Spectral Analysis
T_rec    = 20; % Spectral window length (s).
nfft2_rec = round(T_rec*sr2); % Number of time steps in spectral window for y2h_rec.


[Pyy2h_rec  f2_rec] = pwelch(y2h_rec , hanning(nfft2_rec), nfft2_rec/2, nfft2_rec, sr2);  % PSD of y2h_rec
[Pyy2h_env f2_rec] = pwelch(y2h_env, hanning(nfft2_rec), nfft2_rec/2, nfft2_rec, sr2);  % PSD of y2h_env
[H f2_rec]     = tfestimate(y2h_rec, y2h_env, hanning(nfft2_rec), nfft2_rec/2, nfft2_rec, sr2);  % FRF.

gH_env = abs(H);
pH_env = angle(H)*(180/pi);

df      = f2_rec(2);             % Frequency step (Hz).
k_rec       = round(fc2/df) + 1;  % Index of cutoff frequency.
gain_fc2 = gH_env(k_rec);             % Gain at cutoff frequency.    
psd_fc2  = Pyy2h_env(k_rec)/Pyy2h_rec(k_rec);  % Ratio of PSDs at cutoff frequency.

%% Plotting

subplot(2,2,1);
plot(t2, y2h_rec, 'b-');
xlim([10 15]);
ylim([-0.2 0.6]);
set(gca, 'TickDir', 'out', 'XTick', 10:15);
xlabel('time (s)');
ylabel(' Rectified TA EMG (mV)');

subplot(2,2,3);
plot(t2, y2h_env, 'r-');
xlim([10 15]);
ylim([-0.2 0.6]);
set(gca, 'TickDir', 'out', 'XTick', 10:15);
xlabel('time (s)');
ylabel('Smoothed Envelope of TA EMG (mV)');

subplot(3,2,2);
loglog(f2_rec, Pyy2h_rec, 'b-', f2_rec, Pyy2h_env, 'r-');
xlim([f2_rec(2) 100]);
ylim([1e-12 1e-1]);
set(gca, 'TickDir', 'out', 'XTick', [0.1 1 10 100], 'YTick', 10.^(-18:8:-2));
xlabel('frequency (Hz)');
ylabel('EMG PSD (mV^2/Hz)');
h = legend('rectified', 'smooth enveloped');
set(h, 'Location', 'SouthEast', 'Box', 'off');
s1 = sprintf('f_c^* = %6.4f, ', fcs2);
s2 = sprintf('PSD ratio at: f_c = %6.4f, f_c^* = %6.4f', psd_fc, psd_fc2); 
title([s1 s2]);

subplot(3,2,4);
loglog(f2_rec, gH_env, 'b-', f2(k), gH(k), 'ro', f2_rec(k_rec), gH_env(k_rec), 'r*');
xlim([f2_rec(2) 100]);
ylim([1e-9 10]);
set(gca, 'TickDir', 'out', 'XTick', [0.1 1 10 100], 'YTick', 10.^(-9:3:0));
xlabel('frequency (Hz)');
ylabel('gain');
s1 = sprintf('gain at f_c = %6.4f', gain_fc);
s2 = sprintf('gain at f_c^* = %6.4f', gain_fc2);
h = legend('gain', s1, s2);
set(h, 'Location', 'SouthWest', 'Box', 'off');

subplot(3,2,6);
semilogx(f2_rec, pH_env, '.');
xlim([f2_rec(2) 100]);
ylim([-180 180]);
set(gca, 'TickDir', 'out', 'XTick', [0.1 1 10 100], 'YTick', -180:90:180);
xlabel('frequency (Hz)');
ylabel('phase (deg)');