function isPositiveArr = isEmpty(myEllArr)
%
% ISEMPTY - checks if the ellipsoid object is empty.
%
% Input:
%   regular:
%       myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of 
%            ellipsoids.
%
% Output:
%   isPositiveArr: logical[nDims1,nDims2,...,nDimsN], 
%       isPositiveArr(iCount) = true - if ellipsoid
%       myEllMat(iCount) is empty, false - otherwise.
% 
% Example:
%   ellObj = ellipsoid();
%   isempty(ellObj)
% 
%   ans =
% 
%        1
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

import elltool.conf.Properties;

ellipsoid.checkIsMe(myEllArr);

isPositiveArr = ~dimension(myEllArr);
