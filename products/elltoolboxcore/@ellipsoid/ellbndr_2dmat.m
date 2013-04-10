function [ bpMat ] = ellbndr_2dmat( cenVec, qMat,absTol, nPoints)
%
% ELLBNDR_2DMAT - computes the boudary of 2D ellipsoid given its center
%                 and shape matrix
%
dirMat = gras.geom.circlepart(nPoints);
[~,bpMat]=ellipsoid.rhomat(qMat,cenVec,absTol,dirMat');
end

