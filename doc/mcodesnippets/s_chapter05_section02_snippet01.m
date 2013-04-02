aMat = [0 1; 0 0]; bMat = eye(2);  % matrices A and B, B is identity
uBoundsEllObj = struct();
% center of the ellipsoid depends on t
uBoundsEllObj.center = {'sin(t)'; 'cos(t)'};  
uBoundsEllObj.shape = [9 0; 0 2];  % shape matrix of the ellipsoid is static
% create linear system object
sys = elltool.linsys.LinSys(aMat, bMat, uBoundsEllObj); 
