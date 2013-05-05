function bpMat = ellbndr_2d(myEll)
%
% ELLBNDR_2D - compute the boundary of 2D ellipsoid. Private method.
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1]- ellipsoid of the dimention 2.
%
% Output:
%   bpMat: double[2, nPoints + 1] - boundary points of the ellipsoid myEll.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
            
ellipsoid.checkIsMe(myEll);
nPoints = myEll.nPlot2dPoints;
phiVec = linspace(0, 2*pi, nPoints);
lMat = [cos(phiVec); sin(phiVec)];
[~, xMat] = rho(myEll, lMat);
bpMat = [xMat xMat(:, 1)];
