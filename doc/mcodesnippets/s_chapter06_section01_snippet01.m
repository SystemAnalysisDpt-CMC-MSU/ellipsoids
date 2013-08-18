aMat = [cos(1) sin(1); -sin(1) cos(1)];
uBoundsEllObj = ell_unitball(2);  % control bounds
% define linear discrete-time system
lsys = elltool.linsys.LinSysFactory.create(aMat, eye(2), uBoundsEllObj,...
    [], [], 'd');
x0EllObj = ell_unitball(2);  % set of initial conditions
dirsMat = [cos(0:0.1:pi); sin(0:0.1:pi)];  % 32 initial directions
nSteps  = 100;  % number of time steps

% compute the reach set
rsObj = elltool.reach.ReachDiscrete(lsys, x0EllObj, dirsMat, [0 nSteps]);