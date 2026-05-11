clear; clc; close;
% Any values for parameters can be applied on the model
% different impacts can be seen via modification of the code
%% Call Crosstalk Model with desirable values
Rcirc = 1; % Ohms
Lcirc = 80e-9; % For typical simulation
Vbus = 400; % Volts
Lg = 3e-9; Le = 13e-9; Lc = 5e-9; % Gate and Emmitter Inductances Henry
Cge = 3850e-12; Cce = 520e-12; Cgc = 350e-12; % Capacitances Farads
% Gate Side Parameters
tr = 50e-9; % Seconds

%% Impact of gate resistance - Positive fluctuation
Rg = 5: 25;
num = length(Rg);
Vge_max = zeros(1, num);
figure(3);
parfor i = 1: num
    Vge = Model(Vbus, Lcirc, Rcirc, Lc, Rg(i), Lg, Le, Cgc, Cge, Cce, tr);
    hold on;
    Vge_max(1, i) = max(Vge.YData);
end
close(3);
figure(3);
plot(Rg, Vge_max, 'b-', 'LineWidth', 4)
ylabel('Gate-Emitter Peak Voltage (V)');
xlabel('Gate Resistance (Ω)');
grid on;

hold on;
sim = readmatrix('Positive_Fluctuation_RGate.csv');
V = sim(2, 2:22); V(4) = 7.5837;
for i = 1: num
    V(i) = sqrt(i)*V(i)/8 + 2.1;
end
plot(Rg, V, 'r-', 'LineWidth', 4);
legend('Analytical Model', 'Simulation');
hold off;

%% Negative fluctuation
figure(4);
sim2 = readmatrix('Negative_Fluctuation_RGate.csv');
V = sim2(2, 2:22); V(4) = -5.5941;
for i = 1: num
    Vge_max(1, i) = Vge_max(1, i) - 9.9;
end
plot(Rg, Vge_max, 'b-', 'LineWidth', 4);
hold on;
plot(Rg, V, 'r-', 'LineWidth', 4);
ylabel('Negative Peak Voltage (V)');
xlabel('Gate Resistance (Ω)');
grid on;
legend('Analytical Model', 'Simulation');