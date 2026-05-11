clc; clear; close;
%% Reading Values from Excel Files
sim1 = readmatrix('3DNR3.csv');
sim2 = readmatrix('3DNR4.csv');
sim3 = readmatrix('3DNR5.csv');
sim4 = readmatrix('3DNR6.csv');
sim5 = readmatrix('3DNR7.csv');
sim6 = readmatrix('3DNR8.csv');
sim7 = readmatrix('3DNR9.csv');
sim8 = readmatrix('3DNR10.csv');

%% Extracting the values from PSPICE
V1 = sim1(2, 2:42);
V2 = sim2(2, 2:42);
V3 = sim3(2, 2:42);
V4 = sim4(2, 2:42);
V5 = sim5(2, 2:42);
V6 = sim6(2, 2:42);
V7 = sim7(2, 2:42);
V8 = sim8(2, 2:41); V8(41) = -94.246;

V = [V1; V2; V3; V4; V5; V6; V7; V8];
RG = 3:10;
Le = 10:50;

%%3D Plot
f = figure;
surf(Le, RG, V);
colormap(f, flipud(colormap(f)));
colorbar;

xlabel('Emitter Inductance (nH)');
ylabel('Gate Resistance (Ω)');
zlabel('Gate-Emitter Negative Peak Voltage (V)');

fontname(gca, 'Times New Roman');
fontsize(30, 'points');
grid on;
grid minor;