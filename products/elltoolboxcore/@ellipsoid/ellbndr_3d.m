function xMat = ellbndr_3d(myEll)
%
% ELLBNDR_3D - compute the boundary of 3D ellipsoid. Private method.
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1]- ellipsoid of the dimention 3.
%
% Output:
%   xMat: double[3, nCols] - boundary points of the ellipsoid myEll.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

nMPoints   = myEll.nPlot3dPoints/2;
nNPoints   = nMPoints/2;

psyVec = linspace(0, pi, nNPoints);
phiVec = linspace(0, 2*pi, nMPoints);

lMat   = [];
for i = 2:(nNPoints - 1)
    arrVec = cos(psyVec(i))*ones(1, nMPoints);
    lMat   = [lMat [cos(phiVec)*sin(psyVec(i)); ...
        sin(phiVec)*sin(psyVec(i)); arrVec]];
end
[rVec, xMat] = rho(myEll, lMat);
