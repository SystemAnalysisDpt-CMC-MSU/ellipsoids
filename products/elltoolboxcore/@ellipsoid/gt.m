function isPositiveArr = gt(firstEllArr, secondEllArr)
%
% GT - checks if the first ellipsoid is bigger than the second one.
%
% Input:
%   regular:
%       firsrEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - array
%           of ellipsoids.
%       secondEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - array
%           of ellipsoids of the corresponding dimensions.
%
% Output:
%   isPositiveArr: logical [nDims1,nDims2,...,nDimsN],
%       isPositiveArr(iCount) = true - if firsrEllArr(iCount)
%       contains secondEllArr(iCount)
%       when both have same center, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

import modgen.common.throwerror;
import modgen.common.checkmultvar;

ellipsoid.checkIsMe(firstEllArr,'first');
ellipsoid.checkIsMe(secondEllArr,'second');

isFstScal = isscalar(firstEllArr);
isSecScal = isscalar(secondEllArr);

checkmultvar('x1 || x2 ||all(size(x3)==size(x4))',...
    4,isFstScal,isSecScal,firstEllArr,secondEllArr,...
    'errorTag','wrongSizes',...
    'errorMessage','sizes of ellipsoidal arrays do not match.');

if ~(isFstScal || isSecScal)
    isPositiveArr = arrayfun(@(x,y) isbigger(x,y),firstEllArr,secondEllArr);
elseif isSecScal
    isPositiveArr = arrayfun(@(x) isbigger(x,secondEllArr),firstEllArr);
else
    isPositiveArr = arrayfun(@(x) isbigger(firstEllArr,x),secondEllArr);
end
