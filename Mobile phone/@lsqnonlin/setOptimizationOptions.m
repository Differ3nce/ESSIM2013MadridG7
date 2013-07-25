function setOptimizationOptions(this, options, varargin)
%SETOPTIMIZATIONOPTIONS  Interprets the optimization options which may be
%   structure differently for various models.

% Author(s): Rajiv Singh
%   Copyright 2006-2011 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $ $Date: 2012/01/12 21:34:30 $

% Initializations.
Model = this.Model;

if isstruct(options)
   % Old "Algorithm" structure was provided
   sopt = optimset('lsqnonlin');
   sopt.PrecondBandWidth = Inf; % Force medium scale trust-region.
   sopt.Jacobian = 'on';
   sopt.Display = 'off';
   sopt.TolFun = options.Tolerance*1e-3;  % b.c.
   sopt.MaxIter = options.MaxIter;
   sopt.Criterion = options.Criterion;
   sopt.Weighting = options.Weighting;
elseif isa(options, 'idoptions.GenericEstimation')
   % Options object: must implement idoptions.NumericalSearch
   sopt = options.SearchOption.Advanced;
   sopt.Jacobian = 'on';
   sopt.Display = 'off';
   sopt.PrecondBandWidth = Inf;
end

if sopt.MaxIter==0
   sopt.TolFun = Inf; %to stop iterations prematurely
end

%{
option = [];
if isstruct(options)
   alg = varargin{1};
elseif isa(options, 'idoptions.GenericEstimation')
   option = options.SearchOption;
   alg = option2Algorithm(this, Model.Algorithm);
else
   alg = Model.Algorithm;
end

if isequal(option,[])
   option = optimset('lsqnonlin');
   option.PrecondBandWidth = Inf; % Force medium scale trust-region.
   option.Jacobian = 'on';
   option.Display = 'off';
   option.TolFun = alg.Tolerance*1e-3;  % todo: lsqnonlin defaults are usually lower.
end

if option.MaxIter<0
    option.MaxIter = 0;
    option.TolFun = Inf; %to stop iterations prematurely
else
    option.MaxIter = alg.MaxIter;
end
%}

if isa(this.Data,'iddata')
   ut.DataSize = size(this.Data, 1);
elseif iscell(this.Data)
   % time domain data in raw form
   if iscell(this.Data{1}) %idnlfun case
      ut.DataSize = size(this.Data{1}{1}, 1);
   else
      % deconstructed iddata (such as idpoly/pem_f)
      ut.DataSize = cellfun(@(x)size(x,1),this.Data);
   end
elseif isstruct(this.Data)
   ut.DataSize = this.Data.Ncaps;
else
   ctrlMsgUtils.error('Ident:utility:unknownData','lsqnonlin')
end

%option.CostType = 'SSE'; % Fixed cost type for lsqnonlin, where doSqrLam is false.

ut.ComputeProjFlag = false; % default (overridden for ssfree)
ut.ProjectionFun = '';
options.Utility = ut;

% Ask model to configure model-specific properties
options = configureOptimizationOptions(Model, options, this);
ut.isLinmod = isa(Model,'idpack.ltidata');

if ut.isLinmod && ~options.Utility.struc.realflag
   ctrlMsgUtils.error('Ident:estimation:LsqnonlinComplexData')
end

ut = options.Utility;

% Initialize field for iteration info
ut.IterInfo = struct('Iteration',0);
Display = options.Display;

% Display = 'Full' should be treated as Display = 'On' for nonlinear models.
% todo: handle "full" Display for idnlgrey?
if (isa(Model, 'idnlmodel') && strcmpi(Display, 'full'))
   Display = 'on';
end

ut.isLinmod = isa(Model, 'idpack.ltidata');
ProgressViewer = options.ProgressWindow;
if ~ut.isLinmod && ischar(ProgressViewer)
   ProgressViewer = idpack.EstimProgress.getEstimProgressView(false, true);
end

Display = options.Display;
if ~strcmpi(Display, 'off')
   if ~isempty(ProgressViewer) && (~isvalid(ProgressViewer) || ...
         ~ProgressViewer.ActiveJavaWindow)
      % replace invalid handle with []
      ProgressViewer = [];
   end
end

%showpar = false;
if strcmpi(Display,'full')
   sys = this.Model;
   %allPar = localGetPar(this.Model);
   TFESTFlag = isa(sys, 'idpack.ssdata') && sys.TFMod;
   oldPar = localGetPar(sys,TFESTFlag);
   if isa(sys, 'idpack.ltidata')
      struc  = options.Utility.struc;
      names = localGetNames(sys,TFESTFlag);
      NotShow = struc.fixparind;
      names(NotShow) = [];
      oldPar(NotShow) = [];
      %ParInd = 1:struc.Npar; ParInd(struc.fixparind) = []; % free par index
      ParInfo = [names, cell(length(names),3)];
      ParamStr = ctrlMsgUtils.message('Ident:general:msgParamStr');
      NameStr =  xlate('Name');
      NewValueStr = ctrlMsgUtils.message('Ident:general:msgNewValueStr');
      OldValueStr = ctrlMsgUtils.message('Ident:general:msgOldValueStr');
      GradStr = ctrlMsgUtils.message('Ident:general:msgGradStr');
   end
end

options.Utility = ut;
options.SearchOption = sopt;
this.Options = options; % could be struct or options object

prevloss = [];

% Attach output function.
if isstruct(options)
   this.Options.SearchOption.OutputFcn = @localOutput;
   % Determine heading to display.
   commonheader = LocalGetCommonHeader(this.Options.SearchOption);
else
   this.Options.SearchOption.Advanced.OutputFcn = @localOutput;
   % Determine heading to display.
   commonheader = LocalGetCommonHeader(options.SearchOption.Advanced);
end

linestr = repmat('-', 1, 62);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Nested functions.                                                              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------------------------
   function stop = localOutput(values, state, type, varargin)
      % Used to store progress information and stop optimization
      drawnow; % Force processing of any stop event
      newInfo = this.getIterInfo(values, state, type);
      %TrueNobs = max(1, sum(option.Utility.DataSize)-length(values)/NY);
      if strcmpi(Display, 'on')
         switch type
            case 'init'
               showInitialInfo;
            case 'iter'
               showDisplay;
            case 'done'
               showEndInfo;
            otherwise
               % Do nothing!
         end
      elseif strcmpi(Display, 'full')
         switch type
            case 'init'
               showFullInitialInfo;
            case 'iter'
               showFullDisplay;
            case 'done'
               showFullEndInfo;
            otherwise
               % Do nothing!
         end
      end
      
      % Update current iteration information in options
      this.Options.Utility.IterInfo = newInfo;
      
      % 1. find out if optimization should stop
      % 2. send an event to inform the GUI object.
      if ~isempty(ProgressViewer)
         stop = ProgressViewer.STOP;
      else
         stop = false;
      end
      if strcmpi(Display, 'off') && ~ut.isLinmod
         stop = LocalSendEvent(Model,newInfo,prevloss,type);
      end
      
      prevloss = newInfo.Cost;
      %------------------------------------------------------------------
      function showInitialInfo
         % Determine heading to display.
         header = sprintf('\n%s\n%s\n%s\n%s\n%s', commonheader, ...
            linestr, ...
            '                                 Norm of      First-order', ...
            ' Iteration      Cost             step         optimality  ', ...
            linestr);
         
         formatstr = ' %5.0f    %13.6g    %10.3s    %13.3s ';
         %newInfo = this.getIterInfo(values, state, type);
         currOutput = sprintf(formatstr, newInfo.Iteration, newInfo.Cost, '-', '-');
         idDisplayEstimationInfo('Progress',{header, currOutput},ProgressViewer);
      end
      
      %------------------------------------------------------------------
      function showDisplay
         if (state.iteration > 0) && (state.iteration <= sopt.MaxIter)
            formatstr = ' %5.0f    %13.6g    %10.3g    %13.3g';
            %newInfo = this.getIterInfo(values, state, type);
            currOutput = sprintf(formatstr, newInfo.Iteration, ...
               newInfo.Cost, newInfo.StepSize, newInfo.FirstOrd);
            idDisplayEstimationInfo('Progress',currOutput,ProgressViewer);
         end
      end
      
      %------------------------------------------------------------------
      function showEndInfo
         idDisplayEstimationInfo('Progress',linestr,ProgressViewer);
      end
      
      %------------------------------------------------------------------
      function showFullInitialInfo
         % Determine heading to display.
         
         Disp{1} = linestr;
         Disp{2} = commonheader;
         Disp{3} = linestr;
         
         Disp{4} = 'Initial Estimate:';
         Disp{5} = sprintf('   Current cost: %5.6g\n',newInfo.Cost);
         idDisplayEstimationInfo('Progress',Disp,ProgressViewer);
         %disp('   Parameters:')
         updateParInfo(0);
         idestimatorpack.parDisplay(ParInfo,0,{NameStr,ParamStr},ProgressViewer);
         %prevloss = newInfo.Cost;
         idDisplayEstimationInfo('Progress',' ',ProgressViewer)
      end
      
      %------------------------------------------------------------------
      function showFullDisplay
         
         Disp{1} = sprintf('Iteration %d:\n',newInfo.Iteration);
         Disp{2} = sprintf('   Current cost: %5.6g   Previous cost: %5.6g\n',...
            newInfo.Cost,prevloss);
         idDisplayEstimationInfo('Progress',Disp,ProgressViewer);
         %prevloss = newInfo.Cost;
         %disp('   Param          New value     Prev. value     Gradient ')
         %setParameterString(1);
         %localDisp(Pdisp, UnnamedPar);
         
         
         %fprintf('   Param         %s       Prev. value    Direction \n',[char(Nl*ones(1,NamLen-8)),'New value'])
         updateParInfo(1);
         idestimatorpack.parDisplay(ParInfo,1,{NameStr,NewValueStr,OldValueStr,GradStr},ProgressViewer);
         
         clear Disp;
         Disp{1} = sprintf('   Step-size: %5.6g\n',newInfo.StepSize);
         Disp{2} = sprintf('   First-order optimality: %5.6g\n\n',newInfo.FirstOrd);
         idDisplayEstimationInfo('Progress',Disp,ProgressViewer);
      end
      
      %------------------------------------------------------------------
      function showFullEndInfo
         Disp{1} = 'Estimation complete.';
         Disp{2} = sprintf('First-order optimality (largest slope): %5.6g\n',...
            newInfo.FirstOrd);
         Disp{3} = sprintf('Final cost: %5.6g\n',newInfo.Cost);
         Disp{4} = ' ';
         idDisplayEstimationInfo('Progress',Disp,ProgressViewer);
      end
      
      %------------------------------------------------------------------
      function updateParInfo(Flag_)
         % Return a nice display of parameter names and current values
         
         if Flag_>0
            np_ = size(ParInfo,1);
            npnew = numel(newInfo.Values);
            if npnew>np_
               % can happen if i.c. is estimated for polynomial models
               newnames = strseq('x',1:npnew-np_);
               ParInfo = [ParInfo; [newnames, cell(length(newnames),3)]];
               oldPar = [oldPar;zeros(npnew-np_,1)];
            elseif npnew<np_
               ParInfo = ParInfo(1:npnew,:);
               oldPar = oldPar(1:npnew,:);
            end
            ParInfo(:,2) =  num2cell(newInfo.Values');
            ParInfo(:,3) = num2cell(oldPar);
            ParInfo(:,4) =  num2cell(newInfo.Gradient);
            oldPar = newInfo.Values;
         else
            ParInfo(:,2) =  num2cell(oldPar);
         end
      end
      
   end
end
%--------------------------------------------------------------------------
%- LOCAL FUNCTION (not nested)---------------------------------------------
%--------------------------------------------------------------------------
function stop = LocalSendEvent(Model,newInfo,oldcost,type)
% event types: 'optimStartInfo','optimIterInfo','optimEndInfo'

stop = false;
messenger = idestimatorpack.getOptimMessenger(Model);
if isempty(messenger) || ~isa(messenger,'nlutilspack.optimmessenger')
   return;
end

stop = messenger.Stop;

info = struct('Iteration',newInfo.Iteration,...
   'Cost',newInfo.Cost,...
   'OldCost',oldcost,...
   'StepSize',newInfo.StepSize,...
   'Optimality',newInfo.FirstOrd,...
   'Bisections',[],...
   'Name','lsqnonlin',...
   'ModelType',class(Model));

%sprintf('%s:%d',type, newInfo.Iteration)
switch type
   case 'init'
      ed = nlutilspack.idguievent(messenger,'optimStartInfo');
   case 'iter'
      ed = nlutilspack.idguievent(messenger,'optimIterInfo');
   case 'done'
      ed = nlutilspack.idguievent(messenger,'optimEndInfo');
   otherwise
      return;
end
ed.Info = info;
messenger.send('optiminfo',ed);
end

%--------------------------------------------------------------------------
function str = LocalGetCommonHeader(option)
% Determine heading to display.

%option = this.Options;
if strcmp(option.Algorithm,'trust-region-reflective')
   str = 'Algorithm: Trust-Region Reflective Newton';
else
   str = 'Algorithm: Levenburg-Marquardt';
end
%{
if strcmpi(option.LargeScale, 'off') % never true currently (awaiting lsqnonlin revision)
   if strcmpi(option.LevenbergMarquardt, 'off')
      str = 'Gauss-Newton line search (LSQNONLIN, LargeScale = ''Off'')';
   else
      str = 'Levenburg-Marquardt line search (LSQNONLIN, LargeScale = ''Off'')';
   end
else
   str = 'Trust-Region Reflective Newton (LSQNONLIN, LargeScale = ''On'')';
end
%}

%{
str = ['   Scheme: ',str];

if strcmpi(option.Criterion,'det')
   str = sprintf('Criterion: Determinant minimization\n%s',str);
else
   str = sprintf('Criterion: Trace minimization\n%s',str);
end
%}

end

%--------------------------------------------------------------------------
function par = localGetPar(sys,TFESTFlag)
% Temporary gateway to fetch parameters.

if strcmp(class(sys),'idpack.ssdata')
   par = getpwithx0(sys);
   if TFESTFlag
      try
         IODPar = sys.Delay.IO;
         delpar = zeros(numel(IODPar),1);
         for ct = 1:numel(delpar)
            delpar(ct) = IODPar(ct).Value;
         end
         par = [par; delpar];
      end
   end
elseif ~isa(sys,'idpack.ltidata') % nonlinear models
   par = getParameterVector(this.Model);
else
   par = getp(sys);
end

end

%--------------------------------------------------------------------------
function names = localGetNames(sys,TFESTFlag)
% Get parameter names. Temporary gateway.

if isa(sys,'idnlmodel')
   names = pvget(sys,'PName');
   if isempty(names)
      sys = setpname(sys);
      names = pvget(sys,'PName');
   end
else
   if isa(sys, 'idpack.greydata')
      names = getplabels(sys);
      if sys.ProcMod.IsProcMod
         for iN = 1:numel(names)
            if any(strncmpi(names{iN},{'Tp','Tw'},2))
               names{iN} = ['1/',names{iN}];
            end
         end
      end
   elseif isa(sys, 'idpack.ssdata')
      names = getplabelswithx0(sys);
      if TFESTFlag
         try
            IOD = sys.Delay.IO;
            delnames = cell(numel(IOD),1);
            for ct = 1:numel(IOD)
               delnames{ct} = IOD(ct).Info.Label;
            end
            names = [names; delnames];
         end
      end
   else
      names = getParInfo(sys,'Name');
   end
   
   if all(strcmp(names,''))
      names = getDefaultParNames(sys,'withx0');
      if TFESTFlag
         try
            if numel(sys.Delay.IO)==1
               delnames = {'ioDelay'};
            else
               delnames = strseq('ioDelay(',1:numel(sys.Delay.IO));
               delnames = cellfun(@(k_)[k_,')'],delnames,'UniformOutput',false);
            end
            names = [names; delnames];
         end
      end
   end
end
end
