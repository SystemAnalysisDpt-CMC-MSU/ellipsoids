function ellArr=projection(ellArr,basisMat)
%
% PROJECTION - computes projection of the AEllipsoid onto the given 
%				subspace. Modified given array is on output (not its copy).     
%
%	projEllArr=projection(ellArr,basisMat)  Computes projection of the 
%		AEllipsoid ellArr onto a subspace,specified by orthogonal 
%		basis vectors basisMat. ellArr can be an array of AEllipsoids of 
%		the same dimension. Columns of B must be orthogonal vectors.
%
% Input:
%	regular:
%		ellArr: AEllipsoid [nDims1,nDims2,...,nDimsN] - array
%			of AEllipsoids.
%		basisMat: double[nDim,nSubSpDim] - matrix of orthogonal basis
%			vectors
%
% Output:
%	ellArr: AEllipsoid [nDims1,nDims2,...,nDimsN] - array of
%		projected AEllipsoids,generally,of lower dimension.
%
% Example:
%	ellObj=ellipsoid([-2; -1; 4],[4 -1 0; -1 1 0; 0 0 9]);
%	basisMat=[0 1 0; 0 0 1]';
%	outEllObj=ellObj.projection(basisMat)
% 
%	outEllObj =
% 
%	Center:
%		-1
%		 4
% 
%	Shape:
%		1     0
%		0     9
% 
%	Nondegenerate ellipsoid in R^2.
% 
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California
%			2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2012 $
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
checkIsMeVirtual(ellArr);
modgen.common.checkvar(basisMat,@(x)isa(x,'double'),'errorTag',...
    'wrongInput','errorMessage',...
    'second input argument must be matrix with orthogonal columns.');
if ~isempty(ellArr)   
    [nDim,nBasis]=size(basisMat);
    nDimsArr=dimension(ellArr);
    modgen.common.checkmultvar('(x2<=x1) && all(x3(:)==x1)',...
        3,nDim,nBasis,nDimsArr,'errorTag','wrongInput',...
        'errorMessage',...
        'dimensions mismatch or number of basis vectors too large.');
    % check the orthogonality of the columns of basisMat
    scalProdMat=basisMat'*basisMat;
    normSqVec=diag(scalProdMat);
    [~,absTol]=ellArr.getAbsTol(@max);
    isOrtogonalMat=(scalProdMat-diag(normSqVec))>absTol;
    if any(isOrtogonalMat(:))
        modgen.common.throwerror('wrongInput',...
            'basis vectors must be orthogonal.');
    end
    % normalize the basis vectors
    normMat=repmat(realsqrt(normSqVec.'),nDim,1);
    ortBasisMat=basisMat./normMat;
    % compute projection
    arrayfun(@(x)projectionSingleInternal(x,ortBasisMat),ellArr);
end        
end