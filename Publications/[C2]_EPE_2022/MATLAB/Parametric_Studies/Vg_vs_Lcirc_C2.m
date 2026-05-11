clear; close; clc;
%% This code plots the effect of circuit inductance on the gate voltage - Param. Definition
Rcr = 1; Lcr = 500e-9;
Lg = 3e-9; Ls = 13e-9;
Cgs = 3e-9; Cds = 100e-12; Cgd = 50e-12;
Vbus = 650; Rg = 15;
tr = 90e-9;

%% Vg - Output Parameter of the System
syms s;
Vgs = (Cgd*Vbus*exp(-s*tr)*(exp(s*tr) - 1)*(Rg + Lg*s))/(s*tr*(Cds*Rcr*s + Cgd*Rcr*s + Cgd*Rg*s + Cgs*Rg*s + Cds*Lcr*s^2 + Cgd*Lcr*s^2 + Cgd*Lg*s^2 + Cgs*Lg*s^2 + Cgs*Ls*s^2 + Cds*Cgd*Lcr*Lg*s^4 + Cds*Cgs*Lcr*Lg*s^4 + Cgd*Cgs*Lcr*Lg*s^4 + Cds*Cgs*Lcr*Ls*s^4 + Cgd*Cgs*Lcr*Ls*s^4 + Cgd*Cgs*Lg*Ls*s^4 + Cds*Cgd*Lcr*Rg*s^3 + Cds*Cgd*Lg*Rcr*s^3 + Cds*Cgs*Lcr*Rg*s^3 + Cds*Cgs*Lg*Rcr*s^3 + Cgd*Cgs*Lcr*Rg*s^3 + Cgd*Cgs*Lg*Rcr*s^3 + Cds*Cgs*Ls*Rcr*s^3 + Cgd*Cgs*Ls*Rcr*s^3 + Cgd*Cgs*Ls*Rg*s^3 + Cds*Cgd*Rcr*Rg*s^2 + Cds*Cgs*Rcr*Rg*s^2 + Cgd*Cgs*Rcr*Rg*s^2 + 1));
Vgs_t = ilaplace(Vgs);
fplot(Vgs_t, [0 4e-6]);