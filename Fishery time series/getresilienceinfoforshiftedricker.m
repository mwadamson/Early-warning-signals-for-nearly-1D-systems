function attractorInfo = getresilienceinfoforshiftedricker(xx,t,paravec)

r0=paravec(1); r1=paravec(2); K0=paravec(3); K1=paravec(4);
a0=paravec(5); a1=paravec(6); b0=paravec(7); b1=paravec(8);

fx = shiftedrickermapnonstationary(xx,t,[r0 r1 K0 K1 a0 a1 b0 b1]);
 
xintersect=NaN;
N=length(xx);

% t
% figure(4)
% plot(xx,fx)
% hold on
% plot(xx,xx,'k')
% hold off
% pause

for i=N:-1:2
    if sign(fx(i)-xx(i))~=sign(fx(i-1)-xx(i-1))
        xintersect=i-1;
        break
    end
end

if isnan(xintersect)==1
    Attmin=0;
    CritThresh=0;
else
    Attmax=max(fx);
    Attmin=shiftedrickermapnonstationary(Attmax,t,[r0 r1 K0 K1 a0 a1 b0 b1]);
    CritThresh=0;
    
    critthreshfound=0;
    i=1;
    while critthreshfound==0 && i<N
        if fx(i+1)>xx(i+1)
            CritThresh=xx(i);
            critthreshfound=1;
        else
            i=i+1;
        end
    end
end

attractorInfo=[Attmin CritThresh];