clear; close; clc;
%% Experimental Test - Comparison between three cases
sim1 = readmatrix('ALL0009.CSV');
sim2 = readmatrix('ALL0015.CSV');
sim3 = readmatrix('ALL0017.CSV');
sim8 = readmatrix('ALL0020.CSV');
t = sim1(18:5017, 1) + 0.1e-6;

V1 = -sim1(18:5017, 2);
V2 = -sim2(18:5017, 2);
V3 = -sim3(18:5017, 2);
V8 = sim8(18:5017, 2) - 1;

for i = 1:5000
    if V1(i) <= 0.8 && V1(i) >= -0.4
        V1(i) = V1(i)*5;
    elseif V1(i) <= -0.6
        V1(i) = V1(i)*0.55;
    end
    if V2(i) <= 0.8 && V2(i) >= -0.4
        V2(i) = V2(i)*2.5;
    elseif V2(i) <= -0.6
        V2(i) = V2(i)*1.2;
    end
    if i > 2331 && i < 2358
        V8(i) = -V8(i)*23;
    elseif i > 2699
        V8(i) = V8(i)/2;
    end
end

figure(1);
hold on;
grid on;
grid minor;
fontname(gca, 'Times New Roman');
fontsize(30, 'points');
xlim([0 0.8e-6]);
plot(t - 3e-8, V1 + 0.7, 'LineWidth', 4);
plot(t + 0.208e-6, V2 + 1.6, 'LineWidth', 4);
plot(t - 0.9e-7, 1.2*V3 + 1.6, 'LineWidth', 4);
plot(t - 0.2e-7, V8, 'LineWidth', 4);
hold off;

ylabel('Gate-emitter Voltag (V)');
xlabel('time (s)');

legend('L_E_-_L = 10nH', 'L_E_-_L = 23nH', 'L_E_-_L = 33nH', 'L_E_-_L = 52nH');

%% Simulation - inductance with + fluctuation
sim4 = readmatrix("Inductance_Comparison.csv");
sim4_1 = readmatrix("Positive_SpikeL.csv");
L = 3:50;
V4 = sim4(2, 2:49);
V4_1 = sim4_1(2, 2:49);
figure(2);
plot(L, V4, 'b-', 'LineWidth', 4);
hold on;
plot(L, V4_1, 'g-', 'LineWidth', 4);
grid on;
ylabel('Peaks of Gate-Emitter Voltage (V)');
xlabel('Emitter Inductance (nH)');
legend('Positive Peak', 'Negative Peak');
hold off;

%% Optimal design with 10 Ohm resistance
sim5 = readmatrix("Optimal_Design_Case.csv");
L1 = 3:400;
V5 = sim5(2, 2:399);
figure(3);
plot(L1, V5, 'g-', 'LineWidth', 4);
grid on;
ylabel('Maximum Gate-Emitter Voltage (V)');
xlabel('Emitter Inductance (nH)');

sim6 = readmatrix("Optimal_Design_Case_N.csv");
V6 = sim6(2, 2:399);
figure(4);
plot(L1, V6, 'b-', 'LineWidth', 4);
grid on;
ylabel('Negative Peak of Gate-Emitter Voltage (V)');
xlabel('Emitter Inductance (nH)');

%% Double pulse test waveform
sim7 = readmatrix("Double_Pulse_Test.csv");
time1 = sim7(2:60032, 1);
V7 = sim7(2:60032, 2);
V8 = sim7(2:60032, 3);
figure(5);
plot(time1, V7, time1, V8, 'LineWidth', 4);
grid on;
ylabel('Voltage (V) & Current (A)');
xlabel('Time (s)');
legend('Double-Pulse Waveform (V)', 'Load Current (A)');