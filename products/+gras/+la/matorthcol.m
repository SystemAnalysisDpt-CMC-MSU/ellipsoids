function oMat=matorthcol(srcMat)
% MATORTHCOL builds a matrix with columns composed of orthogonalized
% columns of srcMat
%
% Input:
%   regular:
%       srcMat: double[nDims,nCols]
%
% Output:
%   oMat: double[nDims,nCols]
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2013-08-14$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
oMat=gras.la.matorth(srcMat);
oMat=oMat(:,1:size(srcMat,2));