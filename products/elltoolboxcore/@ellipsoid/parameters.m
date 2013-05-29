function [myEllCenterVec, myEllShapeMat] = parameters(myEll)
%
% PARAMETERS - returns parameters of the ellipsoid.
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1] - single ellipsoid of dimention nDims.
%
% Output:
%   myEllCenterVec: double[nDims, 1] - center of the ellipsoid myEll.
%   myEllShapeMat: double[nDims, nDims] - shape matrix
%       of the ellipsoid myEll.
% 
% Example:
%   ellObj = ellipsoid([-2; 4], [4 -1; -1 5]);
%   [centVec shapeMat] = parameters(ellObj)
%   centVec =
% 
%       -2
%        4
%
%   shapeMat =
% 
%       4    -1
%      -1     5
% 
% 
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
% 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

if nargout < 2
    myEllCenterVec = double(myEll);
else
    [myEllCenterVec, myEllShapeMat] = double(myEll);
end
