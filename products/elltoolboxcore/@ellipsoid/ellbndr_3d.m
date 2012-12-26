function bpMat = ellbndr_3d(myEll)
%
% ELLBNDR_3D - compute the boundary of 3D ellipsoid. Private method.
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1]- ellipsoid of the dimention 3.
%
% Output:
%   bpMat: double[3, nCols] - boundary points of the ellipsoid myEll.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

ellipsoid.checkIsMe(myEll);

nMPoints   = 0.5*myEll.nPlot3dPoints;
nNPoints   = 0.5*nMPoints;
psyVec = linspace(0, pi, nNPoints);
phiVec = linspace(0, 2*pi, nMPoints);

cosPhiVec = repmat(cos(phiVec),1,(nNPoints - 2));
sinPhiVec = repmat(sin(phiVec),1,(nNPoints - 2));
cosPsyMat = repmat(cos(psyVec(2:(nNPoints - 1))),nMPoints,1);
cosPsyVec = reshape(cosPsyMat,1,nMPoints*(nNPoints - 2));
sinPsyMat = repmat(sin(psyVec(2:(nNPoints - 1))),nMPoints,1);
sinPsyVec = reshape(sinPsyMat,1,nMPoints*(nNPoints - 2));
lMat = [cosPhiVec.*sinPsyVec; ...
        sinPhiVec.*sinPsyVec; ...
        cosPsyVec];
[~, bpMat] = rho(myEll, lMat);
