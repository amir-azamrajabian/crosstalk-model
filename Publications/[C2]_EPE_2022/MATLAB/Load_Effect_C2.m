clear; close; clc;

RLOAD = 10: 5: 100;
VGE1 = 2.5*[2.34E+00	2.65E+00	2.84E+00	2.98E+00	3.09E+00	3.17E+00	3.24E+00	3.29E+00	3.33E+00	3.37E+00	3.40E+00	3.43E+00	3.46E+00	3.48E+00	3.50E+00	3.52E+00	3.53E+00	3.55E+00	3.56E+00];
ILOAD = 400./RLOAD;
figure(1);
plot(ILOAD, VGE1, 'r-', 'LineWidth', 4);
xlabel('Load Current(A)');
ylabel('Gate-Emitter Voltage (V)');
grid on;
legend('Simulation');