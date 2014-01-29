%define array of four hyperplanes:
hypVec = hyperplane([1 1; -1 -1; 1 -1; -1 1]', [2 2 2 2])

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
firstPolObj  = hyperplane2polytope(hypVec);
% covert polytope to array of hyperplanes  
convertedHypVec = polytope2hyperplane(firstPolObj);  
convertedHypVec == hypVec

% ans =
% 
%      1     1     1     1
