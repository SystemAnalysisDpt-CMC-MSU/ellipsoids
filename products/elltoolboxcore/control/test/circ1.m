
R = 4; L = 0.5; C = 0.1; 
A = [0 -1/C; 1/L -R/L];
B = [1/C 0; 0 1/L];
A1 = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
B1 = {'10' '0'; '0' '1/(2 + sin(t))'};
I = ell_unitball(2);
U.center = {'1000/(t^2)'; 'sin(2*t)'};
U.shape = [4 -1; -1 1];

X0 = 0.0001*ell_unitball(2);
T  = [0 10];
T1 = 20;
L0 = [0 1; 1 1; 1 0; 1 -1]';
%L0 = [0 1; 1 0]';

s1  = elltool.linsys.LinSysContinuous(A, B, I);
s2  = elltool.linsys.LinSysContinuous(A1, B1, U);
rs1 = elltool.reach.ReachContinuous(s1, X0, L0, T, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);
rs2 = rs1.evolve(T1, s2);

rs1.plotByEa(); hold on;
rs1.plotByIa(); hold on;
rs2.plotByEa('r'); hold on;
rs2.plotByIa('y'); hold on;
