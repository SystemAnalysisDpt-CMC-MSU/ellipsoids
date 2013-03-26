I = EE(:, 2).hpintersection(H)% compute the intersections of ellipsoids
                                  % in the second column of EE
                                  % with hyperplane H: 

% I =
% 2x1 array of ellipsoids.

I.isdegenerate  % resulting ellipsoids should lose rank

% ans =
% 
%      1
%      1