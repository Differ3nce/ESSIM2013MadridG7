function [O] = maxfiltTom(X,w)
O=ones(length(X),1);
O=O(1,:);
for i=1:(length(X))
    O(i)=max(X(max(1,i-w):min(length(X),i+w)));
end