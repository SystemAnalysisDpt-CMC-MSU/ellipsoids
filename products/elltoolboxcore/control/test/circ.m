
R = 2; L = 1; C = 0.1; 
A = [-R/L -1/L; 1/C 0]; B = [1/L; 0];
I = ellipsoid(1);

X0 = ell_unitball(2);
T  = [0 10];
L0 = [0 1; 1 1; 1 0; 1 -1]';

s  = elltool.linsys.LinSysContinuous(A, B, I);
rs = elltool.reach.ReachContinuous(s, X0, L0, T, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

rs.plotByEa(); hold on;
rs.plotByIa(); hold on;
