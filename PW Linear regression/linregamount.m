function linregamount(data,window,amount)

T=length(data);
simplefilter=ones(window,1)/window;
filtereddata=filter(simplefilter,1,data);
figure(1)
subplot(2,1,1)
plot(1:T,filtereddata,'r')
subplot(2,1,2)
plot(1:T-(window-1)/2,filtereddata(1+(window-1)/2:T),'r',1:T-(window-1)/2,data(1:T-(window-1)/2),'b')

filtered_data=filtereddata(1+(window-1)/2:T);
xx = 1:length(filtered_data);
  yy = filtered_data;
  bp = sort(medfiltamountacc(data,window,amount));
  ab2 = BrokenStickRegression(xx, yy, bp');
  figure(3)
  plot(ab2(:,1),ab2(:,2))
  figure(2)% breakpoints.
  plot(xx, yy, '.',ab2(:, 1), ab2(:, 2), 'r-o')
  legend('data points',  'NSTICK vectorial', ...
     'Location', 'NW')