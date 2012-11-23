function modEllArr = shape(inpEllArr, modMat)
%
% SHAPE - modifies the shape matrix of the ellipsoid without changing its center.
%
%
% Description:
% ------------
%
%    EM = SHAPE(E, A)  Modifies the shape matrices of the ellipsoids in the
%                      ellipsoidal array E. The centers remain untouched -
%                      that is the difference of the function SHAPE and
%                      linear transformation A*E.
%                      A is expected to be a scalar or a square matrix
%                      of suitable dimension.
%        
%
% Output:
% -------
%
%    EM - array of modified ellipsoids.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%    Rustam Guliev <glvrst@gmail.com>


import modgen.common.type.simple.checkgenext;
checkgenext(@(x1,x2)isa(x1,'ellipsoid')&&isa(x2,'double'),2,inpEllArr,modMat,'Input argument',' ');

if ~isscalar(modMat)
    [nRow, nDim] = size(modMat); 
    if nRow ~= nDim
        error('SHAPE: only square matrices are allowed.');    
    end 
    nDimsVec = dimension(inpEllArr(:));
    if ~all(nDimsVec==nDim)
    	error('SHAPE: dimensions do not match.');
    end    
end

modEllArr = arrayfun(@(x) fsingleShape(x),inpEllArr);

    function modEll = fsingleShape(singEll)
        qMat    = modMat*(singEll.shape)*modMat';
        qMat    = 0.5*(qMat + qMat');
        modEll = ellipsoid(singEll.center, qMat);
    end
end


