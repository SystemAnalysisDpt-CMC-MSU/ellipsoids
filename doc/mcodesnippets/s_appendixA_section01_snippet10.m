E1 = ellipsoid([-2; -1], [4 -1; -1 1]);
E2 = 3*ell_unitball(2);
L = [1 0; 1 1; 0 1; -1 1]';
absTol = elltool.conf.Properties.getAbsTol();
E2.isbaddirection(E1, L, absTol)

% ans =
% 
%      0     1     1     0
