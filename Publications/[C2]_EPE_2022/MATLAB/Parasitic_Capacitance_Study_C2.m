clear; close; clc;

state1 = csvread('No_Change.csv', 2);
time1 = state1(:, 1);
VGE1 = state1(:, 2);

state2 = csvread('Minus_Thirty.csv', 2);
time2 = state2(:, 1);
VGE2 = state2(:, 2);

state3 = csvread('Plus_Thirty.csv', 2);
time3 = state3(:, 1);
VGE3 = state3(:, 2);

figure(1);
plot(time1, VGE1, 'LineWidth', 4);
hold on;
plot(time2, VGE2, '-','LineWidth', 4);
plot(time3, VGE3, '-','LineWidth', 4);
grid on;
xlabel('time (s)');
ylabel('Gate-Emitter Voltage (V)');
legend('Main Vlaues', '-30%', '+30%');