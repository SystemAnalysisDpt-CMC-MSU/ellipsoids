firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
secEllObj = ell_unitball(2);
firstEllObj.isinside([firstEllObj secEllObj], 'i')

% ans =
% 
%      1