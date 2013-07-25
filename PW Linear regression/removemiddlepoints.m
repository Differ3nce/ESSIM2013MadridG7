function [R] = removemiddlepoints(points, tresh)
found = false;
T=length(points);
res=[];
for i=1:T-1
    if found==false
        if points(i+1)-points(i)<=tresh
            found=true;
        end
        res=[res,points(i)];
    else
        if points(i+1)-points(i)>tresh
            res=[res,points(i)];
            found=false;
        end
    end 
end
R=[res,points(T)];
end