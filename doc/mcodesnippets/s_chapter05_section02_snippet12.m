% polytope secPolObj is obtained by affine transformation of firstPolObj
secPolObj = 0.5*firstPolObj + [1; 1];  

% check if the intersection of ellipsoids in the first column of ellMat
% contains the union of polytopes firstPolObj and secPolObj:

ellMat(:, 1).isContainedInIntersection([firstPolObj secPolObj])  

% ans =
% 
%      0
