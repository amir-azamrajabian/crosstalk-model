%% PSpice_Results_Plotter.m
% =========================================================================
% PSpice Simulation Results Plotter – Crosstalk Parametric Studies
% =========================================================================
%
% PURPOSE:
%   Reads CSV files exported from Cadence PSpice (OrCAD) and plots the
%   peak gate-emitter crosstalk voltage (Vp-GE) as a function of several
%   circuit parameters.  Each section corresponds to one parametric study
%   run in PSpice; the results validate or complement the analytical model.
%
% CSV FILE FORMAT (PSpice export):
%   Row 1  – header / axis label text
%   Row 2  – parameter values (x-axis)
%   Rows 3+ – time-domain waveform samples (not used in peak extraction)
%   The first column (index 1) is the x-axis; columns 2..N are traces.
%
%   Example: sim(1, 2:22) selects 21 peak values for a 21-point sweep.
%
% STUDIES INCLUDED:
%   1. Negative Gate Bias (Vbias) – Resistive load, first pulse
%   2. Power-Loop Inductance (Lcirc) – Peak Vge vs. Lcirc (50–250 nH)
%   3. Snubber Inductance (series-L snubber) – Vge vs. snubber inductance
%   4. Snubber Resistance (RC snubber) – Vge vs. snubber inductance
%   5. Inductive Load Current effect – Peak Vge vs. load current
%   6. Resistive Load Current effect – Peak Vge vs. load current
%
% INPUT CSV FILES REQUIRED (must be in the MATLAB working directory or path):
%   Vbias_Resistive_First_Pulse.csv   (Section 1)
%   L_Circuit_Swing.csv               (Section 2)
%   Snubber_Circuit.csv               (Section 3 – inductive snubber)
%   Snubber_Circuit_R.csv             (Section 4 – resistive snubber)
%   Inductive_Load_Effect.csv         (Section 5)
%   Inductive_Load_Current.csv        (Section 5)
%   Resistive_Load_Effect.csv         (Section 6)
%   Resistive_Load_Current.csv        (Section 6)
%
% COMMENTED SECTIONS:
%   Inductive-load bias studies (Sections marked with %) are preserved for
%   reference but disabled; enable by uncommenting when the corresponding
%   CSV files are available.
%
% RELATED PUBLICATIONS:
%   [C1] A. Azam Rajabian and S. Mohsenzade, "Investigating the Effect of
%        the Power Path Parasitic Inductance on Si-IGBT Crosstalk Using a
%        Comprehensive Model," PEDSTC 2022, pp. 414–419,
%        doi: 10.1109/PEDSTC53976.2022.9767324.
%   [C2] A. Azam Rajabian, S. Mohsenzade, J. Naghibi, and K. Mehran,
%        "Characterization of Si-IGBT Crosstalk with a Concentration on
%        Power Circuit Parasitic Elements and the Device Operation Point,"
%        EPE'22 ECCE Europe, pp. 1–10,
%        doi: 10.1109/EPE22ECCEEurope50083.2022.9907736.
%
% Author:  Amir Azam Rajabian
% Date:    15.03.2025
% Version: 2.0  (refactored with extended documentation)
% =========================================================================

clear; close all; clc;

%% ── Study 1: Effect of Negative Gate Bias (Vbias) ───────────────────────
% A negative gate-emitter bias applied to the passive switch QL raises the
% threshold for false turn-on.  This study sweeps the bias magnitude (0–20 V)
% and records the peak crosstalk voltage during the first pulse commutation.
%
% NOTE: Inductive-load cases are commented out below; uncomment if those
%       CSV files are available.
%
% -- Inductive load (first and second pulses) – DISABLED ─────────────────
% sim_1 = csvread('Vbias_Inductive_First_Pulse.csv',  2);
% sim_2 = csvread('Vbias_Inductive_Second_Pulse.csv', 2);
% V_1 = sim_1(1, 2:17);   % 16-point sweep
% V_2 = sim_2(1, 2:17);
% for i = 1:16
%     V_1(i) = V_1(i) + (i-1);   % Offset correction: PSpice stores delta values
%     V_2(i) = V_2(i) + (i-1);
% end
% figure(1);
% plot(0:15, V_1, 'LineWidth', 4); hold on;
% plot(0:15, V_2, 'LineWidth', 4);
% xlabel('Negative Gate Bias Magnitude (V)');
% ylabel('Peak V_{P-GE} (V)');
% legend('First Pulse','Second Pulse'); grid on;
% -- End disabled inductive section ───────────────────────────────────────

% Resistive load – first pulse (ACTIVE)
sim_3 = csvread('Vbias_Resistive_First_Pulse.csv', 2);  % Skip 2 header rows
V_3   = sim_3(1, 2:22);   % 21 sweep points: Vbias = 0 to 20 V

% Restore absolute peak values: PSpice stores incremental offsets
for i = 1 : 21
    V_3(i) = V_3(i) + (i - 1);  % Add back the bias offset (0, 1, 2, …, 20 V)
end

figure(2);
plot(0:20, V_3, 'b-', 'LineWidth', 4);
xlabel('Negative Gate Bias Magnitude |V_{bias}| (V)');
ylabel('Peak Crosstalk Voltage, V_{P-GE} (V)');
title('Study 1: Effect of Negative Gate Bias – Resistive Load, First Pulse');
grid on;

% Resistive load – second pulse (DISABLED)
% sim_4 = csvread('Vbias_Resistive_Second_Pulse.csv', 2);
% V_4 = sim_4(1, 2:17);

%% ── Study 2: Effect of Power-Loop Stray Inductance (Lcirc) ──────────────
% The total PCB power-loop inductance Lcirc is swept from 50 to 250 nH in
% 5 nH steps (41 points).  As Lcirc increases, the oscillatory energy in
% the commutation loop grows, increasing the Vge crosstalk amplitude beyond
% a certain inductance threshold.
sim_5 = csvread('L_Circuit_Swing.csv', 2);
V_5   = sim_5(1, 2:42);   % 41 sweep points: Lcirc = 50, 55, …, 250 nH

figure(3);
plot(50 : 5 : 250, V_5, 'r-', 'LineWidth', 4);
xlabel('Power-Loop Stray Inductance, L_{circ} (nH)');
ylabel('Peak Crosstalk Voltage, V_{P-GE} (V)');
title('Study 2: Effect of L_{circ} on Crosstalk – PSpice Simulation');
grid on;

%% ── Study 3: Effect of Series-L Snubber on Crosstalk ────────────────────
% A small series inductor inserted in the gate loop (snubber inductance)
% can attenuate the high-frequency displacement currents.  The sweep covers
% 1–20 nH of snubber inductance.
sim_6 = csvread('Snubber_Circuit.csv', 2);
V_6   = sim_6(1, 2:21);   % 20 sweep points

figure(4);
plot(1:20, V_6, 'g-', 'LineWidth', 4);
xlabel('Snubber Inductance (nH)');
ylabel('Peak Crosstalk Voltage, V_{P-GE} (V)');
title('Study 3: Effect of Gate-Loop Series-L Snubber on Crosstalk');
grid on;

%% ── Study 4: Effect of Resistive Snubber (RC) on Crosstalk ──────────────
% An RC snubber (or resistor in series with the snubber inductor) damps the
% LC resonance differently.  This study uses the same inductance axis as
% Study 3 but with a resistor added to the snubber branch.
sim_7 = csvread('Snubber_Circuit_R.csv', 2);
V_7   = sim_7(1, 2:21);   % 20 sweep points

figure(5);
plot(1:20, V_7, 'm-', 'LineWidth', 4);
xlabel('Snubber Branch Inductance (nH)');
ylabel('Peak Crosstalk Voltage, V_{P-GE} (V)');
title('Study 4: Effect of RC Snubber on Crosstalk');
grid on;

%% ── Studies 5 & 6: Effect of Load Current ───────────────────────────────
% Load current determines the initial collector current Ic0 of the active
% switch at turn-on, which affects the dv/dt through the current-dependent
% VCE fall rate.  Higher load current → faster dv/dt → larger Vge spike.

% Study 5: Inductive load (RL)
sim_8  = csvread('Inductive_Load_Effect.csv',   2);  % Peak Vge vs. current
sim_9  = csvread('Inductive_Load_Current.csv',  2);  % Load current values
V_8    = sim_8(1, 2:22);   % 21 current points
I_inductive = sim_9(1, 2:22);

figure(6);
plot(I_inductive, V_8, 'b-', 'LineWidth', 4);
xlabel('Inductive Load Current (A)');
ylabel('Peak Crosstalk Voltage, V_{P-GE} (V)');
title('Study 5: Effect of Load Current (Inductive Load)');
grid on;

% Study 6: Resistive load
sim_10 = csvread('Resistive_Load_Effect.csv',   2);
sim_11 = csvread('Resistive_Load_Current.csv',  2);
V_9    = sim_10(1, 2:19);  % 18 current points
I_resistive = sim_11(1, 2:19);

figure(7);
plot(I_resistive, V_9, 'r-', 'LineWidth', 4);
xlabel('Resistive Load Current (A)');
ylabel('Peak Crosstalk Voltage, V_{P-GE} (V)');
title('Study 6: Effect of Load Current (Resistive Load)');
grid on;
