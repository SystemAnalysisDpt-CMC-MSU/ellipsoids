
import elltool.conf.Properties;
Properties.getAbsTol()
A = [0.9 1;0 0.7];
B = [1 0; 0 1];
G = [0.4 0.02; 0.02 0.4];

X0 = ell_unitball(2);

U = ell_unitball(2);
V = ell_unitball(2);
o = [];

s = elltool.linsys.LinSysDiscrete(A, B, U, G, V, [], [], 'd');

phi = 0:0.05:pi;
L = [cos(phi); sin(phi)];
%L = [1 0; 0 1; 1 1; 1 -1]';
N = [0 10];

rs1 = elltool.reach.ReachDiscrete(s, X0, L, N,'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-5);

o.minmax = 1;

rs2 = elltool.reach.ReachDiscrete(s, X0, L, N);

plotByEa(rs1); hold on;
plotByEa(rs2, 'g'); hold on;
