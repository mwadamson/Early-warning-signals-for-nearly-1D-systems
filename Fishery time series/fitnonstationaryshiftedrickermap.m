function paramvec = fitnonstationaryshiftedrickermap(t, x, y, initpara)

%Uses MATLAB's nonlinear least squares fitting to fit peak-to-peak
%data to a ricker map w/ allee effect with parameters evolving linearly in time

% Inputs: t - the time points, x - the peak at time t(i), y - log(x(i+1)/x(i))
% should be column vectors
% initpara the initial vector of parameters, should be a column vector
% Ouputs: paramvec - the vector of paramters [r0 r1 K0 K1] that minimises
% the sum of the squared residuals

X = [t x y];
X = sortrows(X, 2);
Y = X(:, 3);
X(:, 3) = [];

opts = optimset('Display', 'off');
paramvec = lsqcurvefit(@shiftedrickermapnonstationaryfittingversion, initpara, X, Y, [], [], opts);

