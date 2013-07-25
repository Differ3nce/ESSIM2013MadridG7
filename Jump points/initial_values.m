function [x,initial_height,v] = initial_values(i,delay)
%delay=15

%importing data
data=importdata(sprintf('j%d.txt',i));
height=data(:,1);

%moving average filter
filtered_height=filter(ones(1,20)/20,1,height);
filtered_height=filtered_height(10:end);

[Jump]=jump_points2(i);
x=Jump+delay;
initial_height=filtered_height(Jump+delay);
v=(filtered_height(Jump+delay+1)-filtered_height(Jump+delay-1))/(2*0.25);
end

