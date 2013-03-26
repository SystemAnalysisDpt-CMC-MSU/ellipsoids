Q = 0.5*P + [1; 1];  % polytope Q is obtained by affine transformation of P

% check if the intersection of ellipsoids in the first column of EE
% contains the union of polytopes P and Q:
EE(:, 1).isinside([P Q])  % equivalent to: isinside(EE(:, 1), P | Q)

% ans =
% 
%      0
