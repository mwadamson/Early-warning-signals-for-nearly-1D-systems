function timeSeriesArray = LakePhosphorousTimeSeriesGenerator(xInitial, timeStep, timeLength, noiseIntensity, soilPhosphorousRange, parameterVec)

U0 = soilPhosphorousRange(1);
Uend = soilPhosphorousRange(2);
U1 = (Uend - U0)/timeLength;

c1 = parameterVec(1); c2 = parameterVec(2); c3 = parameterVec(3); c4 = parameterVec(4); m = parameterVec(5); q = parameterVec(6); 

timeVector=(0:timeStep:timeLength)';
nTime = timeLength/timeStep + 1;

X = zeros(nTime, 1);
X(1) = xInitial;

for i = 1:nTime - 1
    Vector = LakephosphorousSDE(X(i), timeStep*(i-1), [U0 U1 c1 c2 c3 c4 m q], noiseIntensity);
    deterministicComponent = Vector(1); stochasticComponent = Vector(2);
    whiteNoise = randn;
    
    X(i+1) = X(i) + deterministicComponent*timeStep + timeStep*stochasticComponent.*whiteNoise;
end
timeSeriesArray = [timeVector, X];