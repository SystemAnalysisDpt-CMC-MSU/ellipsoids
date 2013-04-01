adMat = [0 1; -1 -0.5]; bdMat = [0; 1];  % matrices A and B
udBoundsEll  = ellipsoid(1);  % control bounds: unit ball in R
% discrete-time system
dtsys = elltool.linsys.LinSys(adMat, bdMat, udBoundsEll, [], [], [], [], 'd'); 
