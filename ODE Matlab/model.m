function xdot = model (t,x,c)
global g0 M Rstar L0 rho0 T0 m
A=-g0*M/(Rstar*L0);
xdot=[x(2);-g0+1/(2*m)*rho0*((T0+L0*x(1))/T0)^(A-1)*x(2)^2*c];
end