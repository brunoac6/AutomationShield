clear; clc; close all;

HeatShield=HeatShield;                      % Construct object from class
HeatShield.begin();                         % Initialize shield

fileName = '../images/pid';
plotRealtime = false;

R = [HeatShield.sensorRead()*ones(1,100), 40*ones(1,400), 60*ones(1,400), HeatShield.sensorRead()*ones(1,300)];
D = [0*ones(1,100), 0*ones(1,200), 100*ones(1,200), 0*ones(1,400), 100*ones(1,300)];
Ts = 0.5;

if length(R) ~= length(D)
    disp("Dimensions of input signals don't meet.")
    return;
end

t = Ts*(0:1:length(R)-1); % time vector

Y = zeros(1, length(R));
E = zeros(1, length(R));
U = zeros(1, length(R));
Uc = zeros(1, length(R));
Treal = zeros(1, length(R));

Kp = 5;      % PID Gain
Ti = 30.0;    % PID Integral time constant
Td = 1.0;     % PID Derivative time constant
umax = 100;   % Maximum input
umin = 0;     % Minimum input

fileID = fopen([fileName '.txt'],'w');

fprintf(fileID, 'SIMULATION PARAMETERS:\n\n');
fprintf(fileID, 'Start time: %s \n', datetime());
fprintf(fileID, 'This test will take %0.5g minutes to finish.\n\n', Ts*length(R)/60);
fprintf('This test will take %0.5g minutes to finish.\n\n', Ts*length(R)/60);
fprintf(fileID, 'Ts = %0.5g s\n', Ts);
fprintf(fileID, 'Kp = %0.5g s\n', Kp);
fprintf(fileID, 'Ti = %0.5g s\n', Ti);
fprintf(fileID, 'Td = %0.5g s\n', Td);

% u(k) = K_p \left[ \frac{T_s}{T_I} \sum_{v=0}^{k} e(v) + \frac{T_D}{T_s} \left(e(k) - e(k-1) \right) \right ]
% Ki = \frac{K_p}{T_i} and K_d = K_p T_d

for i=2:length(R)
    tic;
    HeatShield.fanActuator(D(i));
    Y(i) = HeatShield.sensorRead();
    E(i) = R(i) - Y(i);
    % Integral term
    I = 0;
    for v=1:i
        I = I + E(v);
    end
    U(i) = Kp*(E(i) + (Ts/Ti)*I + (Td/Ts)*(E(i) - E(i-1)));
    Uc(i) = constrain(U(i), 0, 100);
    HeatShield.cartrigeActuator(Uc(i));
    Treal(i) = toc;
    pause(Ts - Treal(i));
    
    %%% Plot 
    if ~plotRealtime
        continue;
    end
    subplot(4,1,1); 
        plot(i, R(i), 's', 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue', 'MarkerSize', 2); hold on; grid on;
        plot(i, Y(i), '*'); hold on; grid on;
        title('Output Singal - Reference (blue) / Measured (asterisk)'); xlabel('Samples'); ylabel('Temperature �C');
    subplot(4,1,2); 
        plot(i, D(i), 'o', 'MarkerFaceColor', 'red', 'MarkerEdgeColor','red', 'MarkerSize', 2); hold on; grid on;
        title('Disturb Signal'); xlabel('Samples'); ylabel('Percentage');
    subplot(4,1,3); 
        plot(i, E(i), 'o', 'MarkerFaceColor', 'red', 'MarkerEdgeColor','red', 'MarkerSize', 2); hold on; grid on;
        title('Error'); xlabel('Samples'); ylabel('Temperature �C');
    subplot(4,1,4); 
        plot(i, U(i), 'o', 'MarkerFaceColor', 'red', 'MarkerEdgeColor','red', 'MarkerSize', 2); hold on; grid on;
        title('Control Effort'); xlabel('Samples'); ylabel('Percentage');
end
hold off;
%%%%%% TURN OFF HARDWARE
HeatShield.cartrigeActuator(0);
HeatShield.fanActuator(0);
disp("Test ended.")

%% Saving to csv file
T = table(R', Y', D', E', U', Uc');
T.Properties.VariableNames = {'Reference', 'Measured', 'Disturb', 'Error', ...
    'Control_Effort', 'Constrained_Control_Effort'};
T.Properties.UserData = ['Data sampled every ' num2str(Ts) ' second(s)'];
writetable(T, [fileName '.csv']);

%%
figure('Units', 'pixels', 'Position', [0 0 602 698], 'PaperPositionMode', 'auto');
subplot(4,1,1);
    plot(t, R, 'LineWidth', 2, 'Color', 'blue'); hold on;
    plot(t, Y, 'o', 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red', 'MarkerSize', 2); grid on;
    title('Reference (blue) / Measured (red)'); xlabel('Time [s]'); ylabel('Temperature [�C]');
subplot(4,1,2);
    plot(t, D, 'LineWidth', 2, 'Color', 'red'); grid on;
    axis([0 length(R)*Ts 0 100]);
    title('Disturb'); xlabel('Time [s]'); ylabel('Percentage');
subplot(4,1,3);
    plot(t, E, 'LineWidth', 2, 'Color', 'blue'); grid on;
    title('Error'); xlabel('Time [s]'); ylabel('Temperature [�C]');
subplot(4,1,4);
    plot(t, Uc, 'LineWidth', 2, 'Color', 'green'); grid on;hold on;
    plot(t, U, 'LineWidth', 1, 'Color', 'magenta'); 
    legend('Unconstrained Control Effort', 'Constrained Control Effort');
    axis([0 length(R)*Ts -300 300]);
    title('Control Effort'); xlabel('Time [s]'); ylabel('Percentage');
print([fileName '.eps'], '-depsc');
print([fileName '.jpg'], '-djpeg');
print([fileName '.svg'], '-dsvg');