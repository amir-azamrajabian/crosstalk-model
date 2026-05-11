clear; close; clc;
%% This Code is for analysing the effect of R_Gate on the peack voltage of gate voltage
R_gate = [1: 5: 100];
V_peackg = [1.6166 6.0185 9.2406 11.650 13.441 14.804 15.870 16.723 17.421 18.002 18.493 18.913 19.276 19.593 19.872 20.120 20.342 20.541 20.721 20.885];
figure(1);
plot(R_gate, V_peackg, 'LineWidth', 2)
title('Gate resistor effects on the gate voltage');
xlabel('Rg');
ylabel('Vg');

%% Over voltage under different gate resistors
V_peackd = [752.855 750.836 750.988 751.092 751.161 751.209 751.245 751.273 751.296 751.315 751.330 751.344 751.355 751.365 751.374 751.382 751.389 751.395 751.401 751.406];
figure(2);
plot(R_gate, V_peackd, 'LineWidth', 2);
title('Gate resistor effects on the drain voltage');
xlabel('Rg');
ylabel('Vd');