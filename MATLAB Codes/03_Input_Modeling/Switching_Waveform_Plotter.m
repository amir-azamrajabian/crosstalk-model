%% Switching_Waveform_Plotter.m
% =========================================================================
% IGBT Switching Waveform Plotter – Collector Current and VCE Overlay
% =========================================================================
%
% PURPOSE:
%   Reads two CSV files from the PSpice simulation of the half-bridge
%   circuit and overlays the IGBT collector-emitter current (I_IGBT) and
%   the collector-emitter voltage (VCE_High) on the same time axis.
%   A zoomed view is extracted to focus on the switching transient.
%
% PHYSICAL CONTEXT:
%   During a turn-on transient, the collector current Ic rises while VCE
%   falls.  The crossover of these two waveforms determines the switching
%   energy loss (turn-on loss area = ∫ Vce * Ic dt).  This plot is used to:
%     1. Identify the rise time tr (used in the analytical model).
%     2. Verify the device operating point (peak Ic, final VCE).
%     3. Calibrate the piecewise VCE model in VCE_Waveform_Generator.m.
%
% INPUT FILES:
%   I_IGBT.csv      – Two-column CSV: [time(s), collector current(A)]
%   VCE_High.csv    – Two-column CSV: [time(s), VCE(V)]
%   Both files must share the same time vector (exported from the same
%   PSpice simulation run).
%
% PROCESSING:
%   - Time is shifted so t=0 corresponds to 4 µs before the switching event
%     (t0 = 4 µs is the nominal gate trigger time in the PSpice netlist).
%   - INDEX_1 (= 40) and INDEX_2 (= peak current index) define the window
%     of interest for the zoomed figure.  Adjust INDEX_1 if the simulation
%     time resolution changes.
%
% OUTPUTS:
%   Figure 1 – Full waveform: Ic(t) and VCE(t) on same axes, time-shifted
%   Figure 2 – Zoomed switching transient: Ic and VCE from INDEX_1 to peak
%
% NOTES:
%   - The ylabel "Collector Emitter Voltage (V) & Current (A)" is correct
%     for the dual-axis overlay plot (no secondary y-axis needed since the
%     peak Ic and Vbus are comparable in magnitude at the chosen scales).
%   - INDEX_2 is found as the index of max(I), which corresponds to the
%     current overshoot peak (diode reverse recovery phenomenon).
%   - t_prime is shifted by 2.2e-8 s (22 ns) to align the zero crossing
%     with the common reference in published figures.
%
% RELATED PUBLICATIONS:
%   [C1] A. Azam Rajabian and S. Mohsenzade, "Investigating the Effect of
%        the Power Path Parasitic Inductance on Si-IGBT Crosstalk Using a
%        Comprehensive Model," PEDSTC 2022, doi: 10.1109/PEDSTC53976.2022.9767324.
%   [TPEL] A. Azam Rajabian and S. Mohsenzade, IEEE Trans. Power Electron.
%           (In Preparation). (Switching waveform characterisation)
%
% Author:  Amir Azam Rajabian
% Date:    15.03.2025
% Version: 2.0  (refactored with extended documentation)
% =========================================================================

clear; close all; clc;

%% ── 1. Load Collector Current Waveform ───────────────────────────────────
sim_1 = readmatrix('I_IGBT.csv');

% Shift time so the switching transient reference is at t = 0.
% The PSpice simulation has the gate trigger at exactly t = 4 µs.
t = sim_1(:, 1) - 4e-6;   % [s]  Time vector (re-zeroed)
I = sim_1(:, 2);           % [A]  Collector current

%% ── 2. Load Collector-Emitter Voltage Waveform ───────────────────────────
sim_2  = readmatrix('VCE_High.csv');
VCE    = sim_2(:, 2);      % [V]  Collector-emitter voltage of high-side IGBT
% Note: sim_2 shares the same time vector as sim_1 (same PSpice run).

%% ── 3. Figure 1 – Full Waveform Overlay ─────────────────────────────────
figure(1);
plot(t, I,   'b-', 'LineWidth', 4);  % Collector current
hold on;
plot(t, VCE, 'r-', 'LineWidth', 4);  % Collector-emitter voltage
xlabel('Time (s)');
ylabel('Collector-Emitter Voltage (V)  &  Collector Current (A)');
title('Full Switching Waveform – IGBT Turn-On (PSpice)');
legend('I_C (A)', 'V_{CE} (V)');
grid on;

%% ── 4. Define Zoomed Switching-Transient Window ──────────────────────────
% INDEX_1: start of the relevant transient (skip pre-switching steady state)
%   Value 40 corresponds to approximately 4 ns after t=0 at 0.1 ns/sample.
%   Adjust if the PSpice time step differs.
INDEX_1 = 40;

% INDEX_2: end of the transient window (current overshoot peak)
%   This peak is caused by diode reverse-recovery current flowing through
%   the freewheeling diode when the high-side IGBT turns on.
INDEX_2 = find(I == max(I), 1);

% Extract the zoomed sub-arrays
t_prime   = t(INDEX_1 : INDEX_2) - 2.2e-8;  % [s]  Fine-align to published figures
I_prime   = I(INDEX_1 : INDEX_2);            % [A]
VCE_prime = VCE(INDEX_1 : INDEX_2);          % [V]

%% ── 5. Figure 2 – Zoomed Turn-On Transient ──────────────────────────────
figure(2);
plot(t_prime, I_prime,   'b-', 'LineWidth', 4);
hold on;
plot(t_prime, VCE_prime, 'r-', 'LineWidth', 4);
xlabel('Time (s)');
ylabel('Collector-Emitter Voltage (V)  &  Collector Current (A)');
title('Zoomed Turn-On Switching Transient (Diode Reverse-Recovery Region)');
legend('I_C (A)', 'V_{CE} (V)');
grid on;

fprintf('Switching window: INDEX_1=%d, INDEX_2=%d (%.1f ns duration)\n', ...
        INDEX_1, INDEX_2, (INDEX_2 - INDEX_1) * 1e10);
fprintf('Peak collector current: %.2f A\n', max(I_prime));
fprintf('Initial VCE: %.1f V → Final VCE: %.1f V\n', VCE_prime(1), VCE_prime(end));
