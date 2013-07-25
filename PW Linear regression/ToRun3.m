l=l-mean(l);
intl=l;
for i=2:length(l)
    intl(i)=intl(i-1)+l(i);
end
figure(8)
plot(0.25*intl)
figure(9)
