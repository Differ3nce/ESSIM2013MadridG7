function [dfdx,dfdp] = Derivatives(t,x,p)
global g0 M Rstar L0 rho0 T0 m
%...................................................
% Derivatives
%
% Evaluate the derivatives dfdx and dfdp for the function f
%
% Requested Data:
%   t:  interval of time 
%   x:  substrate concentration
%   p:  parameter of the substrate concentration in the reactor model
%
% Data:
%   theta1: first parameter value of the reaction model
%   theta2: second parameter value of the reaction model
%   dfdx:   derivative of the reaction model respect to x
%   dfdp:   derivative of the reaction model respect to the parameters
%..................................................


%theta1 = p(1);
%theta2 = p(2);

% Evaluate the derivatives dfdx and dfdp
%dfdx = -theta1 * theta2 ./ (theta2 + x).^2;
%dfdp=[-x ./ (theta2 + x), theta1 * x ./ (theta2 + x).^2];
A=-(g0*M)/(Rstar*L0);
dfdx=[0 1; 
    (1/(2*m*rho0))*(A-1)*(((T0+L0*x(1))/T0)^(A-2))*(L0/T0)*x(2)^2*p, (1/m)*rho0*((T0+L0*x(1))/T0)^(A-1)*x(2)*p
    ];
dfdp=[0;1/(2*m*rho0)*(((T0+L0*x(1))/T0)^(A-1))* x(2)^2];



