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
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2013-04-17$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
import modgen.common.throwerror;
ABS_TOL=1e-7;
nDims = size(dstVec, 1);
if ~isreal(srcVec)
    throwerror('wrongInput:srcComplex',...
        'source vector is expected to be real');
end
if ~isreal(dstVec)
    throwerror('wrongInput:dstComplex',...
        'destination vector is expected to be real');    
end
dstSquaredNorm=sum(dstVec.*dstVec);
srcSquaredNorm=sum(srcVec.*srcVec);
if dstSquaredNorm==0
    throwerror('wrongInput:dstZero',...
        'destination vectors are expected to be non-zero');
end
if srcSquaredNorm==0
    throwerror('wrongInput:srcZero',...
        'source vectors are expected to be non-zero');
end
    
dstVec = dstVec/realsqrt(dstSquaredNorm);
srcVec = srcVec/realsqrt(srcSquaredNorm);
%
scalProd = sum(srcVec.*dstVec);
sVal = realsqrt(max(1 - scalProd*scalProd,0));
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
