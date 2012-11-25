function invEllMat = inv(myEllMat)
%
% INV - inverts shape matrices of ellipsoids in the given array.
%   I = INV(myEllMat)  Inverts shape matrices of ellipsoids in the
%       array myEllMat. In case shape matrix is sigular, it is
%       regularized before inversion.
%
% Input:
%   regular:
%       myEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
%
% Output:
%    invEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids with
%       inverted shape matrices.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;

if ~(isa(myEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        'INV: input argument must be array of ellipsoids.');
end

invEllMat = myEllMat;
[mRows, nCols] = size(invEllMat);

absTolMat = getAbsTol(invEllMat);
for iRow = 1:mRows
    for jCol = 1:nCols
        if isdegenerate(invEllMat(iRow, jCol))
            regShMat = ellipsoid.regularize(invEllMat(iRow, jCol).shape,...
                absTolMat(iRow,jCol));
        else
            regShMat = invEllMat(iRow, jCol).shape;
        end
        regShMat = ell_inv(regShMat);
        invEllMat(iRow, jCol).shape = 0.5*(regShMat + regShMat');
    end
end
