% define new directions, in this case one, but could be more
newDirsMat = [1; -1];
% compute approximations for the new directions
firstRsObj = firstRsObj.refine(newDirsMat);
% snap shot of the reach set at time t = 5
cutObj = firstRsObj.cut(5);
% check if ellObj intersects the internal approximation
cutObj.intersect(ellObj, 'i')  

% ans =
% 
%      1