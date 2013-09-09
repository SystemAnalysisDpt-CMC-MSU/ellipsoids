o.save_all = 1;
R = 4; L = 0.5; C = 0.1; 
A = [0 -1/C; 1/L -R/L];
B = [1/C 0; 0 1/L];
A1 = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
B1 = {'10' '0'; '0' '1/(2 + sin(t))'};
I = ell_unitball(2);
U.center = {'1000/(t^2)'; 'sin(2*t)'};
U.shape = [4 -1; -1 1];

X0 = 0.00001*ell_unitball(2);
T  = 10;
T1 = 20;
L0 = [0 1; 1 1; 1 0; 1 -1]';
%L0 = [0 1; 1 0]';

s1  = linsys(A, B, I);
s2  = linsys(A1, B1, U);
rs1 = reach(s1, X0, L0, T, o);
rs2 = evolve(rs1, T1, s2);

plotByEa(rs1); hold on;
plotByIa(rs1); hold on;
plotByEa(rs2, 'r'); hold on;
plotByIa(rs2, 'y'); hold on;
