% polytope secPolObj is obtained by affine transformation of firstPolObj
secPolObj = 0.5*firstPolObj + [1; 1];  

% check if the intersection of ellipsoids in the first column of ellMat
% contains the union of polytopes firstPolObj and secPolObj:

% equivalent to: doesIntersectionContain(ellMat(:, 1), firstPolObj | secPolObj)
ellMat(:, 1).doesIntersectionContain([firstPolObj secPolObj])  

% ans =
% 
%      0
