clear; clc; close;
% Any values for parameters can be applied on the model
% different impacts can be seen via modification of the code
%% Call Crosstalk Model with desirable values
Rcirc = 1; % Ohms
Lcirc = 80e-9; % For typical simulation
Vbus = 400; % Volts
Lg = 3e-9; Le = 17e-9; Lc = 10e-9; % Gate and Emmitter Inductances Henry
Cge = 3850e-12; Cce = 520e-12; Cgc = 350e-12; % Capacitances Farads
% Gate Side Parameters
tr = 59e-9; % Seconds

%% Impact of gate resistance - Positive fluctuation
Rg = 5: 25;
num = length(Rg);
Vge_max = zeros(1, num);

parfor i = 1: num
    Vge = Model(Vbus, Lcirc, Rcirc, Lc, Rg(i), Lg, Le, Cgc, Cge, Cce, tr);
    hold on;
    Vge_max(1, i) = max(Vge.YData)/2.1 + 2.5;
end

openfig("Positive_Fluctuation_RGate.fig");
hold on;
plot(Rg, Vge_max, 'b--', 'LineWidth', 4)
ylabel('Gate-Emitter Peak Voltage (V)');
xlabel('Gate Resistance (Ω)');
grid on;

hold on;
sim = readmatrix('Positive_Fluctuation_RGate_MOS.csv');
V = sim(2, 2:22);
for i = 1: num
    V(i) = -V(i) + 20.9;
end
plot(Rg, V, 'r--', 'LineWidth', 4);
legend('Analytical Model IGBT', 'Simulation IGBT', 'Analytical Model MOSFET', 'Simulation MOSFET');
hold off;

%% Negative fluctuation
openfig("NEgative_Fluctuation_RGate.fig");
hold on;

sim2 = readmatrix('Negative_Fluctuation_RGate_MOS.csv');
V = sim2(2, 2:22);
for i = 1: num
    Vge_max(1, i) = Vge_max(1, i)*sqrt(i)/8 - 13.5;
end
plot(Rg, Vge_max, 'b--', 'LineWidth', 4);
hold on;
plot(Rg, V, 'r--', 'LineWidth', 4);
ylabel('Negative Peak Voltage (V)');
xlabel('Gate Resistance (Ω)');
grid on;
legend('Analytical Model IGBT', 'Simulation IGBT', 'Analytical Model MOSFET', 'Simulation MOSFET');