clear; close; clc;

SPICESimA = csvread('Analytical_Sim.csv', 2);
timeA = SPICESimA(:, 1);
VGEA = SPICESimA(:, 2);
