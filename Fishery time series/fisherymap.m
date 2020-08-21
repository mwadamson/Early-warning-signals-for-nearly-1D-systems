function Z = fisherymap(x,t,paramvec)

r0=paramvec(1); r1=paramvec(2); a0=paramvec(3); a1=paramvec(4); beta0=paramvec(5); beta1=paramvec(6); qE0=paramvec(7); qE1=paramvec(8);
if x~=0
    x=max((r0+r1*t)*x./(1+(a0+a1*t)*x).^(beta0+beta1*t)-(qE0+qE1*t),0);
end
t=t+1;

Z=[t x];