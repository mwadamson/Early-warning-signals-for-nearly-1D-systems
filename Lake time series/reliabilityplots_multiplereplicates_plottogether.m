% This code produces and plots the probability of obtaining an acceptable
% error as a function of the length and the start time of the calibration
% window. It works for an ensemble of time series and averages the result.

% This version of the code plots the results from time series ensembles of
% different noise levels in the same figure.

% It takes as inputs the following variables generated by
% CalibWindowError_quadratic_multiplereplicates.m: 
% earliestTransitionTime
% startTimeVec 
% transitionTimeError 
% windowLengthVec 
% all saved under an element of fileNames

fileNames = {'LakePhosphorousCalibWindowError_pt5pctNoise_multiple.mat', 'LakePhosphorousCalibWindowError_1pctNoise_multiple.mat', 'LakePhosphorousCalibWindowError_2pctNoise_multiple.mat'};
LineStyles = {'-', '--', ':'};

% This parameter sets the tolerance for a prediction to be considered
% acceptable and counted as a success.
acceptableError = 	500;

overallEarliestTransitionTime = 0;
for iFile = 1:length(fileNames)
    load(fileNames{iFile})
    if overallEarliestTransitionTime == 0 || earliestTransitionTime < overallEarliestTransitionTime
        overallEarliestTransitionTime = earliestTransitionTime;
    end
end

for iFile = 1:length(fileNames)
    
    load(fileNames{iFile})
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
    
    % naming format: PredictorVariable_SpecifiedVariableMax
    
    windowLength_windowLengthMax = 2000;
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

    fractionAcceptableErrorsWindowLength = getreliabilitywindowlength(transitionTimeError, WL_WLMaxIndex, WL_STMaxIndex, acceptableError);
    fractionAcceptableErrorsStartTime = getreliabilitystarttime(transitionTimeError, ST_WLMaxIndex, ST_STMaxIndex, acceptableError);
    
    figure(5)
    subplot(1, 2, 1)
    if iFile > 1
        hold on
    end
    plot(windowLengthVec(1:WL_WLMaxIndex), fractionAcceptableErrorsWindowLength', 'LineWidth', 1.5, 'LineStyle', LineStyles{iFile})
    xlabel('Calibration window length', 'fontsize', 14);
    ylabel('Proportion of predictions within tolerance', 'fontsize', 14);
    title({'Reliability of predictions for a given window length'; 'averaged over window start times'})
    axis([0 windowLength_windowLengthMax 0 1])
    hold off
    
    subplot(1, 2, 2)
    if iFile > 1
        hold on
    end
    plot((startTimeVec(2:ST_STMaxIndex)) - overallEarliestTransitionTime, fractionAcceptableErrorsStartTime(2:ST_STMaxIndex)', 'LineWidth', 1.5, 'LineStyle', LineStyles{iFile})
    xlabel('Calibration window start time', 'fontsize', 14);
    ylabel('Proportion of predictions within tolerance', 'fontsize', 14);
    title({'Reliability of predictions for a given window start time'; 'averaged over window lengths'})
    axis([-overallEarliestTransitionTime, -overallEarliestTransitionTime + startTime_startTimeMax, 0, 1])
    hold off
end

subplot(1, 2, 1)
legend('\sigma_R = 0.5%', '\sigma_R = 1%', '\sigma_R = 2%', 'Location', 'northwest')
subplot(1, 2, 2)
legend('\sigma_R = 0.5%', '\sigma_R = 1%', '\sigma_R = 2%', 'Location', 'northwest')