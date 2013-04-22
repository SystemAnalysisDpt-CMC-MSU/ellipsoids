function oArr= mlorthtransl(srcMat,dstArray)
% MLORTHTRANSL generates a set of orthogonal matrices that translate each of
% the given vectors into a corresponding another vector from another set
%
% Input:
%   regular:
%       srcMat: double[nDims,nVecs]
%       dstArray: double[nDims,nVecs,nElems]
%
% Output:
%   oArr: double[nDims,nDims,nElems,nVecs]
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-01$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
nElems=size(dstArray,3);
nDims=size(dstArray,1);
nVecs=size(srcMat,2);
oArr=zeros([nDims,nDims,nElems,nVecs]);
ABS_TOL=1e-7;
for l=1:1:nVecs
    srcVec=srcMat(:,l);
    for t=1:1:nElems
        dstVec=dstArray(:,l,t);        
        dstVec = dstVec/sqrt(sum(dstVec.*dstVec));
        srcVec = srcVec/sqrt(sum(srcVec.*srcVec));
        scalProd = sum(srcVec.*dstVec);
        sVal = sqrt(1 - scalProd^2);
        qMat = zeros(nDims, 2);
        qMat(:, 1) = dstVec;
        %
        if abs(sVal) > ABS_TOL
            qMat(:, 2) = (srcVec - scalProd * dstVec)/sVal;
        else
            qMat(:, 2) = 0; 
        end;
        sMat = [scalProd-1 sVal; -sVal scalProd-1];
        %
        oArr(:,:,t,l) = eye(nDims) + (qMat*sMat)*qMat';
    end
end