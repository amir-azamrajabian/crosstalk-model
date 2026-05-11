%% CrosstalkModel.m
% =========================================================================
% Analytical Crosstalk Model for Phase-Leg Power Converters
% =========================================================================
%
% PURPOSE:
%   Computes the gate-emitter voltage (Vge) induced in the passive (lower)
%   switch of a phase-leg when the active (upper) switch commutates.
%   The model is fully analytical: circuit equations are written in the
%   Laplace domain, solved symbolically, and transformed back to the time
%   domain via inverse Laplace transform.
%
% THEORY (see associated publications):
%   During the turn-on transient of the high-side switch QH, the
%   collector-emitter voltage VCE falls from Vbus toward zero with a
%   ramp-like slope characterised by the rise time tr.  This dv/dt drives
%   displacement currents through the parasitic capacitances Cgc and Cce of
%   the passive low-side switch QL, perturbing its gate node voltage Vg and
%   emitter node voltage Ve.  The model solves the three-node network
%   (gate, emitter, collector of QL) in the s-domain by applying Kirchhoff's
%   Current Law (KCL) at each node.
%
%   Node equations (KCL, all currents leaving each node = 0):
%
%     Gate node:
%       Vg / (Rg + s*Lg)  +  (Vg - Ve)*s*Cge  +  (Vg - Vc)*s*Cgc  =  0
%
%     Emitter node:
%       (Ve - Vg)*s*Cge  +  Ve / (s*Le)  =  0
%
%     Collector node:
%       (Vc - Vg)*s*Cgc  +  (Vc - Ve)*s*Cce
%         +  [Vc - Vexc(s)] / (Rcirc + s*(Lcirc + Lc))  =  0
%
%   where the ramp excitation in the s-domain is:
%       Vexc(s) = Vbus * (1 - exp(-s*tr)) / (s^2 * tr)
%
% INPUTS:
%   Vbus   [V]   DC bus (supply) voltage
%   Lcirc  [H]   Total stray inductance of the power-loop PCB trace
%   Rcirc  [Ω]   Stray resistance of the power-loop trace
%   Lc     [H]   Collector-lead parasitic inductance of QL
%   Rg     [Ω]   Gate-drive resistance seen by QL
%   Lg     [H]   Gate-lead parasitic inductance of QL
%   Le     [H]   Emitter-lead (source-lead) parasitic inductance of QL
%   Cgc    [F]   Gate-to-collector (reverse transfer) capacitance of QL
%   Cge    [F]   Gate-to-emitter input capacitance of QL
%   Cce    [F]   Collector-to-emitter output capacitance of QL
%   tr     [s]   Rise time of the high-side switch VCE waveform
%
% OUTPUT:
%   Vge    Handle to the line object of the Vge-vs-time plot.
%          Access the computed voltage samples via  Vge.YData.
%
% USAGE EXAMPLE:
%   figure;
%   Vge = CrosstalkModel(400, 180e-9, 1, 1e-9, 20, 3e-9, 5e-9, ...
%                        75e-12, 3793e-12, 183e-12, 50e-9);
%   peak = max(Vge.YData);
%   fprintf('Peak Vge = %.2f V\n', peak);
%
% DEPENDENCIES:
%   NodeEquationSolver.m  – must be on the MATLAB path (same folder).
%
% NOTES:
%   - The symbolic computation (ilaplace) can be slow (~5–30 s per call).
%     Use parfor in the calling script to parallelise parameter sweeps.
%   - The 0.8 scaling factor applied to the analytical result accounts for
%     the effective damping not captured by the linear ramp approximation
%     of the VCE excitation.  Remove it if using the exact piecewise input.
%   - All inputs must be strictly positive (physically meaningful values).
%
% RELATED PUBLICATIONS:
%   [J1] A. Azam Rajabian and S. Mohsenzade, "Interrelation of Gate
%        Resistance and Emitter/Source Inductance Impact on Inductive Load
%        Phase-Leg Crosstalk," IEEE J. Emerg. Sel. Topics Ind. Electron.,
%        doi: 10.1109/JESTIE.2024.3476274.
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
% Version: 2.0
% =========================================================================

function Vge = CrosstalkModel(Vbus, Lcirc, Rcirc, Lc, Rg, Lg, Le, ...
                               Cgc, Cge, Cce, tr)

    %% ── 1. Input Validation ──────────────────────────────────────────────
    if nargin < 11
        error('CrosstalkModel: Expected 11 input arguments, got %d.', nargin);
    end

    inputArgs = [Vbus, Lcirc, Rcirc, Lc, Rg, Lg, Le, Cgc, Cge, Cce, tr];
    if any(inputArgs <= 0)
        idx = find(inputArgs <= 0);
        names = {'Vbus','Lcirc','Rcirc','Lc','Rg','Lg','Le', ...
                 'Cgc','Cge','Cce','tr'};
        error('CrosstalkModel: Non-positive value detected in argument(s): %s', ...
              strjoin(names(idx), ', '));
    end

    %% ── 2. Symbolic Variables ────────────────────────────────────────────
    % Node voltages (unknowns) and the complex-frequency variable s.
    syms Vg Vc Ve s

    %% ── 3. KCL Node Equations in the Laplace Domain ─────────────────────
    % All capacitor admittances: Y_C = s*C
    % Inductor impedances:       Z_L = s*L
    % Resistor impedances:       Z_R = R
    %
    % Excitation: ramp approximation of the VCE fall on the high-side switch.
    %   A voltage step of amplitude Vbus decelerating over rise time tr gives
    %   a Laplace-domain expression:  Vexc(s) = Vbus*(1 - e^{-s*tr}) / (s^2*tr)

    Vexc = (Vbus - Vbus * exp(-s * tr)) / (s^2 * tr);  % s-domain VCE excitation

    % Gate node – KCL (sum of currents leaving node = 0):
    %   Current through gate impedance (Rg + sLg) toward ground  [← gate-drive loop]
    %   Displacement current through Cge toward emitter node
    %   Displacement current through Cgc toward collector node
    eq1 = Vg / (Rg + s*Lg) ...
        + (Vg - Ve) * s * Cge ...
        + (Vg - Vc) * s * Cgc;

    % Emitter node – KCL:
    %   Displacement current through Cge toward gate node
    %   Current through emitter inductance Le toward ground
    eq2 = (Ve - Vg) * s * Cge ...
        + Ve / (s * Le);

    % Collector node – KCL:
    %   Displacement current through Cgc toward gate node
    %   Displacement current through Cce toward emitter node
    %   Current through power-loop impedance (Rcirc + s*(Lcirc+Lc)) toward excitation
    eq3 = (Vc - Vg) * s * Cgc ...
        + (Vc - Ve) * s * Cce ...
        + (Vc - Vexc) / (Rcirc + s * (Lcirc + Lc));

    %% ── 4. Solve the System of Node Equations ────────────────────────────
    % NodeEquationSolver calls MATLAB's symbolic solve() for the three
    % coupled KCL equations and returns a structure with fields Vg, Vc, Ve.
    sol = NodeEquationSolver(eq1, eq2, eq3);

    %% ── 5. Derive the Transfer Function: Vge = Vg - Ve ──────────────────
    % The crosstalk signal of interest is the voltage appearing between
    % gate and emitter of QL, which could falsely trigger or stress the device.
    trf = simplify(vpa(sol.Vg - sol.Ve));

    %% ── 6. Inverse Laplace Transform → Time-Domain Response ─────────────
    % Convert the s-domain transfer function to a callable MATLAB function
    % of time.  The 'simplify' call reduces expression size before ilaplace.
    trftime = matlabFunction(simplify(ilaplace(trf)));

    % Time vector: 0 to 3 µs with 0.1 ns resolution
    % (captures the full transient including the oscillatory tail)
    t = 0 : 1e-10 : 3e-6;

    %% ── 7. Plot Gate-Emitter Voltage vs. Time ────────────────────────────
    % The 0.8 empirical factor corrects for the linear-ramp over-estimation
    % of the displacement current (calibrated against experimental data).
    Vge = plot(t, 0.8 * trftime(t), 'b-', 'LineWidth', 4);
    xlabel('Time (s)');
    ylabel('Gate-Emitter Voltage, V_{GE} (V)');
    title('Crosstalk-Induced Gate-Emitter Voltage');
    grid on;
    grid minor;
    fontsize(30, 'points');

end
