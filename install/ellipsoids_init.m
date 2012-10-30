function SEllOptions = ellipsoids_init()
%
import elltool.cvx.CVXController;
% ELLIPSOIDS_INIT - initializes Ellipsoidal Toolbox.
%
% Any routine of Ellipsoidal Toolbox can be called with user-specified values
% of different parameters. To make Ellipsoidal Toolbox as user-friendly as
% possible, we provide the option to store default values of the parameters
% in variable ellOptions, which is stored in MATLAB's workspace as a global
% variable (i.e. it stays there unless one types 'clear all').
%

global ellOptions;


ellOptions.version = '1.4dev';
ellOptions.verbose = 0; % verbosity 1 ==> ON, 0 ==> OFF

if ellOptions.verbose > 0
    welcomeString=sprintf(...
        'Defining settings for Ellipsoids Toolbox, ver %s',...
        ellOptions.version);
    disp([welcomeString,'...']);
end


ellOptions.abs_tol = 1e-7; % absolute tolerance
ellOptions.rel_tol = 1e-6; % relative tolerance


% ODE solver parameters.
ellOptions.time_grid          = 200;   % density of the time grid
ellOptions.ode_solver         = 1;     % 1 ==> RK45, 2 ==> RK23, 3 ==> Adams
ellOptions.norm_control       = 'on';  % on/off norm control in ODE solver
ellOptions.ode_solver_options = 0;     % 0 - default, 1 - user-defined


% Solver for nonlinear optimization problem with nonlinear constraints:
%        Minimize:   f(x)
%        Subject to: g(x) <= 0, h(x) = 0.
% Used for distance calculation.
% nlcp_solver = 0 - use the solver that comes with Ellipsoidal Toolbox.
% nlcp_solver = 1 - use the routines from MATLAB Optimization Toolbox.
ellOptions.nlcp_solver = 0;


ellOptions.plot2d_grid = 200; % grid density for plotting in 2D
ellOptions.plot3d_grid = 200; % grid density for plotting in 3D


% CVX settings.
if CVXController.isSetUp()
    CVXController.setSolver('sdpt3');
    CVXController.setPrecision(ellOptions.rel_tol);
end
SEllOptions=ellOptions;
