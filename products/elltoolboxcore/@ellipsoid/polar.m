function polEllArr = polar(ellArr)
% POLAR - computes the polar ellipsoids.
%
%   polEllArr = POLAR(ellArr)  Computes the polar ellipsoids for those
%       ellipsoids in ellArr, for which the origin is an interior point.
%       For those ellipsoids in E, for which this condition does not hold,
%       an empty ellipsoid is returned.
%
%   Given ellipsoid E(q, Q) where q is its center, and Q - its shape matrix,
%   the polar set to E(q, Q) is defined as follows:
%   P = { l in R^n  | <l, q> + sqrt(<l, Q l>) <= 1 }
%   If the origin is an interior point of ellipsoid E(q, Q),
%   then its polar set P is an ellipsoid.
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
%           of ellipsoids.
%
% Output:
%   polEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
%    	polar ellipsoids.
%
% Example:
%   ellObj = ellipsoid([4 -1; -1 1]);
%   ellObj.polar() == ellObj.inv()
% 
%   ans =
% 
%       1
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
import modgen.common.throwerror
ellipsoid.checkIsMe(ellArr);
modgen.common.checkvar(ellArr,'~any(isdegenerate(x))',...
    'errorTag','degenerateEllipsoid',...
    'errorMessage','The resulting ellipsoid is not bounded');
sizeCVec = num2cell(size(ellArr));
polEllArr(sizeCVec{:}) = feval(class(ellArr));

for iElem = 1:numel(ellArr)
    polEllArr(iElem) = getScalarPolarInternal(ellArr(iElem));
end