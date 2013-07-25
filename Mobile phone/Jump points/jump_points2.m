function [jump]=jump_points2(j) % j = data set

% uses norm of [x,y,x] acceleration vector

skydive1=importdata(sprintf('j%d.txt',j));
height=skydive1(:,1);
T=length(height);
x=zeros(1,T);
for i=1:T;
    vector=[skydive1(i,3),skydive1(i,4),skydive1(i,2)];
    x(i)=norm(vector);
end

X=medfilt1(x,21);
av_acc=sum(X)/T;
threshhold=av_acc/1.5;
jump=find(X<threshhold,1,'first');

figure(1)
plot(1:T,height)

 
end


