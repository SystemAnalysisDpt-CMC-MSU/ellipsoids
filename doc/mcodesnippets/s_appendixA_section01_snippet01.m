firstEll = ellipsoid;
mat = [3 1; 0 1; -2 1]; 
secEll = ellipsoid([1; -1; 1], mat*mat');
thirdEll = ellipsoid(eye(2));
fourthEll = ellipsoid(0);
ellMat = [firstEll secEll; thirdEll fourthEll];
[dimArr, rankArr] = ellMat.dimension

% dimArr =
% 
%    0     3
%    2     1
% 
% rankArr =
% 
%    0     2
%    2     0