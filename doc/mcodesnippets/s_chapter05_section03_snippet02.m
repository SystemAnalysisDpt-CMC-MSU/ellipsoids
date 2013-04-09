A = [0 1 0 0; -1 0 1 0; 0 0 0 1; 0 0 -1 0];
B = [0; 0; 0; 1];
U = ellipsoid(1);
sys = elltool.linsys.LinSysFactory.create(A, B, U);  % 4-dimensional system
L  = [1 1 0 1; 0 -1 1 0; -1 1 1 1; 0 0 -1 1]'; % matrix of directions
% reach set from time 0 to 5
rs = elltool.reach.ReachContinuous(sys, ell_unitball(4), L, [0 5]);
BB = [1 0 0 1; 0 1 1 0]';  % basis of 2-dimensional subspace
ps = projection(rs, BB);  % project reach set rs onto basis BB
plot_ea(ps);  % plot external approximation
hold on;
plot_ia(ps);  % plot internal approximation
