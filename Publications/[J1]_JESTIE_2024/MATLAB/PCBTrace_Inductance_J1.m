clear; close; clc;
% Inductance of a trace calculator with 3D plot output
%% Variables
W = 0.19685: 1e-3: 1.9685; % Measurements in inches
L = 0.3937: 1e-3: 3.93701; % Measurements in inches
H = 0.0023622; % Measurements in inches

%% Equation of inductance of trace
L_trace = zeros(length(W), length(L));
for i = 1: length(W)
    for j = 1: length(L)
        L_trace(i, j) = 5.08*L(j)*(log((2*L(j))/(W(i) + H)) + 0.5 + 0.2235*(W(i) + H)/L(j));
        % Inductance in "Nanohenries"
    end
end
mesh(convlength(L.*10^3, 'in', 'm'), convlength(W.*10^3, 'in', 'm'), L_trace);
xlabel('Trace Length (L_t) [mm]');
ylabel('Trace Width (W_t) [mm]');
zlabel('Trace Inductance (L_t_r_a_c_e) [nH]');