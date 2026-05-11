 clear; close; clc;
% New Comprehensive Input
% The output is for SPICE application
% output format is .txt
% 1st part of the model is linear voltage drop (Approximation)
% 2nd part of the model is linear voltage drop (Approximation)
%% First pulse [0 4] us - (phase 0)
% Extracted from Cadence PSPICE
sim = readmatrix('VCE_First_Pulse.csv');
t0 = sim(:, 1);
V0 = sim(:, 2);

% Delay caused by the Rgate - Shifted phase correction
t0_1 = 4e-6 + 1e-10: 1e-10: 4.005e-6;
for i = 1: length(t0_1) % merging the vectors for having continuous output
    t0(40022 + i) = t0_1(i);
    V0(40022 + i) = 400;
end

%% Extracting the VCE voltage [4 4+tr] us - (phase 1) - Analytical equation
syms Iload Vbus Va tr gfs Vth CGC_avg Rgate Le Lc Vdriver;
VGP = Vth + Iload/(2*gfs);
a = (Vdriver - VGP)/(Rgate*CGC_avg);

eq1 = Iload == ((a*tr^2)/2)/(Le + Lc);
eq2 = tr*(Vdriver - VGP)/(Rgate) == CGC_avg*(Vbus - Va);
sol1 = solve([eq1 eq2], [tr Va]);
tr = sol1.tr; Va = sol1.Va;

%% Variable definition - Numeric output
Lc = 100e-9; Vdriver = 20; Le = 3e-9; Rgate = 20; Vth = 5; gfs = 20; Vbus = 400; Iload = 22;

%% Cgc definition
syms COXD Xparam
% Values extracted from datasheet - IXGH60N60C2 IGBT IXYS company
eq3 = 97e-12 == (COXD*(Xparam/sqrt(25)))/(COXD + Xparam/sqrt(25));
eq4 = 89e-12 == (COXD*(Xparam/sqrt(30)))/(COXD + Xparam/sqrt(30));
sol2 = solve([eq3 eq4], [COXD Xparam]);

COXD = double(vpa(subs(sol2.COXD), 5)); % Gate-collector oxide capacitor
Xparam = double(vpa(subs(sol2.Xparam), 5)); % Constant values - calculated with solving 3 equations based on datasheet

VCE = 25: 1e-3: Vbus; % Collector-emitter voltage
CGCJ = zeros(1, length(VCE));
CGC = zeros(1, length(VCE));
for i = 1: length(VCE)
    CGCJ(i) = Xparam/sqrt(VCE(i) - Vth); % Gate-collector junction capacitor
    CGC(i) = (COXD*CGCJ(i))/(COXD + CGCJ(i));
end
CGC_avg = mean(CGC);

%% Phase 1 orientation - [tr Va] approximation
tr = double(vpa(subs(tr), 5)); Va = double(vpa(subs(Va), 5));
for i = 1: length(tr)
    if tr(i) > 0 && Va(i) < Vbus && Va(i) > 0
        disp(['tr = ', num2str(tr(i)), ' (s)']);
        disp(['Va = ', num2str(Va(i)), ' (V)']);
    else
        tr(i) = []; Va(i) = [];
    end
end

t1 = t0(40072) + 1e-10: 1e-10: t0(40072) + tr;
VQH = Vbus - double(vpa(subs(a), 5))*(t1 - t0(40072));
for i = 1: length(t1) % merging the vectors for having continuous output 
    t0(40072 + i) = t1(i);
    V0(40072 + i) = VQH(i);
end

%% Phase 2 orientation - [4+tr t]
% This is from previous model introduced in EPE Conference paper
% Instead of VBus we should use Va, and instead of trise we need to use
% trise - tr

%% Plotting the final result
plot(t0, V0, 'r-', 'LineWidth', 4);
grid on;
xlabel('Time (s)');
ylabel('Collector-emitter voltage of the high-side switch (V)');

%% Write data in the text file
dataPoints = [t0'; V0'];
fileID = fopen('Input_Values.txt', 'w');
fprintf(fileID, '%10.35f %30.25f\n', dataPoints);