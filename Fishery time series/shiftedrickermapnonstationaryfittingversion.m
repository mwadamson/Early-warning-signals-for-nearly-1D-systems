function x2 = shiftedrickermapnonstationaryfittingversion(paravec, x)
% outputs the ricker function shifted up in the x and y directions 
% for the given input x = [x1 t];

x1 = x(:, 2); t = x(:, 1);

rBase = paravec(1);
rRateOfChange = paravec(2);
KBase = paravec(3);
KRateOfChance = paravec(4);
rightShiftBase = paravec(5);
rightShiftRateOfChange = paravec(6);
upShiftBase = paravec(7);
upShiftRateOfChange = paravec(8);

x2 = (x1 - (rightShiftBase + rightShiftRateOfChange*t)).*exp((rBase ...
    + rRateOfChange.*t).*(1 - (x1 - (rightShiftBase ...
    + rightShiftRateOfChange*t))./(KBase + KRateOfChance.*t))) ...
    + (upShiftBase + upShiftRateOfChange*t);
