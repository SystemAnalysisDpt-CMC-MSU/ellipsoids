% nondegenerate ellipsoid in R^2
firstEll = ellipsoid([2; -1], [9 -5; -5 4]); 
secEll = firstEll.polar;  % secEll is polar ellipsoid for firstEll
% thirdEll is generated from secEll by inverting its shape matrix
thirdEll = secEll.inv; 
% 2x2 array of ellipsoids
ellArr = [firstEll secEll; thirdEll ellipsoid([1; 1], eye(2))]; 
% check if firstEll is bigger than each of the ellipsoids in ellArr
ellArr <= firstEll  

% ans =
% 
%      1     0
%      1     0
