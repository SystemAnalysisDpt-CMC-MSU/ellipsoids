function [xMat, fMat] = ellPoints3d(ell)
recLevel = ell.RECURSE_LEVEL;
[vMat, fMat] = gras.geom.tri.spheretri(recLevel);
nPoints = size(vMat, 1);
nDim = numel(ell.getCenter());
xMat = zeros(nDim, nPoints+1);
for iPoint = 1:nPoints
    [rVec, xVec] = rho(ell, vMat(iPoint, :).');
    xMat(:, iPoint) = xVec;
end
xMat(:, end) = xMat(:, 1);
end

