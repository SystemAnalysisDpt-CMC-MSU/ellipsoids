firstEllObj = ellipsoid([4 -1; -1 1]);
secEllObj = ell_unitball(2);
ellVec = [firstEllObj secEllObj];
trVec = ellVec.trace()

% trVec =
% 
%     5     2