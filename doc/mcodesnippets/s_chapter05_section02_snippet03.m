G = [0; 1];  % matrix G
V = ellipsoid(1);  % disturbance bounds: unit ball in R
sys_d = linsys(A, B, U, G, V);
