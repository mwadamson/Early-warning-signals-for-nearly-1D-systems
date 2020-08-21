% This code produces and plots the probability of obtaining an acceptable
% error as a function of the length and the start time of the calibration
% window. It works for an ensemble of time series and averages the result.

% It takes as inputs the following variables generated by
% CalibWindowError_quadratic_multiplereplicates.m: 
% earliestTransitionTime
% startTimeVec 
% transitionTimeError 
% windowLengthVec 
% all saved under fileName

load('fisherycalibrationwindow1pctnoisemultiple.mat')

% This parameter sets the tolerance for a prediction to be considered
% acceptable and counted as a success.
acceptableError = 	500;

nTimeSeries = size(transitionTimeError, 1);
nCalibWindowStart = size(transitionTimeError, 2);
nCalibWindowLength = size(transitionTimeError, 3);

maxWindowTime = round(0.95 * earliestTransitionTime / 100) * 100;
if maxWindowTime > earliestTransitionTime
    maxWindowTime = floor(0.95 * earliestTransitionTime / 100) * 100;
end

% Since the start time and the window length are dependent (they must add
% up to the transition time), we need to limit their ranges when computing
% the averages to ranges where they are independent.

% format: PredictorVariable_SpecifiedVariableMax

windowLength_windowLengthMax = 1750;
windowLength_startTimeMax = maxWindowTime - windowLength_windowLengthMax;
startTime_startTimeMax = 1500;
startTime_windowLengthMax = maxWindowTime - startTime_startTimeMax;


WL_WLMaxFinder = windowLength_windowLengthMax * ones(1, nCalibWindowLength);
WL_STMaxFinder = windowLength_startTimeMax * ones(1, nCalibWindowStart);

ST_WLMaxFinder = startTime_windowLengthMax * ones(1, nCalibWindowLength);
ST_STMaxFinder = startTime_startTimeMax * ones(1, nCalibWindowStart);

[~, WL_WLMaxIndex] = min(abs(windowLengthVec - WL_WLMaxFinder));
[~, WL_STMaxIndex] = min(abs(startTimeVec - WL_STMaxFinder));
[~, ST_WLMaxIndex] = min(abs(windowLengthVec - ST_WLMaxFinder));
[~, ST_STMaxIndex] = min(abs(startTimeVec - ST_STMaxFinder));

fractionAcceptableErrorsWindowLength = zeros(WL_WLMaxIndex, 1);
fractionAcceptableErrorsStartTime = zeros(ST_STMaxIndex, 1);

% For loops follow the convention that the variable that is fixed comes
% first, then the variable that is averaged over.
% But 'i' always denotes the Start Time (1st dimension in ExtinctTimeError2
% ) and 'j' always denotes the Window Length
for iWindowLength = 1:WL_WLMaxIndex
    acceptableErrorSum = 0;
    for iTimeSeries = 1:nTimeSeries
        for iStartTime = 1:WL_STMaxIndex   % elements below the secondary diagonal are invalid because they correspond to
            % calibration windows which extend after the transition
            if ~isnan(transitionTimeError(iTimeSeries, iStartTime, iWindowLength)) && abs(transitionTimeError(iTimeSeries, iStartTime, iWindowLength)) <= acceptableError
                acceptableErrorSum = acceptableErrorSum + 1;
            end
        end
        fractionAcceptableErrorsWindowLength(iWindowLength) = acceptableErrorSum / WL_STMaxIndex / nTimeSeries;
    end
end

for iStartTime = 1:ST_STMaxIndex
    acceptableErrorSum = 0;
    for iTimeSeries = 1:nTimeSeries
        
        for iWindowLength = 1:ST_WLMaxIndex   % elements below the secondary diagonal are invalid because they correspond to
            % calibration windows which extend after the transition
            if ~isnan(transitionTimeError(iTimeSeries, iStartTime, iWindowLength)) && abs(transitionTimeError(iTimeSeries, iStartTime, iWindowLength)) <= acceptableError
                acceptableErrorSum = acceptableErrorSum + 1;
            end
        end
        fractionAcceptableErrorsStartTime(iStartTime) = acceptableErrorSum / ST_WLMaxIndex / nTimeSeries;
    end
end

figure(1)
subplot(1, 2, 1)
plot(windowLengthVec(1:WL_WLMaxIndex), fractionAcceptableErrorsWindowLength', 'LineWidth', 1.5)
xlabel('Calibration window length', 'fontsize', 14);
ylabel('Proportion of predictions within tolerance', 'fontsize', 14);
%title('(a)', 'FontSize', 14)
axis([0 windowLength_windowLengthMax 0 1])

subplot(1, 2, 2)
hold on
plot((startTimeVec(2:ST_STMaxIndex)) - earliestTransitionTime, fractionAcceptableErrorsStartTime(2:ST_STMaxIndex)', 'LineWidth', 1.5)
hold off
xlabel('Calibration window start time', 'fontsize', 14);
ylabel('Proportion of predictions within tolerance', 'fontsize', 14);
%title('(b)', 'FontSize', 14)
axis([-2790 -2790 + startTime_startTimeMax 0 1])