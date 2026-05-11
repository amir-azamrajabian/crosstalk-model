%% This code shows Gate-Emitter Voltage under different conditions
clear; close; clc;
% Param. Definition
Rcr = 1; Lcr = 60e-9; % Circuit Losses
Lg = 3e-9; Ls = 8e-9; % Gate and Emmitter Inductances
Cgs = 3600e-12; Cds = 210e-12; Cgd = 54e-12; % Capacitances
% gfs = 14; Vth = 5.1; % Transconductance and Threshold Voltage
% Gate Side Parameters
Rg = 25;
tr = 100e-9;
Vbus = 400;

syms s;
% counter = 0; j = 1;
% time = zeros(1, 18); Peak_Voltage = zeros(1, 18); Esc = zeros(1, 18);
% for Vbus = 200: 50: 800
    Vge = (Cgd*Vbus*exp(-s*tr)*(exp(s*tr) - 1)*(Rg + Lg*s))/(s*tr*(Cds*Rcr*s + Cgd*Rcr*s + Cgd*Rg*s + Cgs*Rg*s + Cds*Lcr*s^2 + Cgd*Lcr*s^2 + Cgd*Lg*s^2 + Cgs*Lg*s^2 + Cgs*Ls*s^2 + Cds*Cgd*Lcr*Lg*s^4 + Cds*Cgs*Lcr*Lg*s^4 + Cgd*Cgs*Lcr*Lg*s^4 + Cds*Cgs*Lcr*Ls*s^4 + Cgd*Cgs*Lcr*Ls*s^4 + Cgd*Cgs*Lg*Ls*s^4 + Cds*Cgd*Lcr*Rg*s^3 + Cds*Cgd*Lg*Rcr*s^3 + Cds*Cgs*Lcr*Rg*s^3 + Cds*Cgs*Lg*Rcr*s^3 + Cgd*Cgs*Lcr*Rg*s^3 + Cgd*Cgs*Lg*Rcr*s^3 + Cds*Cgs*Ls*Rcr*s^3 + Cgd*Cgs*Ls*Rcr*s^3 + Cgd*Cgs*Ls*Rg*s^3 + Cds*Cgd*Rcr*Rg*s^2 + Cds*Cgs*Rcr*Rg*s^2 + Cgd*Cgs*Rcr*Rg*s^2 + 1));
    Vge_t = ilaplace(Vge);
    figure(1);
    Vge_tp = fplot(Vge_t, [0 1e-6],'LineWidth', 4);
    grid on;
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
% 
% Vbus2 = 200: 50: 800;
% % Results
% figure(2);
% plot(Vbus2, time);
% figure(3);
% plot(Vbus2, peak_Voltage);
% figure(4);
% plot(Vbus2, Esc);