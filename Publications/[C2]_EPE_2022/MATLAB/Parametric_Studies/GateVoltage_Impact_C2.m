clear; close; clc;
sim = csvread('Gate_Voltage.csv', 2);
% Definitions 
[n ~] = size(sim);
time = sim(:, 1);
V = zeros(20, n);
% Plotting
figure(1);
for i = 0: 20
    V(i+1, :) = sim(:, i+2) + i;
    plot(time, V(i+1, :), 'LineWidth', 4);
    hold on;
end

legend('0', '-1', '-2', '-3', '-4', '-5', '-6', '-7', '-8', '-9', '-10', '-11', '-12', '-13', '-14', '-15', '-16', '-17', '-18', '-19', '-20');
xlabel('time (s)');
ylabel('Gate-emitter Voltage (V)');