%% SwitchingEquations_TPEL.m
% =========================================================================
% Analytical Switching Equations Derivation
% Prepared for: IEEE Transactions on Power Electronics (In Preparation)
% =========================================================================
%
% TARGET PUBLICATION:
%   [TPEL] A. Azam Rajabian and S. Mohsenzade,
%          IEEE Transactions on Power Electronics (In Preparation).
%          These equations form the analytical basis of the extended
%          switching model to be presented in the TPEL submission.
%
% BUILDS ON:
%   [C1] A. Azam Rajabian and S. Mohsenzade, PEDSTC 2022,
%        doi: 10.1109/PEDSTC53976.2022.9767324.
%   [J1] A. Azam Rajabian and S. Mohsenzade, IEEE JESTIE 2024,
%        doi: 10.1109/JESTIE.2024.3476274.
%
% PURPOSE:
%   Derives and displays two sets of analytical equations used to model
%   the high-side switch commutation in a half-bridge circuit:
%
%   PART 1: Phase 1 Switch-On Equations (Miller plateau region)
%     Solves for the rise time tr and the intermediate VCE value Va at
%     the end of the Miller plateau.  These are the inputs to the
%     VCE waveform model in SwitchingInput_Generator_TPEL.m.
%
%   PART 2: Phase 2 Resonance Equations (post-Miller VCE fall)
%     Derives the LC resonant response after the Miller plateau ends.
%     The inductor (Lc + loop inductance) and freewheeling diode
%     capacitance (CL) form a resonant circuit, producing the
%     characteristic oscillatory VCE tail.
%
% THEORETICAL BACKGROUND:
%
%   Phase 1 (Miller plateau, 0 ≤ t ≤ tr):
%     Gate current flows entirely into Cgc; Vgs is clamped at VGP.
%     Two constraints uniquely determine tr and Va:
%       (i)  Iload = [a*tr^2/2] / (Le + Lc)        — current rise equation
%       (ii) tr*(Vdriver-VGP)/Rg = Cgc_avg*(Vbus-Va) — charge balance
%     where a = (Vdriver - VGP)/(Rg * Cgc_avg) is the slope [V/s].
%
%   Phase 2 (resonant fall, t > tr):
%     After the Miller plateau, the inductor-capacitor (Lc–CL) circuit
%     oscillates as VCE falls from Va toward VCE(sat).
%     Circuit equations (Kirchhoff's Voltage and Current Laws):
%       Lc * d(IL)/dt = Vbus - VCE_L - Rc * IL       — inductor voltage
%       CL * d(VCE_L)/dt = IL - Iload                 — capacitor current
%     where IL is the inductor current, VCE_L is the capacitor voltage,
%     CL is the effective load + device output capacitance, and
%     Rc is the damping resistance in the loop.
%
% OUTPUT:
%   Console display of:
%   - Simplified symbolic expressions for tr and Va
%   - Simplified symbolic expressions for IL(t) and VCE_L(t)
%   - Pretty-printed VCE_L(t) for readability in publications
%
% NOTE:
%   This script produces symbolic results only (no numeric values).
%   For numeric simulation, substitute parameter values and use
%   SwitchingInput_Generator_TPEL.m.
%
% SYMBOLS USED:
%   Iload  – load current [A]
%   Vbus   – DC-link voltage [V]
%   Va     – intermediate VCE at end of Miller plateau [V]
%   tr     – Miller plateau duration / rise time [s]
%   gfs    – IGBT transconductance [S]
%   Vth    – IGBT threshold voltage [V]
%   CGC_avg – average gate-collector capacitance over commutation [F]
%   Rgate  – gate resistance [Ω]
%   Le, Lc – emitter and collector parasitic inductances [H]
%   Vdriver – gate-drive supply voltage [V]
%   t      – time [s]  (used in the ODE solution, Phase 2)
%   CL     – equivalent load capacitance [F]
%   Rc     – loop damping resistance [Ω]
%
% Author:  Amir Azam Rajabian
% Date:    15.03.2025
% Version: 1.1  (refactored with extended documentation)
% =========================================================================

clear; close all; clc;

%% ══════════════════════════════════════════════════════════════════════════
%  PART 1: Phase 1 Equations – Miller Plateau Rise Time and Va
%  ════════════════════════════════════════════════════════════════════════

syms Iload Vbus Va tr gfs Vth CGC_avg Rgate Le Lc Vdriver

% Miller plateau gate voltage (Vgs value during plateau)
VGP = Vth + Iload / (2 * gfs);

% Slope of the gate-to-collector voltage ramp (VCE fall rate during plateau)
a = (Vdriver - VGP) / (Rgate * CGC_avg);

% Equation 1: collector current reaches Iload at end of phase 1
%   The current builds up as Ic(t) = a*t^2/(2*(Le+Lc)), reaching Iload at t=tr
eq1 = Iload == ((a * tr^2) / 2) / (Le + Lc);

% Equation 2: charge balance on gate-collector capacitance
%   Charge supplied by gate driver: Q = (Vdriver-VGP)/Rg * tr
%   Charge needed to change Cgc voltage: Cgc_avg * (Vbus - Va)
eq2 = tr * (Vdriver - VGP) / Rgate == CGC_avg * (Vbus - Va);

% Solve for the two unknowns: rise time tr and intermediate voltage Va
sol1 = solve([eq1, eq2], [tr, Va]);

fprintf('═══ PART 1: Phase 1 (Miller Plateau) Analytical Solutions ═══\n\n');
fprintf('Rise time, tr:\n');
disp(simplify(sol1.tr));

fprintf('\nIntermediate VCE at end of plateau, Va:\n');
disp(simplify(sol1.Va));

%% ══════════════════════════════════════════════════════════════════════════
%  PART 2: Phase 2 Equations – Resonant VCE Fall (LC Oscillation)
%  ════════════════════════════════════════════════════════════════════════
% After the Miller plateau, the inductor Lc and equivalent load capacitance
% CL form a resonant circuit.  The natural frequency is ω₀ = 1/√(Lc·CL).
% Damping is provided by the loop resistance Rc.
%
% The ODE system:
%   Lc * dIL/dt  = Vbus - Vcel - Rc * IL   (KVL around inductor loop)
%   CL * dVcel/dt = IL - Iload              (KCL at capacitor node)
%
% Initial conditions at the start of Phase 2 (t = tr):
%   IL(0)  = Iload  (current was rising; at t=tr it equals load current)
%   Vcel(0) = 0     (capacitor was uncharged before commutation)

syms IL(t) Vcel(t) CL Rc

% System of first-order ODEs
eqns = [Lc * diff(IL,  t) == Vbus - Vcel - Rc * IL, ...
        CL * diff(Vcel, t) == IL  - Iload];

% Initial conditions
cond = [IL(0)   == Iload, ...
        Vcel(0) == 0];

% Analytical solution via MATLAB's dsolve
sol2 = dsolve(eqns, cond);

fprintf('\n═══ PART 2: Phase 2 (Resonant Fall) Analytical Solutions ═══\n\n');
fprintf('Inductor current, I_L(t):\n');
disp(simplify(sol2.IL));

fprintf('\nCapacitor (VCE) voltage, V_CEl(t):\n');
disp(simplify(sol2.Vcel));

fprintf('\nPretty-printed V_CEl(t) for publication:\n');
pretty(simplify(sol2.Vcel));
