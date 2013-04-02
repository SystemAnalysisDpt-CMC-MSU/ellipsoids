firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
secEllObj = firstEllObj + [5; 5];
hypObj  = hyperplane([1; -1]);
ellVec = [firstEllObj secEllObj];
ellVec.intersect(hypObj)

% ans =
% 
%      1

ellVec.intersect(hypObj, 'i')

% ans =
% 
%     -1
