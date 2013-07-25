function this = lsqnonlin(aModel, aData, varargin)
%LSQNONLIN  Constructor.

% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2011/10/22 21:59:38 $

% Create object.
this = idestimatorpack.lsqnonlin;

% Check if OPTIM is available.
if ~idpack.isOptimInstalled
    ctrlMsgUtils.error('Ident:general:optimRequired')
end

if nargin>0
    % Initialize object.
    this.initialize(aModel, aData, varargin{:});
end

% Note: (todo): Lennart mentions minimizing
% trace(e*\lam*e') which is a weighted sse. The "native"
% version of sse assumes a fixed weighting (noise structure
% constant; constant sqrlam). Regularization may
% still be applied.
%
% For minimizing the weighted trace, the noise variance
% ("weights") must be known. We may:
% Option 1: run some weight-free iterations to compute the
% noise variance to obtain a stable value for it,
% or:
% Option 2: use a modified version of lsqnonlin that
% updates noise variance at each iteration (and thus
% returns a custom cost, which is a modification to
% lsqnonlin not implemented yet).