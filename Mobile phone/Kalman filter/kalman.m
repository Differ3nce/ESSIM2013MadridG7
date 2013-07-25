
function kalman(i);

% Physical constant used
global g0 M Rstar L0 rho0 T0 m h cstar expo z0 v0 zob
g0=9.81;
m=70;   
rho0=1.2041;
T0=293;  
L0=-0.0065;
M=0.0289644;
Rstar=8.31432;
cstar = 0.52;
expo = -g0*M/(Rstar*L0)-1;

% Data
skydive=importdata(sprintf('j%d.txt',i));
zob = skydive(:,1);
aobz = skydive(:,2);
aobx = skydive(:,3);
aoby = skydive(:,4);
A(:,1) = (aobx/128);
A(:,2) = (aoby/128);
A(:,3) = (aobz/128);
Anorm = sqrt(sum(A.^2,2));
Anorm = (Anorm-1)*g0;

% Initial states
[Jump Parachute] = Jump_points(71,i)
delay = 10;
[JumpDelay,initial_height,initial_velocity] = initial_values(i,delay)
Jump = JumpDelay;
zob = zob(Jump:Parachute);   % height observed after the jump
aob = Anorm(Jump:Parachute); % velocity observed after the jump
z0 = initial_height;         % altitude when the diver is jumping (zob(1))
v0 = initial_velocity;       % velocity on the z-axis when the diver is jumping
u_0b = [z0,v0];              % the background data
scheme = 2;                  % Euler or RK4 method

% Time simulation
tassim = length(zob)-1       % number of data available 
tpredict = 50;               % number of state to predict after
tfinal = tassim + tpredict;  % time of the assimilation
h = 0.25;                    % time step in seconds 

% Observation noise matrix R
R = zeros(2,2,tfinal);   
for i = 1 : tfinal
    R(:,:,i) = [15^2 0 ; 0 (0.5)^2];
end


%%%%%%%%%%%%%%%%%%%
%  Kalman Filter  %
%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
%  Initialization  %
%  ua(0) = ub      %
%  Pa(0) = I       %
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Etape k (prediction - update)                                          %
%                                                                         %
%  uf(k+1) = ua(k) + f(ua(k))                   (KF1) Euler Scheme        %
%  Pf(k+1) = Mkl*Pa(k)*Mkl^t+Q(k)               (KF2) Mkl Jacobian matrix %
%  K(k+1)  = Pf(k+1)*H^t*(H*Pf(k+1)*H^t+R(k+1))^(-1)(KF3)                 %
%                                                                         %
%  ua(k+1) = uf(k+1)+K(k+1)*(uobs(k+1)-H*uf(k+1)) (KF4)                   %
%  Pa(k+1) = (I-K(k+1)*H)*Pf(k+1)                 (KF5)                   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Memory storage
zf = zeros(tfinal);
vf = zeros(tfinal);
ua = zeros(2,tfinal);
uf = zeros(2,tfinal);        
K = zeros(2,2,tfinal);       % Gain matrix
Pf = zeros(2,2,tfinal);      % Forecast covariance matrix
Pa = zeros(2,2,tfinal);      % Analysis covariance matrix
Ml = zeros(2,2,tfinal);      % Jacobian matrix
Q = diag([5^2,(0.2)^2]);              % Q = 0
H = zeros(2,2,tfinal);              % Observation matrix which is constant

% --- Initialization --- %

% We start from the background estimation u_b0
zf = u_0b(1);
vf = u_0b(2);
uf(:,1) = [zf(1);vf(1)]; % 
u_ob=zeros(2,tfinal);
u_ob=[zob';aob'];

% Covariance matrix error initialize from Identity
Pf(:,:,1) = eye(2); 

ua(:,1) = uf(:,1); 

% Observation matrix
H = [1 0 ; 0 0];

% For displaying matrix (debug)
T = zeros(2,2);

% Initialization of the gain matrix
K(:,:,1) = Pf(:,:,1)*H'*pinv(H*Pf(:,:,1)*H'+R(:,:,1)); 
T = K(:,:,1); % to debug

% Initialization of the covariance matrix
%Pa(:,:,1) = (eye(2,2)-K(:,:,1)*H)*Pf(:,:,1);
Pa(:,:,1) = R(:,:,1);
T = Pa(:,:,1); % almost equal to the identity because K ~ 0
length(zob)
for k = 1 : tfinal-1
    
    if k >= tassim
        u_ob(:,k+1)=0;
    end
    
    if (k>=25) & (k <= tassim) & (mod(k,5) == 0) 
     cstar = opt_c(k);
    end
   
    % We get the previous analysis term ua
    zf(k) = ua(1,k);
    vf(k) = ua(2,k);
    
    % We update uf(k+1) ------------------------------- (KF1)
    if scheme == 1
    % Euler scheme
       zf(k+1) = zf(k)+h*vf(k);
       vf(k+1) = vf(k)+h*(-g0+1/(2*m)*rho0*((T0+L0*zf(k))/T0)^(expo))*vf(k)^2*cstar;
    elseif scheme == 2
%         k1 = model(1,[zf(k),vf(k)],cstar);
%         k2 = model(1,[zf(k)+h/2*k1(1),vf(k)+h/2*k1(2)],cstar);
%         k3 = model(1,[zf(k)+h/2*k2(1),vf(k)+h/2*k2(2)],cstar);
%         k4 = model(1,[zf(k)+h*k3(1),vf(k)+h*k3(2)],cstar);
%         zf(k+1) = zf(k) + h/6*[k1(1)+2*k2(1)+2*k3(1)+k4(1)];
%         vf(k+1) = vf(k) + h/6*[k1(2)+2*k2(2)+2*k3(2)+k4(2)];
          [zf(k+1) vf(k+1)] = RK4(zf(k),vf(k));
    end
      
    % We store into a vector
    uf(:,k+1)=[zf(k+1);vf(k+1)];
    
    % We compute the jacobian matrix at the current point 
%     Ml(1,1,k) = 0;
%     Ml(1,2,k) = 1;
%     Ml(2,2,k) = rho0*((T0+L0*zf(k))/T0)^(expo)*vf(k)*cstar/m;
%     Ml(2,1,k) = 0.5*rho0*((T0+L0*zf(k))/T0)^(expo)*expo*L0*cstar*vf(k)^2/(m*(T0+L0*zf(k)));
      Ml(:,:,k) = admDiffFor(@RK4, 1, zf(k), vf(k)); % quasi constant [1 0.24 ; 0 0.95]
 
    T = Ml(:,:,k); %to debug 
    
     Pf(:,:,k+1) = Ml(:,:,k)*Pa(:,:,k)*Ml(:,:,k)'+Q; %(KF2)
     T = Pf(:,:,k+1); % to debug

    % If there is an observation at time tk
    if u_ob(:,k+1) ~= 0 
        
        H(:,:,k+1) = [1 0 ; 0.5*rho0*((T0+L0*zf(k))/T0)^(expo)*expo*L0*cstar*vf(k)^2/(m*(T0+L0*zf(k))) rho0*((T0+L0*zf(k))/T0)^(expo)*vf(k)*cstar/m];
        T = H(:,:,k+1);
        
        % We update K(k+1) ---------------------------- (KF3)
        K(:,:,k+1) = Pf(:,:,k+1)*H(:,:,k+1)'*pinv(H(:,:,k+1)*Pf(:,:,k+1)*H(:,:,k+1)'+R(:,:,k+1));
        T = K(:,:,k+1); % to debug
        
        % We compute the anaysis xa(k+1) -------------------- (KF4)
        %ua(:,k+1) = uf(:,k+1)+K(:,:,k+1)*(u_ob(:,k+1)-H(:,:,k+1)*uf(:,k+1));
        innovation = K(:,:,k+1)*(u_ob(:,k+1)-[zf(k+1);-g0+1/(2*m)*rho0*((T0+L0*zf(k+1))/T0)^(expo)*vf(k+1)^2*cstar]);
        ua(:,k+1) = uf(:,k+1)+innovation;
        
        % We compute the covariance analysis matrix Pa  (KF5)
        Pa(:,:,k+1) = (eye(2,2)-K(:,:,k+1)*H(:,:,k+1))*Pf(:,:,k+1);
    else
        % Else we just copy
        ua(:,k+1) = uf(:,k+1);
        Pa(:,:,k+1) = Pf(:,:,k+1);
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Compute the solution derived from u_b  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zb = zeros(tfinal,1);
vb = zeros(tfinal,1);

% Initialization to u_0b
zb(1) = u_0b(1);
vb(1) = u_0b(2);

% Euler scheme
for i = 1 : tfinal-1
    if scheme == 1
        zb(i+1) = zb(i) + h*vb(i);
        vb(i+1) = vb(i) + h*(-g0+(1/(2*m)*rho0*((T0+L0*zb(i))/T0)^(expo))*vb(i)^2*cstar);
    elseif scheme == 2
        k1 = model(1,[zb(i),vb(i)],cstar);
        k2 = model(1,[zb(i)+h/2*k1(1),vb(i)+h/2*k1(2)],cstar);
        k3 = model(1,[zb(i)+h/2*k2(1),vb(i)+h/2*k2(2)],cstar);
        k4 = model(1,[zb(i)+h*k3(1),vb(i)+h*k3(2)],cstar);
        zb(i+1) = zb(i) + h/6*[k1(1)+2*k2(1)+2*k3(1)+k4(1)];
        vb(i+1) = vb(i) + h/6*[k1(2)+2*k2(2)+2*k3(2)+k4(2)];
    end
end

%%%%%%%%%%%%%%%%%%%
% DISPLAY RESULTS %
%%%%%%%%%%%%%%%%%%%

t = 0:h:tfinal*h-h;

% Display height
figure;
plot(t,zb); % from the model beginning at the initial state u_b0
hold on;
plot(t(1:length(zob)),zob,'o'); % the observations of height
plot(t,ua(1,:),'r'); % the kalman filter 
hold off;

% Display acceleration
figure;

hold on
plot(t(1:length(aob)),aob,'-b'); % the observations of acceleration 
plot(t(1:size(ua,2)-1),(ua(2,2:end)-ua(2,1:end-1))/h,'g'); % the kalman filter
plot(t(1:length(vb)-1),(vb(2:end)-vb(1:end-1))/h); % from the model beginning at initial state u_b0
hold off;

figure;
plot(t(1:size(ua,2)),ua(2,:),'r'); % the kalman filter
hold on;
plot(t(1:length(vb)),vb); % from the model beginning at initial state u_b0

%opt_ode=odeset('RelTol',1e-8,'AbsTol',1e-8);
%[T,Z] = ode45(@model, t,u_0b,opt_ode,cstar);
%hold on
%plot(t,Z(:,1),'-g');

end

% TODO
% cstar doit etre recalculé avec la nouvelle condition initiale v0
% matrix noise à revoir