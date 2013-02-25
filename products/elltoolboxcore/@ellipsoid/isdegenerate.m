function isPositiveArr = isdegenerate(myEllArr)
%
% ISDEGENERATE - checks if the ellipsoid is degenerate.
%
% Input:
%   regular:
%       myEllArr: ellipsoid[nDims1,nDims2,...,nDimsN] - array of ellipsoids.
%
% Output:
%   isPositiveArr: logical[nDims1,nDims2,...,nDimsN], 
%       isPositiveArr(iCount) = true if ellipsoid myEllMat(iCount) 
%       is degenerate, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

ellipsoid.checkIsMe(myEllArr);

modgen.common.checkvar( myEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar(myEllArr,'~any(isempty(x(:)))',...
    'errorTag','wrongInput:emptyEllipsoid',...
    'errorMessage','input argument contains empty ellipsoid.');
isPositiveArr = arrayfun(@(x) rank(x.shape) < size(x.shape,1) ,myEllArr);