E = ellipsoid([-2; -1], [4 -1; -1 1]);
B = ell_unitball(2);
isinside(E, [E B], 'i')

% ans =
% 
%      1
