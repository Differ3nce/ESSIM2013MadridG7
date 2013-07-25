function js= jump_step(data)
% this function computes the jumping timestamp from the variable data which
% contains the z acceleration in the second column
acc=data(:,2);
js=find((acc>0),1,'first')-1;
end

