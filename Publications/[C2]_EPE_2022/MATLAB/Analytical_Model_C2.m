%% This code shows Gate-Emitter Voltage under different conditions
clear; close; clc;
% Param. Definition
Rcr = 1; Lcr = 50e-9; % Circuit Losses
Lg = 3e-9; Ls = 13e-9; Ld = 10.9e-9; % Gate, Collector and Emmitter Inductances
Cgs = 3400e-12; Cds = 198e-12; Cgd = 56e-12; % Capacitances
% gfs = 55; Vth = 5; % Transconductance and Threshold Voltage
% Gate Side Parameters
Rg = 20; Vbus = 400;
tr = 90e-9;
% Mutual Inductances
Mgc = -2e-9; Mce = -5e-9; Mge = -2e-9;

syms s;
% counter = 0; j = 1;
% time = zeros(1, 18); Peak_Voltage = zeros(1, 18); Esc = zeros(1, 18);
% for Vbus = 200: 50: 800
%     Vge = (Cgd*Vbus*exp(-s*tr)*(exp(s*tr) - 1)*(Rg + Lg*s + Mce*s + Mgc*s - Mge*s))/(s*tr*(Cds*Rcr*s + Cgd*Rcr*s + Cgd*Rg*s + Cgs*Rg*s + Cds*Lcr*s^2 + Cds*Ld*s^2 + Cgd*Lcr*s^2 + Cgd*Ld*s^2 + Cgd*Lg*s^2 + Cgs*Lg*s^2 + Cgs*Ls*s^2 + Cds*Mce*s^2 + 2*Cgd*Mce*s^2 + Cds*Mgc*s^2 - Cds*Mge*s^2 + 2*Cgd*Mgc*s^2 - 2*Cgd*Mge*s^2 + 2*Cgs*Mgc*s^2 + Cds*Cgd*Mce^2*s^4 - Cgd*Cgs*Mce^2*s^4 + Cds*Cgd*Mgc^2*s^4 + Cds*Cgd*Mge^2*s^4 + 2*Cds*Cgs*Mgc^2*s^4 + 3*Cgd*Cgs*Mgc^2*s^4 - Cgd*Cgs*Mge^2*s^4 + Cds*Cgd*Lcr*Lg*s^4 + Cds*Cgs*Lcr*Lg*s^4 + Cds*Cgd*Ld*Lg*s^4 + Cds*Cgs*Ld*Lg*s^4 + Cgd*Cgs*Lcr*Lg*s^4 + Cgd*Cgs*Ld*Lg*s^4 + Cds*Cgs*Lcr*Ls*s^4 + Cds*Cgs*Ld*Ls*s^4 + Cgd*Cgs*Lcr*Ls*s^4 + Cgd*Cgs*Ld*Ls*s^4 + Cgd*Cgs*Lg*Ls*s^4 + Cds*Cgd*Lcr*Mce*s^4 + Cds*Cgd*Ld*Mce*s^4 + Cds*Cgd*Lg*Mce*s^4 + Cds*Cgs*Lg*Mce*s^4 + Cds*Cgd*Lcr*Mgc*s^4 - Cds*Cgd*Lcr*Mge*s^4 + 2*Cds*Cgs*Lcr*Mgc*s^4 + Cds*Cgd*Ld*Mgc*s^4 - Cds*Cgd*Ld*Mge*s^4 + 2*Cds*Cgs*Ld*Mgc*s^4 + 2*Cgd*Cgs*Lcr*Mgc*s^4 + Cds*Cgd*Lg*Mgc*s^4 + 2*Cgd*Cgs*Ld*Mgc*s^4 - Cds*Cgd*Lg*Mge*s^4 + Cds*Cgs*Lg*Mgc*s^4 - Cds*Cgs*Lg*Mge*s^4 + 2*Cgd*Cgs*Lg*Mgc*s^4 + Cds*Cgs*Ls*Mce*s^4 + 2*Cgd*Cgs*Ls*Mce*s^4 + Cds*Cgs*Ls*Mgc*s^4 - Cds*Cgs*Ls*Mge*s^4 + 2*Cgd*Cgs*Ls*Mgc*s^4 - 2*Cgd*Cgs*Ls*Mge*s^4 + 2*Cds*Cgd*Mce*Mgc*s^4 - 2*Cds*Cgd*Mce*Mge*s^4 + 2*Cds*Cgs*Mce*Mgc*s^4 + 2*Cgd*Cgs*Mce*Mgc*s^4 + 2*Cgd*Cgs*Mce*Mge*s^4 - 2*Cds*Cgd*Mgc*Mge*s^4 - 2*Cds*Cgs*Mgc*Mge*s^4 - 2*Cgd*Cgs*Mgc*Mge*s^4 + Cds*Cgd*Lcr*Rg*s^3 + Cds*Cgd*Lg*Rcr*s^3 + Cds*Cgs*Lcr*Rg*s^3 + Cds*Cgs*Lg*Rcr*s^3 + Cds*Cgd*Ld*Rg*s^3 + Cds*Cgs*Ld*Rg*s^3 + Cgd*Cgs*Lcr*Rg*s^3 + Cgd*Cgs*Lg*Rcr*s^3 + Cgd*Cgs*Ld*Rg*s^3 + Cds*Cgs*Ls*Rcr*s^3 + Cgd*Cgs*Ls*Rcr*s^3 + Cgd*Cgs*Ls*Rg*s^3 + Cds*Cgd*Mce*Rcr*s^3 + Cds*Cgd*Mce*Rg*s^3 + Cds*Cgs*Mce*Rg*s^3 + Cds*Cgd*Mgc*Rcr*s^3 - Cds*Cgd*Mge*Rcr*s^3 + 2*Cds*Cgs*Mgc*Rcr*s^3 + 2*Cgd*Cgs*Mgc*Rcr*s^3 + Cds*Cgd*Mgc*Rg*s^3 - Cds*Cgd*Mge*Rg*s^3 + Cds*Cgs*Mgc*Rg*s^3 - Cds*Cgs*Mge*Rg*s^3 + 2*Cgd*Cgs*Mgc*Rg*s^3 + Cds*Cgd*Rcr*Rg*s^2 + Cds*Cgs*Rcr*Rg*s^2 + Cgd*Cgs*Rcr*Rg*s^2 + 1));
%     Vge_t = ilaplace(Vge);
%     figure(1);
%     Vge_tp = fplot(Vge_t, [0 1.5e-6]);
%     for i = 1: length(Vge_tp.XData)
%         if Vge_tp.YData(i) >= Vth
%             counter = counter + 1;
%         end
%     end
%     Vbus
%     time(j) = counter*(Vge_tp.XData(2) - Vge_tp.XData(1))
%     Peak_Voltage(j) = max(Vge_tp.YData)
%     Esc(j) = gfs*(Peak_Voltage(j) - Vth)*Vbus*time(j)
%     counter = 0; j = j + 1;
%     disp('-------------------------------')
% end
Vge = (Cgd*Vbus*exp(-s*tr)*(exp(s*tr) - 1)*(Rg + Lg*s + Mce*s + Mgc*s - Mge*s))/(s*tr*(Cds*Rcr*s + Cgd*Rcr*s + Cgd*Rg*s + Cgs*Rg*s + Cds*Lcr*s^2 + Cds*Ld*s^2 + Cgd*Lcr*s^2 + Cgd*Ld*s^2 + Cgd*Lg*s^2 + Cgs*Lg*s^2 + Cgs*Ls*s^2 + Cds*Mce*s^2 + 2*Cgd*Mce*s^2 + Cds*Mgc*s^2 - Cds*Mge*s^2 + 2*Cgd*Mgc*s^2 - 2*Cgd*Mge*s^2 + 2*Cgs*Mgc*s^2 + Cds*Cgd*Mce^2*s^4 - Cgd*Cgs*Mce^2*s^4 + Cds*Cgd*Mgc^2*s^4 + Cds*Cgd*Mge^2*s^4 + 2*Cds*Cgs*Mgc^2*s^4 + 3*Cgd*Cgs*Mgc^2*s^4 - Cgd*Cgs*Mge^2*s^4 + Cds*Cgd*Lcr*Lg*s^4 + Cds*Cgs*Lcr*Lg*s^4 + Cds*Cgd*Ld*Lg*s^4 + Cds*Cgs*Ld*Lg*s^4 + Cgd*Cgs*Lcr*Lg*s^4 + Cgd*Cgs*Ld*Lg*s^4 + Cds*Cgs*Lcr*Ls*s^4 + Cds*Cgs*Ld*Ls*s^4 + Cgd*Cgs*Lcr*Ls*s^4 + Cgd*Cgs*Ld*Ls*s^4 + Cgd*Cgs*Lg*Ls*s^4 + Cds*Cgd*Lcr*Mce*s^4 + Cds*Cgd*Ld*Mce*s^4 + Cds*Cgd*Lg*Mce*s^4 + Cds*Cgs*Lg*Mce*s^4 + Cds*Cgd*Lcr*Mgc*s^4 - Cds*Cgd*Lcr*Mge*s^4 + 2*Cds*Cgs*Lcr*Mgc*s^4 + Cds*Cgd*Ld*Mgc*s^4 - Cds*Cgd*Ld*Mge*s^4 + 2*Cds*Cgs*Ld*Mgc*s^4 + 2*Cgd*Cgs*Lcr*Mgc*s^4 + Cds*Cgd*Lg*Mgc*s^4 + 2*Cgd*Cgs*Ld*Mgc*s^4 - Cds*Cgd*Lg*Mge*s^4 + Cds*Cgs*Lg*Mgc*s^4 - Cds*Cgs*Lg*Mge*s^4 + 2*Cgd*Cgs*Lg*Mgc*s^4 + Cds*Cgs*Ls*Mce*s^4 + 2*Cgd*Cgs*Ls*Mce*s^4 + Cds*Cgs*Ls*Mgc*s^4 - Cds*Cgs*Ls*Mge*s^4 + 2*Cgd*Cgs*Ls*Mgc*s^4 - 2*Cgd*Cgs*Ls*Mge*s^4 + 2*Cds*Cgd*Mce*Mgc*s^4 - 2*Cds*Cgd*Mce*Mge*s^4 + 2*Cds*Cgs*Mce*Mgc*s^4 + 2*Cgd*Cgs*Mce*Mgc*s^4 + 2*Cgd*Cgs*Mce*Mge*s^4 - 2*Cds*Cgd*Mgc*Mge*s^4 - 2*Cds*Cgs*Mgc*Mge*s^4 - 2*Cgd*Cgs*Mgc*Mge*s^4 + Cds*Cgd*Lcr*Rg*s^3 + Cds*Cgd*Lg*Rcr*s^3 + Cds*Cgs*Lcr*Rg*s^3 + Cds*Cgs*Lg*Rcr*s^3 + Cds*Cgd*Ld*Rg*s^3 + Cds*Cgs*Ld*Rg*s^3 + Cgd*Cgs*Lcr*Rg*s^3 + Cgd*Cgs*Lg*Rcr*s^3 + Cgd*Cgs*Ld*Rg*s^3 + Cds*Cgs*Ls*Rcr*s^3 + Cgd*Cgs*Ls*Rcr*s^3 + Cgd*Cgs*Ls*Rg*s^3 + Cds*Cgd*Mce*Rcr*s^3 + Cds*Cgd*Mce*Rg*s^3 + Cds*Cgs*Mce*Rg*s^3 + Cds*Cgd*Mgc*Rcr*s^3 - Cds*Cgd*Mge*Rcr*s^3 + 2*Cds*Cgs*Mgc*Rcr*s^3 + 2*Cgd*Cgs*Mgc*Rcr*s^3 + Cds*Cgd*Mgc*Rg*s^3 - Cds*Cgd*Mge*Rg*s^3 + Cds*Cgs*Mgc*Rg*s^3 - Cds*Cgs*Mge*Rg*s^3 + 2*Cgd*Cgs*Mgc*Rg*s^3 + Cds*Cgd*Rcr*Rg*s^2 + Cds*Cgs*Rcr*Rg*s^2 + Cgd*Cgs*Rcr*Rg*s^2 + 1));
Vge_t = ilaplace(Vge);
figure(1);
Vge_tp = fplot(Vge_t, [0 1e-6]);
ylim([-5 10]);
grid on;
% hold on;
% Vge_tp1 = fplot(Vge_t1, [0 1e-6], 'LineWidth', 3);