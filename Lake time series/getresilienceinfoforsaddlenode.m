function attractorInfo = getresilienceinfoforsaddlenode(t,paravec)

% This code finds and outputs the stable and unstable equilibria of a nonstationary quadratic map 
% at a particular time

% of the inputs, xx can be a vector, but t must be a single time value -
% the outputs are Attractor(t) 

alpha0=paravec(1); alpha1=paravec(2); beta0=paravec(3); beta1=paravec(4);
gamma0=paravec(5); gamma1=paravec(6);

alpha=alpha0+alpha1*t;
beta=beta0+beta1*t;
gamma=gamma0+gamma1*t;

if (beta-1)^2>4*alpha*gamma         %uses the discriminant to check if there are equilibria
    AttractorState = 1/2/alpha*(-(beta-1)-sqrt((beta-1)^2-4*alpha*gamma));
    CritThresh = 1/2/alpha*(-(beta-1)+sqrt((beta-1)^2-4*alpha*gamma));
else
    AttractorState = NaN;
    CritThresh = NaN;
end

attractorInfo=[AttractorState CritThresh];