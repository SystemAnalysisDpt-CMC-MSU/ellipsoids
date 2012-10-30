function oMat= mlorthtransl(srcMat,dstArray)
% MLORTHTRANSL generates a set of orthogonal matrices that translate each of
% the given vectors into a corresponding another vector from another set
%
% Input:
%   regular:
%       srcMat: double[nDims,nVecs]
%       dstArray: double[nDims,nVecs,nElems]
%
% Output:
%   oMat: double[nDims,nDims,nElems,nVecs]
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-01$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
nElems=size(dstArray,3);
nDims=size(dstArray,1);
nVecs=size(srcMat,2);
oMat=zeros([nDims,nDims,nElems,nVecs]);
for l=1:1:nVecs
    [srcQ,srcR]=qr(srcMat(:,l));
    if srcR(1,1)<0
        srcQ(:,1)=-srcQ(:,1);
    end
    srcQTr=transpose(srcQ);
    for t=1:1:nElems
        [dstQ,dstR]=qr(dstArray(:,l,t));
        if dstR(1,1)<0
            dstQ(:,1)=-dstQ(:,1);
        end
        oMat(:,:,t,l)=dstQ*srcQTr;
    end
end