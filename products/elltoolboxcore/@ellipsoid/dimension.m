function [spaceDimMat, ellDimMat] = dimension(myEllMat)
%
% DIMENSION - returns the dimension of the space in which the ellipsoid
%             is defined and the actual dimension of the ellipsoid.
%
% Input:
%   regular:
%       myEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
%
% Output:
%   regular:
%       spaceDimMat: double[mRows, nCols] - space dimensions.
%
%   optional:
%       ellDimMat: double[mRows, nCols] - dimensions of the ellipsoids
%           in myEllMat.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;

[mRows, nCols] = size(myEllMat);
spaceDimMat = zeros(mRows, nCols);
ellDimMat = zeros(mRows, nCols);

for iRows = 1:mRows
    for jCols = 1:nCols
        spaceDimMat(iRows, jCols) = size(myEllMat(iRows, jCols).shape, 1);
        ellDimMat(iRows, jCols) = rank(myEllMat(iRows, jCols).shape);
        if isempty(myEllMat(iRows, jCols).shape) ...
                || isempty(myEllMat(iRows, jCols).center)
            spaceDimMat(iRows, jCols) = 0;
            ellDimMat(iRows, jCols) = 0;
        end
    end
end
