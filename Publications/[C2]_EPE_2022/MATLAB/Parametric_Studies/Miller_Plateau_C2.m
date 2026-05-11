clear; close; clc;
%% Correlation between T_rise and R_gate - Parameters
Cgdt25 = 132e-12; Cgdt600 = Cgdt25/sqrt(25*600); Cgd = (Cgdt25 + Cgdt600)/2
Vbus = 600;
Vth = 5.8; gfs = 14; I = 40; Rg = 10;
%% t_rise Equation
Vmill = Vth + I/gfs;
tmill = Rg*(Vbus*Cgd)/(15 - Vmill)