function oMat=matorth(srcMat)
% MATORTH generates an orthogonal matrix that contains in its first k
% columns orthogonalized vectors specified on input as [n,k] matrix
%
% Input:
%   regular:
%       srcMat: double[nDims,nCols]
%
% Output:
%   oMat: double[nDims,nDims]
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-25$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
[oMat,srcR]=qr(srcMat);
isNegDiagVec=diag(srcR)<0;
oMat(:,isNegDiagVec)=-oMat(:,isNegDiagVec);