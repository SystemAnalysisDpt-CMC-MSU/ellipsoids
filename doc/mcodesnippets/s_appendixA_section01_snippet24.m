ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
ellObj ~= [ellObj ellipsoid(eye(2))]

% ans =
% 
%      0     1