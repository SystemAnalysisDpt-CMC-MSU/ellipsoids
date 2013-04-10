function [ bpMat ] = ellbndr_3dmat( cenVec, qMat,nPoints, absTol)
%
% ELLBNDR_3DMAT - computes the boudary of 3D ellipsoid given its center
%                 and shape matrix
%
sphereTriangNum=ellipsoid.calcDepth(nPoints);
[dirMat, ~] = gras.geom.tri.spheretri(sphereTriangNum);
[~, bpMat] = ellipsoid.rhomat(qMat,cenVec,absTol,dirMat');
end

