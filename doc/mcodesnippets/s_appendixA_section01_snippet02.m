ell = ellipsoid([-2; -1], [4 -1; -1 1]);
mat = [1 1; 1 -1; -1 1; -1 -1]';
distArray = ell.distance(mat)

% distArray =
% 
%      2.3428    1.0855    1.3799    -1.0000