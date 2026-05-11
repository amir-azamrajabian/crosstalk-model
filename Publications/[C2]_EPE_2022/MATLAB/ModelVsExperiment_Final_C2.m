clear; close; clc;

SPICESimA = csvread('ALL0001.csv', 2);
timeA = SPICESimA(:, 1) + 110e-9;
VGEA = SPICESimA(:, 2) - 0.8;

SPICESimE = csvread('ALL0002.csv', 2);
timeE = SPICESimE(:, 1) + 110e-9;
VGEE = SPICESimE(:, 2) - 0.8;

SPICESimEE = csvread('ALL0003.csv', 2);
timeEE = SPICESimEE(:, 1) + 120e-9;
VGEEE = SPICESimEE(:, 2) - 0.7 ;

figure(1);
plot(timeA, VGEA, 'LineWidth', 4);
hold on;
plot(timeE, VGEE, 'LineWidth', 4);
plot(timeEE, VGEEE, 'LineWidth', 4);
xlim([0 1e-6]);