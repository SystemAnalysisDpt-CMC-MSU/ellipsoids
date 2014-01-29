function [myEllCentVec,  myEllShMat] = double(myEll)
%
% DOUBLE - returns parameters of the ellipsoid.
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1] - single ellipsoid of dimention nDims.
%         
%
% Output:
%   myEllCentVec: double[nDims, 1] - center of the ellipsoid myEll.
%       
%   myEllShMat: double[nDims, nDims] - shape matrix of the ellipsoid myEll.
%       
% Example:
%   ellObj = ellipsoid([-2; -1], [2 -1; -1 1]);
%   [centVec, shapeMat] = double(ellObj)
%   centVec =
% 
%       -2
%       -1
% 
% 
%   shapeMat =
% 
%        2    -1
%       -1     1
% 
% 
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
% 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

ellipsoid.checkIsMe(myEll);
myEll.checkIfScalar();
%
if nargout < 2
    myEllCentVec = myEll.shapeMat;
else
    myEllCentVec = myEll.centerVec;
    myEllShMat = myEll.shapeMat;
 end