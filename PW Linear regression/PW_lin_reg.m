function PW_lin_reg(amount)

skydive1=importdata('j3.txt');

data=skydive1(:,2);
T=length(data);

simplefilter=ones(amount,1)/amount;
filtereddata=filter(simplefilter,1,data);
figure(1)
subplot(2,1,1)
plot(1:T,filtereddata,'r')
subplot(2,1,2)
plot(1:T-amount/2,filtereddata(1+amount/2:T),'r',1:T-amount/2,data(1:T-amount/2),'b')

filtered_data=filtereddata(1+amount/2:T);
xx = 1:length(filtered_data);
  yy = filtered_data;
  bp = [3870, 3942, 4467,4491,4723,4743,4760,T-amount/2];  
  ab2 = BrokenStickRegression(xx, yy, bp);
  figure(3)
  plot(ab2(:,1),ab2(:,2))
  figure(2)% breakpoints.
  plot(xx, yy, '.',ab2(:, 1), ab2(:, 2), 'r-o')
  legend('data points',  'NSTICK vectorial', ...
     'Location', 'NW')
end