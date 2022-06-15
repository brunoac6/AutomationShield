clear; clc; close all;

HeatShield = HeatShield;
HeatShield.begin();

Tsamples = 2;

fileName = 'cartridge-fan_response';

cartridgeBehaviourValue = [0*ones(1,50), 60*ones(1,450), 20*ones(1,200), 0*ones(1,300)];
fanBehaviourValue = [0*ones(1,50), 0*ones(1,100), 100*ones(1,50), 0*ones(1,300), 40*ones(1,300), 100*ones(1,200)];

if length(cartridgeBehaviourValue) ~= length(fanBehaviourValue)
    disp("Dimensions of input signals don't meet.")
    return;
end

Nsamples = length(cartridgeBehaviourValue);
Temp = zeros(1, Nsamples);

fprintf('This test will take %0.5g minutes to finish.\n', Tsamples*Nsamples/60)

figure(1);
for i=1:Nsamples
    HeatShield.cartrigeActuator(cartridgeBehaviourValue(i));
    HeatShield.fanActuator(fanBehaviourValue(i));
    Temp(i) = HeatShield.sensorRead();
    subplot(2,1,1); 
        plot(i, Temp(i), 'x'); hold on; grid on;
        title('Output Singal'); xlabel('Samples'); ylabel('Temperature ºC');
    subplot(2,1,2); 
        plot(i, cartridgeBehaviourValue(i), 'o', 'MarkerFaceColor', 'red', 'MarkerEdgeColor','red'); hold on; grid on;
        plot(i, fanBehaviourValue(i), 's', 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue'); hold on; grid on;
        title('Input and Disturb Signals'); xlabel('Samples'); ylabel('Percentage');
    pause(Tsamples);
end
hold off;
%%%%%% TURN OFF HARDWARE
HeatShield.cartrigeActuator(0);
HeatShield.fanActuator(0);
disp("Test ended.")

%% Saving to csv file
T = table(cartridgeBehaviourValue', fanBehaviourValue', Temp');
T.Properties.VariableNames = {'ActuatorCartrige', 'ActuatorFan', 'Temperature'};
T.Properties.UserData = ['Data sampled every ' num2str(Tsamples) ' second(s)'];
writetable(T, [fileName '.csv']);

%%
figure(2);
subplot(2,1,1);
    plot(Temp, 'LineWidth', 1.5); grid on; 
    title(['Output Singal - sampled every ' num2str(Tsamples) ' second(s)']); 
    xlabel('Samples'); ylabel('Temperature ºC');
subplot(2,1,2);
    plot(cartridgeBehaviourValue, 'LineWidth', 1.5); grid on; hold on; 
    plot(fanBehaviourValue, 'LineWidth', 1.5);
    title('Input [Heater] and Disturb [Fan] Signals');
    xlabel('Sample'); ylabel('Percentage'); legend('Heater', 'Fan');
print([fileName '.eps'], '-depsc');
print([fileName '.jpg'], '-djpeg');