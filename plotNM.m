function y=plotNM(tf)
% close all
global alpha beta muh lambda2 rho gamma muj dj sigma

alpha=1/(365*2);%.1153,50 days to be able to hunt on their own,50 days= 7.1429 weeks, not an ecological sink
% q=0.015;
% epsilon=.258956;%estimated.55,
muh=1/(365*5);
lambda2=1;%estimated 1,
beta=(3.44 / 365 / 2) * (2/3) * 0.835;
rho=8.9*.83*(1/30);
sigma=.4232;
% delta=.66*13.5;%estimated
% rho=0.85/50;%Tucson not a sink
% sigma=.999;%Proportion of infected meat [0,1]
%rate of prey delivery=delta/h =8.9, estes mannan
% c=1.5;%estimated
% h=1;%estimated greater than delta for there not to be exponential growth in all classes
gamma=.59/40;% 40 days until disease is abated, not an eco. sink
muj=.36/(365*2);%Survival rate for juvenile was 64% , not an eco. sink
dj=.41/40;%0.205, .4/52*7,%%kills 40% annually
%d=96.75% for stability
tspan=[0,tf];
H=200;Sh=200;Ih=100;Rh=0;

[t,x]=ode45('newmodel',tspan,[H;Sh;Ih;Rh]);

plot(t,x(:,1),'r');
hold on
plot(t,x(:,2),'b');
plot(t,x(:,3),'k');
plot(t,x(:,4),'g');
legend('H','S','I','R',2)
ylabel('hawk population')
xlabel('time(days)')