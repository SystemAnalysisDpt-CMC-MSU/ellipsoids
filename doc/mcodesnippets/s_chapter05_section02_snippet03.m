gMat = [0; 1];  % matrix G
vEll = ellipsoid(1);  % disturbance bounds: unit ball in R
sys_d = elltool.linsys.LinSys(aMat, bMat, uBoundsEll, gMat, vEll);
