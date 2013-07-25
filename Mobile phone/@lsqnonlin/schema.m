function schema
%SCHEMA  Defines properties for @lsqnonlin class.

% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2011/10/22 21:59:40 $

% Get handles of associated packages and classes.
hDeriveFromPackage = findpackage('idestimatorpack');
hDeriveFromClass = findclass(hDeriveFromPackage, 'estimator');
hCreateInPackage = hDeriveFromPackage;

% Construct class.
schema.class(hCreateInPackage, 'lsqnonlin', hDeriveFromClass);