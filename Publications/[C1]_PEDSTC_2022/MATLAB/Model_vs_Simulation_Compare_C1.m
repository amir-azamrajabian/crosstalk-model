clc; clear; close;
SPICESim = csvread('SPICESIM.csv', 2);
time = SPICESim(:, 1);
VGESim = SPICESim(:, 2);
figure(1);
plot(time, VGESim, 'r-', 'LineWidth', 4);
title('Gate-Emitter Voltage in SPICE and Analytic Model');
xlabel('Time (s)');
ylabel('Gate-Emitter Voltage (V)');
hold on;
Rcr = 1; Lcr = 190e-9; % Circuit Losses
Lg = 3e-9; Ls = 13e-9; % Gate and Emmitter Inductances
Cgs = 2.253e-9; Cds = 103e-12; Cgd = 66.53e-12; % Capacitances
Vbus = 600;

syms s;
% Analyitic
Rg = 12;
tr = 46e-9*Rg/12;
VGEANA = (Cgd*Vbus*exp(-s*tr)*(exp(s*tr) - 1)*(Rg + Lg*s))/(s*tr*(Cds*Rcr*s + Cgd*Rcr*s + Cgd*Rg*s + Cgs*Rg*s + Cds*Lcr*s^2 + Cgd*Lcr*s^2 + Cgd*Lg*s^2 + Cgs*Lg*s^2 + Cgs*Ls*s^2 + Cds*Cgd*Lcr*Lg*s^4 + Cds*Cgs*Lcr*Lg*s^4 + Cgd*Cgs*Lcr*Lg*s^4 + Cds*Cgs*Lcr*Ls*s^4 + Cgd*Cgs*Lcr*Ls*s^4 + Cgd*Cgs*Lg*Ls*s^4 + Cds*Cgd*Lcr*Rg*s^3 + Cds*Cgd*Lg*Rcr*s^3 + Cds*Cgs*Lcr*Rg*s^3 + Cds*Cgs*Lg*Rcr*s^3 + Cgd*Cgs*Lcr*Rg*s^3 + Cgd*Cgs*Lg*Rcr*s^3 + Cds*Cgs*Ls*Rcr*s^3 + Cgd*Cgs*Ls*Rcr*s^3 + Cgd*Cgs*Ls*Rg*s^3 + Cds*Cgd*Rcr*Rg*s^2 + Cds*Cgs*Rcr*Rg*s^2 + Cgd*Cgs*Rcr*Rg*s^2 + 1));
Vge_t = ilaplace(VGEANA);
fplot(Vge_t, [0 1e-6], 'b--','LineWidth', 4);
legend('Simulation in PSPICE', 'Analytic Model')