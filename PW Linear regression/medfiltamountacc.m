function [res]=medfiltamountacc(data,window,amount)
T=length(data);
y=data';

figure(5)
plot(1:T,data,'r',1:T,y)
acc=(y(1:T-2)-2*y(2:T-1)+y(3:T))/.25^2;
plotyy(1:T,[0,acc,0],1:T,data)
sortedacc=sort(acc,'descend');%add abs around acc later
tresh=sortedacc(amount);
treshup=tresh<=acc;
treshdown=-100000>=acc;
res=[find(treshup.*acc),find(treshdown.*acc)];
figure(6)
plot(1:T,[0,acc,0],1:T,-tresh*ones(T,1),1:T,tresh*ones(T,1))
[len]=length(res)
end