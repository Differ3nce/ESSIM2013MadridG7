D=importdata('j1.txt');
data=D(:,2);
len=length(data);


cutofffactor=10;
startcutoff=00;
clear('cutoffunction');
%cutofffunction=[10*ones(round(len/10),1);0*(ones(len-round(len/10),1))];
x=1:len;
cutofffunction=sqrt(1./(1.+(0.2*x).^2));
%cutofffunction=cutofffunction/sum(cutofffunction)*len;


figure(4)
plot(data)
fourier=fft(data);
figure(2)
fourierabs=abs(fourier);
plot(fourierabs(5,len))
figure(3)
chosenfourier=fourier.*transpose(cutofffunction);
chosenfourierabs=abs(chosenfourier);
plot(chosenfourierabs(5,len))

figure(1)
plot(real(ifft(chosenfourier)))