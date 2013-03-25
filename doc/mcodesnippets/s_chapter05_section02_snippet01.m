A = [0 1; 0 0]; B = eye(2);  % matrices A and B, B is identity
U = struct();
U.center = {'sin(t)'; 'cos(t)'};  % center of the ellipsoid depends on t
U.shape = [9 0; 0 2];  % shape matrix of the ellipsoid is static
sys = elltool.linsys.LinSys(A, B, U);  % create linear system object
