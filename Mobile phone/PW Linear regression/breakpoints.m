function breakpoints(data,amount)
simplefilter=ones(amount,1)/amount;
filtereddata=filter(simplefilter,1,data);
T=length(data);
figure(1)
plot(1:T,filtereddata,'r')
figure(2)
difdata=diff(medfiltTom(filtereddata,50),1);
plot(difdata)
difdifdata=[0,medfiltTom(diff(difdata,1),10),0];
figure(3)

plotyy(1:T,difdifdata,1:T,filtereddata)