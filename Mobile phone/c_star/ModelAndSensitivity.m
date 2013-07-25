function zdot = ModelAndSensitivity(t,z,p,n,np)
%...................................................
% ModelAndSensitivity
%
% Computes the ODE of the model and the ODE of the parameter sensitivities
%
% Requested Data:
%   t:  interval of time 
%   z:  initial substrate concentration and initial parameter sensitivities
%   p:  parameter of the substrate concentration in the reactor model
%   n:  number of variables in the ODE
%   np: number of parameters
%
% Data:
%   x:      integrated times
%   sp:     vector with all the parameter sensitivities
%   Sp:     matrix of the parameter sensitivities
%   xdot:   velocity of the Enzyme Catalyzed Reaction
%   dfdx:   derivative of the reaction model respect to x
%   dfdp:   derivative of the reaction model respect to the parameters
%   Spdot:  derivative of the parameter sensitivities matrix
%   zdot:   derivative of the vector with the first part x and second sp
%
% Functions Called
%   model:          model for the ODE of the reaction
%   Derivatives:    Evaluate the derivatives dfdx and dfdp
%..................................................

% Unpack the vector z
x = z(1:n,1); % Unpack states
sp = z(n+1:end,1); % Unpack sensitivities
Sp = reshape(sp,n,np); % Sensitivities as a matrix

% Computes the ODEs for the model and the sensitivity
xdot = model(t,x,p); % Evaluate the model equations
[dfdx,dfdp] = Derivatives(t,x,p); % Evaluate the derivatives
Spdot = dfdx*Sp + dfdp;
zdot = [xdot; Spdot(:)];% Return derivatives as a vector