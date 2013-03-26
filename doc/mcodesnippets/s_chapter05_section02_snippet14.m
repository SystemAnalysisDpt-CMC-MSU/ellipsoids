L1 = [1; -1];  % define new directions, in this case one, but could be more
rs = rs.refine(L1)  % compute approximations for the new directions
ct = rs.cut(5);  % snap shot of the reach set at time t = 5
ct.intersect(E, 'i')  % check if E intersects the internal approximation

% ans =
% 
%      1