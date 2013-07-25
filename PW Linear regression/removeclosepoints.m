function [R] = removeclosepoints(points,tresh)
T=length(points);
res=[];
found=false;
for i=1:T-1
    if found==false
        if points(i+1)-points(i)<=tresh
            res = [res,round((points(i+1)+points(i))/2)];
            found=true;
        else
            res = [res,points(i)];
        end
    else
        found=false;
    end
end
if found==false
    res=[res,points(T)];
end
R=res;

end