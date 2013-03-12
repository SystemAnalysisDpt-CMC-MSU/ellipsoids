I = hpintersection(EE(:, 2), H(1))% compute the intersections of ellipsoids
                                  % in the second column of EE
                                  % with hyperplane H(1): 

% I =
% 2x1 array of ellipsoids.

isdegenerate(I)  % resulting ellipsoids should lose rank

% ans =
% 
%      1
%      1
