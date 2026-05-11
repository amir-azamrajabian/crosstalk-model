clear; close; clc;
%% This Code is for analysing the effect of R_Gate on the peack voltage of gate voltage
L_circ = [60: 5: 300];
V_peakg = [7.7724 7.8795 7.9789 8.0575 8.0554 7.9569 7.7788 7.8441 7.9233 7.9983 8.0697 8.1375 8.2022 8.2633 8.3068 8.3195 8.2972 8.2398 8.1496 8.0302 7.8886 7.9424 7.9946 8.0452 8.0942 8.1418 8.1880 8.2329 8.2765 8.3190 8.3603 8.4006 8.4398 8.4780 8.5152 8.5516 8.5872 8.6213 8.6517 8.6768 8.6954 8.7069 8.7108 8.7072 8.6959 8.6771 8.6510 8.6178 8.5777];
figure(1);
plot(L_circ, V_peakg, 'LineWidth', 2)
title('Circuit Inductance effects on the gate-emitter voltage');
xlabel('Lcirc. (nH)');
ylabel('Vg (V)');