E = ellipsoid([-2; -1], [4 -1; -1 1]);
X = ell_unitball(2);
E.isinside([E X], 'i')

% ans =
% 
%      1