E = ellipsoid([-2; -1], [4 -1; -1 1]);
B = 3*ell_unitball(2);
L = [1 0; 1 1; 0 1; -1 1]';
isbaddirection(B, E, L)

% ans =
% 
%      0     1     1     0
