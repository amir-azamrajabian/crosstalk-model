clear; close; clc;
%% This Code is for analysing the effect of load power consumption
R_Load = 5: 1:40; % Ohm
Watt = [50.000 44.082 39.375 35.556 32.400 29.752 27.500 25.562 23.878 22.400 21.094 19.931 18.889 17.950 17.100 16.327 15.620 14.972 14.375 13.824 13.314 12.840 12.398 11.986 11.600 11.238 10.898 10.579 10.277 9.992 9.722 9.4668 9.2244 8.9941 8.7750 8.5663]; % Kilo Watt
% Upper than 20 Ohm, the current starts to have overshoot
figure(1);
plot(R_Load, Watt, 'LineWidth', 4)
title('Effect of Load');
xlabel('Load (Ohm)');
ylabel('Power (Kilo Watt)');