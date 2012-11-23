function newEllArr = uminus(inpEllArr)
%
% Description:
% ------------
%
%    Changes the sign of the center of ellipsoid.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%    Rustam Guliev <glvrst@gmail.com>
%

import modgen.common.type.simple.checkgen;
checkgen(inpEllArr,@(x)isa(x,'ellipsoid'),'Input argument');

nDimVec = size(inpEllArr);
newEllCVec = arrayfun(@(x) ellipsoid(-x.center, x.shape),inpEllArr,...
    'UniformOutput',false);

%Conver cell to array
newEllArr(prod(nDimVec)) = ellipsoid; 
newEllArr(:) = newEllCVec{:};
newEllArr = reshape(newEllArr,nDimVec);
