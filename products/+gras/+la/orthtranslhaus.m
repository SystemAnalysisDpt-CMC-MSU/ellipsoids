function oMat=orthtranslhaus(srcVec,dstVec)
% ORTHTRANSLHAUS generates an orthogonal matrix that translates a specified
% vector to another vector that is collinear to the second specified vector
% using the Hausholder method:
%   w=srcVec-dstVec;
%   oMat=I-2*w*w.'./(w.'*w)
%
% Input:
%   regular:
%       srcVec: double[nDims,1]
%       dstVec: double[nDims,1]
%
% Output:
%   oMat: double[nDims,nDims]
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-15$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
MAX_TOL=1e-14;
srcNormVec=srcVec./realsqrt(srcVec'*srcVec);
dstNormVec=dstVec./realsqrt(dstVec'*dstVec);
wVec=srcNormVec-dstNormVec;
wNorm=wVec'*wVec;
if wNorm<MAX_TOL
    rMult=0;
else
    rMult=2/wNorm;
end
oMat=eye(length(srcVec))-rMult.*(wVec*wVec');