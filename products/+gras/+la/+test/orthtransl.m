function oMat=orthtransl(srcVec,dstVec)
% ORTHTRANSL generates an orthogonal matrix that translates a specified
% vector to another vector that is collinear to the second specified vector
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
if numel(srcVec)>1
    oMat=qorth(dstVec)*transpose(qorth(srcVec));
else
    oMat=1;
end