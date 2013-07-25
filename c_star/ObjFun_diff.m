function [f, J] = ObjFun_diff(theta,t,x0,n,np,y)
%...................................................
% ObjFun_diff
%
% Computes the Objective function phi(theta) for the Enzyme Catalyzed 
% Reaction
%
% Requested Data:
%   theta:  parameter of the substrate concentration in the reactor model
%   t:      interval of time 
%   x0:     initial substrate concentration
%   p:      parameter of the substrate concentration in the reactor model
%   n:      number of variables in the ODE
%   np:     number of parameters
%   y:      measured substrate concentration, provided in MMBatchData.mat
%
%..................................................
% Data:
%   T:  integrated times
%   Z:  integrated point
%   f:  objective function phi(theta)
%   J:  Jacobian matrix
%
% Functions Called
%   ModelAndSensitivity: model for the ODE of the reaction and sensitivity
%..................................................

opt_ode=odeset('RelTol',1e-3,'AbsTol',1e-3);

% Solves the ODE for the given data
[T,Z] = ode45(@ModelAndSensitivity,t,[x0; zeros(2,1)],opt_ode,theta,n,np);


% Computes the objective function
f = Z(:,1) - y(1:length(Z(:,1)));
% Jacobian matrix coming from sensitivity
J = Z(:,3);
