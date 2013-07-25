function res = bpaverage(bp,data)
T=length(bp);
points=ones(T-1,1);
for i=1:T-1
    points(i)=floor(round(bp(i)+bp(i+1))/2);
end
R=ones(T,1);
for i=1:T-2
    R(i+1)=mean(data(points(i):points(i+1)));
end
R(1)=mean(data(1:points(1)));
R(T)=mean(data(points(T-1):bp(T)));
res=R;
end