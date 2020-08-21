% Simulates the stochastic lake phosphorous system with noise in the
% nutrient recycling term
% and fits a nonstationary quadratic to the single delay map coordinates

% The outputs are i) the timeseries Zfull=[TimeVec X], TimeVec and X are column vectors
% ii) the values of the delay coordinates at times t and t+tau, Xfull and Yfull,
% both column vectors
% iii) the set of input times to the delay map Peaktimefull

% system should be a function outputting deterministic and stochastic parts
% of the SDE in the form [a; b];

nTimeSeries = 10;

%X0=0.81;
xInitial=1;

timeLength=5001;        %Time length



h0=0; hend=0.5;


harvestRange = [h0 hend];

r=13.5; a=0.03; beta=90; 

parameterVec = [r a beta];

noiseIntensity = 0.03;              

timeSeriesMultiple = zeros(nTimeSeries, timeLength, 2);

for iTimeSeries = 1:nTimeSeries
    timeSeriesMultiple(iTimeSeries, :, :) = Fisherytimeseriesgenerator(xInitial, timeLength, noiseIntensity, harvestRange, parameterVec);
end

figure(1)
hold on
for iTimeSeries = 1:nTimeSeries
    plot(timeSeriesMultiple(iTimeSeries, :, 1), timeSeriesMultiple(iTimeSeries, :, 2))
    xlabel('Time, t')
    ylabel('Population density, x(t)')
end
hold off


