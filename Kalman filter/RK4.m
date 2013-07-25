function [z1 v1] = RK4(z,v)
global h cstar
k1 = model(1,[z,v],cstar);
k2 = model(1,[z+h/2*k1(1),v+h/2*k1(2)],cstar);
k3 = model(1,[z+h/2*k2(1),v+h/2*k2(2)],cstar);
k4 = model(1,[z+h*k3(1),v+h*k3(2)],cstar);

z1 = z + h/6*[k1(1)+2*k2(1)+2*k3(1)+k4(1)];
v1 = v + h/6*[k1(2)+2*k2(2)+2*k3(2)+k4(2)];
end

