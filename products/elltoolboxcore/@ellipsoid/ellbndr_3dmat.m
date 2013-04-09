function [ bpMat ] = ellbndr_3dmat( cenVec, qMat,sphereTriangNum, absTol)
[dirMat, ~] = gras.geom.tri.spheretri(sphereTriangNum);
[~, bpMat] = rhomat(cenVec,qMat, absTol,dirMat);
end

