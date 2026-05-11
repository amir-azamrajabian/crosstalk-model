clear; close; clc;
%% Resonance Converter
Lc = 280e-9; Vbus = 400; Iload = 20; CL = 227e-12; Rc = 1;
t = 0: 1e-13: 400e-9;
VCEL = zeros(1, length(t));
IL = zeros(1, length(t));

parfor i = 1: length(t)
    VCEL(i) = exp(-(t(i)*((CL^2*Rc^2 - 4*Lc*CL)^(1/2) + CL*Rc))/(2*CL*Lc))*((2*Lc*(Vbus - Iload*Rc))/(Rc*(CL^2*Rc^2 - 4*Lc*CL)^(1/2) - 4*Lc + CL*Rc^2) - (Lc*exp((t(i)*((CL^2*Rc^2 - 4*Lc*CL)^(1/2) + CL*Rc))/(2*CL*Lc))*(Iload*(CL^2*Rc^2 - 4*Lc*CL)^(1/2) + 2*CL*Vbus - CL*Iload*Rc))/(CL*(Rc*(CL^2*Rc^2 - 4*Lc*CL)^(1/2) - 4*Lc + CL*Rc^2))) - exp((t(i)*((CL^2*Rc^2 - 4*Lc*CL)^(1/2) - CL*Rc))/(2*CL*Lc))*((Lc*exp(-(t(i)*((CL^2*Rc^2 - 4*Lc*CL)^(1/2) - CL*Rc))/(2*CL*Lc))*(Iload*(CL^2*Rc^2 - 4*Lc*CL)^(1/2) - 2*CL*Vbus + CL*Iload*Rc))/(CL*(4*Lc + Rc*(CL^2*Rc^2 - 4*Lc*CL)^(1/2) - CL*Rc^2)) + (2*Lc*(CL^2*Rc^2 - 4*Lc*CL)^(1/2)*(Vbus - Iload*Rc))/((- CL*Rc^2 + 4*Lc)*((CL^2*Rc^2 - 4*Lc*CL)^(1/2) - CL*Rc)));
    IL(i) = (Iload*(CL^2*Rc^2 - 4*Lc*CL)^(1/2) - CL*Vbus*exp(-(t(i)*((CL^2*Rc^2 - 4*Lc*CL)^(1/2) + CL*Rc))/(2*CL*Lc)) + CL*Vbus*exp((t(i)*((CL^2*Rc^2 - 4*Lc*CL)^(1/2) - CL*Rc))/(2*CL*Lc)) + CL*Iload*Rc*exp(-(t(i)*((CL^2*Rc^2 - 4*Lc*CL)^(1/2) + CL*Rc))/(2*CL*Lc)) - CL*Iload*Rc*exp((t(i)*((CL^2*Rc^2 - 4*Lc*CL)^(1/2) - CL*Rc))/(2*CL*Lc)))/(CL^2*Rc^2 - 4*Lc*CL)^(1/2);
end

%% Variable definition - Numeric output
figure(1);
plot(t, VCEL, 'r-', 'LineWidth', 4);
hold on;
plot(t, IL, 'b-', 'LineWidth', 4);
grid on;
xlabel('Time (s)');
ylabel('Voltage & Current');
legend('Low-side collector-emitter voltage (V)', 'Inductance of circuit current (A)');