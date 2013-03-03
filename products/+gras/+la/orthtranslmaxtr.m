function oMat=orthtranslmaxtr(srcVec,dstVec,maxMat)
% ORTHTRANSLMAXVOL generates an orthogonal matrix oMat that translates 
% a specified vector srcVec to another vector that is collinear to 
% the second specified vector dstVec
% The matrix S is chosen to maximize Tr(oMat*maxMat) where maxMat
% is specified
%
% Input:
%   regular:
%       srcVec: double[nDims,1]
%       dstVec: double[nDims,1]
%       maxMat: double[nDims,nDims]
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
[oSrcMat,srcR]=qr(srcVec);
[oDstMat,dstR]=qr(dstVec);
%
if xor(srcR(1,1)>0,dstR(1,1)>0)
    oDstMat(:,1)=-oDstMat(:,1);
end
%
U0=oDstMat(:,2:end);
V0=oSrcMat(:,2:end);
srcNVec=oSrcMat(:,1);
dstNVec=oDstMat(:,1);
K=transpose(V0)*maxMat*U0;
[M,~,N] = svd(K);
Sline=N*M';
oMat=U0*Sline*V0'+dstNVec*srcNVec';