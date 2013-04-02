firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
secEllObj = firstEllObj + [5; 5];
ellVec = [firstEllObj secEllObj];
ellVec.isinternal([-2 3; -1 4], 'i')

% ans =
% 
%      0     0

ellVec.isinternal([-2 3; -1 4])

% ans =
% 
%      1     1