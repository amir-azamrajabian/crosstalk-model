clc; clear; close;
%% Call Crosstalk Model with desirable values
Rcirc = 1; % Ohms
Lcirc = 80e-9; % For typical simulation
Vbus = 400; % Volts
Lg = 3e-9; Le = 4e-9; Lc = 1e-9; % Gate and Emmitter Inductances Henry
Cge = 3793e-12; Cce = 183e-12; Cgc = 75e-12; % Capacitances Farads
% Gate Side Parameters
tr = 50e-9; % Seconds
Rg = 10;
t = 0:3e-6/3006:3e-6;

sim1 = readmatrix('OldModel.csv');
V1 = sim1(:, 2);
sim2 = readmatrix('Jahdi_Model.csv');
V2 = sim2(:, 2);

plot(0:3e-6/3021:3e-6, V2/1.5, 'g-', 'LineWidth', 4);
hold on;
Vge = Model(Vbus, Lcirc, Rcirc, Lc, Rg, Lg, Le, Cgc, Cge, Cce, tr);
plot(t, V1/1.35, 'r-', 'LineWidth', 4);

grid on;
xlabel('Time (s)');
ylabel('Gate-emitter Voltage (V)');
fontname(gca, 'Times New Roman');
fontsize(30, 'points');

legend('Model in [20]', 'Model in [21]', 'Proposed Model');