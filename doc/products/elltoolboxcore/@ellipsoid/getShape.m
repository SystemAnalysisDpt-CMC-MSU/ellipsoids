function outEllArr = getShape(ellArr, modMat)
%
% GETSHAPE -  do the same as SHAPE method: modifies the shape matrix of the 
%    ellipsoid without changing its center, with only difference, that 
%    it doesn't modify input array of ellipsoids.
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
%           of ellipsoids.
%       modMat: double[nDim, nDim]/[1,1] - square matrix or scalar
%
% Output:
%	outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of modified
%       ellipsoids.
%
% Example:
%   ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   tempMat = [0 1; -1 0];
%   outEllObj = ellObj.getShape(tempMat)
% 
%   outEllObj =
% 
%   Center:
%       -2
%       -1
% 
%   Shape:
%       1     1
%       1     4
% 
%   Nondegenerate ellipsoid in R^2.
%
% $Author: Khristoforov Dmitry <dmitrykh92@gmail.com> $   
% $Date: May-2013$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
outEllArr = ellArr.getCopy();
outEllArr.shape(modMat);
end
