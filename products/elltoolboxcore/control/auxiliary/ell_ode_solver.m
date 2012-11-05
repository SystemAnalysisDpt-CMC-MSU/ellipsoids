function [tt, xx] = ell_ode_solver(fn, t, x0, varargin)
%
% ELL_ODE_SOLVER - caller for particular ODE solver.
%

  import elltool.conf.Properties;

  opt = odeset('NormControl', Properties.getODENormControl(), ...
               'RelTol', Properties.getRelTol(), ...
               'AbsTol', Properties.getAbsTol());
           
  switch properties.getODESolverName()
    case 'ode 23',
      opt      = odeset(opt, 'InitialStep', abs(t(1)-t(2))/2);
      [tt, xx] = ode23(fn, t, x0, opt, varargin{:});
    case 'ode 113',
      [tt, xx] = ode113(fn, t, x0, opt, varargin{:});
    otherwise,
      [tt, xx] = ode45(fn, t, x0, opt, varargin{:});
  end

  return;
