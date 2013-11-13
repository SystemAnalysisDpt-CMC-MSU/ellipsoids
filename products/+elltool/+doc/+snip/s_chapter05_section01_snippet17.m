% ellipsoid defined by squeezing the ellipsoid ellMat(2, 2)
fourthEllObj = ellMat(2, 2).getShape(0.4);  
% check if the geometric difference firstEllObj - fourthEllObj is nonempty
firstEllObj >= fourthEllObj  
% 
% ans =
% 
%      1

% compute and plot this geometric difference
firstEllObj.minkdiff(fourthEllObj);