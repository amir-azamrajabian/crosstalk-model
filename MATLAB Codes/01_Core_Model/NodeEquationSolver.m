%% NodeEquationSolver.m
% =========================================================================
% Symbolic KCL Node-Equation Solver for the Crosstalk Circuit
% =========================================================================
%
% PURPOSE:
%   Solves the system of three simultaneous Kirchhoff Current Law (KCL)
%   equations that describe the gate (Vg), collector (Vc), and emitter (Ve)
%   node voltages of the passive (lower) switch in a phase-leg crosstalk
%   model.  The equations are written in the Laplace domain by the calling
%   function (CrosstalkModel.m) and passed here as symbolic expressions.
%
% BACKGROUND:
%   The three-node network of the passive switch QL is described by KCL at:
%     • Gate node     → eq1  (involves Rg, Lg, Cge, Cgc)
%     • Emitter node  → eq2  (involves Cge, Le)
%     • Collector node → eq3 (involves Cgc, Cce, Rcirc, Lcirc, Lc, excitation)
%
%   All symbolic variables (circuit parameters and Laplace variable s)
%   used inside the equations must already be defined by the caller via
%   'syms'.  This function introduces no new assumptions on those variables.
%
% INPUTS:
%   eq1   Symbolic expression for KCL at the gate node      (= 0 implied)
%   eq2   Symbolic expression for KCL at the emitter node   (= 0 implied)
%   eq3   Symbolic expression for KCL at the collector node (= 0 implied)
%
% OUTPUT:
%   sol   Structure with fields:
%           sol.Vg  – Laplace-domain gate voltage solution
%           sol.Vc  – Laplace-domain collector voltage solution
%           sol.Ve  – Laplace-domain emitter voltage solution
%
% USAGE EXAMPLE (called internally by CrosstalkModel.m):
%   syms Vg Vc Ve s Rg Lg Cge Cgc Le Cce Rcirc Lcirc Lc Vbus tr
%   eq1 = Vg/(Rg+s*Lg) + (Vg-Ve)*s*Cge + (Vg-Vc)*s*Cgc;
%   eq2 = (Ve-Vg)*s*Cge + Ve/(s*Le);
%   eq3 = (Vc-Vg)*s*Cgc + (Vc-Ve)*s*Cce + ...
%         (Vc - (Vbus - Vbus*exp(-s*tr))/(s^2*tr)) / (Rcirc + s*(Lcirc+Lc));
%   sol = NodeEquationSolver(eq1, eq2, eq3);
%
% NOTES:
%   - MATLAB's symbolic 'solve' returns exact closed-form solutions when
%     the system is linear in [Vg, Vc, Ve], which is the case here.
%   - Mutual inductance symbols (Mgc, Mce, Mge) are declared for potential
%     future extension to coupled-inductor models; they are not yet used
%     in the default circuit equations.
%   - For large symbolic expressions, execution time of solve() may reach
%     several seconds.  The caller should use parfor to parallelise sweeps.
%
% RELATED PUBLICATIONS:
%   [J1] A. Azam Rajabian and S. Mohsenzade, IEEE JESTIE 2024,
%        doi: 10.1109/JESTIE.2024.3476274.
%   [C1] A. Azam Rajabian and S. Mohsenzade, PEDSTC 2022,
%        doi: 10.1109/PEDSTC53976.2022.9767324.
%
% Author:  Amir Azam Rajabian
% Date:    15.03.2025
% Version: 2.0
% =========================================================================

function sol = NodeEquationSolver(eq1, eq2, eq3)

    %% ── Symbolic Variable Declaration ────────────────────────────────────
    % Circuit element parameters (must match those used by the caller).
    syms Rcirc Lcirc Lg Lc Le Rg Cgc Cge Cce

    % Mutual inductance terms — reserved for future coupled-inductor model.
    % Currently zero; declared here to keep the symbol table consistent.
    syms Mgc Mce Mge  %#ok<NUSED>

    % Laplace variable and unknown node voltages.
    syms s
    syms Vg Vc Ve

    % Excitation parameters (bus voltage and switch rise time).
    syms Vbus tr

    %% ── Solve the Linear System ──────────────────────────────────────────
    % The KCL equations are linear in the three unknowns [Vg, Vc, Ve].
    % MATLAB's 'solve' returns a structure with one field per unknown.
    %
    % System form:  A(s) * [Vg; Vc; Ve] = b(s)
    % where A(s) contains admittances and b(s) contains the excitation terms.
    sol = solve([eq1, eq2, eq3], [Vg, Vc, Ve]);

end
