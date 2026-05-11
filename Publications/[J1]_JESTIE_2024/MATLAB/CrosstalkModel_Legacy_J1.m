%% The analytical model for crosstalk
% This model is comprehensive and contains parasitic elements, mutual
% inductance and rise time of switches. 
% The list of used parameters in this code
% 
% * Vbus: Bus Voltage
% * Lcirc: Parasitic Inductance of Circuit
% * Rcirc: Parasitic Resistance of Circuit
% * Lc: Collector Inductance
% * Rg: Gate Resistance
% * Lg: Gate Inductance
% * Le: Emitter Inductance
% * Cgc: Gate-Collector Capacitance
% * Cge: Gate-Emitter Capacitance
% * Cce: Collector-Emitter Capacitance
% * tr: Rise Time of the Upper side Switch 
%
% The aforementioned values must be applied by user

%% Model Function
function Vge = Model(Vbus, Lcirc, Rcirc, Lc, Rg, Lg, Le, Cgc, Cge, Cce, tr)
%% Robustness of Function
Input_Arguement = [Vbus Lcirc Rcirc Lc Rg Lg Le Cgc Cge Cce tr];
Input_Arguement = Input_Arguement(Input_Arguement <= 0);
if ~isempty(Input_Arguement)
    error('The input arguements must be poitive');
elseif nargin < 11
    error('Not enough inputs');
end

%% Evaluating the Transfer Function
syms Vg Vc Ve s;

eq1 = Vg/(Rg + s*Lg) + (Vg - Ve)*s*(Cge) + (Vg - Vc)*s*(Cgc);
eq2 = (Ve - Vg)*s*(Cge) + Ve/(s*Le) + (Ve - Ve)*s*Cce;
eq3 = (Vc - Vg)*s*(Cgc) + (Vc - Ve)*s*Cce + (Vc - (Vbus - Vbus*exp(-s*tr))/(s^2*tr))/(Rcirc +s*(Lcirc + Lc));

sol = SimulEq(eq1, eq2, eq3);
trf = simplify(vpa(sol.Vg - sol.Ve)); % Transfer function of crosstalk model

trftime = matlabFunction(simplify(ilaplace(trf)));
t = 0:1e-10:3e-6;
%% Plotting Output
Vge = plot(t, 0.8*trftime(t), 'b-', 'LineWidth', 4);
xlabel('time (s)');
ylabel('Gate-Emitter Voltage (V)');
grid on;
grid minor;
% fontname(gca, "Times New Roman");
fontsize(30, 'points');
end