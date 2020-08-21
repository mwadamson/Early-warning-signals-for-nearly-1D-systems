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
xInitial=1.09;

timeLength=3000;        %Time length

U0=600;
%U0=800; U1=0;               %False positive test 1
Uend=1100;     %Final soil phosphorous (after Brock & Carpenter, 2012) %when T=3000
%Uend=1183;      % If T=3500
%Uend=3000;     %Final soil phosphorous (after Brock & Carpenter, 2012)
soilPhosphorousRange = [U0 Uend];

c1=0.00115; c2=0.85; 
c3=0.019; c4=2.4; m=200; q=8;
parameterVec = [c1 c2 c3 c4 m q];

noiseIntensity=0.01;               


timeStep=0.05;
nTimeDelay=2;
timeDelay = nTimeDelay*timeStep;

% The first time series gives us the number of time points
timeSeriesArray = LakePhosphorousTimeSeriesGenerator(xInitial, timeStep, timeLength, noiseIntensity, soilPhosphorousRange, parameterVec);
timeSeriesMultiple = zeros(nTimeSeries, size(timeSeriesArray, 1), size(timeSeriesArray, 2));
timeSeriesMultiple(1, :, :) = timeSeriesArray;

for iTimeSeries = 2:nTimeSeries
    timeSeriesMultiple(iTimeSeries, :, :) = LakePhosphorousTimeSeriesGenerator(xInitial, timeStep, timeLength, noiseIntensity, soilPhosphorousRange, parameterVec);
end

figure(1)
hold on
for iTimeSeries = 1:nTimeSeries
    plot(timeSeriesMultiple(iTimeSeries, :, 1), timeSeriesMultiple(iTimeSeries, :, 2))
    xlabel('Time, t')
    ylabel('Phosphorous level, x(t)')
end
hold off


