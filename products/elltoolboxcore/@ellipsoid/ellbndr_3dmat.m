function [ bpMat ] = ellbndr_3dmat( cenVec, qMat,sphereTriangNum, absTol)
%
% ELLBNDR_3DMAT - computes the boudary of 3D ellipsoid given its center
%                 and shape matrix
%
[dirMat, ~] = gras.geom.tri.spheretri(sphereTriangNum);
[~, bpMat] = ellipsoid.rhomat(qMat,cenVec,absTol,dirMat');
end

