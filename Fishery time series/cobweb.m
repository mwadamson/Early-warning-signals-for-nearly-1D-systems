function cobweb(f,paramvec,x0,xmax,N)
% generate the cobweb plot associated with
% the orbits x_n+1=f(x_n).
% N is the number of iterates,
% paramvec stores the parameters of f
% x0 is the initial point.
% use @[function file name] to input that function as f


x(1)=0;             %the domain starts from the origin x
t=1;
h=0.0001;           %h is the resolution of the domain (x-values)

x=0:h:xmax;
   

y=f(x,t,paramvec);   % work out y-values to plot the function y=f(x)


%plot(x,y,'k'); % plot the function
hold on;       % turn hold on to gather up all plots in one graph
%plot(x,x,'r'); % plot the identity line
%axis([0 xmax 0 xmax])

x(1)=x0;

for i=1:N                                   % loop plots N orbits starting from x0
    x(i+1)=f(x(i),t,paramvec);                % set x(t_i+1)=f(x(t_i))              
    line([x(i),x(i)],[x(i),x(i+1)],'Color',[ 0.8500    0.3250    0.0980]);        % draw the lines
    line([x(i),x(i+1)],[x(i+1),x(i+1)],'Color',[ 0.8500    0.3250    0.0980]);
    %pause(0.05)                              %pause for some seconds (optional)
    
    if x(i+1)<0
        break                               %stop if x(t_i) becomes negative
    end
end

hold off;      % turn hold off so that future plots won't be on the same graph
