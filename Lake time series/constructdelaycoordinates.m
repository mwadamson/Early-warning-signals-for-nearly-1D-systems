function delayMapFull = constructdelaycoordinates(timeSeriesArray, nTimeDelay)
% This function outputs delay coordinates y_{t-\tau} = x_t, along with the
% times corresponding to the x values. 
% timeSeriesArray is an nTime x 2 array, with the times in column 1 and the
% values of the state variable in column 2.
% timeDelay is the time delay expressed *in No of time steps*.

timeVec = timeSeriesArray(:, 1);
nTime = length(timeVec);

delayCoordsX = timeSeriesArray(1 : nTime - nTimeDelay, 2);
delayCoordsY = timeSeriesArray(1 + nTimeDelay : nTime, 2);
delayXTimes  = timeSeriesArray(1 : nTime - nTimeDelay, 1);

delayMapFull=[delayCoordsX delayCoordsY delayXTimes];