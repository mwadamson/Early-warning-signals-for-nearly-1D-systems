function timeSeriesArray = Fisherytimeseriesgenerator(xInitial, nTime, noiseIntensity, harvestRange, parameterVec)

r = parameterVec(1); a = parameterVec(2); beta = parameterVec(3); 
h0 = harvestRange(1); hEnd = harvestRange(2); 
h1 = (hEnd - h0)/(nTime - 1);

timeSeriesArray = zeros(nTime, 2);
timeSeriesArray(1, 2) = xInitial;

for iTime = 1:nTime-1
    Hold = fisherymap(timeSeriesArray(iTime, 2), iTime, [r 0 a 0 beta 0 h0 h1]);
    timeSeriesArray(iTime+1,1) = Hold(1);
    timeSeriesArray(iTime+1,2) = (1 + noiseIntensity*randn)*Hold(2);
end


