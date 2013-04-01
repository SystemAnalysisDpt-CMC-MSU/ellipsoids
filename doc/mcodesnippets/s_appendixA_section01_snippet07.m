firstEll = ellipsoid([-2; -1], [4 -1; -1 1]);
secEll = firstEll + [5; 5];
hyp  = hyperplane([1; -1]);
ellArr = [firstEll secEll];
ellArr.intersect(hyp)

% ans =
% 
%      1

ellArr.intersect(hyp, 'i')

% ans =
% 
%     -1
