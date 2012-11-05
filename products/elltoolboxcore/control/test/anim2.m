import elltool.conf.Properties;

A3 = [0 1; 0 0];
B3 = [0; 1];
U3 = ell_unitball(1);
s3 = linsys(A3, B3, U3);

A2 = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
B2 = {'10' '0'; '0' '1/(2 + sin(t))'};
U2.center = [0; 0];
U2.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};
s2 = linsys(A2, B2, U2);

A1 = [0 1; -4 0];
B1 = [1; 0];
U1 = ell_unitball(1);
C1 = [0; 1];
V1 = ellipsoid(0.05);
s1 = linsys(A1, B1, U1);

X0 = ell_unitball(2);

T1  = 5;
T2  = 10;
T3  = 15;

L0  = [1 0; 2 1; 1 1; 1 2; 0 1; -1 2; -1 1; -2 1]';
rs1 = reach(s1, X0, L0, T1);
rs2 = evolve(rs1, T2, s2);
rs3 = evolve(rs2, T3, s3);


