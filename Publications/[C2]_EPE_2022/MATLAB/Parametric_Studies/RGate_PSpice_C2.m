clear; close; clc;
%% Results in Pspice
Rg = 5: 40;
Vge = [10.517 9.3414 8.4185 9.1746 9.2232 8.8412 8.4548 8.112 8.3288 8.5717 8.4057 8.1969 7.9835 7.9646 8.2529 8.2116 8.0676 7.9259 7.779 8.0576 8.1031 7.9945 7.8862 7.779 7.9202 8.0154 7.9549 7.8614 7.7745 7.8186 7.9426 7.9237 7.8503 7.7723 7.7454 7.8809];

figure(1);
plot(Rg, Vge, 'LineWidth', 2);
title('Effect of Gate Resistance and rise time on Gate-Emitter Voltage');
xlabel('Rg');
ylabel('Vge');