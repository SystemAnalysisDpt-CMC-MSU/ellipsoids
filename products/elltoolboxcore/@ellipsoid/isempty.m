function isPositiveMat = isempty(myEllMat)
%
% ISEMPTY - checks if the ellipsoid object is empty.
%
% Input:
%   regular:
%       myEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
%
% Output:
%   isPositiveMat: logical[1mRows, nCols], 
%       isPositiveMat(iRow, jCol) = true - if ellipsoid
%       myEllMat(iRow, jCol) is empty, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import modgen.common.throwerror;

if ~(isa(myEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        'ISEMPTY: input argument must be ellipsoid.');
end

isPositiveMat = ~dimension(myEllMat);
