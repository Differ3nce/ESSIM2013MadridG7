skydive1=importdata('j1.txt');
data=sqrt(skydive1(:,2).^2+skydive1(:,3).^2+skydive1(:,4).^2)/128;
%Linregvelocityscan(data,35,0.4,5)
%linregamount(data,35,20)
[jump,para]=Jump_points(25,1);
d=data(jump:para);
d=d';
s=spline1(data(jump:para),10,0.1,-0.1,3,2);
l=linreg3(data(jump:para),10,0.1,-0.1,3,2);
figure(7)
plot(jump:para-5,abs(s(1:(length(d)-5))-d(1:(length(d)-5))),'b',jump:para-5,abs(d(1:(length(d)-5))-l),'r')
meanS=sum(abs(s(1:(length(d)-5))-d(1:(length(d)-5))))/(length(d)-5)
meanL=sum(abs(d(1:(length(d)-5))-l))/(length(d)-5)
varS=sum(abs(s(1:(length(d)-5))-d(1:(length(d)-5))).^2)/(length(d)-5)-meanS^2
varL=sum(abs(d(1:(length(d)-5))-l).^2)/(length(d)-5)-meanL^2
Rstuff=d(1:(length(d)-5))-l
save(sprintf('Rstuff','Rstuff'))
%plot(jump:para,spline(jump+points,data(jump+points),jump:para),jump:para,data(jump:para))
%removeclosepoints([1,4,5,8,10,100,101,102,104,105,106],1)
%4471
%4723
l=l-1;
intl=l;
for i=2:length(l)
    intl(i)=intl(i-1)+l(i);
end
d=d-1;
intd=d;
for i=2:length(d)
    intd(i)=intd(i-1)+d(i);
end
figure(8)
hold off
plot(0.25*intl)
hold on
plot(0.25*intd)
h=skydive1(jump:para,1);
dh=diff(filter(21,1,h));
plot(dh)
figure(9)
plot(h)