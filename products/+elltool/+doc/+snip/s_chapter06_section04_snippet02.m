%initial conditions:
x0EllObj = [170; 180; 175; 170] + 10*ell_unitball(4);

dirsMat = [1; 0; 0; 0];  % single initial direction
nSteps = 100;  % number of time steps

% free-flow reach set
ffrsObj = elltool.reach.ReachDiscrete(firstSys, x0EllObj, dirsMat, [0 nSteps]);  
externalEllMat = ffrsObj.get_ea();  % 101x1 array of external ellipsoids
