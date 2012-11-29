function maxEigMat = maxeig(inpEllMat)
%
% MAXEIG - return the maximal eigenvalue of the ellipsoid.
%
% Input:
%   regular:
%       inpEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
%
% Output:
%   maxEigMat: double[mRows, nCols] - matrix of maximal eigenvalues
%       of ellipsoids in the input matrix inpEllMat.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;
import elltool.conf.Properties;

if ~(isa(inpEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        'MAXEIG: input argument must be ellipsoid.');
end

[mRows, nCols] = size(inpEllMat);
maxEigMat = zeros(mRows,nCols);
for iRow = 1:mRows
    for jCol = 1:nCols
        if isempty(inpEllMat(iRow,jCol))
            throwerror('wrongInput:emptyEllipsoid', ...
                'MAXEIG: input argument is empty.');
        end
        maxEigMat(iRow,jCol) = max(eig(inpEllMat(iRow, jCol).shape));
    end
end
