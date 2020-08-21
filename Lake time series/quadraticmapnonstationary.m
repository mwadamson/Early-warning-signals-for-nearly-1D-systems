function x2=quadraticmapnonstationary(paravec,x)

x1=x(:,2); t=x(:,1);

a2const=paravec(1);
a2time=paravec(2);
a1const=paravec(3);
a1time=paravec(4);
a0const=paravec(5);
a0time=paravec(6);

x2=(a2const+a2time*t).*x1.^2+(a1const+a1time*t).*x1+(a0const+a0time*t);