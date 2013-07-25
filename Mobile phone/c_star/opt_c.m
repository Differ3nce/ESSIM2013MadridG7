function opt_c_star= opt_c(s)
% The function cstar computes the optimal value of the parameter c=Cd*A
% given the freefalling model with drag and s samples of the measured data
global g0 M Rstar L0 rho0 T0 m zob

%%%%%%%%%% COMPUTATION OPTIMAL VALUE C* %%%%%%%%%%%%%%%
tf=.25*(s-1);   % final time with given s
c=0.5;          % initial guess

% Defines the option for lsqnonlin
opt=optimset('Jacobian','on','Algorithm','levenberg-marquardt','Display','off');
% Solves the unconstrained optimization problem
opt_c_star=lsqnonlin(@(p)ObjFun_diff(p,t0:.25:tf,x0,n,np,zob),c,[],[],opt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

