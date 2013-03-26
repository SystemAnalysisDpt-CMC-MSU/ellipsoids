% define disturbance:
G = [0 0; 0 0; 1 0; 0 1];
V = 0.5*ell_unitball(2);
lsysd = elltool.linsys.LinSys(A, B, U, G, V);  % linear system with disturbance
rsd = elltool.reach.ReachContinuous(lsysd, X0, L0, T);  % reach set
psd = rsd.projection(BB);  % reach set projection onto (x1, x2)
% plot projection of reach set external approximation:
subplot(2, 2, 3);
ps.plot_ea;  % plot the whole reach tube
subplot(2, 2, 4);
ps.cut(4)
ps.plot_ea;  % plot reach set approximation at time t = 4
