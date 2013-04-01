firstEll = ellipsoid([4 -1; -1 1]);
secEll = ell_unitball(2);
ellArr = [firstEll secEll]
volArr = ellArr.volume

% VolArr =
% 
%     5.4414     3.1416