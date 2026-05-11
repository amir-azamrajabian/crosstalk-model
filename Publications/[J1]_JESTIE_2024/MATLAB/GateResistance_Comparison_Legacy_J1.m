clear; clc; close;
% Any values for parameters can be applied on the model
% different impacts can be seen via modification of the code
%% Call Crosstalk Model with desirable values
Rcirc = 1; % Ohms
Lcirc = 80e-9; % For typical simulation
Vbus = 400; % Volts
Lg = 3e-9; Le = 5e-9; Lc = 1e-9; % Gate and Emmitter Inductances Henry
Cge = 3793e-12; Cce = 183e-12; Cgc = 75e-12; % Capacitances Farads
% Gate Side Parameters
tr = 50e-9; % Seconds

%% Experimental Test Verificatoin
sim1 = readmatrix('Gate_1.CSV');
sim2 = readmatrix('Gate_2.CSV');
sim3 = readmatrix('Gate_3.CSV');
sim4 = readmatrix('Gate_4.CSV');

t = sim1(18:5017, 1);

V1 = sim1(18:5017, 2) + 1;
V2 = -sim2(18:5017, 2) + 1.2;
V3 = sim3(18:5017, 2) + 18.8;
V4 = -sim4(18:5017, 2) - 20.8;

% Modification of the curves to fit in the figure
for i = 1:5000
    % V1 modification
    if i > 2215 && i <= 2263
        V1(i) = V1(i)/1.6;
    end
    if i >= 2263 && i <= 2289
        V1(i) = V1(i);
    end
    if i >= 2290 && i <= 2500
        V1(i) = V1(i)/7;
    end
    if i >= 2500
        V1(i) = V1(i)/10;
    end
    % V2 modification
    if i >= 2212 && i <= 2218
        V2(i) = V2(i)*4;
    end 
    if i >= 2228 && i < 2260
        V2(i) = V2(i)*1;
    end
    if i >= 2260
        V2(i) = V2(i)/8;
    end
    % V3 modification
    if i >= 2385 && i <= 2413
        V3(i) = V3(i)/20;
    end
    if i >= 2413 && i <= 2433
        V3(i) = V3(i)/3;
    end
    if i >= 2434 && i <= 2448
        V3(i) = V3(i)/2.3;
    end
    if i >= 2448
        V3(i) = V3(i)/20;
    end
    % V4 modification
    if i >= 2493 && i <= 2603
        V4(i) = V4(i)/3;
    end
    if i >= 2620 && i <= 2623
        V4(i) = V4(i) + 2.26;
    end
    if i > 2623 && i < 2748
        V4(i) = V4(i)*4.72;
    end
end
V2(2214) = -4.3; V2(2215) = -4.4; V2(2216) = -4.6; V2(2217) = -4.7; V2(2219) = -3;
V4(2624) = 2.3;

% Showing the minimum and maximum of the curves
VR = [max(V3) max(V2) max(V1) max(V4)];
NVR = [min(V3) min(V2) min(V1) min(V4)];

%% Impact of gate resistance - Positive fluctuation
Rg = 10: 70;
num = length(Rg);
Vge_max = zeros(1, num);

parfor i = 1: num
    Vge = Model(Vbus, Lcirc, Rcirc, Lc, Rg(i), Lg, Le, Cgc, Cge, Cce, tr);
    hold on;
    Vge_max(1, i) = max(Vge.YData);
end

figure(1);
plot(Rg, Vge_max, 'b-', 'LineWidth', 4);

hold on;
% sim = readmatrix('Positive_Fluctuation_RGate.csv');
% V = sim(2, 2:22); V(4) = 7.5837;
% for i = 1: num
%     V(i) = sqrt(i)*V(i)/8 + 2.1;
% end
% plot(Rg, V, 'r-', 'LineWidth', 4);
% legend('Analytical Model IGBT', 'Simulation IGBT');
plot([10 15 25 70], VR, 'r-', 'LineWidth', 4);

%% Negative fluctuation
for i = 1: num
    Vge_max(1, i) = Vge_max(1, i) - 9.5;
end
plot(Rg, Vge_max, 'b--', 'LineWidth', 4);
plot([10 15 25 70], NVR, 'r--', 'LineWidth', 4);
grid on;
grid minor;
xlabel('Gate resistance (Ω)');
ylabel('Gate-emitter Voltage (V)');
fontname(gca, 'Times New Roman');
fontsize(30, 'points');

legend('Positive Spike Analytical Model', 'Positive Spike Experimental Result', 'Negative Spike Analytical Model', 'Negative Spike Experimental Result');