% ellipsoid defined by squeezing the ellipsoid ellArr(2, 2)
fourthEll = shape(ellArr(2, 2), 0.4);  
% check if the geometric difference firstEll - fourthEll is nonempty
firstEll >= fourthEll  
% 
% ans =
% 
%      1
firstEll.minkdiff(fourthEll); % compute and plot this geometric difference
