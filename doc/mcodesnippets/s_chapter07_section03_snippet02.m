M  = ellipsoid(0.01*eye(3));  % terminating set
TT = 3;  % terminating time

% compute backward reach set:
% compute the reach set:
brs2 = elltool.reach.ReachContinuous(s2, M, L0, [TT TS]);  % second system comes first
brs1 = brs2.evolve(0, s1);  % then the first system

% obtain projections onto (x1, x2) subspace:
bps1 = brs1.projection(BB);
bps2 = brs2.projection(BB);

% plot the results:
subplot(2, 2, 3);
bps1.plot_ea('r');  % external apprx. of backward reach set 1 (red)
hold on;
bps1.plot_ia('g');  % internal apprx. of backward reach set 1 (green)
bps2.plot_ea('y');  % external apprx. of backward reach set 2 (yellow)
bps2.plot_ia(bps2, 'b');  % internal apprx. of backward reach set 2 (blue)

% plot the 3-dimensional backward reach set at time t = 0:
subplot(2, 2, 4);
brs1 = cut(brs1, 0);
brs1.plot_ea('r');
hold on;
brs1.plot_ia('g');
