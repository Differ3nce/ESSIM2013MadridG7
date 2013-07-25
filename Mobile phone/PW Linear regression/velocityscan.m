function [res]=velocityscan(data,window,treshhold)
T=length(data);
y=data';

figure(5)
plot(1:T,data,'r',1:T,y)
vel=(y(2:T)-y(1:T-1))/.25;
plotyy(1:T,[vel,0],1:T,data)
zeroone = medfiltTom(1*(abs(vel)>treshhold),window);
points = abs(diff(zeroone,1));
res = find(points);
figure(6)
plot(1:T-1,zeroone)

end