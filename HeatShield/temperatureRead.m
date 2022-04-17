clear;

HeatShield = HeatShield;
HeatShield.begin();

MA = 10;
Tsamples = 0.1;
for i=1:1000
    y = 0;
%    for j=1:MA
        y = y + HeatShield.getThermistorVoltage();
%        pause(0.01);
%    end
    y = y/MA;
    Y(i) = y;
    plot(i,y, 'o');
    pause(Tsamples);
    hold on;
end