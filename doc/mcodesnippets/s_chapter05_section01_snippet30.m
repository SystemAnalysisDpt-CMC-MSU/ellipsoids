% compute the intersections of ellipsoids in the second column of ellArr
% with hyperplane firstHyp: 

intersectEllArr = ellArr(:, 2).hpintersection(firstHyp)

% intersectEllArr =
% 2x1 array of ellipsoids.

intersectEllArr.isdegenerate  % resulting ellipsoids should lose rank

% ans =
% 
%      1
%      1