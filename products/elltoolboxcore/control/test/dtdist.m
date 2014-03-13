A = [0.9 1;0 0.7];
B = [1 0; 0 1];
G = [0.4 0.02; 0.02 0.4];

X0 = ell_unitball(2);

U = ell_unitball(2);
V = ell_unitball(2);

s = elltool.linsys.LinSysDiscrete(A, B, U, G, V, [], [], 'd');

phi = 0:0.05:pi;
L = [cos(phi); sin(phi)];
N = 10;

rs1 = elltool.reach.ReachDiscrete(s, X0, L, [0 N]);


rs2 = reach(s, X0, L, [0 N],'isMinMax',true);

rs1.plotByEa();
rs2.plotByEa('g');
