% after initializing we create ellipsoid for control function
diagMat = diag(alphaVec);
uEllObj = ellipsoid(diagMat);
% define linear systems
linSysObj=elltool.linsys.LinSysContinuous(aMat, bMat, uEllObj);
% initialize direction matrix
nDims = 4;
nDirs = 1;
psi = 0 : (pi / nDirs) : pi;
theta = 0 : (pi / nDirs) : pi;
phi = 0 : (2 * pi / nDirs) : 2 * pi;
dirNum = length(psi) ^ (nDims - 1);
[a1, a2, a3] = ndgrid(psi, theta, phi);
lineDir1Mat = reshape(cos(a1), [1, dirNum]);
lineDir2Mat = reshape(sin(a1) .* cos(a2), [1, dirNum]);
lineDir3Mat = reshape(sin(a1) .* sin(a2) .* cos(a3), [1, dirNum]);
lineDir4Mat = reshape(sin(a1) .* sin(a2) .* sin(a3), [1, dirNum]);
dirMat = [lineDir1Mat; lineDir2Mat; lineDir3Mat; lineDir4Mat];
dirMat = dirMat(:, 2 : end);
dirMat = dirMat ./ sqrt(repmat(sum(dirMat .^ 2, 1), nDims, 1));
% set of start coordinates
x0EllObj = 1E-2 * ell_unitball(4) + x0Vec;
% calculate solvability set
timeVec = [endTime, 0];
rsTubeObj = elltool.reach.ReachContinuous(linSysObj, x0EllObj, dirMat, ...
    timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-3);