%% SwitchingInput_Generator_TPEL.m
% =========================================================================
% Analytically-Derived VCE Switching Waveform Generator
% Prepared for: IEEE Transactions on Power Electronics (In Preparation)
% =========================================================================
%
% TARGET PUBLICATION:
%   [TPEL] A. Azam Rajabian and S. Mohsenzade,
%          IEEE Transactions on Power Electronics (In Preparation).
%          This script will support the extended switching waveform model
%          section of the TPEL submission.
%
% BUILDS ON:
%   [C1] A. Azam Rajabian and S. Mohsenzade, PEDSTC 2022,
%        doi: 10.1109/PEDSTC53976.2022.9767324.
%   [J1] A. Azam Rajabian and S. Mohsenzade, IEEE JESTIE 2024,
%        doi: 10.1109/JESTIE.2024.3476274.
%
% PURPOSE:
%   Constructs the high-side switch VCE(t) waveform using a two-phase
%   analytical model derived from the circuit equations of the half-bridge.
%   Unlike VCE_Waveform_Generator.m (which uses curve-fitted polynomials),
%   this version derives the waveform parameters analytically from device
%   and circuit specifications, making it more general.
%
% VCE WAVEFORM MODEL (Two-Phase Turn-On Transient):
%
%   Phase 0: VCE = Vbus  (gate driver charges Ciss through Rg; no dv/dt yet)
%   Phase 1: VCE falls linearly from Vbus to Va  (Miller plateau region)
%     Duration: tr  (rise time, derived analytically below)
%     Slope:    -a = -(Vdriver - VGP) / (Rg * Cgc_avg)   [V/s]
%     where VGP = Vth + Iload/(2*gfs)  is the Miller plateau gate voltage
%
%   Phase 2: VCE falls from Va to 0  (derived in EPE paper; see JESTIE ref)
%
%   The key equations linking tr and Va:
%     (i)  Iload = (a * tr^2 / 2) / (Le + Lc)
%          — Current rises parabolically while VCE is being pulled down
%     (ii) tr * (Vdriver - VGP) / Rg = Cgc_avg * (Vbus - Va)
%          — Charge balance: gate charge displaces Cgc from Vbus to Va
%
% DEVICE PARAMETERS (IXGH60N60C2 IGBT):
%   Vbus    = 400 V,  Iload  = 22 A,  Vth  = 5 V
%   gfs     = 20 S,   Le     = 3 nH,  Lc   = 100 nH
%   Rgate   = 20 Ω,   Vdriver = 20 V (gate-drive supply)
%
% OUTPUTS:
%   Figure 1 – Complete piecewise VCE(t) waveform
%   Input_Values.txt – PSpice-compatible PWL data file
%
% Author:  Amir Azam Rajabian
% Date:    15.03.2025
% Version: 1.1  (refactored with extended documentation for TPEL archive)
% =========================================================================

clear; close all; clc;

%% ── 1. Load Pre-Switching PSpice Data (Phase 0: Steady State) ───────────
% The CSV contains the off-state (VCE ≈ Vbus) simulation trace.
sim = readmatrix('VCE_First_Pulse.csv');
t0  = sim(:, 1);   % [s]  Absolute time vector
V0  = sim(:, 2);   % [V]  Collector-emitter voltage (steady state)

% Append extra points at Vbus to bridge the Rg·Ciss charging delay
t0_1 = 4e-6 + 1e-10 : 1e-10 : 4.005e-6;   % 50 extra points
for i = 1 : length(t0_1)
    t0(40022 + i) = t0_1(i);
    V0(40022 + i) = 400;   % [V]  Flat at Vbus before dv/dt begins
end

%% ── 2. Analytical Derivation of tr and Va (Phase 1 Parameters) ──────────
% Define symbolic variables for the analytical solution
syms Iload Vbus Va tr gfs Vth CGC_avg Rgate Le Lc Vdriver

% Miller plateau gate voltage: VGP = Vth + Iload / (2*gfs)
% (point where Vgs stops rising because gate current flows entirely into Cgc)
VGP = Vth + Iload / (2 * gfs);

% Slope of VCE during the Miller plateau [V/s]
% a = rate of change of Cgc charge voltage = (Vgs_drive - VGP) / (Rg * Cgc_avg)
a = (Vdriver - VGP) / (Rgate * CGC_avg);

% Equation 1: collector current rise during phase 1
%   The collector current Ic rises from 0 to Iload while VCE falls.
%   With a parabolic VCE fall, Ic(tr) = integral{dv/dt / (Le+Lc)} = a*tr^2/(2*(Le+Lc))
eq1 = Iload == ((a * tr^2) / 2) / (Le + Lc);

% Equation 2: charge balance on Cgc during phase 1
%   Total gate charge delivered to Cgc: Q = Ig * tr = (Vdriver-VGP)/Rg * tr
%   This equals the change in Cgc charge: Cgc_avg * (Vbus - Va)
eq2 = tr * (Vdriver - VGP) / Rgate == CGC_avg * (Vbus - Va);

% Solve symbolically for tr (rise time) and Va (VCE at end of Miller plateau)
sol1 = solve([eq1, eq2], [tr, Va]);
tr_sym = sol1.tr;
Va_sym = sol1.Va;

%% ── 3. Substitute Numeric Values ─────────────────────────────────────────
Lc_val      = 100e-9;  % [H]  Collector parasitic inductance
Vdriver_val = 20;      % [V]  Gate-drive supply voltage
Le_val      = 3e-9;    % [H]  Emitter parasitic inductance
Rgate_val   = 20;      % [Ω]  Gate resistance
Vth_val     = 5;       % [V]  IGBT threshold voltage
gfs_val     = 20;      % [S]  IGBT transconductance
Vbus_val    = 400;     % [V]  DC-link voltage
Iload_val   = 22;      % [A]  Load current at commutation instant

% Derive Cgc_avg using the voltage-dependent capacitance model
% (Series combination of oxide capacitance Cox_D and junction cap Cgc_J)
syms COXD Xparam
eq3 = 97e-12 == (COXD * (Xparam / sqrt(25))) / (COXD + (Xparam / sqrt(25)));
eq4 = 89e-12 == (COXD * (Xparam / sqrt(30))) / (COXD + (Xparam / sqrt(30)));
sol2   = solve([eq3, eq4], [COXD, Xparam]);
COXD_n = double(vpa(subs(sol2.COXD),   5));
Xp_n   = double(vpa(subs(sol2.Xparam), 5));

VGE_th = Vth_val;   % Gate-emitter threshold used as VCE offset in Cgc_J
VCE_range = 25 : 1e-3 : Vbus_val;
Cgc_arr = zeros(1, length(VCE_range));
for i = 1 : length(VCE_range)
    Cgc_J_i      = Xp_n / sqrt(VCE_range(i) - VGE_th);
    Cgc_arr(i)   = (COXD_n * Cgc_J_i) / (COXD_n + Cgc_J_i);
end
CGC_avg_val = mean(Cgc_arr);

% Substitute all numeric values into the symbolic solutions
tr_num = double(vpa(subs(tr_sym, ...
    {Iload,       Vbus,     Vth,     gfs,     CGC_avg,     Rgate,     Le,     Lc,     Vdriver}, ...
    {Iload_val, Vbus_val, Vth_val, gfs_val, CGC_avg_val, Rgate_val, Le_val, Lc_val, Vdriver_val}), 5));

Va_num = double(vpa(subs(Va_sym, ...
    {Iload,       Vbus,     Vth,     gfs,     CGC_avg,     Rgate,     Le,     Lc,     Vdriver}, ...
    {Iload_val, Vbus_val, Vth_val, gfs_val, CGC_avg_val, Rgate_val, Le_val, Lc_val, Vdriver_val}), 5));

% Select the physically valid solution (tr > 0, 0 < Va < Vbus)
for i = 1 : length(tr_num)
    if tr_num(i) > 0 && Va_num(i) < Vbus_val && Va_num(i) > 0
        tr_valid = tr_num(i);
        Va_valid = Va_num(i);
        fprintf('Phase 1: tr = %.3f ns,  Va = %.2f V\n', tr_valid*1e9, Va_valid);
    end
end

%% ── 4. Construct Phase 1 VCE Segment (Miller Plateau Fall) ──────────────
% VCE falls linearly from Vbus to Va over the rise time tr
a_num = double(vpa(subs((Vdriver-VGP)/Rgate/CGC_avg, ...
    {Vdriver,     Vth,     gfs,     CGC_avg,     Rgate}, ...
    {Vdriver_val, Vth_val, gfs_val, CGC_avg_val, Rgate_val}), 5));

t_start = t0(40072);   % Time at which the dv/dt phase begins
t1      = t_start + 1e-10 : 1e-10 : t_start + tr_valid;
VQH     = Vbus_val - a_num .* (t1 - t_start);   % Linear VCE fall

% Append Phase 1 to the pre-switching steady-state
for i = 1 : length(t1)
    t0(40072 + i) = t1(i);
    V0(40072 + i) = VQH(i);
end

%% ── 5. Plot the Final Composite Waveform ────────────────────────────────
figure(1);
plot(t0, V0, 'r-', 'LineWidth', 4);
grid on;
xlabel('Time (s)');
ylabel('Collector-Emitter Voltage of High-Side Switch, V_{CE} (V)');
title('Analytically-Derived V_{CE} Turn-On Waveform – TPEL Model');

%% ── 6. Export to PSpice Text File ───────────────────────────────────────
dataPoints = [t0'; V0'];
fileID = fopen('Input_Values.txt', 'w');
if fileID == -1
    error('Cannot open Input_Values.txt for writing.');
end
fprintf(fileID, '%10.35f %30.25f\n', dataPoints);
fclose(fileID);
fprintf('PSpice PWL file written: Input_Values.txt\n');
