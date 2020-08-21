function fractionAcceptableErrors = getreliabilitywindowlength(transitionTimeError, windowLengthMaxIndex, startTimeMaxIndex, acceptableError)

nTimeSeries = size(transitionTimeError, 1);
fractionAcceptableErrors = zeros(windowLengthMaxIndex, 1);

for iWindowLength = 1:windowLengthMaxIndex
    acceptableErrorSum = 0;
    for iTimeSeries = 1:nTimeSeries
        for iStartTime = 1:startTimeMaxIndex   % elements below the secondary diagonal are invalid because they correspond to
            % calibration windows which extend after the transition
            if ~isnan(transitionTimeError(iTimeSeries, iStartTime, iWindowLength)) && abs(transitionTimeError(iTimeSeries, iStartTime, iWindowLength)) <= acceptableError
                acceptableErrorSum = acceptableErrorSum + 1;
            end
        end
        fractionAcceptableErrors(iWindowLength) = acceptableErrorSum / startTimeMaxIndex / nTimeSeries;
    end
end