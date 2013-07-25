function [res]=medfilttresh(data,window,treshdown,treshup)
T=length(data);
y=medfiltTom(data,window);

figure(5)
plot(1:T,data,'r',1:T,y)
der=(diff(y,1))/.25;
plotyy(1:T-1,der,1:T,data)
figure(6)
plot(1:T,[der,0],1:T,treshdown*ones(T,1),1:T,treshup*ones(T,1))
res=[find(treshup>der),find(treshdown<der)];
end