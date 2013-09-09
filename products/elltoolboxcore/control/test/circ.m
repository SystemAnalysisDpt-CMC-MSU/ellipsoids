o.save_all = 1;
R = 2; L = 1; C = 0.1; 
A = [-R/L -1/L; 1/C 0]; B = [1/L; 0];
I = ellipsoid(1);

X0 = ell_unitball(2);
T  = 10;
L0 = [0 1; 1 1; 1 0; 1 -1]';

s  = linsys(A, B, I);
rs = reach(s, X0, L0, T, o);

plotByEa(rs); hold on;
plotByIa(rs); hold on;
