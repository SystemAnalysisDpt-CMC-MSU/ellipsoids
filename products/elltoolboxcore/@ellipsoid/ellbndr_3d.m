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

sphereTriangNum=3;
[cenVec qMat]=double(myEll);
absTol=myEll.getAbsTol();
bpMat=ellbndr_2dmat(cenVec,qMat,sphereTriangNum,absTol);
