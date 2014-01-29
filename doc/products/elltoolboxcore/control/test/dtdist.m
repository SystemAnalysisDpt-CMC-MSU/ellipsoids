A = [0.9 1;0 0.7];
B = [1 0; 0 1];
G = [0.4 0.02; 0.02 0.4];

X0 = ell_unitball(2);

U = ell_unitball(2);
V = ell_unitball(2);
o = [];

s = linsys(A, B, U, G, V, [], [], 'd');

phi = 0:0.05:pi;
L = [cos(phi); sin(phi)];
%L = [1 0; 0 1; 1 1; 1 -1]';
N = 10;

rs1 = reach(s, X0, L, N, o);

o.minmax = 1;

rs2 = reach(s, X0, L, N, o);

plotByEa(rs1); hold on;
plotByEa(rs2, 'g'); hold on;
