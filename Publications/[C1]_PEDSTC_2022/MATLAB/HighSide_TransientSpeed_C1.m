clc; clear; close;
V_peakg = [9.987 9.3534 8.8015 9.619 10.058 10.140 9.961 9.673 9.4026 9.1460 8.9012 8.6689 8.8142 9.1817 9.3410 9.3206 9.1826 9.0276 8.8775 8.7307 8.5882 8.5262 8.8252 8.9909 9.0266 8.9595 8.8527 8.7474 8.6435 8.5417 8.4556 8.6333 8.7918 8.8535 8.8292 8.7531 8.6724 8.5922 8.5133];
Rg = 10: 48;
time = 46.*Rg./12;
figure(1);
plot(time, V_peakg, 'r-', 'LineWidth', 3);
title('Effect of High-Side Transient Device on Gate-Emitter Voltage');
ylabel('Gate-Emitter Voltage (V)');
xlabel('High-Side Device Transient Time (ns)');