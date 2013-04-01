firstEll = ellipsoid([-2; -1], [4 -1; -1 1]);
secEll = firstEll + [5; 5];
ellArr = [firstEll secEll];
ellArr.isinternal([-2 3; -1 4], 'i')

% ans =
% 
%      0     0

ellArr.isinternal([-2 3; -1 4])

% ans =
% 
%      1     1