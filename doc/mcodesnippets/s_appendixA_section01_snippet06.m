E = ellipsoid([-2; -1], [4 -1; -1 1]);
H = [hyperplane([0 -1; -1 0]', 1); hyperplane([0 -2; -1 0]', 1)];
I = E.hpintersection(H)

% I =
% 2x2 array of ellipsoids.
