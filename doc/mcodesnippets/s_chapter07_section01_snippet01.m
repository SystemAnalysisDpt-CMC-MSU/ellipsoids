A = [cos(1) sin(1); -sin(1) cos(1)];
U = ell_unitball(2);  % control bounds
% define linear discrete-time system
lsys = elltool.linsys.LinSysFactory.create(A, eye(2), U, [], [], [], [], 'd');
X0 = ell_unitball(2);  % set of initial conditions
L0 = [cos(0:0.1:pi); sin(0:0.1:pi)];  % 32 initial directions
N  = 100;  % number of time steps
rs = elltool.reach.ReachDiscrete(lsys, X0, L0, N);% compute the reach set
