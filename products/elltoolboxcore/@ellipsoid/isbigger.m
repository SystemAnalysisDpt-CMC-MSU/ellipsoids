function isPositive = isbigger(fstEll, secEll)
%
% ISBIGGER - checks if one ellipsoid would contain the other if their
%            centers would coincide.
%   RES = ISBIGGER(E1, E2)  Given two single ellipsoids of the same
%       dimension, E1 and E2, check if E1 would contain E2 inside if
%       they were both centered at origin.
%
% Input:
%   regular:
%       fstEll: ellipsod [1, 1] - first ellipsoid.
%       secEll: ellipsod [1, 1] - second ellipsoid of the same dimention.
%
% Output:
%   isPositive: logical[1, 1], true - if ellipsoid fstEll
%       would contain secEll inside, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import modgen.common.throwerror;

if ~(isa(fstEll, 'ellipsoid')) || ~(isa(secEll, 'ellipsoid'))
    throwerror('wrongInput', ...
        'ISBIGGER: both arguments must be single ellipsoids.');
end

[mFstEllRows, nFstEllCols] = size(fstEll);
[mSecEllRows, nSecEllCols] = size(secEll);
if (mFstEllRows > 1) || (nFstEllCols > 1) || (mSecEllRows > 1) ...
        || (nSecEllCols > 1)
    throwerror('wrongInput', ...
        'ISBIGGER: both arguments must be single ellipsoids.');
end

[nFstEllSpaceDim, nFstEllDim] = dimension(fstEll);
[nSecEllSpaceDim, nSecEllDim] = dimension(secEll);
if nFstEllSpaceDim ~= nSecEllSpaceDim
    throwerror('wrongSizes', ...
        'ISBIGGER: both ellipsoids must be of the same dimension.');
end
if nFstEllDim < nSecEllDim
    isPositive = false;
    return;
end

fstEllShMat = fstEll.shape;
secEllShMat = secEll.shape;
if nFstEllDim < nFstEllSpaceDim
    if Properties.getIsVerbose()
        fprintf('ISBIGGER: Warning! First ellipsoid is degenerate.');
        fprintf('          Regularizing...');
    end
    fstEllShMat = ellipsoid.regularize(fstEllShMat,fstEll.absTol);
end

tMat = ell_simdiag(fstEllShMat, secEllShMat);
if max(abs(diag(tMat*secEllShMat*tMat'))) < (1 + fstEll.absTol)
    isPositive = true;
else
    isPositive = false;
end
