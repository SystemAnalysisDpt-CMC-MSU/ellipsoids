function xMat = ellbndr_2d(myEll)
%
% ELLBNDR_2D - compute the boundary of 2D ellipsoid. Private method.
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1]- ellipsoid of the dimention 2.
%
% Output:
%   xMat: double[2, nPoints + 1] - boundary points of the ellipsoid myEll.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

nPoints = myEll.nPlot2dPoints;
phiVec = linspace(0, 2*pi, nPoints);
lMat = [cos(phiVec); sin(phiVec)];
[rVec, xMat] = rho(myEll, lMat);
xMat = [xMat xMat(:, 1)];
