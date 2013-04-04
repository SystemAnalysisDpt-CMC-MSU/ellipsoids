G = [0; 1];  % matrix G
V = ellipsoid(1);  % disturbance bounds: unit ball in R
sys_d = elltool.linsys.LinSysFactory.create(A, B, U, G, V);
