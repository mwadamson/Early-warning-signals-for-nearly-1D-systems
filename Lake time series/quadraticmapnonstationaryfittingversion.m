function Z=quadraticmapnonstationaryfittingversion(paravec,x)
%outputs the logistic function for the given input x, and parameters r and 
%K, alpha is an unused parameter so that this function works with
%cobweb_3parameters

x1=x(:,2); t=x(:,1);

alpha0=paravec(1);
alpha1=paravec(2);
beta0=paravec(3);
beta1=paravec(4);
gamma0=paravec(5);
gamma1=paravec(6);

x2=(alpha0+alpha1*t).*x1.^2+(beta0+beta1*t).*x1+(gamma0+gamma1*t);
Z=x2;