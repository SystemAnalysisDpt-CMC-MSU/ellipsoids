firstEllObj = ellipsoid([4 -1; -1 1]);
secEllObj = ell_unitball(2);
ellVec = [firstEllObj secEllObj]
volVec = ellVec.volume()

% volVec =
% 
%     5.4414     3.1416