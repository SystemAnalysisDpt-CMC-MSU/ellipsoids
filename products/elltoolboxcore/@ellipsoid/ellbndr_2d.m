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

nPoints = myEll.nPlot2dPoints;
[cenVec qMat]=double(myEll);
absTol=myEll.getAbsTol();
bpMat=ellbndr_2dmat(cenVec,qMat,nPoints,absTol);