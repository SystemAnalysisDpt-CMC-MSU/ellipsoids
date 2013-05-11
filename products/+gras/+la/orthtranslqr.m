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
%
nDims = length(srcVec);
%
if nDims == 1
    oMat = sign(srcVec*dstVec);
else
    [QMat,RMat] = qr([srcVec,dstVec],0);
    %
    cosVal = dot(srcVec,dstVec) / ...
        realsqrt(dot(srcVec,srcVec)*dot(dstVec,dstVec));
    sinVal = -realsqrt(1 - cosVal*cosVal);
    if RMat(1, 1)*RMat(2, 2) < 0
        sinVal = -sinVal;
    end
    %
    QSMat = zeros(nDims, 2);
    QSMat(:, 1) = QMat(:, 1)*(cosVal-1) + QMat(:, 2)*sinVal;
    QSMat(:, 2) = -QMat(:, 1)*sinVal + QMat(:, 2)*(cosVal-1);
    %
    oMat = eye(nDims) + QSMat*(QMat.');
end
end

