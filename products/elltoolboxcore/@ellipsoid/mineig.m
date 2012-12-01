function minEigMat = mineig(inpEllMat)
%
% MINEIG - return the minimal eigenvalue of the ellipsoid.
%
% Input:
%   regular:
%       inpEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
%
% Output:
%   minEigMat: double[mRows, nCols] - array of minimal eigenvalues
%       of ellipsoids in the input array inpEllMat.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;
import elltool.conf.Properties;

if ~(isa(inpEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        'MINEIG: input argument must be ellipsoid.');
end

[mRows, nCols] = size(inpEllMat);
minEigMat = zeros(mRows,nCols);
for iRow = 1:mRows
    for jCol = 1:nCols
        if isempty(inpEllMat(iRow,jCol))
            throwerror('wrongInput:emptyEllipsoid', ...
                'MINEIG: input argument is empty.');
        end
        if isdegenerate(inpEllMat(iRow, jCol))
            minEigMat(iRow,jCol)=0;
        else
            minEigMat(iRow,jCol) = ...
                min(eig(inpEllMat(iRow, jCol).shape));
        end
    end
end
