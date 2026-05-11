clear; close; clc;
%% Defining IGBT transfer Function in Active region
syms Rcirc Lcirc Lg Lc Le Rg Cgc Cge Cce;
syms Mgc Mce Mge; % Only used when there is substantial mutual inductance
syms s;
syms Vg Vc Ve;
syms Vbus tr;

eq1 = Vg/(Rg + s*Lg) + (Vg - Ve)*s*(Cge*(sqrt(Vbus/25))) + (Vg - Vc)*s*(Cgc*(sqrt(25/Vbus)));
eq2 = (Ve - Vg)*s*(Cge*(sqrt(Vbus/25))) + Ve/(s*Le) + (Ve - Ve)*s*Cce;
eq3 = (Vc - Vg)*s*(Cgc*(sqrt(25/Vbus))) + (Vc - Ve)*s*Cce + (Vc - (Vbus - Vbus*exp(-s*tr))/(s^2*tr))/(Rcirc +s*(Lcirc + Lc));

sol = solve([eq1 eq2 eq3], [Vg Vc Ve]);
trf = simplify(vpa(sol.Vg - sol.Ve));