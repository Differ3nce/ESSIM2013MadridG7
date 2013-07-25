function medfilt(N)

skydive1=importdata('j1.txt');

SD=skydive1(:,2);
T=length(SD);

y=medfilt1(SD,N);

figure(5)
plot(y)

end