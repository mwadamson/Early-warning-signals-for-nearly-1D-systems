% clear all

% This code computes the error in the predicted extinction time of the
% method when different windows of an ensemble time series are used to
% calibrate the model. The window is determined by the start
% time and window length.

% The file to be loaded should contain a 3D array named timeSeriesMultiple
% which should have the time series index in dimension 1, the time in
% dimension 2, and the time series measurement in dimension 3
close all
fileName = 'LakePhosphorousTimeSeries_pt5pctNoise_Multiple.mat';
load(fileName)
windowPlotResolution = 200;

% The resolution of the calibration window heat map, greater numbers mean a
% finer grid. For the paper, this should be 250. For testing, as low as 10
% will do.
errorTruncationLevel = 2750;
% The maximal absolute value of the error to be plotted.
missedTransitionError = 5000;

nTimeSeries = size(timeSeriesMultiple, 1);

% First we determine the earliest time at which we see a transition in any
% of the time series so that we can take the length and start time of the
% calibration window over the same range for all of them.

trueTransitionTimeVector = zeros(nTimeSeries, 1);
for iTimeSeries = 1 : nTimeSeries
    trueTransitionTimeVector(iTimeSeries) = getTransitionTime(squeeze(timeSeriesMultiple(iTimeSeries, :, :)), 0.2);
end

earliestTransitionTime = min(trueTransitionTimeVector);

maxWindowTime = round(0.95 * earliestTransitionTime / 100) * 100;
if maxWindowTime > earliestTransitionTime
    maxWindowTime = floor(0.95 * earliestTransitionTime / 100) * 100;
end

timeSeriesStartTime = timeSeriesMultiple(1, 1, 1);

if ~all(timeSeriesMultiple(:, 1, 1) == timeSeriesStartTime)
    error('At least one of the time series starts at a different time to the others.')
end

step = (maxWindowTime - timeSeriesStartTime) / windowPlotResolution;               %The step length for the calibration window times used

endStartTime = maxWindowTime - step;
% The final start time is one step before the maximum window time, while
% step serves as the minimum window time.

startTimeVec = timeSeriesStartTime : step : endStartTime;  %The vector of start times considered for the calibration window
windowLengthVec = step : step : maxWindowTime - timeSeriesStartTime;          %construct a vector for the different time window lengths

% The three different error arrays serve different purposes:
% transitionTimeError stores the errors as they are. ...Truncated cuts off
% the errors at the level determined by errorTruncationLevel for more
% informative plots. ...WithoutNaN truncates the errors like
% errorTruncationLevel, and also assigns missed predictions an error
% determined by missedTransitionError so that the average prediction error
% can still be computed for these calibration windows.

transitionTimeError = NaN(nTimeSeries, length(startTimeVec), length(windowLengthVec));
transitionTimeErrorTruncated = transitionTimeError;
transitionTimeErrorWithoutNaN = transitionTimeError;

tic

for iTimeSeries = 1 : nTimeSeries
    currentTimeSeries = squeeze(timeSeriesMultiple(iTimeSeries, :, :));
    
    delayMapFull = constructdelaycoordinates(currentTimeSeries, 2);
    
    delayXCoords = delayMapFull(:, 1);
    delayYCoords = delayMapFull(:, 2);
    delayXTimes = delayMapFull(:, 3);
    
    trueTransitionTime = trueTransitionTimeVector(iTimeSeries);
    
    % we only use 95% of the time series up to the transition, rounded to the
    % nearest '100', unless this is past the transition (if the transition
    % happens before t = 1000)
    
    for iStartTime = 1 : length(startTimeVec)
        startTime = startTimeVec(iStartTime);                    %denotes the start time for the current calibration window
        for jWindowTime = 1 : length(startTime : step : maxWindowTime) - 1       %-1 because we're counting the number of steps between length(StartTime:step:EndTime) nodes
            
            totalTime = startTime + jWindowTime*step;           %denotes the total length of the current calibration window
            
            iPeakTime = 1;
            iPeakStart = 0;
            
            while iPeakStart == 0                  %this loop finds the index of the first peak in the current time window
                if delayXTimes(iPeakTime) >= startTime
                    iPeakStart = iPeakTime;
                end
                iPeakTime = iPeakTime + 1;
            end
            
            iPeakEnd = iPeakStart;
            
            while iPeakEnd == iPeakStart       %this loop finds the index of the last peak in the current time window
                if delayXTimes(iPeakTime) >= totalTime || iPeakTime == length(delayXTimes)
                    iPeakEnd = iPeakTime;
                end
                iPeakTime = iPeakTime + 1;
            end
            
            iPeakTime = 1;
            seriesStartElement = 0;                        %This loop finds the index of the start time of the current time window, in the total time vector
            while seriesStartElement == 0
                if currentTimeSeries(iPeakTime, 1) >= startTime
                    seriesStartElement = iPeakTime;
                end
                iPeakTime = iPeakTime + 1;
            end
            
            seriesEndElement = seriesStartElement;
            while seriesEndElement == seriesStartElement     %This loop finds the index of the end time of the current time window, in the total time vector
                if currentTimeSeries(iPeakTime, 1) >= totalTime  || iPeakTime == length(currentTimeSeries)
                    seriesEndElement = iPeakTime;
                end
                iPeakTime = iPeakTime + 1;
            end
            
            iPeakTime = [];
            
            delayXTimesWindow = delayXTimes(iPeakStart : iPeakEnd);     %Restricts the  peak values to the current time window
            delayXCoordsWindow = delayXCoords(iPeakStart : iPeakEnd);
            delayYCoordsWindow = delayYCoords(iPeakStart : iPeakEnd);
            
            paramVec = fitnonstationaryquadraticmap(delayXTimesWindow, delayXCoordsWindow, delayYCoordsWindow, [-1 0 1 0 1 0]');    %Find the parameters of the quadratic map with linearly changing parameters in time,
            %according to the peak-to-peak map in the current time series window
            
            extinctionTimeVector = getextinctiontimeviasaddlenode(paramVec);     %getextinctiontimeviasaddlenode detects the saddle-node bifurcation times in the quadratic map
            
            if length(extinctionTimeVector) == 1
                extinctTime = extinctionTimeVector;
            elseif length(extinctionTimeVector) > 1
                if extinctionTimeVector(1) > 0 && extinctionTimeVector(2) < 0
                    extinctTime = extinctionTimeVector(1);
                elseif extinctionTimeVector(2) > 0 && extinctionTimeVector(1) < 0
                    extinctTime = extinctionTimeVector(2);
                else
                    extinctTime = NaN;
                end
            else
                
            end
            
            transitionTimeError(iTimeSeries, iStartTime, jWindowTime) = extinctTime - trueTransitionTime;     %The error in the predicted extinction time is just the difference between it and the true extinction time
            
            if extinctTime - trueTransitionTime > errorTruncationLevel
                transitionTimeErrorTruncated(iTimeSeries, iStartTime, jWindowTime)  = errorTruncationLevel;
                transitionTimeErrorWithoutNaN(iTimeSeries, iStartTime, jWindowTime) = errorTruncationLevel;
            elseif extinctTime - trueTransitionTime < -errorTruncationLevel
                transitionTimeErrorTruncated(iTimeSeries, iStartTime, jWindowTime)  = -errorTruncationLevel;
                transitionTimeErrorWithoutNaN(iTimeSeries, iStartTime, jWindowTime) = -errorTruncationLevel;
            else
                transitionTimeErrorTruncated(iTimeSeries, iStartTime, jWindowTime)  = extinctTime - trueTransitionTime;
                if isnan(extinctTime)
                    transitionTimeErrorWithoutNaN(iTimeSeries, iStartTime, jWindowTime) = missedTransitionError;
                else
                    transitionTimeErrorWithoutNaN(iTimeSeries, iStartTime, jWindowTime) = extinctTime - trueTransitionTime;
                end
            end
        end
    end
end

nTimeSeries = size(timeSeriesMultiple, 1);
% Plot the errors for each time series separately.
for iTimeSeries = 1:nTimeSeries
    figure()
    
    [~, h1] = contourf((startTimeVec') - trueTransitionTimeVector(iTimeSeries), windowLengthVec', squeeze(transitionTimeErrorTruncated(iTimeSeries, :, :))', 80);
    set(h1, 'linestyle', 'none');
    
    set(gca, 'fontsize', 12)
    set(gca, 'YDir', 'normal')                                %only for use with imagesc - which flips the y axis
    
    colormap('jet')
    colorbar
    
    xlabel('Start time of calibration window relative to transition', 'fontsize', 14);
    ylabel('Calibration window length', 'fontweight', 'bold', 'fontsize', 14);
    numberString = num2str(iTimeSeries);
    title({'Error in the predicted transition time' ' ' ; 'for time series number ' numberString})
end

% Compute the average error and plot it.

averageTransitionTimeError = squeeze(sum(transitionTimeErrorWithoutNaN)) / nTimeSeries;
figure()

[~, h1] = contourf((startTimeVec') - earliestTransitionTime, windowLengthVec', averageTransitionTimeError', 80);
set(h1, 'linestyle', 'none');

set(gca, 'fontsize', 12)
set(gca, 'YDir', 'normal')                               

colormap('jet')
colorbar

xlabel('Start time of calibration window relative to transition', 'fontsize', 14);
ylabel('Calibration window length', 'fontsize', 14);
title({'Average signed error in the predicted'; 'transition time over all time series'});

% Compute the average absolute error and plot it.

averageAbsoluteTransitionTimeError = squeeze(sum(abs(transitionTimeErrorWithoutNaN))) / nTimeSeries;
figure()

[c1, h1] = contourf((startTimeVec') - earliestTransitionTime, windowLengthVec', averageAbsoluteTransitionTimeError', 80);
set(h1, 'linestyle', 'none');

set(gca, 'fontsize', 12)
set(gca, 'YDir', 'normal')                                %only for use with imagesc - which flips the y axis

colormap('jet')
colorbar

xlabel('Start time of calibration window relative to transition', 'fontsize', 14);
ylabel('Calibration window length', 'fontsize', 14);
title({'Average absolute error in the predicted transition time' ; 'over all time series'});

toc