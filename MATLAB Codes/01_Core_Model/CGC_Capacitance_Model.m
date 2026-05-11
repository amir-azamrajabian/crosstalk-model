%% CGC_Capacitance_Model.m
% =========================================================================
% Gate-Collector (Miller) Capacitance Model for IGBTs
% =========================================================================
%
% PURPOSE:
%   Models the nonlinear gate-to-collector capacitance Cgc of an IGBT as a
%   function of the collector-emitter voltage VCE.  The model decomposes Cgc
%   into two series components:
%     1. Cox_D  – fixed gate-oxide capacitance (bias-independent)
%     2. Cgc_J  – voltage-dependent junction capacitance (depletion layer)
%
%   Parameters Cox_D and Xparam are extracted by fitting two datasheet
%   operating points, then Cgc(VCE) is plotted and its average computed
%   over a specified voltage range.
%
% THEORY:
%   The junction capacitance of a one-sided abrupt p-n junction scales with
%   the square root of the reverse voltage:
%       Cgc_J(VCE) = Xparam / sqrt(VCE - VGE)
%
%   The total gate-collector capacitance is the series combination:
%       Cgc(VCE) = (Cox_D * Cgc_J) / (Cox_D + Cgc_J)
%
%   Two equations at known (VCE, Cgc) datasheet points uniquely determine
%   Cox_D and Xparam.  Calibrated against IXGH60N60C2 (IXYS) datasheet.
%
% DEVICE REFERENCE:
%   IGBT: IXGH60N60C2 (IXYS / Littelfuse)
%   Datasheet operating points used for fitting:
%     Point 1:  VCE = 25 V,  Cgc ≈ 97 pF   (Crss at 25 V)
%     Point 2:  VCE = 30 V,  Cgc ≈ 90 pF   (Crss at 30 V)
%   Gate-emitter threshold voltage: VGE_th = 5 V (used to offset VCE)
%
% OUTPUTS:
%   Figure 1 – Cgc(VCE) curve from VCE = 25 V to 400 V
%   Command window – Average Cgc value over 25–100 V range
%
% USAGE:
%   Run as a standalone script.  The average Cgc value can be fed into
%   the parametric sweep in CrosstalkModel.m when Vbus is fixed.
%
% NOTES:
%   - Change the two datasheet operating-point values (eq3, eq4) to
%     calibrate the model to a different IGBT or SiC MOSFET.
%   - The averaging range (25–100 V) is chosen to match the VCE excursion
%     during a typical half-bridge commutation at Vbus = 400 V.
%     Adjust VCE1 limits if using a different bus voltage.
%   - To use this with SiC MOSFETs, replace VGE with VGS and re-extract
%     Cox_D and Xparam from the MOSFET datasheet Crss curves.
%
% RELATED PUBLICATIONS:
%   [J1] A. Azam Rajabian and S. Mohsenzade, "Interrelation of Gate
%        Resistance and Emitter/Source Inductance Impact on Inductive Load
%        Phase-Leg Crosstalk," IEEE JESTIE 2024,
%        doi: 10.1109/JESTIE.2024.3476274.
%        (Section on Cgc voltage dependency)
%   [C2] A. Azam Rajabian et al., EPE'22 ECCE Europe 2022,
%        doi: 10.1109/EPE22ECCEEurope50083.2022.9907736.
%
% Author:  Amir Azam Rajabian
% Date:    15.03.2025
% Version: 2.0  (refactored with extended documentation)
% =========================================================================

clear; close all; clc;

%% ── 1. Extract Model Parameters from Datasheet Points ───────────────────
% Two simultaneous equations based on series-capacitor model at two voltages.
% These constrain the two unknowns: Cox_D (oxide cap) and Xparam (junction
% capacitance scaling coefficient).

syms COXD Xparam

% Datasheet calibration: IXGH60N60C2 Crss values
%   Cgc(VCE=25V) ≈ 97 pF  →  (Cox_D * Cgc_J(25)) / (Cox_D + Cgc_J(25)) = 97e-12
%   Cgc(VCE=30V) ≈ 90 pF  →  (Cox_D * Cgc_J(30)) / (Cox_D + Cgc_J(30)) = 90e-12
eq3 = 97e-12 == (COXD * (Xparam / sqrt(25))) / (COXD + (Xparam / sqrt(25)));
eq4 = 90e-12 == (COXD * (Xparam / sqrt(30))) / (COXD + (Xparam / sqrt(30)));

sol2 = solve([eq3, eq4], [COXD, Xparam]);

% Convert symbolic solutions to double-precision floats
COXD   = double(vpa(subs(sol2.COXD),   5));  % [F]  Gate-oxide capacitance
Xparam = double(vpa(subs(sol2.Xparam), 5));  % [F·V^0.5]  Junction cap coefficient

VGE_th = 5;  % [V]  Gate-emitter threshold voltage of the IGBT

fprintf('Extracted parameters:\n');
fprintf('  Cox_D  = %.4e F\n', COXD);
fprintf('  Xparam = %.4e F·V^0.5\n', Xparam);

%% ── 2. Compute Cgc Over Full Voltage Range ───────────────────────────────
% Sweep VCE from near-threshold (25 V) to maximum bus voltage (400 V)
VCE  = 25 : 1e-3 : 400;           % [V]  Collector-emitter voltage sweep
Cgc_J = zeros(1, length(VCE));    % Preallocate junction capacitance array
Cgc   = zeros(1, length(VCE));    % Preallocate total Cgc array

for i = 1 : length(VCE)
    % Junction (depletion) capacitance: varies as 1/sqrt(VCE - VGE_th)
    Cgc_J(i) = Xparam / sqrt(VCE(i) - VGE_th);

    % Total Cgc: series combination of oxide and junction capacitances
    Cgc(i) = (COXD * Cgc_J(i)) / (COXD + Cgc_J(i));
end

%% ── 3. Plot Cgc vs VCE ───────────────────────────────────────────────────
figure(1);
plot(VCE, Cgc, 'r-', 'LineWidth', 4);
grid on;
xlabel('Collector-Emitter Voltage, V_{CE} (V)');
ylabel('Gate-Collector Capacitance, C_{GC} (F)');
title('Nonlinear Gate-Collector (Miller) Capacitance vs. V_{CE}');
legend('C_{GC}(V_{CE}) model – IXGH60N60C2');

%% ── 4. Compute Average Cgc Over the Active Switching Range ──────────────
% During commutation the VCE swings mainly between 25 V and 100 V before
% the plateau region ends.  The average over this range is used as a
% representative constant value in the analytical crosstalk model.
VCE1  = 25 : 1e-3 : 100;
Cgc_J1 = zeros(1, length(VCE1));
Cgc1   = zeros(1, length(VCE1));

for j = 1 : length(VCE1)
    Cgc_J1(j) = Xparam / sqrt(VCE1(j) - VGE_th);
    Cgc1(j)   = (COXD * Cgc_J1(j)) / (COXD + Cgc_J1(j));
end

Cgc_avg = mean(Cgc1);
fprintf('\nAverage C_GC over VCE = 25–100 V:\n');
fprintf('  C_GC_avg = %.4e F  (%.2f pF)\n', Cgc_avg, Cgc_avg * 1e12);
disp(['Use this value for Cgc in CrosstalkModel.m: ', num2str(Cgc_avg), ' F']);
