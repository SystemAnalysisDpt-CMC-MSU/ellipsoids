function modEllArr = shape(ellArr, modMat)
%
% SHAPE - modifies the shape matrix of the ellipsoid without
%   changing its center.
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
%	modEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of modified
%       ellipsoids.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%


ellipsoid.checkIsMe(ellArr,'first');
modgen.common.checkvar(modMat, @(x)isa(x,'double'),...
    'errorMessage','second input argument must be double');

isModScal = isscalar(modMat);
if isModScal
    modMatSq = modMat*modMat;
else
    [nRows, nDim] = size(modMat);
    nDimsVec = dimension(ellArr);
    modgen.common.checkmultvar('(x1==x2)&&all(x3==x2)',...
        3,nRows,nDim,nDimsVec,'errorMessage',...
        'input matrix not square or dimensions do not match');
end
sizeCVec = num2cell(size(ellArr));
modEllArr(sizeCVec{:}) = ellipsoid;
arrayfun(@(x) fSingleShape(x), 1:numel(ellArr) );
    function fSingleShape(index)
        singEll = ellArr(index);
        if isModScal
            qMat = modMatSq*singEll.shapeMat;
        else
            qMat    = modMat*(singEll.shapeMat)*modMat';
            qMat    = 0.5*(qMat + qMat');
        end
        modEllArr(index).centerVec = singEll.centerVec;
        modEllArr(index).shapeMat = qMat;
    end
end
