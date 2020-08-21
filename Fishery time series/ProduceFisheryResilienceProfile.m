%This code produces a forecast resilience profile 

%NB: The initial conditions for the nonlinear fitting in initialParameterGuess are
%important. Make sure they are reasonable based on the scatter plot points, otherwise the method may not converge.

%The x-domain over which the peak-to-peak map is constructed should also be
%changed depending on the data set

load('HassellHarvestingTimeSeries.mat')

timeSeries = Zfull;

delayMapFull = constructdelaycoordinates(timeSeries, 1);

delayCoordsX = delayMapFull(:, 1);
delayCoordsY = delayMapFull(:, 2);
delayXTimes = delayMapFull(:, 3);

tic
startTime = timeSeries(1, 1);           %The start time of the time series
step = 1;               %The step length for the calibration window times used

endTime = timeSeries(length(timeSeries) - 1, 1);

h=1;                                     %Step size for the time points

figure(1)
plot(timeSeries(:, 1), timeSeries(:, 2), 'LineWidth', 1.5)
xlabel('Time, t')
ylabel('Population level, x_t')

windowStartTime = input('Insert the start time of the calibration window: ');
windowEndTime = input('Insert the end time of the calibration window: ');
% dictates the range of points in the time series that are plotted in the
% scatter plots
scatterStartTime = 0;           
scatterEndTime = 2500;

close figure 1

figure(1)
rectangle('Position', [windowStartTime 0 windowEndTime-windowStartTime 2], 'FaceColor', [0.75,0.75,0.75], 'EdgeColor', [0.75,0.75,0.75])
set(gca, 'Layer', 'top');                                           %brings the tick marks to the top
grid off                                                            %stops the grid showing
hold on
plot(timeSeries(:,1), timeSeries(:,2))
title({'Plot of the time series used' ; 'and the calibration window'})
xlabel('Time', 'fontweight', 'bold', 'fontsize', 12);
ylabel('Population level', 'fontweight', 'bold', 'fontsize', 12);

predictionTimeVector = startTime:endTime;       %timevec is the time vector for the predicted probability of persistence
nPredictionTimes = length(predictionTimeVector);
fittedMapResolution = 18000;
fittedMapMax = 1.5*max(delayCoordsX);
fittedMapStep = fittedMapMax/(fittedMapResolution - 1);
fittedMapDomain = 0:fittedMapStep:fittedMapMax;           %xx is the domain over which the fitted quadratic map with uncertainty is constructed
%N=length(xx);
%denotes the total length of the current calibration window

i = 1;
peakStartElement = 0;
scatterStartElement = 0;
%this loop finds the index of the first peak in the calibration window and
%the scatter plot range
while peakStartElement==0 || scatterStartElement==0                 
    if delayXTimes(i)>=windowStartTime
        peakStartElement = i;
    end
        
    if delayXTimes(i)>=scatterStartTime
        scatterStartElement = i;
    end
    
    i = i+1;
end

peakEndElement = peakStartElement;
scatterEndElement = scatterStartElement;
%this loop finds the index of the last peak in the calibration window and
%the scatter plot range
while peakEndElement==peakStartElement ||  scatterEndElement==scatterStartElement       
    if delayXTimes(i)>=windowEndTime
        peakEndElement = i-1;
    else
        if i==length(delayXTimes)
            peakEndElement = i;
        end
    end
    
    if delayXTimes(i)>=scatterEndTime
        scatterEndElement = i-1;
    else
        if i==length(delayXTimes)
            scatterEndElement = i;
        end
    end
    
    i = i+1;
end

% This loop finds the index of the start time of the calibration window, in
% the time series
i = 1;
seriesStartElement = 0;                        
while seriesStartElement==0
    if timeSeries(i,1)>=windowStartTime
        seriesStartElement = i;
    end
    i = i+1;
end

% This loop finds the index of the end time of the calibration window, in
% the time series
seriesEndElement = seriesStartElement;
while seriesEndElement==seriesStartElement    
    if timeSeries(i,1)>=windowEndTime  || i==length(timeSeries)
        seriesEndElement = i;
    end
    i = i+1;
end

i = [];
% Restricts the peak values and delay coordinates to those inside the calibration window
delayXTimesWindow = delayXTimes(peakStartElement:peakEndElement);
delayCoordsXWindow = delayCoordsX(peakStartElement:peakEndElement);
delayCoordsYWindow = delayCoordsY(peakStartElement:peakEndElement);

% Restricts the peak values and delay coordinates to those inside the scatter plot range
delayXTimesScatter = delayXTimes(scatterStartElement:scatterEndElement);
delayCoordsXScatter = delayCoordsX(scatterStartElement:scatterEndElement);
delayCoordsYScatter = delayCoordsY(scatterStartElement:scatterEndElement);

%Initial conditions for the fitting of the nonstationary 2-shifted Ricker map:
initialParameterGuess = [2.6 0 1 0 0.006 0 0.02 -0.0001]';
paramvec = fitnonstationaryshiftedrickermap(delayXTimesWindow, delayCoordsXWindow, delayCoordsYWindow, initialParameterGuess);    %Find the parameters of the shifted ricker map with linearly changing parameters in time

figure(2)
hold on

cmap = colormap('jet');
nColors = length(cmap);
snapshotTimes = [0 6000];

for i = 1:length(delayCoordsXScatter)
    iColor = ceil((delayXTimesScatter(i) - scatterStartTime)/(scatterEndTime - scatterStartTime)*nColors);
    if iColor==0
        iColor = 1;
    end
    plot(delayCoordsXScatter(i), delayCoordsYScatter(i), 'Marker', 'o', 'MarkerEdgeColor', cmap(iColor, :))
end

plot(fittedMapDomain, fittedMapDomain, 'k', 'LineWidth', 1.5)

fittedMap = shiftedrickermapnonstationary(fittedMapDomain, snapshotTimes(1), paramvec);
plot(fittedMapDomain, fittedMap, 'w', 'LineWidth', 2)
plot(fittedMapDomain, fittedMap, 'Color', cmap(1, :), 'LineWidth', 2, 'LineStyle', '--')

fittedMap = shiftedrickermapnonstationary(fittedMapDomain, snapshotTimes(2), paramvec);
plot(fittedMapDomain, fittedMap, 'w', 'LineWidth', 2)
plot(fittedMapDomain, fittedMap, 'Color', [0.3 0 0], 'LineWidth', 2, 'LineStyle', '--')

hold off
axis([0 2 0 2])
set(gca, 'fontsize', 12)
set(gca, 'box', 'off')

caxis([0 2500])
colorbar

title({'Scatter plot of successive points in the time series'; 'together with fitted maps at two time points'})
xlabel('Population at time t', 'fontweight', 'bold', 'fontsize', 14);
ylabel('Population at time t+1', 'fontweight', 'bold', 'fontsize', 14);


% This figure is just to demonstrate how the critical threshold and the
% attractor minimum are found.
figure(4)
fittedMapDomainPlotting = linspace(0, 3, 20000);
fittedMap = shiftedrickermapnonstationary(fittedMapDomainPlotting, 0, [2.5 0 1 0 0.1 0 0 0]);
[plotmaximum, i] = max(fittedMap);
plotminimum = shiftedrickermapnonstationary(plotmaximum, 0, [2.5 0 1 0 0.1 0 0 0]);

lowequilibriumfinder = abs(fittedMap - fittedMapDomainPlotting);
lowequilibriumfinder = lowequilibriumfinder(1:ceil(0.25*length(lowequilibriumfinder)));

[holdingvariable j] = min(lowequilibriumfinder);
plotthreshold = fittedMapDomainPlotting(j);

plot(fittedMapDomainPlotting, fittedMap, 'LineWidth', 2)
hold on
plot(fittedMapDomainPlotting, fittedMapDomainPlotting, 'k', 'LineWidth', 1.5)

cobweb(@shiftedrickermapnonstationary, [2.5 0 1 0 0.1 0 0 0], 0.7, 2, 200)

line([fittedMapDomainPlotting(i) fittedMapDomainPlotting(i)], [0 fittedMapDomainPlotting(i)], 'LineStyle', '--', 'Color', [0.9290    0.6940    0.1250], 'LineWidth', 2);
line([fittedMapDomainPlotting(i) fittedMapDomainPlotting(i)], [fittedMapDomainPlotting(i) plotmaximum], 'Color', [0.9290    0.6940    0.1250], 'LineWidth', 2);
line([fittedMapDomainPlotting(i) plotmaximum], [plotmaximum plotmaximum], 'Color', [0.9290    0.6940    0.1250], 'LineWidth', 2);
line([plotmaximum plotmaximum], [plotmaximum plotminimum], 'Color', [0.9290    0.6940    0.1250], 'LineWidth', 2);
line([plotmaximum plotmaximum], [plotmaximum 0], 'LineStyle', '--', 'Color', [0.9290    0.6940    0.1250], 'LineWidth', 2);
line([plotmaximum 0], [plotminimum plotminimum], 'Color', [0.9290    0.6940    0.1250], 'LineWidth', 2);
line([plotthreshold 0], [plotthreshold plotthreshold], 'Color', [0.8500    0.3250    0.0980], 'LineWidth', 2);


hold off
title({'Example for finding the attractor minimum' ; 'and the critical threshold'})
xlabel('Population at time t', 'fontweight', 'bold', 'fontsize', 14);
ylabel('Population at time t+1', 'fontweight', 'bold', 'fontsize', 14);
axis([0 2 0 2])
set(gca, 'fontsize', 12)
set(gca, 'box', 'off')


%pause

attractorMin = zeros(nPredictionTimes, 1);
critThresh = zeros(nPredictionTimes, 1);

for ii = 1:nPredictionTimes
    t = predictionTimeVector(ii);
    attractorInfo = getresilienceinfoforshiftedricker(fittedMapDomain, t, paramvec) ;               % getresilienceinfoforshiftedricker... determines the attractor minimum and critical threshold for the system
    attractorMin(ii) = attractorInfo(1);                                               
    critThresh(ii) = attractorInfo(2);
end

figure(3)
plot(timeSeries(:,1), timeSeries(:,2), 'Color', [0.65,0.65,0.65], 'HandleVisibility', 'off')
set(gca, 'Layer', 'top');                                           
grid off                                                            
hold on
plot(predictionTimeVector, attractorMin, 'Color', [0    0.4470    0.7410], 'LineWidth', 2)                                        
plot(predictionTimeVector,critThresh, '--', 'Color', [ 0.8500    0.3250    0.0980], 'LineWidth', 2)
hold off
title('Forecast resilience profile')
xlabel('Time, t', 'fontweight', 'bold', 'fontsize', 12);                                          
ylabel('Population level, x_t', 'fontweight', 'bold', 'fontsize', 12);
axis([0 max(predictionTimeVector) 0 0.3])
legend('Forecast attractor minimum', 'Forecast critical threshold')


toc