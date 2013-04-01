%define array of four hyperplanes:
hypArr = hyperplane([1 1; -1 -1; 1 -1; -1 1]', [2 2 2 2])

% array of hyperplanes: 
% size: [1 4]
% 
% Element: [1 1]
% Normal:
%      1
%      1
% 
% Shift:
%      2
% 
% Hyperplane in R^2.
% 
% 
% Element: [1 2]
% Normal:
%     -1
%     -1
% 
% Shift:
%      2
% 
% Hyperplane in R^2.
% 
% 
% Element: [1 3]
% Normal:
%      1
%     -1
% 
% Shift:
%      2
% 
% Hyperplane in R^2.
% 
% 
% Element: [1 4]
% Normal:
%     -1
%      1
% 
% Shift:
%      2
% 
% Hyperplane in R^2.

% convert array of hyperplanes to polytope
firstPol  = hyperplane2polytope(hypArr);
% covert polytope to array of hyperplanes  
convertedHypArr = polytope2hyperplane(firstPol);  
convertedHypArr == hypArr

% ans =
% 
%      1     1     1     1
