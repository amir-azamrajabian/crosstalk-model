%% Solves Simultaneous Equations
% Equations related to crosstalk model is solved. Inputs are three
% kirchhoff's law in the node
%% Function
function sol = SimulEq(eq1, eq2, eq3)
% Definition of Crosstalk Variables
syms Rcirc Lcirc Lg Lc Le Rg Cgc Cge Cce;
syms Mgc Mce Mge; % Only used when there is substantial mutual inductance
syms s;
syms Vg Vc Ve;
syms Vbus tr;
% Output
sol = solve([eq1 eq2 eq3], [Vg Vc Ve]);
end