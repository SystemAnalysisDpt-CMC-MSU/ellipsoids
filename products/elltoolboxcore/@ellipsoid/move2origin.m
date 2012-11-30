function outEllMat = move2origin(inpEllMat)
%
% MOVE2ORIGIN - moves ellipsoids in the given array to the origin.
%
%   outEllMat = MOVE2ORIGIN(inpEll) - Replaces the centers of
%       ellipsoids in inpEllMat with zero vectors.
%
% Input:
%   regular:
%       inpEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
%
% Output:
%   outEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids
%       with the same shapes as in inpEllMat centered at the origin.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;

if ~(isa(inpEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        'MOVE2ORIGIN: argument must be array of ellipsoids.');
end

outEllMat = inpEllMat;
[mRows, nCols] = size(outEllMat);

for iRow = 1:mRows
    for jCol = 1:nCols
        nDims = dimension(outEllMat(iRow, jCol));
        outEllMat(iRow, jCol).center = zeros(nDims, 1);
    end
end
