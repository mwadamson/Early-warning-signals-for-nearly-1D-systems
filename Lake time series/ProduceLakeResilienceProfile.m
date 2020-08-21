%clear all

%This code produces a forecast of the resilience of a
%population based on a single calibration window of the time series to be
%predicted.
%The inputs are the time series, values at t and t+tau, and the peak times:
%Zfull, Xfull,Yfull,Peaktimefull, respectively, which should be prestored in memory
%This can be done by running the code FisheriesTimeSeriesGen.m and
%selecting a time series number to investigate

%NB: The initial conditions for the nonlinear fitting around line 99 are
%important. Make sure they are reasonable based on the peak-to-peak data
%points, otherwise the method may not converge.

%The x-domain over which the peak-to-peak map is constructed should also be
%changed depending on the data set
clear all
load('LakePhosphorousTimeSeries.mat')
timeSeries = Zfull;
tic
delayMapFull = constructdelaycoordinates(timeSeries, 2);
    
    delayCoordsX = delayMapFull(:, 1);
    delayCoordsY = delayMapFull(:, 2);
    delayXTimes = delayMapFull(:, 3);

startTime = timeSeries(1,1);           %The start time of the time series
step = 1;               %The step length for the calibration window times used

timeDelay = 40;

endTime = 2*timeSeries(length(timeSeries) - 1, 1);           %The end time of the time series

h = 1;                                     %Step size for the time points

windowStartTime = input('Insert the start time of the calibration window: ');
windowEndTime = input('Insert the end time of the calibration window: ');
% dictates the points in the time series that are plotted in the scatter
% diagram
scatterStartTime = 0;           
scatterEndTime = 2700;


figure(1)
rectangle('Position', [windowStartTime 0 windowEndTime-windowStartTime 7], 'FaceColor', [0.75,0.75,0.75], 'EdgeColor', [0.75,0.75,0.75])
hold on
plot(timeSeries(:,1), timeSeries(:,2), 'LineWidth', 1.5)
set(gca, 'Layer', 'top');                                           %brings the tick marks to the top
grid off                                                            %stops the grid showing
hold off
title({'Plot of the time series used' ; 'and the calibration window'})
xlabel('Time, t', 'fontweight', 'bold', 'fontsize', 12);
ylabel('Lake water phosphorous concentration', 'fontweight', 'bold', 'fontsize', 12);

eps = 0.01;               %eps is the uncertainty in the fitted quadratic peak-to-peak map
timevec = linspace(startTime, endTime, 1000);       %timevec is the time vector for the predicted probability of persistence
NN = length(timevec);
N = 18000;
p2pstep = 1.5*max(delayCoordsX)/(N - 1);
xx = 0:p2pstep:1.5*max(delayCoordsX);           %xx is the domain over which the fitted quadratic map with uncertainty is constructed
xx = xx';
%N=length(xx);
%denotes the total length of the current calibration window

i = 1;
peakStartElement = 0;
scatterStartElement = 0;

while peakStartElement==0 || scatterStartElement==0                 %this loop finds the index of the first peak in the calibration window and scatter plot
    if delayXTimes(i)>=windowStartTime
        peakStartElement = i;
    end
    
    if delayXTimes(i)>=scatterStartTime
        scatterStartElement = i;
    end
    
    i=i+1;
end

peakEndElement = peakStartElement;
scatterEndElement = scatterStartElement;

while peakEndElement==peakStartElement ||  scatterEndElement==scatterStartElement     %this loop finds the index of the last peak in the calibration window and scatter plot
    if delayXTimes(i)>=windowEndTime
        peakEndElement = i-2;
    else
        if i==length(delayXTimes)
            peakEndElement = i;
        end
    end
    
    if delayXTimes(i)>=scatterEndTime
        scatterEndElement = i-2;
    else
        if i==length(delayXTimes)
            scatterEndElement = i;
        end
    end
    
    i = i + 1;
end

i = 1;
seriesStartElement = 0;                        %This loop finds the index of the start time of the calibration window, in the total time vector
while seriesStartElement==0
    if timeSeries(i,1)>=windowStartTime
        seriesStartElement = i;
    end
    i = i + 1;
end

seriesEndElement=seriesStartElement;
while seriesEndElement==seriesStartElement     %This loop finds the index of the end time of the current time window, in the total time vector
    if timeSeries(i,1)>=windowEndTime  || i==length(timeSeries)
        seriesEndElement = i;
    end
    i = i + 1;
end

i = [];

peakTime = delayXTimes(peakStartElement:peakEndElement);     %Restricts the  peak values to the current time window
peakTimeScatter = delayXTimes(scatterStartElement:scatterEndElement);
X = delayCoordsX(peakStartElement:peakEndElement);
XScatter = delayCoordsX(scatterStartElement:scatterEndElement);
Y = delayCoordsY(peakStartElement:peakEndElement);
YScatter = delayCoordsY(scatterStartElement:scatterEndElement);
Z = timeSeries(seriesStartElement:seriesEndElement,:);             %Restricts the model time series to the current time window

paramvec = fitnonstationaryquadraticmap(peakTime, X, Y, [-1 0 1 0 1 0]);    %Find the parameters of the quadratic map with linearly changing parameters in time,

snapshotTimes = [0 3000];
snapshotMap1 = quadraticmapnonstationary(paramvec, [ones(length(xx), 1)*snapshotTimes(1) xx]);
snapshotMap2 = quadraticmapnonstationary(paramvec, [ones(length(xx), 1)*snapshotTimes(2) xx]);

clear figure(2)
figure(2)
plot(xx, xx, 'k', 'LineWidth', 1.5)
hold on
cmap = colormap('jet');
nColors = length(cmap);
for i = 1:length(XScatter)
    iColor = ceil((peakTimeScatter(i) - scatterStartTime)/(snapshotTimes(2 - scatterStartTime))*nColors);
    if iColor==0
        iColor = 1;
    end
    plot(XScatter(i), YScatter(i), 'Marker', 'o', 'MarkerEdgeColor', cmap(iColor,:))
end

plot(xx, snapshotMap1, 'w')
plot(xx, snapshotMap1, 'Color', cmap(1,:), 'LineWidth', 2, 'LineStyle', '--')
iColor = ceil((snapshotTimes(2) - windowStartTime)/(snapshotTimes(2) - windowStartTime)*nColors);
plot(xx, snapshotMap2, 'w')
plot(xx, snapshotMap2, 'Color', cmap(iColor,:), 'LineWidth', 2, 'LineStyle', '--')
hold off

caxis([windowStartTime snapshotTimes(2)])
colorbar

axis([0 3 0 3])
set(gca, 'box', 'off')

title({'Scatter plot of successive points in the time series'; 'together with fitted maps at two time points'})
xlabel('Phosphorous concentration at time t', 'fontweight', 'bold', 'fontsize', 12);
ylabel(['Phosphorous concentration at time t+' num2str(timeDelay)], 'fontweight', 'bold', 'fontsize', 12);


attractorState = zeros(NN, 1);
critThresh = zeros(NN, 1);

for ii = 1:NN
    t = timevec(ii);
    attractorInfo = getresilienceinfoforsaddlenode(t, paramvec);                      %Attmin_CritThresh_quad finds the attractor minimum and critical threshold  
    attractorState(ii) = attractorInfo(1);                                                 %of the fitted system at a given time
    critThresh(ii) = attractorInfo(2);
end

figure(3)
plot(timeSeries(:,1), timeSeries(:,2), 'Color', [0.65,0.65,0.65], 'HandleVisibility', 'off', 'LineWidth', 1.5)
set(gca, 'Layer', 'top');                                           %brings the tick marks to the top
grid off                                                            %stops the grid showing
hold on
BlueRGB = get(gca, 'ColorOrder');
BlueRGB = BlueRGB(1, 1:3);
plot(timevec, attractorState, 'Color', BlueRGB, 'LineWidth', 2)
RedRGB = get(gca, 'ColorOrder');
RedRGB = RedRGB(2, 1:3);
plot(timevec, critThresh, '--', 'Color', RedRGB, 'LineWidth', 2)

hold off
title('Forecast resilience profile')
xlabel('Time, t', 'fontweight', 'bold', 'fontsize', 12);                                          
ylabel('Lake water phosphorous concentration', 'fontweight', 'bold', 'fontsize', 12);


toc