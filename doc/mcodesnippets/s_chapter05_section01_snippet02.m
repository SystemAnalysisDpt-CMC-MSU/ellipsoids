% nondegenerate ellipsoid in R^2
firstEllObj = ellipsoid([2; -1], [9 -5; -5 4]); 
secEllObj = firstEllObj.polar();% secEll is polar ellipsoid for firstEllObj
% thirdEllObj is generated from secEllObj by inverting its shape matrix
thirdEllObj = secEllObj.getInv(); 
% 2x2 array of ellipsoids
ellMat = [firstEllObj secEllObj; thirdEllObj ellipsoid([1; 1], eye(2))]; 
% check if firstEllObj is bigger than each of the ellipsoids in ellMat
ellMat <= firstEllObj  

% ans =
% 
%      1     0
%      1     0
