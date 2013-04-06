% create two 4-dimensional ellipsoids:
E1 = ellipsoid([14 -4 2 -5; -4 6 0 1; 2 0 6 -1; -5 1 -1 2]);
E2 = inv(E1);

% specify 3-dimensional subspace by its basis:
BB = [1 0 0 0; 0 0 1 0; 0 1 0 1]';  % columns of BB must be orthogonal

% get 3-dimensional projections of E1 and E2:
PP = projection([E1 E2], BB)  % array PP contains projections of E1 and E2

% PP =
% 1x2 array of ellipsoids.

plot(PP);  % plot ellipsoids in PP
