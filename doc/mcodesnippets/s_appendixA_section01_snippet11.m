firstEll = ellipsoid([-2; -1], [4 -1; -1 1]);
secEll = ell_unitball(2);
firstEll.isinside([firstEll secEll], 'i')

% ans =
% 
%      1