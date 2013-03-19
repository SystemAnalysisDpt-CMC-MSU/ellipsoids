L1 = [1; -1];  % define new directions, in this case one, but could be more
rs = refine(rs, L1)  % compute approximations for the new directions
ct = cut(rs, 5);  % snap shot of the reach set at time t = 5
intersect(ct, E, 'i')  % check if E intersects the internal approximation

% ans =
% 
%      1
