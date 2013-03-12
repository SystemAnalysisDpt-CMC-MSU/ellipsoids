M  = ellipsoid(0.01*eye(3));  % terminating set
TT = 3;  % terminating time

% compute backward reach set:
% compute the reach set:
brs2 = reach(s2, M, L0, [TT TS]);  % second system comes first
brs1 = evolve(brs2, 0, s1);  % then the first system

% obtain projections onto (x1, x2) subspace:
bps1 = projection(brs1, BB);
bps2 = projection(brs2, BB);

% plot the results:
subplot(2, 2, 3);
plot_ea(bps1, 'r');  % external apprx. of backward reach set 1 (red)
hold on;
plot_ia(bps1, 'g');  % internal apprx. of backward reach set 1 (green)
plot_ea(bps2, 'y');  % external apprx. of backward reach set 2 (yellow)
plot_ia(bps2, 'b');  % internal apprx. of backward reach set 2 (blue)

% plot the 3-dimensional backward reach set at time t = 0:
subplot(2, 2, 4);
plot_ea(cut(brs1, 0), 'r');
hold on;
plot_ia(cut(brs1, 0), 'g');
