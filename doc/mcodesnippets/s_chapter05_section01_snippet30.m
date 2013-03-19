I = hpintersection(EE(:, 2), H)% compute the intersections of ellipsoids
                                  % in the second column of EE
                                  % with hyperplane H: 

% I =
% 2x1 array of ellipsoids.

isdegenerate(I)  % resulting ellipsoids should lose rank

% ans =
% 
%      1
%      1
