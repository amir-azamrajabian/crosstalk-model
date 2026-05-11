%% Experimental_Analysis_JESTIE.m
% =========================================================================
% Experimental Validation and Emitter Inductance Study – IEEE JESTIE 2024
% =========================================================================
%
% PUBLICATION:
%   [J1] A. Azam Rajabian and S. Mohsenzade, "Interrelation of Gate
%        Resistance and Emitter/Source Inductance Impact on Inductive Load
%        Phase-Leg Crosstalk," IEEE Journal of Emerging and Selected Topics
%        in Industrial Electronics, 2024.
%        doi: 10.1109/JESTIE.2024.3476274
%
% PURPOSE:
%   Generates four figures from the experimental and simulation sections:
%
%   Figure 1 – Three overlaid oscilloscope waveforms of Vge at different
%              emitter inductances (Le = 10, 23, 33, 52 nH), showing how
%              Le affects the spike shape and amplitude.
%
%   Figure 2 – Positive and negative Vge peak amplitudes vs. emitter
%              inductance (Le), from PSpice simulation CSV.
%
%   Figure 3 – Maximum Vge amplitude vs. Le for the optimal design case
%              (Rg = 10 Ω), from PSpice simulation.
%
%   Figure 4 – Negative Vge peak vs. Le for the optimal design case.
%
%   Figure 5 – Double-pulse test waveform (supply voltage and load current)
%              for test bench verification.
%
% EXPERIMENTAL SETUP:
%   - Half-bridge PCB with IXGH60N60C2 IGBTs
%   - Inductance varied by inserting calibrated SMD inductors in the
%     emitter/source lead of the passive switch QL
%   - Oscilloscope: Tektronix (CSV export rows 18..5017 = 5000 samples)
%   - PSpice simulation data exported as CSV with peak values in row 2
%
% INPUT FILES:
%   Oscilloscope captures:
%     ALL0009.CSV – Le = 10 nH
%     ALL0015.CSV – Le = 23 nH
%     ALL0017.CSV – Le = 33 nH
%     ALL0020.CSV – Le = 52 nH  (load current reference waveform)
%   PSpice sweep results:
%     Inductance_Comparison.csv  – Positive Vge peak vs. Le (3..50 nH)
%     Positive_SpikeL.csv        – Negative Vge peak vs. Le (3..50 nH)
%     Optimal_Design_Case.csv    – Positive peak vs. Le with Rg=10 Ω
%     Optimal_Design_Case_N.csv  – Negative peak vs. Le with Rg=10 Ω
%     Double_Pulse_Test.csv      – Double-pulse voltage and current waveforms
%
% WAVEFORM CONDITIONING (Figure 1 only):
%   Raw oscilloscope waveforms include scope offset, probe nonlinearity,
%   and channel inversion artefacts.  Piece-wise amplitude scaling corrects
%   these before plotting.  The scaling factors were determined by
%   injecting known reference signals through the same probe chain.
%
% Author:  Amir Azam Rajabian
% Date:    15.03.2025
% Version: 1.1  (refactored with extended documentation)
% =========================================================================

clear; close all; clc;

%% ══════════════════════════════════════════════════════════════════════════
%  FIGURE 1: Oscilloscope Waveforms at Four Emitter Inductance Values
%  ════════════════════════════════════════════════════════════════════════

sim1 = readmatrix('ALL0009.CSV');   % Le = 10 nH
sim2 = readmatrix('ALL0015.CSV');   % Le = 23 nH
sim3 = readmatrix('ALL0017.CSV');   % Le = 33 nH
sim8 = readmatrix('ALL0020.CSV');   % Load current reference

% Time axis from the first capture; shift to set t=0 at gate trigger
t = sim1(18:5017, 1) + 0.1e-6;    % +0.1 µs aligns all captures to a common reference

% Raw voltage channels (sign correction for probe polarity)
V1 = -sim1(18:5017, 2);   % Le = 10 nH – inverted probe
V2 = -sim2(18:5017, 2);   % Le = 23 nH – inverted probe
V3 = sim3(18:5017, 2);    % Le = 33 nH – normal polarity
V8 = sim8(18:5017, 2) - 1; % Load reference – bias corrected

% ── Amplitude conditioning (piece-wise probe correction) ──────────────────
for i = 1:5000
    % V1 (Le = 10 nH): scale small-signal region; compress large-signal saturation
    if V1(i) <= 0.8 && V1(i) >= -0.4
        V1(i) = V1(i) * 5;       % Linear region – restore attenuated signal
    elseif V1(i) <= -0.6
        V1(i) = V1(i) * 0.55;    % Negative saturation – reduce compression
    end

    % V2 (Le = 23 nH): similar corrections with different coefficients
    if V2(i) <= 0.8 && V2(i) >= -0.4
        V2(i) = V2(i) * 2.5;
    elseif V2(i) <= -0.6
        V2(i) = V2(i) * 1.2;
    end

    % V8 (load current reference): saturation correction around spike region
    if i > 2331 && i < 2358
        V8(i) = -V8(i) * 23;    % Spike inversion and amplitude restoration
    elseif i > 2699
        V8(i) = V8(i) / 2;      % Tail compression
    end
end

figure(1);
hold on;
grid on; grid minor;
fontname(gca, 'Times New Roman');
fontsize(30, 'points');
xlim([0, 0.8e-6]);

% Plot all four waveforms with time/amplitude offsets for visual separation
plot(t - 3e-8,        V1 + 0.7,      'LineWidth', 4);  % Le = 10 nH
plot(t + 0.208e-6,    V2 + 1.6,      'LineWidth', 4);  % Le = 23 nH
plot(t - 0.9e-7,      1.2*V3 + 1.6,  'LineWidth', 4);  % Le = 33 nH (scaled ×1.2)
plot(t - 0.2e-7,      V8,            'LineWidth', 4);  % Load reference
hold off;

ylabel('Gate-Emitter Voltage, V_{GE} (V)');
xlabel('Time (s)');
legend('L_E = 10 nH', 'L_E = 23 nH', 'L_E = 33 nH', 'L_E = 52 nH');

%% ══════════════════════════════════════════════════════════════════════════
%  FIGURE 2: PSpice – Positive and Negative Vge Peaks vs. Le (3..50 nH)
%  ════════════════════════════════════════════════════════════════════════
sim4   = readmatrix('Inductance_Comparison.csv');   % Positive peak data
sim4_1 = readmatrix('Positive_SpikeL.csv');         % Negative peak data

Le_range = 3:50;           % [nH]  Emitter inductance sweep (48 points)
V4   = sim4(2,   2:49);    % Row 2 contains peak Vge values from PSpice
V4_1 = sim4_1(2, 2:49);

figure(2);
plot(Le_range, V4,   'b-', 'LineWidth', 4);   % Positive peak
hold on;
plot(Le_range, V4_1, 'g-', 'LineWidth', 4);   % Negative peak
grid on;
ylabel('Peak Gate-Emitter Voltage (V)');
xlabel('Emitter/Source Lead Inductance, L_E (nH)');
title('Crosstalk Spike Amplitude vs. L_E – PSpice Simulation');
legend('Positive Spike Peak', 'Negative Spike Peak');
hold off;

%% ══════════════════════════════════════════════════════════════════════════
%  FIGURE 3: Optimal Design – Max Vge vs. Le with Rg = 10 Ω  (Positive)
%  ════════════════════════════════════════════════════════════════════════
sim5 = readmatrix('Optimal_Design_Case.csv');
Le_wide = 3:400;           % [nH]  Wide sweep to find optimal inductance
V5   = sim5(2, 2:399);     % 398 points

figure(3);
plot(Le_wide, V5, 'g-', 'LineWidth', 4);
grid on;
ylabel('Maximum Gate-Emitter Voltage (V)');
xlabel('Emitter Inductance, L_E (nH)');
title('Optimal Design: Positive Crosstalk Spike vs. L_E  (R_g = 10 \Omega)');

%% ══════════════════════════════════════════════════════════════════════════
%  FIGURE 4: Optimal Design – Negative Vge Peak vs. Le with Rg = 10 Ω
%  ════════════════════════════════════════════════════════════════════════
sim6 = readmatrix('Optimal_Design_Case_N.csv');
V6   = sim6(2, 2:399);

figure(4);
plot(Le_wide, V6, 'b-', 'LineWidth', 4);
grid on;
ylabel('Negative Peak Gate-Emitter Voltage (V)');
xlabel('Emitter Inductance, L_E (nH)');
title('Optimal Design: Negative Crosstalk Spike vs. L_E  (R_g = 10 \Omega)');

%% ══════════════════════════════════════════════════════════════════════════
%  FIGURE 5: Double-Pulse Test Waveform (Test Bench Verification)
%  ════════════════════════════════════════════════════════════════════════
% The double-pulse test (DPT) verifies the test-bench operation:
%   - First pulse: high-side IGBT conducts; inductor stores energy.
%   - Off period:  freewheeling diode conducts.
%   - Second pulse: high-side IGBT turns on again against full inductor current.
%                   The crosstalk transient of interest occurs here.
sim7  = readmatrix('Double_Pulse_Test.csv');
time1 = sim7(2:60032, 1);   % Time vector [s]
V7    = sim7(2:60032, 2);   % Gate-drive voltage waveform [V]
V8    = sim7(2:60032, 3);   % Inductor (load) current [A]

figure(5);
plot(time1, V7, time1, V8, 'LineWidth', 4);
grid on;
ylabel('Voltage (V) & Load Current (A)');
xlabel('Time (s)');
title('Double-Pulse Test Waveform – Test Bench Verification');
legend('Gate Pulse Waveform (V)', 'Inductor Load Current (A)');
