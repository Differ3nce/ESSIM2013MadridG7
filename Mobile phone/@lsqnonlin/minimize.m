function OptimInfo = minimize(this)
% MINIMIZE  Runs the optimization algorithm to minimize the cost and
%    estimate the model parameters.

% Copyright 1986-2011 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2011/10/22 21:59:39 $

% Initializations.
pinfo = this.Info;
p = pinfo.Value;
InfeasibleJac = false;

if isstruct(this.Options)
   isDet = strcmpi(this.Options.Criterion,'det');
   AdvancedOptions = this.Options.SearchOption;
else
   HasWt = hasOutputWeight(this.Options);
   if HasWt
      Wt = this.Options.OutputWeight;
   else
      Wt = [];
   end
   isDet = ~HasWt || isequal(Wt,[]) || strcmp(Wt,'noise');
   AdvancedOptions = this.Options.SearchOption.Advanced;
end

%this.Options.doSqrlam = false;
if isDet
   % turn off 'det'
   if isstruct(this.Options)
      % Model may be a nonlinearity estimator, in which case, there is no
      % "Algorithm"
      if  isa(this.Model,'idnlmodel')
         this.Model.Algorithm.Criterion = 'trace';
      end
      
      if size(this.Options.Weighting,1)>1
         % multi-output case
         ctrlMsgUtils.warning('Ident:estimation:detNotSupportedLSQNONLIN')
      end
      
      this.Options.Criterion = 'trace';
   else
      if HasWt
         this.Options.OutputWeight = eye(size(this.Model,1));
      end
      if strcmp(Wt,'noise')
         ctrlMsgUtils.warning('Ident:estimation:NoiseWtNotSupportedLSQNONLIN')
      end
   end
end

% Call minimizer.
Displ = this.Options.Display;
this.Options.Display = 'off';
[xnew, resnorm, ~, exitflag, output] = ...
    lsqnonlin(@LocalCostFun, p, pinfo.Minimum, pinfo.Maximum, AdvancedOptions, this);
this.Options.Display = Displ;

if InfeasibleJac && exitflag==1
    exitflag = -5;
end

% Output.
OptimInfo = struct('Cost',     resnorm, ...
    'X',        xnew, ...
    'ExitFlag', exitflag, ...
    'Output',   output);

this.info.Value = xnew; %may not be same if optim failed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Nested function.                                                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [R, J] = LocalCostFun(x, varargin)
        % Compute residual vector and its Jacobian.
        JacRequest = (nargout > 1);
        
        %{
        if ~JacRequest
            ctrlMsgUtils.error('Ident:estimation:unsupportedOptimAlgorithm',...
                length(x),sum(this.Options.Utility.DataSize))
        end
        %}
        
        this.Info.Value = x;
        
        [lam, ~, R, J] = ...
            getErrorAndJacobian(this.Model, this.Data, this.Info, this.Options, JacRequest);
        
         if ~JacRequest
            R = [lam;zeros(length(x),1)]; % length one more than par length 
         elseif any(~isfinite(J(:)))
            % This can happen if Jacobian is divergent.
            J = zeros(size(J));
            InfeasibleJac = true;
         end
         
        if any(~isfinite(R(:)))
            R = realmax*ones(size(R));
        end
    end
end
