function [neq, tspan, ntspan, next, t0, tfinal, y0, f0, ...
    options, threshold, rtol, normcontrol, normy, hmax, htry, htspan, ...
    dataType,atol] =   ...
    odearguments(solver,ode, tspan, y0, options)

import modgen.common.throwerror;
if isempty(tspan) || isempty(y0)
    error(message('MATLAB:odearguments:TspanOrY0NotSupplied', solver));
end
if length(tspan) < 2
    error(message('MATLAB:odearguments:SizeTspan', solver));
end
htspan = abs(tspan(2) - tspan(1));
tspan = tspan(:);
ntspan = length(tspan);
t0 = tspan(1);
next = 2;       % next entry in tspan
tfinal = tspan(end);

y0 = y0(:);
neq = length(y0);

% Test that tspan is internally consistent.
if t0 == tfinal
    error(message('MATLAB:odearguments:TspanEndpointsNotDistinct'));
end
tdir = sign(tfinal - t0);
if tdir~=1
    throwerror('wrongInput','time direction is expected to be positive');
end
%
if any( tdir*diff(tspan) <= 0 )
    error(message('MATLAB:odearguments:TspanNotMonotonic'));
end

f0 = feval(ode,t0,y0); 
[m,n] = size(f0);
if n > 1
    error(message('MATLAB:odearguments:FoMustReturnCol', func2str( ode )));
elseif m ~= neq
    error(message('MATLAB:odearguments:SizeIC', func2str( ode ), m, neq, func2str( ode )));
end

% Determine the dominant data type
classT0 = class(t0);
classY0 = class(y0);
classF0 = class(f0);
%
dataType = superiorfloat(t0,y0,f0);

if ~( strcmp(classT0,dataType) && strcmp(classY0,dataType) && ...
        strcmp(classF0,dataType))
    warning('MATLAB:odearguments:InconsistentDataType',...
        'Mixture of single and double data for ''t0'', ''y0'', and ''f(t0,y0)'' in call to %s.',solver);
end
% Get the error control options, and set defaults.
rtol = odeget(options,'RelTol',1e-3,'fast');
if (length(rtol) ~= 1) || (rtol <= 0)
    error(message('MATLAB:odearguments:RelTolNotPosScalar'));
end
if rtol < 100 * eps(dataType)
    rtol = 100 * eps(dataType);
    warning(message('MATLAB:odearguments:RelTolIncrease', sprintf( '%g', rtol )))
end
atol = odeget(options,'AbsTol',1e-6,'fast');
if any(atol <= 0)
    error(message('MATLAB:odearguments:AbsTolNotPos'));
end
normcontrol = strcmp(odeget(options,'NormControl','off','fast'),'on');
if normcontrol
    if length(atol) ~= 1
        error(message('MATLAB:odearguments:NonScalarAbsTol'));
    end
    normy = norm(y0);
else
    if (length(atol) ~= 1) && (length(atol) ~= neq)
        error(message('MATLAB:odearguments:SizeAbsTol', func2str( ode ), neq));
    end
    atol = atol(:);
    normy = [];
end
threshold = atol / rtol;

% By default, hmax is 1/10 of the interval.
hmax = min(abs(tfinal-t0), abs(odeget(options,'MaxStep',0.1*(tfinal-t0),'fast')));
if hmax <= 0
    error(message('MATLAB:odearguments:MaxStepLEzero'));
end
htry = abs(odeget(options,'InitialStep',[],'fast'));
if ~isempty(htry) && (htry <= 0)
    error(message('MATLAB:odearguments:InitialStepLEzero'));
end

isOutputFcn = ~isempty(odeget(options,'OutputFcn',[],'fast'));
if isOutputFcn
    throwerror('wrongInput','outputFcn is not supported');
end
% Handle the event function
haveEventFcn=odeget(options,'Events',[],'fast');
if haveEventFcn
    throwerror('wrongInput','events are not supported');
end
% Handle the mass matrix
isMassDef= odeget(options,'Mass',[],'fast');
if isMassDef
    throwerror('wrongInput','mass matrix is not supported');
end
isNonNegative = ~isempty(odeget(options,'NonNegative',[],'fast'));
if isNonNegative
    throwerror('wrongInput','non negative regime is not supported');
end
