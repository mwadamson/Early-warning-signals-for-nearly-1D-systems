function extinctionTimes = findextinctiontimesinrickershiftmap(parameterVector, timeRange, stateVariableRange, accuracy)

timeVector = timeRange(1):timeRange(2);
nTime = length(timeVector);
stateVector = stateVariableRange(1):accuracy:stateVariableRange(2);
attractorMinimum = zeros(nTime, 1);
criticalThreshold = zeros(nTime, 1);
extinctionTimes = [];
for iTime = 1:nTime
    time = timeVector(iTime);
    attractorInfo = getresilienceinfoforshiftedricker(stateVector, time, parameterVector) ;               %Attmin_CritThres... determines the attractor minimum and critical threshold for the system - fitting the Ricker map
    attractorMinimum(iTime) = attractorInfo(1);                                                 %with linearly changing parameters in time - for each time
    criticalThreshold(iTime) = attractorInfo(2);
    if iTime > 1 && attractorMinimum(iTime - 1) > criticalThreshold(iTime - 1) && attractorMinimum(iTime) < criticalThreshold(iTime)       %An extinction happens every time the attractor minimum drops below the critical threshold
        extinctionTimes = [extinctionTimes time];
    end
end
