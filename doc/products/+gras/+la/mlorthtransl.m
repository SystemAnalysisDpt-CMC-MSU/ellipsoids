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
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2013-04-17$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
nElems=size(dstArray,3);
nDims=size(dstArray,1);
nVecs=size(srcMat,2);
oArr=zeros([nDims,nDims,nElems,nVecs]);
for iVec=1:1:nVecs
    srcVec=srcMat(:,iVec);
    for iElem=1:1:nElems
        dstVec=dstArray(:,iVec,iElem);
        oArr(:,:,iElem,iVec) = gras.la.orthtransl(srcVec,dstVec);
    end
end