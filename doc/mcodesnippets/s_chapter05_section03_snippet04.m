adMat = [0 1; -1 -0.5]; bdMat = [0; 1];  % matrices A and B
udBoundsEllObj  = ellipsoid(1);  % control bounds: unit ball in R
% discrete-time system
dtsys = elltool.linsys.LinSysDiscrete(adMat, bdMat, udBoundsEllObj); 
% is equal to dtsys = elltool.linsys.LinSysFactory.create(adMat, bdMat,...
%         udBoundsEllObj,...[], [], [], [], 'd'); 