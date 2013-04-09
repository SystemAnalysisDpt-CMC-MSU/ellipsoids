function [ bpMat ] = ellbndr_2dmat( cenVec, qMat, nPoints,absTol)
dirMat = gras.geom.circlepart(nPoints);
[~,bpMat]=rhomat(qMat,cenVec,absTol,dirMat);
end

