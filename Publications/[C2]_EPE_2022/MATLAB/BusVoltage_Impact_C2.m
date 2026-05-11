clear; close; clc;

VBUS = 400: -10: 100;
VGE1 = 3.5*[2.33 2.32 2.31 2.30 2.29 2.275 2.265 2.25 2.24 2.225 2.215 2.20 2.19 2.18 2.17 2.16 2.13 2.10 2.07 2.04 2.00 1.96 1.93 1.90 1.87 1.83 1.79 1.74 1.68 1.62 1.55];
figure(1);
plot(VBUS, VGE1, 'r-', 'LineWidth', 4);
xlabel('Off-State Voltage (V)');
ylabel('V_G_E_1_-_P (V)');
grid on;
legend('Experimental');