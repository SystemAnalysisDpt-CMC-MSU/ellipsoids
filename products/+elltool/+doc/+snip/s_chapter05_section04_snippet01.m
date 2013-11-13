aMat = [0 1; 0 0]; bMat = eye(2);  % matrices A and B, B is identity
SUBounds = struct();
% center of the ellipsoid depends on t
SUBounds.center = {'sin(t)'; 'cos(t)'};  
SUBounds.shape = [9 0; 0 2]; % shape matrix of the ellipsoid is static
% create linear system object
sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
% is equal to sys = elltool.linsys.LinSysFactory.create(aMat, bMat, SUBounds)