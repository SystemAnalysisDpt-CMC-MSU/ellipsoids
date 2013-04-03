function [tt, xx] = ell_ode_solver(fn, t, x0, varargin)
%
% ELL_ODE_SOLVER - caller for particular ODE solver.
%

import elltool.conf.Properties;
INIT_STEP_EXCLUSION_ODE_SOLVER='ode23';

if Properties.getIsODENormControl()
    normControl = 'on';
else
    normControl = 'off';
end
absTol = varargin{end};
opt = odeset('NormControl', normControl, ...
    'RelTol', Properties.getRelTol(), ...
    'AbsTol', absTol);

solverName = Properties.getODESolverName();

if strcmp(solverName,INIT_STEP_EXCLUSION_ODE_SOLVER)
    odeset(opt, 'InitialStep', abs(t(1)-t(2))/2);
end
[tt,xx]=feval(solverName,fn,t,x0,opt,varargin{:});
