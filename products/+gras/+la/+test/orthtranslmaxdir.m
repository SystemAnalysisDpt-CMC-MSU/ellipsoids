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
import gras.la.test.*;
nDims=numel(srcVec);
if nDims>1
    A=qorth(srcVec);
    B=qorth(dstVec);
    a=A(:,1);
    b=B(:,1);
    U0=B(:,2:end);
    V0=A(:,2:end);
    a1=V0'*srcMaxVec;
    b1=U0'*dstMaxVec;
    if nDims>2
        A1=qorth(a1);
        B1=qorth(b1);
        Sline=B1*A1.';
    else
        Sline=sign(a1)*sign(b1);
    end
    oMat=U0*Sline*V0'+b*a';
else
    oMat=sign(srcVec)*sign(dstVec);
end