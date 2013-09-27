function ellArr = shape(ellArr, modMat)
%
% SHAPE - modifies the shape matrix of the ellipsoid without
%   changing its center. Modified given array is on output (not its copy).
%
%	modEllArr = SHAPE(ellArr, modMat)  Modifies the shape matrices of
%       the ellipsoids in the ellipsoidal array ellArr. The centers
%       remain untouched - that is the difference of the function SHAPE and
%       linear transformation modMat*ellArr. modMat is expected to be a
%       scalar or a square matrix of suitable dimension.
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
%           of ellipsoids.
%       modMat: double[nDim, nDim]/[1,1] - square matrix or scalar
%
% Output:
%	ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of modified
%       ellipsoids.
%
% Example:
%   ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   tempMat = [0 1; -1 0];
%   outEllObj = shape(ellObj, tempMat)
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
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%


ellipsoid.checkIsMe(ellArr,'first');
modgen.common.checkvar(modMat, @(x)isa(x,'double'),...
    'errorMessage','second input argument must be double');   
isModScal = isscalar(modMat);
if isModScal
   modMatSq = modMat*modMat;
else
    [nRows, nDim] = size(modMat);
    dimArr = dimension(ellArr);
    modgen.common.checkmultvar('(x1==x2)&&all(x3(:)==x2)',...
        3,nRows,nDim,dimArr,'errorMessage',...
        'input matrix not square or dimensions do not match');
end
arrayfun(@(x) fSingleShape(x), ellArr);
    function fSingleShape(ellObj)
        if isModScal
            qMat = modMatSq*ellObj.shapeMat;
        else
            qMat    = modMat*(ellObj.shapeMat)*modMat';
            qMat    = 0.5*(qMat + qMat');
        end
        ellObj.shapeMat = qMat;
    end
end
