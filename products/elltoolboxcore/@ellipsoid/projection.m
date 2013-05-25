function ellArr = projection(ellArr, basisMat)
%
% PROJECTION - computes projection of the ellipsoid onto the given subspace.
%              modified given array is on output (not its copy).     
%
%   projEllArr = projection(ellArr, basisMat)  Computes projection of the 
%       ellipsoid ellArr onto a subspace, specified by orthogonal 
%       basis vectors basisMat. ellArr can be an array of ellipsoids of 
%       the same dimension. Columns of B must be orthogonal vectors.
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
%           of ellipsoids.
%       basisMat: double[nDim, nSubSpDim] - matrix of orthogonal basis
%           vectors
%
% Output:
%   ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
%       projected ellipsoids, generally, of lower dimension.
%
% Example:
%   ellObj = ellipsoid([-2; -1; 4], [4 -1 0; -1 1 0; 0 0 9]);
%   basisMat = [0 1 0; 0 0 1]';
%   outEllObj = ellObj.projection(basisMat)
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
modgen.common.checkvar(basisMat, @(x)isa(x,'double'),'errorMessage',...
    'second input argument must be matrix with orthogonal columns.');
if ~isempty(ellArr)   
    [nDim, nBasis] = size(basisMat);
    nDimsArr   = dimension(ellArr);
    modgen.common.checkmultvar('(x2<=x1) && all(x3(:)==x1)',...
        3,nDim,nBasis,nDimsArr, 'errorMessage',...
        'dimensions mismatch or number of basis vectors too large.');

    % check the orthogonality of the columns of basisMat
    scalProdMat = basisMat' * basisMat;
    normSqVec = diag(scalProdMat);

    [~, absTol] = ellArr.getAbsTol(@max);
    isOrtogonalMat =(scalProdMat - diag(normSqVec))> absTol;
    if any(isOrtogonalMat(:))
        error('basis vectors must be orthogonal.');
    end

    % normalize the basis vectors
    normMat = repmat( realsqrt(normSqVec.'), nDim, 1);
    ortBasisMat = basisMat./normMat;

    % compute projection
    arrayfun(@(x) fSingleProj(x), ellArr);
end        
    function fSingleProj(ellObj)
        ellObj.shapeMat = ortBasisMat' * ellObj.shapeMat*ortBasisMat;
        ellObj.centerVec = ortBasisMat'*ellObj.centerVec;
    end
end