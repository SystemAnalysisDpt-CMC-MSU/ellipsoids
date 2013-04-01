%initial conditions:
x0Ell = [170; 180; 175; 170] + 10*ell_unitball(4);

dirsMat = [1; 0; 0; 0];  % single initial direction
nSteps = 100;  % number of time steps

% free-flow reach set
ffrsObj = elltool.reach.ReachDiscrete(s1, x0Ell, dirsMat, nSteps);  
externalEllArr = ffrsObj.get_ea;  % 101x1 array of external ellipsoids
