function [res] = BP3(data,window,treshdown,treshup,treshmiddle,treshclose)

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
  bp = sort(medfilttreshacc(data,window,treshdown,treshup));
  bp = removemiddlepoints(bp,treshmiddle);
  bp = removeclosepoints(bp,treshclose);
  if T-bp(length(bp))<=5
      bp=bp(1:length(bp)-1);
  end
  res=bp;
  
end