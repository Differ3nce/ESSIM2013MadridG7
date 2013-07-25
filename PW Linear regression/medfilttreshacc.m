function [res]=medfilttreshacc(data,window,treshdown,treshup)
T=length(data);
y=medfiltTom(data,window);

figure(5)
plot(1:T,data,'r',1:T,y)
acc=(y(1:T-2)-2*y(2:T-1)+y(3:T))/.25^2;
plotyy(1:T,[0,acc,0],1:T,data)
figure(6)
plot(1:T,[0,acc,0],1:T,treshdown*ones(T,1),1:T,treshup*ones(T,1))
res=[find(treshup>acc),find(treshdown<acc)];
end