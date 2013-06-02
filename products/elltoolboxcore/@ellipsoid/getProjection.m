function projEllArr = getProjection(ellArr, basisMat)
%
% GETPROJECTION - do the same as PROJECTION method: computes projection of
%       the ellipsoid onto the given subspace, with only difference, that
%       it doesn't modify input array of ellipsoids.
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
%           of ellipsoids.
%       basisMat: double[nDim, nSubSpDim] - matrix of orthogonal basis
%           vectors
%
% Output:
%   projEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
%       projected ellipsoids, generally, of lower dimension.
%
% Example:
%   ellObj = ellipsoid([-2; -1; 4], [4 -1 0; -1 1 0; 0 0 9]);
%   basisMat = [0 1 0; 0 0 1]';
%   outEllObj = ellObj.getProjection(basisMat)
% 
%   outEllObj =
% 
%   Center:
%       -1
%        4
% 
%   Shape:
%       1     0
%       0     9
% 
%   Nondegenerate ellipsoid in R^2.
%
% $Author: Khristoforov Dmitry <dmitrykh92@gmail.com> $   
% $Date: May-2013$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
projEllArr = ellArr.getCopy();
projEllArr.projection(basisMat);
end