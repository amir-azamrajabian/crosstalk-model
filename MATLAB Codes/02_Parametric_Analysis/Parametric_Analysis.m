%% Parametric_Analysis.m
% =========================================================================
% Parametric Sweep Analysis for the Phase-Leg Crosstalk Model
% =========================================================================
%
% PURPOSE:
%   Evaluates the analytical crosstalk model (CrosstalkModel.m) over ranges
%   of three key design parameters and plots the resulting peak
%   gate-emitter voltage (Vge_peak) vs. each swept variable:
%
%     Study 1 – Power-loop stray inductance  Lcirc  (60–320 nH)
%     Study 2 – DC-link bus voltage          Vbus   (100–650 V)
%     Study 3 – Gate-drive resistance        Rg     (3–25 Ω)
%
%   These three studies directly correspond to the parametric analyses
%   presented in the associated IEEE publications (see references below).
%
% HOW IT WORKS:
%   For each parameter point, CrosstalkModel.m is called to compute the
%   full time-domain Vge waveform.  The peak value is extracted from the
%   plot handle's YData property.  MATLAB's parfor is used to distribute
%   calls across available CPU cores, dramatically reducing total run time
%   for large sweeps.
%
% BASELINE PARAMETERS (held fixed unless swept):
%   Vbus  = 400 V     Rcirc = 1 Ω       Lg = 3 nH
%   Lcirc = 180 nH    Lc    = 1 nH      Le = 5 nH
%   Rg    = 20 Ω      Cge   = 3793 pF   tr = 50 ns
%                     Cce   = 183 pF
%                     Cgc   = 75 pF
%
% NOTE ON Cgc IN STUDY 2 (Vbus sweep):
%   The gate-collector capacitance is voltage-dependent (nonlinear).  In
%   Study 2, Cgc is updated at each Vbus point using the depletion
%   approximation:  Cgc = 53.75 pF * sqrt(25 / Vbus).
%   This scaling was calibrated against the IXGH60N60C2 datasheet
%   (see CGC_Capacitance_Model.m for the full derivation).
%
% DEPENDENCIES:
%   CrosstalkModel.m, NodeEquationSolver.m  – must be on the MATLAB path.
%   Recommended: add the 01_Core_Model folder to the path:
%     addpath(fullfile(fileparts(mfilename('fullpath')), '..', '01_Core_Model'))
%
% OUTPUTS:
%   Figure 1 – Peak Vge vs. Lcirc
%   Figure 2 – Peak Vge vs. Vbus
%   Figure 3 – Peak Vge vs. Rg
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
%   [J1] A. Azam Rajabian and S. Mohsenzade, "Interrelation of Gate
%        Resistance and Emitter/Source Inductance Impact on Inductive Load
%        Phase-Leg Crosstalk," IEEE JESTIE 2024,
%        doi: 10.1109/JESTIE.2024.3476274.
%
% Author:  Amir Azam Rajabian
% Date:    15.03.2025
% Version: 2.0
% =========================================================================

clear; clc;

% ── Add the core model to the path ────────────────────────────────────────
% Adjust this relative path if the folder structure changes.
addpath(fullfile(fileparts(mfilename('fullpath')), '..', '01_Core_Model'));

%% ── Baseline Circuit Parameters (Fixed Unless Swept) ────────────────────
Rcirc = 1;          % [Ω]   Stray resistance of the power-loop trace
Lg    = 3e-9;       % [H]   Gate-lead parasitic inductance
Le    = 5e-9;       % [H]   Emitter-lead parasitic inductance
Lc    = 1e-9;       % [H]   Collector-lead parasitic inductance
Cge   = 3793e-12;   % [F]   Gate-emitter capacitance  (IXGH60N60C2 datasheet)
Cce   = 183e-12;    % [F]   Collector-emitter capacitance
Cgc   = 75e-12;     % [F]   Gate-collector (Miller) capacitance (average)
tr    = 50e-9;      % [s]   High-side switch VCE rise time
Rg    = 20;         % [Ω]   Gate-drive resistance (baseline)

%% ═══════════════════════════════════════════════════════════════════════
%  STUDY 1: Impact of Power-Loop Stray Inductance (Lcirc)
%  -----------------------------------------------------------------------
%  Physical interpretation: Higher Lcirc slows the current rate-of-change
%  di/dt during commutation, which reduces the EMF driving displacement
%  current through Cgc.  However, beyond a certain Lcirc the oscillatory
%  energy stored in the loop inductance can amplify the Vge spike.
%  The net effect is nonlinear and is captured by the full model.
% ═══════════════════════════════════════════════════════════════════════

Vbus_fixed   = 400;                     % [V]   DC-link voltage (fixed)
Lcirc_values = 60e-9 : 5e-9 : 320e-9;  % [H]   Sweep range
numPoints    = numel(Lcirc_values);
Vge_max_Lcirc = zeros(1, numPoints);

% Open a scratch figure to receive CrosstalkModel plot handles (parfor
% requires a pre-existing figure before entering the parallel loop).
figure(1);
parfor idx = 1 : numPoints
    % Call the full analytical model for this Lcirc value
    hPlot = CrosstalkModel(Vbus_fixed, Lcirc_values(idx), Rcirc, Lc, ...
                           Rg, Lg, Le, Cgc, Cge, Cce, tr);
    % Extract the peak Vge from the plot object's Y-data array
    Vge_max_Lcirc(idx) = max(hPlot.YData);
end
close(1);  % Discard the scratch figure

% ── Plot results ──────────────────────────────────────────────────────────
figure(1);
plot(Lcirc_values * 1e9, Vge_max_Lcirc, 'b-', 'LineWidth', 4);
xlabel('Power-Loop Stray Inductance, L_{circ} (nH)');
ylabel('Peak Gate-Emitter Voltage, \hat{V}_{GE} (V)');
title('Study 1: Effect of L_{circ} on Crosstalk Spike Amplitude');
grid on; grid minor;

%% ═══════════════════════════════════════════════════════════════════════
%  STUDY 2: Impact of DC-Link Bus Voltage (Vbus)
%  -----------------------------------------------------------------------
%  Physical interpretation: Higher Vbus increases the dv/dt of the
%  high-side switch VCE, directly increasing the displacement current
%  through Cgc.  The nonlinear Cgc(Vbus) dependency partially counteracts
%  this: at high voltage, Cgc is smaller (depletion layer is wider).
%  Both effects are included here.
% ═══════════════════════════════════════════════════════════════════════

Lcirc_fixed = 180e-9;           % [H]  Fixed stray inductance
Vbus_values = 100 : 10 : 650;   % [V]  DC-link voltage sweep
numPoints   = numel(Vbus_values);
Vge_max_Vbus = zeros(1, numPoints);

figure(2);
parfor idx = 1 : numPoints
    % Voltage-dependent Cgc: depletion approximation calibrated to datasheet.
    % Reference voltage 25 V corresponds to the Crss measurement condition.
    Cgc_dynamic = 53.75e-12 * sqrt(25 / Vbus_values(idx));

    hPlot = CrosstalkModel(Vbus_values(idx), Lcirc_fixed, Rcirc, Lc, ...
                           Rg, Lg, Le, Cgc_dynamic, Cge, Cce, tr);
    Vge_max_Vbus(idx) = max(hPlot.YData);
end
close(2);

% ── Plot results ──────────────────────────────────────────────────────────
figure(2);
plot(Vbus_values, Vge_max_Vbus, 'r-', 'LineWidth', 4);
xlabel('DC-Link Bus Voltage, V_{bus} (V)');
ylabel('Peak Gate-Emitter Voltage, \hat{V}_{GE} (V)');
title('Study 2: Effect of V_{bus} on Crosstalk Spike Amplitude');
grid on; grid minor;

%% ═══════════════════════════════════════════════════════════════════════
%  STUDY 3: Impact of Gate-Drive Resistance (Rg)
%  -----------------------------------------------------------------------
%  Physical interpretation: Rg damps the LC resonance formed by the gate
%  loop inductances (Lg + Le) and the input capacitances (Cge, Cgc).
%  Increasing Rg reduces the positive spike amplitude but also increases
%  the settling time.  An optimal Rg trades off spike suppression against
%  switching speed (and therefore switching losses).
% ═══════════════════════════════════════════════════════════════════════

Rg_values = 3 : 25;      % [Ω]  Gate resistance sweep
numPoints  = numel(Rg_values);
Vge_max_Rg = zeros(1, numPoints);

figure(3);
parfor idx = 1 : numPoints
    hPlot = CrosstalkModel(Vbus_fixed, Lcirc_fixed, Rcirc, Lc, ...
                           Rg_values(idx), Lg, Le, Cgc, Cge, Cce, tr);
    Vge_max_Rg(idx) = max(hPlot.YData);
end
close(3);

% ── Plot results ──────────────────────────────────────────────────────────
figure(3);
plot(Rg_values, Vge_max_Rg, 'k-', 'LineWidth', 4);
xlabel('Gate-Drive Resistance, R_g (\Omega)');
ylabel('Peak Gate-Emitter Voltage, \hat{V}_{GE} (V)');
title('Study 3: Effect of R_g on Crosstalk Spike Amplitude');
grid on; grid minor;
