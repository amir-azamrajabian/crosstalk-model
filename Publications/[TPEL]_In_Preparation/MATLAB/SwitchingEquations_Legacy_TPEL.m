clear; close; clc;
%% Analytical Equation - First Phase
syms Iload Vbus Va tr gfs Vth CGC_avg Rgate Le Lc Vdriver;
VGP = Vth + Iload/(2*gfs);
a = (Vdriver - VGP)/(Rgate*CGC_avg);

eq1 = Iload == ((a*tr^2)/2)/(Le + Lc);
eq2 = tr*(Vdriver - VGP)/(Rgate) == CGC_avg*(Vbus - Va);
sol1 = solve([eq1 eq2], [tr Va]);
tr = sol1.tr; Va = sol1.Va;

display(simplify(sol1.tr)); display(simplify(sol1.Va));

%% Analytical Equation - Resonance Equation
syms IL(t) Vcel(t) CL Rc;

eqns = [Lc*diff(IL, t) == Vbus - Vcel - Rc*IL, CL*diff(Vcel, t) == IL - Iload];
cond = [IL(0) == Iload, Vcel(0) == 0];

sol2 = dsolve(eqns, cond);
display(simplify(sol2.IL)); display(simplify(sol2.Vcel));
pretty(simplify(sol2.Vcel));