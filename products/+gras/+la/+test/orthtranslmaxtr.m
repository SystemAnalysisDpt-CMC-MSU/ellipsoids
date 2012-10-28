function S=orthtranslmaxtr(a,b,C)
% ORTHTRANSLMAXVOL generates an orthogonal matrix that translates a specified
% vector to another vector that is collinear to the second specified vector
% The matrix S is chosen to maximize Tr(S*C) where C is specified
%
% Input:
%   regular:
%       srcVec: double[nDims,1]
%       dstVec: double[nDims,1]
%
% Output:
%   oMat: double[nDims,nDims]
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-05$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
import gras.la.test.*;
nDims=numel(a);
if nDims>1
    A=qorth(a);
    B=qorth(b);
    U0=B(:,2:end);
    V0=A(:,2:end);
    a=A(:,1);
    b=B(:,1);
    K=transpose(V0)*C*U0;
    [M,~,N] = svd(K);
    Sline=N*M';
    S=U0*Sline*V0'+b*a';
else
    S=1;
end