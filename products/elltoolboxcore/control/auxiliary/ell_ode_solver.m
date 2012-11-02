function [tt, xx] = ell_ode_solver(fn, t, x0, varargin)
%
% ELL_ODE_SOLVER - caller for particular ODE solver.
%

  global ellOptions;

  opt = odeset('NormControl', ellOptions.norm_control, ...
               'RelTol', ellOptions.rel_tol, ...
               'AbsTol', ellOptions.abs_tol);
           
  switch ellOptions.ode_solver
    case 2,
      opt      = odeset(opt, 'InitialStep', abs(t(1)-t(2))/2);
      [tt, xx] = ode23(fn, t, x0, opt, varargin{:});
    case 3,
      [tt, xx] = ode113(fn, t, x0, opt, varargin{:});
    otherwise,
      [tt, xx] = ode45(fn, t, x0, opt, varargin{:});
  end

  return;
