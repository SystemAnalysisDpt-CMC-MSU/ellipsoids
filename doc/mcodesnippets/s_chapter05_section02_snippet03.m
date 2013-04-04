gMat = [0; 1];  % matrix G
vEllObj = ellipsoid(1);  % disturbance bounds: unit ball in R
sys_d = elltool.linsys.LinSysFactory.create(aMat, bMat, uBoundsEllObj, gMat, vEllObj);