function transitionTime = getTransitionTime(timeSeriesArray)


transitionTime = find(timeSeriesArray(:, 2) == 0, 1);



