clear; clear; close all;

HeatShield = HeatShield;
HeatShield.begin();

Tsamples = 0.01;
Nsamples = 1000;

V = ones(1, Nsamples);
R = ones(1, Nsamples);
T = ones(1, Nsamples);

figure(1);
for i=1:Nsamples
    V(i) = HeatShield.getThermistorVoltage();
    R(i) = HeatShield.getThermistorResistance();
    T(i) = HeatShield.sensorRead();
    subplot(3,1,1); plot(i, V(i), 'x'); hold on;
    subplot(3,1,2); plot(i, R(i), 'x'); hold on;
    subplot(3,1,3); plot(i, T(i), 'x'); hold on;
    pause(Tsamples);
end
hold off;
% 
% %%
% figure(2)
% A = V;
% x = 1:Nsamples;
% [TF,L,U,C] = isoutlier(A, 'movmedian', 100);
% plot(x,A,x(TF),A(TF),'x',x,L*ones(1,Nsamples),x,U*ones(1,Nsamples),x,C*ones(1,Nsamples))
% legend('Original Data','Outlier','Lower Threshold','Upper Threshold','Center Value')