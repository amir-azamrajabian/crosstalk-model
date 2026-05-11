%% VCE_Waveform_Generator.m
% =========================================================================
% Piecewise Collector-Emitter Voltage Waveform Generator (for PSpice Input)
% =========================================================================
%
% PURPOSE:
%   Constructs a piecewise-analytical approximation of the high-side switch
%   VCE(t) waveform during a turn-on transient and exports it as both a
%   plain-text file (for PSpice PWL source import) and an Excel file (for
%   documentation/post-processing).
%
% PHYSICAL CONTEXT:
%   When the high-side switch QH turns on in a half-bridge, its VCE drops
%   from the DC-link voltage (Vbus ≈ 400 V) to near zero over several
%   nanoseconds.  The exact waveform shape drives the crosstalk on the
%   low-side switch and must be accurately represented in PSpice.
%
%   The waveform is divided into four piecewise segments extracted by
%   curve-fitting the measured or simulated VCE trace:
%
%   Segment | Time offset (from t0)  | Model         | Description
%   --------|------------------------|---------------|---------------------
%     V1    | 0     → 21 ns          | 2nd-order poly| Initial fast drop
%     V2    | 21 ns → 33.9 ns        | Linear        | Miller plateau region
%     V3    | 33.9 ns → 73.9 ns      | Linear        | Slow tail fall
%     V4    | 73.9 ns → ∞            | Zero          | Fully on (VCE ≈ 0)
%
%   The polynomial/linear coefficients in each segment were fitted to
%   measured oscilloscope data from the half-bridge test bench.
%   Re-fit the coefficients if replacing the IGBT or changing Vbus/Iload.
%
% INPUT FILE:
%   VCE_First_Pulse.csv  – Raw PSpice/oscilloscope VCE trace (two columns:
%                          time [s], voltage [V]).  The script reads the
%                          pre-switching steady state from this file and
%                          appends the analytical switching transient.
%
% OUTPUT FILES:
%   Input_Values.txt   – PWL (piecewise-linear) source file for PSpice.
%                        Format per row: <time (35 decimals)>  <voltage (25 decimals)>
%   Input_Values.xlsx  – Same data in Excel, for plotting and archiving.
%
% HOW TO USE IN PSPICE:
%   1. Run this script to generate Input_Values.txt.
%   2. In OrCAD PSpice, place a VPWL (piecewise-linear voltage source).
%   3. Set the FILE parameter to the path of Input_Values.txt.
%   4. PSpice will interpolate between the (time, voltage) pairs.
%
% NOTES:
%   - t0 = 4.0226 µs is the switch turn-on instant identified from the CSV.
%   - Coefficients must be re-extracted if the device, load, or gate
%     resistance changes.  Use MATLAB's Curve Fitting Toolbox for re-fitting.
%   - The data from VCE_First_Pulse.csv covers the off-state; the script
%     appends 50 extra points at Vbus = 400 V to bridge the delay caused
%     by the gate resistance before switching begins.
%
% RELATED PUBLICATIONS:
%   [C2] A. Azam Rajabian, S. Mohsenzade, J. Naghibi, and K. Mehran,
%        "Characterization of Si-IGBT Crosstalk with a Concentration on
%        Power Circuit Parasitic Elements and the Device Operation Point,"
%        EPE'22 ECCE Europe, pp. 1–10,
%        doi: 10.1109/EPE22ECCEEurope50083.2022.9907736.
%   [TPEL] A. Azam Rajabian and S. Mohsenzade, IEEE Trans. Power Electron.
%           (In Preparation). (Extended piecewise input model)
%
% Author:  Amir Azam Rajabian
% Date:    15.03.2025
% Version: 2.0  (refactored with extended documentation)
% =========================================================================

clear; close all; clc;

%% ── 1. Read Pre-Switching Steady-State from PSpice CSV ──────────────────
% The CSV contains the full simulation time vector and VCE during the
% off-state (VCE ≈ Vbus = 400 V) up to the moment of turn-on.
sim = readmatrix('VCE_First_Pulse.csv');
t0  = sim(:, 1);    % [s]  Time vector (absolute)
V0  = sim(:, 2);    % [V]  Collector-emitter voltage

%% ── 2. Bridge the Gate-Resistance Delay Region ───────────────────────────
% Due to the Rg-Ciss time constant, VCE remains flat at Vbus for a short
% interval after the gate drive fires.  This block appends 50 additional
% sample points at V = 400 V to maintain continuity.
t0_1 = 4.0226e-6 + (1e-10 : 1e-10 : 2.10e-8);  % 210 extra points
for i = 1 : length(t0_1)
    t0(40022 + i) = t0_1(i);
    V0(40022 + i) = 403.4897;  % [V]  VCE value just before switching
end

%% ── 3. Segment 1 – Second-Order Polynomial Drop (0 → 21 ns) ─────────────
% The initial rapid fall of VCE from Vbus follows a parabolic trajectory
% driven by the constant gate charging current through Cgc.
% Fit: V(t) = a2*(t - t0)^2 + a1*(t - t0) + a0
%   a2 =  1.8191e17   [V/s^2]  (curvature)
%   a1 = -1.1214e10   [V/s]    (initial slope)
%   a0 =  403.4897    [V]      (initial VCE at switching instant)
t_switch = 4.0226e-6;   % [s]  Turn-on instant (from CSV inspection)

t1 = t_switch + (0 : 1e-10 : 2.10e-8);      % 0 to 21 ns after turn-on
V1 =  1.8191e17 .* (t1 - t_switch).^2 ...
    - 1.1214e10 .* (t1 - t_switch) ...
    + 403.4897;

%% ── 4. Segment 2 – Linear Drop (21 ns → 33.9 ns) ────────────────────────
% During the Miller plateau, the gate voltage is approximately constant and
% Cgc discharges linearly, giving a linear VCE ramp.
% Fit: V(t) = a1*(t - t_switch) + a0
%   a1 = -1.8123e10  [V/s]
%   a0 =  628.80101  [V]
t2 = t_switch + (2.10e-8 : 1e-10 : 3.390e-8);  % 21 ns to 33.9 ns
V2 = -1.8123e10 .* (t2 - t_switch) + 628.80101;

%% ── 5. Segment 3 – Slow Linear Tail Fall (33.9 ns → 73.9 ns) ────────────
% After the Miller plateau, VCE continues to fall slowly as the device
% fully saturates.  The slope is much shallower than segment 2.
% Fit: V(t) = a1*(t - t_switch) + a0
%   a1 = -3.601897e8  [V/s]
%   a0 =  26.64174    [V]
t3 = t_switch + (3.39e-8 : 1e-10 : 7.39e-8);   % 33.9 ns to 73.9 ns
V3 = -3.601896703e8 .* (t3 - t_switch) + 26.64173981;

%% ── 6. Segment 4 – Fully On State (VCE ≈ 0 V) ───────────────────────────
% Once the device is fully saturated, VCE ≈ VCE(sat) ≈ 0 V.
% (The actual saturation voltage ~2 V is neglected for simplicity.)
t4 = t_switch + (7.39e-8 : 1e-10 : 100e-8);    % 73.9 ns onward
V4 = zeros(1, length(t4));

%% ── 7. Visualise the Complete Piecewise Waveform ────────────────────────
figure(1);
plot(t0, V0, 'b-', ...
     t1, V1, 'b-', ...
     t2, V2, 'b-', ...
     t3, V3, 'b-', ...
     t4, V4, 'b-', 'LineWidth', 4);
grid on;
title('Piecewise V_{CE} Waveform of High-Side Switch During Turn-On');
xlabel('Time (s)');
ylabel('Collector-Emitter Voltage, V_{CE} (V)');

%% ── 8. Export to PSpice Text File (PWL format) ───────────────────────────
% Each row: <time>  <voltage>  with high precision for PSpice interpolation.
dataPoints = [t0' t1 t2 t3 t4; V0' V1 V2 V3 V4];

fileID = fopen('Input_Values.txt', 'w');
if fileID == -1
    error('Could not open Input_Values.txt for writing. Check file permissions.');
end
fprintf(fileID, '%10.35f %30.25f\n', dataPoints);
fclose(fileID);
fprintf('PSpice PWL file written: Input_Values.txt (%d data points)\n', size(dataPoints, 2));

%% ── 9. Export to Excel ───────────────────────────────────────────────────
writematrix(dataPoints', 'Input_Values.xlsx');
fprintf('Excel file written: Input_Values.xlsx\n');
