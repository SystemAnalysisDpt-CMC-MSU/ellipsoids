firstEll = ellipsoid([4 -1; -1 1]);
secEll = ell_unitball(2);
ellArr = [firstEll secEll];
trArr = ellArr.trace

% trArr =
% 
%     5     2