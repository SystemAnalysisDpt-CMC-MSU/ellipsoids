function invEllArr = getInv(myEllArr)
%
% GETINV - do the same as INV method: inverts shape matrices of ellipsoids 
%       in the given array, with only difference, that it doesn't modify 
%       input array of ellipsoids.
%
% Input:
%   regular:
%     myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids.
%
% Output:
%    invEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
%       with inverted shape matrices.
% 
% Example:
%   ellObj = ellipsoid([1; 1], [4 -1; -1 5]);
%   invEllObj = ellObj.getInv()
% 
%   invEllObj =
% 
%   Center:
%        1
%        1
% 
%   Shape Matrix:
%       0.2632    0.0526
%       0.0526    0.2105
% 
%   Nondegenerate ellipsoid in R^2.
%
% $Author: Khristoforov Dmitry <dmitrykh92@gmail.com> $   
% $Date: May-2013$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
invEllArr = myEllArr.getCopy();
invEllArr.inv();
end