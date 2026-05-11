clc; clear; close;
% time = [0.3978 0.4026 0.4081 0.4118 0.4136 0.4210 0.4179 0.4271 0.4191 0.4301 0.4307];
Pspice = csvread('PeakVoltage.csv', 2);
V_peakgsim = Pspice(1, 2:20);
V_peakg = [8.8715 9.2070 9.510 9.808 10.006 10.159 10.124 10.0504 9.9433 9.7679 9.5376 9.2650 8.9607 8.7939 8.9409 9.0817 9.2169 9.3469 9.579];
Esc = [0.0014 0.0015 0.0016 0.0017 0.0018 0.0018 0.0019 0.0018 0.0018 0.0017 0.00165 0.00155 0.0015 0.0016 0.00155 0.0016 0.0017 0.0017 0.0018];
Lcr = 60: 10: 240;
figure(1);
plot(Lcr, V_peakg, 'b--','LineWidth', 4);
hold on;
plot(Lcr, V_peakgsim, 'r-','LineWidth', 4);
title('Effect of Parasitic Inductance on Gate-Emitter Voltage');
xlabel('Parasitic Inductance (nH)');
ylabel('Gate - Emitter Voltage (V)');
legend('Analytic Model', 'Simulation in SPICE');

Escsim = zeros(1, 19); gfs = 14; vth = 5.1; Vbus = 600;
time = [45.389 44.184 42.722 42.527 42.888 43.463 44.108 44.767 45.408 46.027 46.604 47.131 47.597 47.99 48.297 48.5 48.571 48.475 48.156]*10^(-9);
figure(2);
for i = 1: 19
    Escsim(i) = gfs*(V_peakgsim(i) - vth)*Vbus*time(i);
end
plot(Lcr, Escsim, 'r-','LineWidth', 3);
hold on;
plot(Lcr, Esc, 'b--', 'LineWidth', 3);
title('Effect of Parasitic Inductance on Crosstalk Energy');
xlabel('Parasitic Inductance (nH)');
ylabel('Crosstalk Energy(J)');
legend('Simulation in SPICE', 'Analytic Model');