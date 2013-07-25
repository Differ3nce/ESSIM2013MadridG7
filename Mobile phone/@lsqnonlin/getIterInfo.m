function IterInfo = getIterInfo(this, values, state, type)
%GETITERINFO  Translates optim info into a common format.

% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2011/10/22 21:59:37 $

% Update IterInfo.
if isempty(state.stepsize)
  state.stepsize = NaN;
end

% todo: cost calculation will not hold if QR is used (because
% Nobs~=numel(state.residual))
IterInfo.Cost      = state.resnorm/numel(state.residual);
IterInfo.FCount    = state.funccount;
IterInfo.FirstOrd  = state.firstorderopt;
IterInfo.Gradient  = state.gradient';
IterInfo.Iteration = state.iteration;
IterInfo.StepSize  = state.stepsize;
IterInfo.Values    = values';
