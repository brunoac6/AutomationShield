% Pseudorandom binary sequency for temperature
RoomTemperature = HeatShield.sensorRead();
MaxTemperature = 100;
Namplitudes = 50;
RandomTemperatures = RoomTemperature + (MaxTemperature-RoomTemperature).*rand(Namplitudes,1);

SamplesFactor = 1 + rand(Namplitudes,1);
MinHoldSamples = 50;
STH = round(MinHoldSamples*SamplesFactor);

Temperature = [];
for i=1:length(STH)
    Temperature = cat(2, Temperature, RandomTemperatures(i)*ones(1, STH(i)));
end

plot(Temperature)
