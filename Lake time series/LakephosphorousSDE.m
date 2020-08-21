function Z = LakephosphorousSDE(X,t,paramvec,sigma)

U0=paramvec(1); U1=paramvec(2); c1=paramvec(3); c2=paramvec(4); 
c3=paramvec(5); c4=paramvec(6); m=paramvec(7); q=paramvec(8);

U=U0+U1*t;

F=X^q./(c4^q+X^q);

a=c1*U-c2*X+c3*m*F;
b=sigma*m*F;
%b=sigma*X;
Z = [a; b];