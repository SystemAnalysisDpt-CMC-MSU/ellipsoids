E1 = ellipsoid;
A = [3 1; 0 1; -2 1]; 
E2 = ellipsoid([1; -1; 1], A*A');
E3 = ellipsoid(eye(2));
E4 = ellipsoid(0);
E = [E1 E2; E3 E4];
[n, r] = E.dimension

% n =
% 
%    0     3
%    2     1
% 
% r =
% 
%    0     2
%    2     0