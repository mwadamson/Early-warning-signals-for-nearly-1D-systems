function transitionTime = getTransitionTime(timeSeriesArray, stateDifferenceThreshold)

% use constructdelaycoordinates to get an array of time points at t and and
% array of time points at t+1
stateDifferencesArray = constructdelaycoordinates(timeSeriesArray, 10);
% stateDifferences stores the absolute value of the change in the state
% variable at times in the timeSeriesArray
stateDifferences = abs(stateDifferencesArray(:, 1) - stateDifferencesArray(:, 2));
% the true transition is taken as the first instance at which the variable
% changes beyond the threshold
TransitionIndex = find(stateDifferences > stateDifferenceThreshold, 1);
transitionTime = timeSeriesArray(TransitionIndex, 1);


