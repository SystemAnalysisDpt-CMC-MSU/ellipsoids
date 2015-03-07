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
% Example:
%   ellObj = ellipsoid([1; 1], eye(2));
%   isdegenerate(ellObj)
% 
%   ans =
% 
%        0
% 
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $  
% $Date: Dec-2012$
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $   $Date: 25-04-2013$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
ellipsoid.checkIsMe(myEllArr);
modgen.common.checkvar(myEllArr,'~any(x(:).isEmpty())',...
    'errorTag','wrongInput:emptyEllipsoid',...
    'errorMessage','input argument contains empty ellipsoid.');
if isempty(myEllArr)
    isPositiveArr = true(size(myEllArr));
else
    isPositiveArr = ~arrayfun(@(x)gras.la.ismatposdef(x.shapeMat,x.absTol),...
        myEllArr);
end