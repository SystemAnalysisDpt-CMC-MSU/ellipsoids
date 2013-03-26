E4 = shape(EE(2, 2), 0.4);  % ellipsoid defined by squeezing the ellipsoid EE(2, 2)
E1 >= E4  % check if the geometric difference E1 - E4 is nonempty
% 
% ans =
% 
%      1
E1.minkdiff(E4);  % compute and plot this geometric difference
