function [myEllCentVec, myEllShMat] = double(myEll)
%
% DOUBLE - returns parameters of the ellipsoid.
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1] - single ellipsoid of dimention nDims.
%
% Output:
%   myEllCentVec: double[nDims, 1] - center of the ellipsoid myEll.
%   myEllShMat: double[nDims, nDims] - shape matrix
%       of the ellipsoid myEll.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

ellipsoid.checkIsMe(myEll);
modgen.common.checkvar(myEll,'isscalar(x)',...
    'errorMessage','input argument must be single ellipsoid.');

if nargout < 2
    myEllCentVec = myEll.shape;
else
    myEllCentVec = myEll.center;
    myEllShMat = myEll.shape;
end