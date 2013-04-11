% compute the intersections of ellipsoids in the second column of ellMat
% with hyperplane firstHypObj: 

intersectEllMat = ellMat(:, 2).hpintersection(firstHypObj)

% intersectEllMat =
% 2x1 array of ellipsoids.

intersectEllMat.isdegenerate()  % resulting ellipsoids should lose rank

% ans =
% 
%      1
%      1