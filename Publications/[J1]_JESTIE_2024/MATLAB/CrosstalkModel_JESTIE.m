%% CrosstalkModel_JESTIE.m
% =========================================================================
% Analytical Crosstalk Model – IEEE JESTIE 2024 Version
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
%   Computes the time-domain gate-emitter voltage (Vge) induced on the
%   passive lower-side switch QL during a high-side turn-on commutation.
%   This version is used to generate the model traces in the JESTIE paper.
%
%   Key difference vs. generic CrosstalkModel.m:
%   - A 0.8 empirical correction factor is applied to the analytical result
%     to match experimental measurements on the IXGH60N60C2 test bench.
%     This factor accounts for the linear-ramp over-estimation of dv/dt
%     and mild damping from PCB resistance not explicitly modelled.
%
% MODEL DERIVATION (Laplace-domain KCL):
%   Three-node network (gate Vg, collector Vc, emitter Ve) of the passive
%   switch QL, with the high-side VCE modelled as a voltage-ramp excitation:
%
%     Vexc(s) = Vbus * (1 - e^{-s*tr}) / (s^2 * tr)
%
%   Gate node:
%     Vg / (Rg + s*Lg)  +  (Vg - Ve)*s*Cge  +  (Vg - Vc)*s*Cgc  =  0
%
%   Emitter node:
%     (Ve - Vg)*s*Cge  +  Ve / (s*Le)  =  0
%
%   Collector node:
%     (Vc - Vg)*s*Cgc  +  (Vc - Ve)*s*Cce
%       +  [Vc - Vexc(s)] / (Rcirc + s*(Lcirc+Lc))  =  0
%
%   Crosstalk voltage: Vge(s) = Vg(s) - Ve(s)
%   Time-domain: vge(t) = L^{-1}{Vge(s)}
%
% INPUTS:
%   Vbus   [V]   DC bus voltage
%   Lcirc  [H]   Power-loop stray inductance
%   Rcirc  [Ω]   Power-loop stray resistance
%   Lc     [H]   Collector-lead inductance of QL
%   Rg     [Ω]   Gate-drive resistance of QL
%   Lg     [H]   Gate-lead inductance of QL
%   Le     [H]   Emitter-lead inductance of QL
%   Cgc    [F]   Gate-collector (Miller) capacitance of QL
%   Cge    [F]   Gate-emitter input capacitance of QL
%   Cce    [F]   Collector-emitter output capacitance of QL
%   tr     [s]   High-side switch VCE rise time
%
% OUTPUT:
%   Vge    Handle to the line plot of vge(t) vs. time.
%          Peak value: max(Vge.YData)
%
% DEPENDENCY:
%   SimulEq.m  (in same folder; renamed NodeEquationSolver in main MATLAB Codes)
%
% Author:  Amir Azam Rajabian
% Date:    15.03.2025
% Version: 1.1  (comments added for publication archiving)
% =========================================================================

function Vge = CrosstalkModel_JESTIE(Vbus, Lcirc, Rcirc, Lc, Rg, Lg, Le, ...
                                      Cgc, Cge, Cce, tr)

    %% ── Input Validation ─────────────────────────────────────────────────
    Input_Arguement = [Vbus, Lcirc, Rcirc, Lc, Rg, Lg, Le, Cgc, Cge, Cce, tr];
    if any(Input_Arguement <= 0)
        error('CrosstalkModel_JESTIE: All input arguments must be positive.');
    elseif nargin < 11
        error('CrosstalkModel_JESTIE: Expected 11 inputs, got %d.', nargin);
    end

    %% ── Symbolic Variables ───────────────────────────────────────────────
    syms Vg Vc Ve s

    %% ── KCL Equations at Each Node ───────────────────────────────────────
    % Gate node (Vg)
    eq1 = Vg / (Rg + s*Lg) ...
        + (Vg - Ve) * s * Cge ...
        + (Vg - Vc) * s * Cgc;

    % Emitter node (Ve) – the (Ve-Ve)*Cce term is zero and omitted
    eq2 = (Ve - Vg) * s * Cge ...
        + Ve / (s * Le);

    % Collector node (Vc) – driven by ramp excitation Vexc
    eq3 = (Vc - Vg) * s * Cgc ...
        + (Vc - Ve) * s * Cce ...
        + (Vc - (Vbus - Vbus * exp(-s*tr)) / (s^2 * tr)) / (Rcirc + s*(Lcirc + Lc));

    %% ── Solve System and Derive Transfer Function ────────────────────────
    sol = SimulEq(eq1, eq2, eq3);

    % Transfer function: Vge(s) = Vg(s) - Ve(s)
    trf = simplify(vpa(sol.Vg - sol.Ve));

    % Inverse Laplace → time-domain response function
    trftime = matlabFunction(simplify(ilaplace(trf)));

    %% ── Time Vector and Plot ─────────────────────────────────────────────
    t = 0 : 1e-10 : 3e-6;   % 0 to 3 µs at 0.1 ns resolution

    % The 0.8 factor is an empirical calibration against experimental data.
    % It corrects for the linear-ramp over-estimation of the high-side dv/dt.
    Vge = plot(t, 0.8 * trftime(t), 'b-', 'LineWidth', 4);
    xlabel('Time (s)');
    ylabel('Gate-Emitter Voltage, V_{GE} (V)');
    title('Analytical Crosstalk Model – JESTIE 2024');
    grid on; grid minor;
    fontsize(30, 'points');

end
