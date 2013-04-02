firstEllObj = ellipsoid;
tempMatObj = [3 1; 0 1; -2 1]; 
secEllObj = ellipsoid([1; -1; 1], tempMatObj*tempMatObj');
thirdEllObj = ellipsoid(eye(2));
fourthEllObj = ellipsoid(0);
ellMat = [firstEllObj secEllObj; thirdEllObj fourthEllObj];
[dimMat, rankMat] = ellMat.dimension()

% dimMat =
% 
%    0     3
%    2     1
% 
% rankMat =
% 
%    0     2
%    2     0