function Extinctiontimes = getextinctiontimeviasaddlenode(paramvec)

% This code finds and outputs the stable and unstable equilibria of a nonstationary quadratic map 
% at a particular time

% of the inputs, xx can be a vector, but t must be a single time value -
% the outputs are Attractor(t) 

alpha0=paramvec(1); alpha1=paramvec(2); beta0=paramvec(3); beta1=paramvec(4);
gamma0=paramvec(5); gamma1=paramvec(6);

A=beta1^2-4*alpha1*gamma1;
B=2*beta0*beta1-2*beta1-4*alpha1*gamma0-4*alpha0*gamma1;
C=beta0^2+1-2*beta0-4*alpha0*gamma0;

t1=1/2/A*(-B-sqrt(B^2-4*A*C));
t2=1/2/A*(-B+sqrt(B^2-4*A*C));

DiscriminantDerivative1=2*beta1*(beta0+beta1*t1-1)-4*alpha1*(gamma0+gamma1*t1)-4*gamma1*(alpha0+alpha1*t1);
DiscriminantDerivative2=2*beta1*(beta0+beta1*t2-1)-4*alpha1*(gamma0+gamma1*t2)-4*gamma1*(alpha0+alpha1*t2);

if DiscriminantDerivative1 < 0
    if DiscriminantDerivative2 < 0
        Extinctiontimes=[t1 t2];
    else
        Extinctiontimes=t1;
    end
else
    if DiscriminantDerivative2 < 0
        Extinctiontimes=t2;
    else
        Extinctiontimes=NaN;
    end
end

