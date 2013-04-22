function oMat=orthtransl(srcVec,dstVec)
% ORTHTRANSL generates an orthogonal matrix that translates a specified
% vector to another vector that is collinear to the second specified vector
%
% Input:
%   regular:
%       srcVec: double[nDims,1]
%       dstVec: double[nDims,1]
%
% Output:
%   oMat: double[nDims,nDims]
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-11-28$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
ABS_TOL=1e-6;
nDims = size(dstVec, 1);
dstVec = dstVec/sqrt(sum(dstVec.*dstVec));
srcVec = srcVec/sqrt(sum(srcVec.*srcVec));
%
scalProd = sum(srcVec.*dstVec);
sVal = sqrt(1 - scalProd*scalProd);
qMat = zeros(nDims, 2);
qMat(:, 1) = dstVec;
if abs(sVal) > ABS_TOL
    qMat(:, 2) = (srcVec - scalProd * dstVec)/sVal;
else
    qMat(:, 2) = 0; 
end;
sMat = [scalProd-1 sVal; -sVal scalProd-1];
%
oMat = eye(nDims) + (qMat*sMat)*qMat';
