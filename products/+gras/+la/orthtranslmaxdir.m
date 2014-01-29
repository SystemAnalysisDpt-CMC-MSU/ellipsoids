function oMat=orthtranslmaxdir(srcVec,dstVec,srcMaxVec,dstMaxVec)
% ORTHTRANSLMAXDIR generates an orthogonal matrix oMat that translates
% vector srcVec to another vector that is collinear to the second 
% specified vector dstVec. The matrix is chosen to maximize 
% (oMat*srcMaxVec,dstMaxVec)
%
% Input:
%   regular:
%       srcVec: double[nDims,1]
%       dstVec: double[nDims,1]
%       srcMaxVec: double[nDims,1]
%       dstMaxVec: double[nDims,1]
%
% Output:
%   oMat: double[nDims,nDims]
%
% References: see
%
% ISSN 0278-6419, Moscow University Computational Mathematics and Cybernetics, 
% 2007, Vol. 31, No. 1, pp. 11–20. © Allerton Press, Inc., 2007.
%
% "Computation of Projections of Reachability Tubes of Linear
% Controlled Systems Based on Ellipsoidal Calculus Techniques"
% P. V. Gagarinov
% 
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-03$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
nDims=numel(srcVec);
if nDims>1
    oSrcMat=gras.la.orthtransl([1;zeros(nDims-1,1)],srcVec);
    oDstMat=gras.la.orthtransl([1;zeros(nDims-1,1)],dstVec);

    %
    U0=oDstMat(:,2:end);
    V0=oSrcMat(:,2:end);
    a=oSrcMat(:,1);
    b=oDstMat(:,1);
    %
    a1=V0'*srcMaxVec;
    b1=U0'*dstMaxVec;
    %
    [o1SrcMat,r1SrcMat]=qr(a1);
    [o1DstMat,r1DstMat]=qr(b1);
    if xor(r1SrcMat(1,1)>0,r1DstMat(1,1)>0)
        o1DstMat(:,1)=-o1DstMat(:,1);
    end
    %
    oMat=U0*o1DstMat*o1SrcMat.'*V0'+b*a';
else
    oMat=sign(srcVec)*sign(dstVec);
end