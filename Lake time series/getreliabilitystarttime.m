function fractionAcceptableErrors = getreliabilitystarttime(transitionTimeError, windowLengthMaxIndex, startTimeMaxIndex, acceptableError)

nTimeSeries = size(transitionTimeError, 1);
fractionAcceptableErrors = zeros(startTimeMaxIndex, 1);

for iStartTime = 1:startTimeMaxIndex
    acceptableErrorSum = 0;
    for iTimeSeries = 1:nTimeSeries
        
        for iWindowLength = 1:windowLengthMaxIndex   % elements below the secondary diagonal are invalid because they correspond to
            % calibration windows which extend after the transition
            if ~isnan(transitionTimeError(iTimeSeries, iStartTime, iWindowLength)) && abs(transitionTimeError(iTimeSeries, iStartTime, iWindowLength)) <= acceptableError
                acceptableErrorSum = acceptableErrorSum + 1;
            end
        end
        fractionAcceptableErrors(iStartTime) = acceptableErrorSum / windowLengthMaxIndex / nTimeSeries;
    end
end