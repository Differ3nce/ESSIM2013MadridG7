% main file to finde optimal value c*
clc
clear all
global data
load('j6.mat'); % the height is called z
z=data(:,1);
%%%%%% TO DO %%%%%%%%
%1- we need to find an automatic way to catch the jumping step and the
% parachute development:: DONE

%2- we need to smooth the data and find the initial vertical velocity:: TO
%DO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%% PARAMETERS SETTING %%%%%%
N=71;
[j,p]=Jump_points_ODE(N);
z=z(j:p);
x0=[z(1);0]; % just to try, we need height and vertical speed at jumping point 4474
t0=0;
tf=.25*(length(z)-1);
n=2;
np=1;
global g0 M Rstar L0 rho0 T0 m
g0=9.81;
m=70;   %choosen according to skydiver
rho0=1.2041; %choosen
T0=293;  %choosen
L0=-0.0065;
M=0.0289644;
Rstar=8.31432;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%% COMPUTATION OPTIMAL VALUE C* %%%%%%%%%%%%%%%
c=0.001;
% Defines the option for lsqnonlin
opt=optimset('Jacobian','on','Algorithm','levenberg-marquardt','Display','iter-detailed');
% Solves the unconstrained optimization problem
[cstar,resnorm,resid,exitflag,output]=lsqnonlin(@(p)ObjFun_diff(p,t0:.25:tf,x0,n,np,z),c,[],[],opt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% COMPUTE SOLUTION SPECIAL CASE C* %%%%%%%%%%%%%
opt_ode=odeset('RelTol',1e-8,'AbsTol',1e-8);
[T,Z] = ode45(@model, t0:.25:tf,x0,opt_ode,cstar);
%plot measures and best solution
figure(1)
plot(z,'o');
hold on
plot(Z(:,1),'-r');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%