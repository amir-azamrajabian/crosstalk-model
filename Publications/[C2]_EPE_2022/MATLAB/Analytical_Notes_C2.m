clear; close; clc;

SPICEsim1 = csvread('Analytical_Mod.csv', 2);
time1 = SPICEsim1(:, 1);
VGE1 = 2*SPICEsim1(:, 2);

SPICEsim2 = csvread('SPICE.csv', 2);
time2 = SPICEsim2(:, 1);
VGE2 = 2*1.15*SPICEsim2(:, 2);

% SPICEsim3 = csvread('ALL0001.csv', 19);
% time3 = SPICEsim3(:, 1) + 125e-9;
% VGE3 = .24*(SPICEsim3(:, 2) - 1.2);

figure(1);
plot(time1, VGE1, 'r-', 'LineWidth', 4);
hold on;
plot(time2, VGE2, 'b--', 'LineWidth', 4);
% plot(time3, VGE3, 'LineWidth', 4);
xlim([0 1e-6]);
xlabel('time(s)');
ylabel('Gate-Emitter Voltage (V)');
grid on;
legend('Analytical Model', 'PSPICE');