k1 = 24;  k2 = 32;
m1 = 1.5; m2 = 1;
% define matrices A, B, and control bounds U:
A = [0 0 1 0; 0 0 0 1; -(k1+k2)/m1 k2/m1 0 0; k2/m2 -(k1+k2)/m2 0 0];
B = [0 0; 0 0; 1/m1 0; 0 1/m2];
U = ell_unitball(2);
lsys = linsys(A, B, U);  % linear system
T = [0 4];  % time interval
% initial conditions:
X0 = [0 2 0 0]' + ellipsoid([0.01 0 0 0; 0 0.01 0 0; 0 0 eps 0; 0 0 0 eps]);
% initial directions (some random vectors in R^4):
L0 = [1 0 1 0; 1 -1 0 0; 0 -1 0 1; 1 1 -1 1; -1 1 1 0; -2 0 1 1]';
rs = reach(lsys, X0, L0, T);  % reach set
BB = [1 0 0 0; 0 1 0 0]';  % orthogonal basis of (x1, x2) subspace
ps = projection(rs, BB);  % reach set projection
% plot projection of reach set external approximation:
subplot(2, 2, 1);
plot_ea(ps, 'g');  % plot the whole reach tube
subplot(2, 2, 2);
plot_ea(cut(ps, 4), 'g');  % plot reach set approximation at time t = 4
