D=importdata('j1.txt');
data=D(:,2);
len=length(data);

amount=100;
simplefilter=ones(amount,1)/amount;
filtereddata=filter(simplefilter,1,data);
figure(1)
x=1:(len-amount/2);
filtereddatashifted=filtereddata(amount/2+1:len);
plot(x,data(x),x,filtereddatashifted,'r')
figure(2)
plot(filtereddata)