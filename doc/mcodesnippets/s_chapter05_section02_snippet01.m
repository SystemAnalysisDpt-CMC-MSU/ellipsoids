aMat = [0 1; 0 0]; bMat = eye(2);  % matrices A and B, B is identity
uBoundsEll = struct();
% center of the ellipsoid depends on t
uBoundsEll.center = {'sin(t)'; 'cos(t)'};  
uBoundsEll.shape = [9 0; 0 2];  % shape matrix of the ellipsoid is static
% create linear system object
sys = elltool.linsys.LinSys(aMat, bMat, uBoundsEll); 
