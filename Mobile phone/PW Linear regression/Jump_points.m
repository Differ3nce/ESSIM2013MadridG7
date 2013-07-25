function [Jump,Parachute]=Jump_points(N,i)


skydive1=importdata(sprintf('j%d.txt',i));

if i==6
SD_x=skydive1(:,2)/128;
SD_z=skydive1(:,3)/128;
else
SD_x=skydive1(:,3)/128;
SD_z=skydive1(:,2)/128;
end


Tx=length(SD_x);
Tz=length(SD_z);

x=medfiltTom(SD_x,N);
z=medfiltTom(SD_z,N);

figure(1)
plot(1:Tz,SD_z,'r',1:Tz,z)
derz=(z(2:end)-z(1:end-1))/.25;
plotyy(1:Tz-1,derz,1:Tz,SD_z)
jump=0.35;
fall=-1;
A=find(derz>jump,1,'first');
B=find(derz<fall,1,'first');

figure(2)
plot(1:Tx,SD_x,'r',1:Tx,x)
derx=(x(2:end)-x(1:end-1))/.25;
plotyy(1:Tx-1,derx,1:Tx,SD_x)
jump=-1;
fall=1;
C=find(derx<jump,1,'first');
D=find(derx>fall,1,'first');

if A>0
    Jump=A;
else
    Jump=C;
end

if B>0
    Parachute=B;
else
    Parachute=D;
end

end
    