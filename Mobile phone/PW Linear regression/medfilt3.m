function [res]=medfilt3tresh(data,treshdown,treshup)
skydive1=importdata('j5.txt');

SD=skydive1(:,2)/128;
T=length(SD);

y=medfiltTom(SD,data);

figure(5)
plot(1:T,SD,'r',1:T,y)
der=(y(2:end)-y(1:end-1))/.25;
plotyy(1:T-1,der,1:T,SD)
figure(6)
plot(1:T,[der,0],1:T,treshdown*ones(T,1),1:T,treshup*ones(T,1))
res=(find(tresh<der));
end