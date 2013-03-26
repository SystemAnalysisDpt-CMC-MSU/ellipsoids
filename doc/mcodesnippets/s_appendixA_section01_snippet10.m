E = ellipsoid([-2; -1], [4 -1; -1 1]);
B = 3*ell_unitball(2);
L = [1 0; 1 1; 0 1; -1 1]';
absTol = elltool.conf.Properties.getAbsTol();
B.isbaddirection(E, L, absTol)

% ans =
% 
%      0     1     1     0
