firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
secEllObj = 3*ell_unitball(2);
dirsMat = [1 0; 1 1; 0 1; -1 1]';
absTol = elltool.conf.Properties.getAbsTol();
secEllObj.isbaddirection(firstEllObj, dirsMat, absTol)

% ans =
% 
%      0     1     1     0
