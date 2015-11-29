function isPositiveArr = isEmpty(myEllArr)
%
% ISEMPTY - checks if the GenEllipsoid object is empty.
%
% Input:
%   regular:
%       myEllArr: GenEllipsoid [nDims1,nDims2,...,nDimsN] - array of 
%            GenEllipsoids.
%
% Output:
%   isPositiveArr: logical[nDims1,nDims2,...,nDimsN], 
%       isPositiveArr(iCount) = true - if GenEllipsoid
%       myEllMat(iCount) is empty, false - otherwise.
% 
% Example:
%   ellObj = elltool.core.GenEllipsoid();
%   isempty(ellObj)
% 
%   ans =
% 
%        1
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com>  
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
import elltool.conf.Properties;
import elltool.core.GenEllipsoid;
GenEllipsoid.checkIsMe(myEllArr);
isPositiveArr = dimension(myEllArr)==0;