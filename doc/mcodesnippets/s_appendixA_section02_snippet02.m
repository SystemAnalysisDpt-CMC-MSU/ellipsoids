H1 = hyperplane([-1; 1]);
H2 = hyperplane([-1; 1; 8; -2; 3], 7);
H3 = hyperplane([1; 2; 0], -1);
H = [H1 H2 H3];
D  = H.dimension

% D =
% 
%    2     5     3