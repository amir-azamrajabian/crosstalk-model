clear; close; clc;
%% This Code is for analysing the effect of R_Gate on the peack voltage of gate voltage
L_circ = [50: 5: 220];

Vge = [4.55E+00	4.67E+00	4.77E+00	4.85E+00	4.91E+00	4.95E+00	4.97E+00	4.98E+00	4.97E+00	4.95E+00	4.93E+00	4.89E+00	4.85E+00	4.80E+00	4.74E+00	4.68E+00	4.62E+00	4.55E+00	4.49E+00	4.42E+00	4.35E+00	4.28E+00	4.21E+00	4.14E+00	4.08E+00	4.12E+00	4.16E+00	4.20E+00	4.24E+00	4.28E+00	4.32E+00	4.36E+00	4.40E+00	4.44E+00	4.47E+00];
figure(1);
plot(L_circ, Vge, 'r-', 'LineWidth', 4);
xlabel('Inductance(nH)');
ylabel('Gate-Emitter Voltage(V)');