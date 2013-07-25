function [Jump,Parachute]=Jump_points_ODE(N)

global data
%skydive1=importdata(sprintf('j%d.txt',i));
%if i==6
%SD_x=skydive1(:,2)/128;
%SD_z=skydive1(:,3)/128;
%else
%SD_x=skydive1(:,3)/128;
%SD_z=skydive1(:,2)/128;
%end
%SD_x=skydive1(:,2)/128;
%SD_z=skydive1(:,3)/128;

SD_x=data(:,3);
SD_z=data(:,2);

Tx=length(SD_x);
Tz=length(SD_z);

x=medfilt1(SD_x,N);
z=medfilt1(SD_z,N);


derz=(z(2:end)-z(1:end-1))/.25;

% figure(1)
% plot(1:Tz,SD_z,'r',1:Tz,z)
% plotyy(1:Tz-1,derz,1:Tz,SD_z)

jump=0.35;
fall=-1;
A=find(derz>jump,1,'first');
B=find(derz<fall,1,'first');

derx=(x(2:end)-x(1:end-1))/.25;

% figure(2)
% plot(1:Tx,SD_x,'r',1:Tx,x)
% plotyy(1:Tx-1,derx,1:Tx,SD_x)
jump=-1;
fall=1;
C=find(derx<jump,1,'first');
D=find(derx>fall,1,'first');

if A>0 Jump=A;
else Jump=C;
end

if B>0
    Parachute=B;
else
    Parachute=D;
end

end
    