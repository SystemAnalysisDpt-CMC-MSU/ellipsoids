firstEll = ellipsoid([-2; -1], [4 -1; -1 1]);
secEll = 3*ell_unitball(2);
dirsMat = [1 0; 1 1; 0 1; -1 1]';
absTol = elltool.conf.Properties.getAbsTol();
secEll.isbaddirection(firstEll, dirsMat, absTol)

% ans =
% 
%      0     1     1     0
