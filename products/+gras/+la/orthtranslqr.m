function oMat = orthtranslqr(srcVec, dstVec)
% ORTHTRANSLQR generates an orthogonal matrix that translates a specified
% vector to another vector that is collinear to the second specified vector
% using QR-factorization
%
% Input:
%   regular:
%       srcVec: double[nDims,1]
%       dstVec: double[nDims,1]
%
% Output:
%   oMat: double[nDims,nDims]
%
% $Author: Ivan Menshikov <ivan.v.menshikov@gmail.com>$ $Date: 2013-05-11$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
import modgen.common.throwerror;
if ~isreal(srcVec)
    throwerror('wrongInput:srcComplex',...
        'source vector is expected to be real');
end
if ~isreal(dstVec)
    throwerror('wrongInput:dstComplex',...
        'destination vector is expected to be real');
end
srcSquaredNorm=sum(srcVec.*srcVec);
dstSquaredNorm=sum(dstVec.*dstVec);
if srcSquaredNorm==0
    throwerror('wrongInput:srcZero',...
        'source vectors are expected to be non-zero');
end
if dstSquaredNorm==0
    throwerror('wrongInput:dstZero',...
        'destination vectors are expected to be non-zero');
end
%
nDims = length(srcVec);
%
if nDims == 1
    oMat = sign(srcVec*dstVec);
else
    [qMat,rMat] = qr([dstVec,srcVec],0);
    %
    cosVal = dot(srcVec,dstVec) / realsqrt(srcSquaredNorm*dstSquaredNorm);
    sinVal = -realsqrt(1 - cosVal*cosVal);
    if rMat(1, 1)*rMat(2, 2) < 0
        sinVal = -sinVal;
    end
    %
    qsMat = zeros(nDims, 2);
    qsMat(:, 1) = qMat(:, 1)*(cosVal-1) + qMat(:, 2)*sinVal;
    qsMat(:, 2) = -qMat(:, 1)*sinVal + qMat(:, 2)*(cosVal-1);
    %
    oMat = eye(nDims) + qsMat*(qMat.');
end
end

