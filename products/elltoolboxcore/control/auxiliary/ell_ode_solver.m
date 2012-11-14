function [tt, xx] = ell_ode_solver(fn, t, x0, varargin)
%
% ELL_ODE_SOLVER - caller for particular ODE solver.
%

  import elltool.conf.Properties;

  opt = odeset('NormControl', Properties.getODENormControl(), ...
               'RelTol', Properties.getRelTol(), ...
               'AbsTol', Properties.getAbsTol());

  solverName = Properties.getODESolverName();
  if strcmp(solverName,'ode23')
      odeset(opt, 'InitialStep', abs(t(1)-t(2))/2);
  end
  [tt,xx]=feval(solverName,fn,t,x0,opt,varargin{:}); 
