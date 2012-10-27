function oMat= mlorthtransl(srcMat,dstArray)
% QORTHTRANSL generates a set of orthogonal matrices that translate each of
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
import gras.la.test.*;
nElems=size(dstArray,3);
nDims=size(dstArray,1);
nVecs=size(srcMat,2);
if nDims>1
    oMat=zeros([nDims,nDims,nElems,nVecs]);    
    for l=1:1:nVecs
        A=transpose(qorth(srcMat(:,l)));
        for t=1:1:nElems
            if norm(dstArray(:,l,t))>0
                oMat(:,:,t,l)=qorth(dstArray(:,l,t))*A;
            else
                oMat(:,:,t,l)=I;
            end
        end
    end
else
    oMat=sign([nDims,nDims,nElems,nVecs]).*...
        repmat(reshape(sign(srcMat),1,1,1,nVecs),[1,1,nElems,1]);
end
    
%