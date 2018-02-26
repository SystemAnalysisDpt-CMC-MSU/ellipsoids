% after initializing we create ellipsoid for control function
diagMat = diag(alphaVec);
uEllObj = ellipsoid(diagMat);
% define linear systems
linSysObj=elltool.linsys.LinSysContinuous(aMat, bMat, uEllObj);
% initialize direction matrix
nDims = 4;
nDirs = 1;
dirMeshVec = 0 : (2 * pi / nDirs) : 2 * pi;
dirNum = length(dirMeshVec) ^ nDims;
[a1, a2, a3, a4] = ndgrid(dirMeshVec, dirMeshVec, dirMeshVec, dirMeshVec);
lineDir1Mat = reshape(a1, [1, dirNum]);
lineDir2Mat = reshape(a2, [1, dirNum]);
lineDir3Mat = reshape(a3, [1, dirNum]);
lineDir4Mat = reshape(a4, [1, dirNum]);
dirMat = [lineDir1Mat; lineDir2Mat; lineDir3Mat; lineDir4Mat];
dirMat = dirMat(:, 2 : end);
dirMat = dirMat ./ sqrt(repmat(sum(dirMat .^ 2, 1), nDims, 1));
% set of start coordinates
x0EllObj = 1E-2 * ell_unitball(4) + x0Vec;
% calculate solvability set
timeVec = [endTime, 0];
rsTubeObj = elltool.reach.ReachContinuous(linSysObj, x0EllObj, dirMat, ...
    timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-3);