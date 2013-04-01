aMat = [cos(1) sin(1); -sin(1) cos(1)];
uBoundsEll = ell_unitball(2);  % control bounds
% define linear discrete-time system
lsys = elltool.linsys.LinSys(aMat, eye(2), uBoundsEll, [], [], [], [], 'd');
x0Ell = ell_unitball(2);  % set of initial conditions
dirsMat = [cos(0:0.1:pi); sin(0:0.1:pi)];  % 32 initial directions
nSteps  = 100;  % number of time steps

% compute the reach set
rsObj = elltool.reach.ReachDiscrete(lsys, x0Ell, dirsMat, nSteps);
