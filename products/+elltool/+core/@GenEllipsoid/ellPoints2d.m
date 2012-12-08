function xMat = ellPoints2d(ell)
nPoints = ell.N_PLOT_POINTS;
lMat = gras.geom.circlepart(nPoints);
nDim = numel(ell.getCenter());
xMat = zeros(nDim, nPoints+1);
for iPoint = 1:nPoints
    [rVec, xVec] = rho(ell, lMat(iPoint, :).');
    xMat(:, iPoint) = xVec;
end
xMat(:, end) = xMat(:, 1);
end

