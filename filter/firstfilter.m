D=importdata('j1.txt');
cutofffactor=10;
startcutoff=00;
dividefactor=2;


data=D(:,2);
len=length(data);
figure(3)
plot(data)
fourier=fft(data);
fourierabs=abs(fourier);
figure(1)
plot(1+startcutoff:(length(D(:,1))/cutofffactor),fourier(1+startcutoff:(length(D(:,1))/cutofffactor)))
chosenfourier=fourier(1:len/dividefactor);
figure(2)
plot(real(ifft(chosenfourier))/dividefactor)