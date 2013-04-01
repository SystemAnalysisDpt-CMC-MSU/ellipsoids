% polytope secPol is obtained by affine transformation of firstPol
secPol = 0.5*firstPol + [1; 1];  

% check if the intersection of ellipsoids in the first column of ellArr
% contains the union of polytopes firstPol and secPol:

% equivalent to: isinside(ellArr(:, 1), firstPol | secPol)
ellArr(:, 1).isinside([firstPol secPol])  

% ans =
% 
%      0
