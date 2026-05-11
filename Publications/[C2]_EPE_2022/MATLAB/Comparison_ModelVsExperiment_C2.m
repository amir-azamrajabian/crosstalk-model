clear; close; clc;

SPICESimA = csvread('Analytical_Sim.csv', 2);
timeA = SPICESimA(:, 1);
VGEA = SPICESimA(:, 2);

SPICESimE = csvread('Exp_Sim.csv', 2);
timeE = SPICESimE(:, 1);
VGEE = SPICESimE(:, 2);

SPICESimEE = csvread('Fourth_State.csv', 2);
timeEE = SPICESimEE(:, 1) + 2.1e-7;
VGEEE = SPICESimEE(:, 2) + 20.32;

figure(1);
plot(timeA, VGEA, 'LineWidth', 4);
hold on;
plot(timeE, VGEE, 'LineWidth', 4);
plot(timeEE, VGEEE, 'LineWidth', 4);
xlim([0 1e-6]);
xlabel('time');
ylabel('Gate-Emitter Voltage');
grid on;
legend('Analytical Model', 'Realistic Model', 'Experiment');