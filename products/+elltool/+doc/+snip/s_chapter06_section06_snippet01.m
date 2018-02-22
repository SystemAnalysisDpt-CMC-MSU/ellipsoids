% Initializing all variables for the physical model
mVec = [4; 2];
l = 0.8;
a = l/2;
r = 0.2;
kVec = [0.2; 0.2];
g = 9.8;
jVec = [mVec(1)*l^2/12; mVec(2)*r^2/2];
sysConst1 = jVec(1) + mVec(1)*a^2 + mVec(2)*l^2; %K
sysConst2 = (mVec(1)*a^2 + mVec(2)*l^2)*g; %M
uVec = [2; 2];

% Initializing A and B according to the theoretical model
aMat = [0 0 -1 0; 0 0 0 1;...
    -sysConst2/sysConst1 0 -kVec(1)/sysConst1 2*kVec(2)/sysConst1;...
    sysConst2/sysConst1 0 kVec(1)/sysConst1 ...
    -(kVec(2)/jVec(2) + 2*kVec(2)/sysConst1)];
bMat = [0 0; 0 0; -1/sysConst1 0; 0 (1/jVec(2))+1/sysConst1];
x1Vec = [0; cos(pi/8); 0; 0];
endTime=0.05;
% Creating ellipsoid for pointwise restrictions on control
diagMat = diag(uVec);
uEllObj = ellipsoid(diagMat);
% Defining linear system
linSysObj=elltool.linsys.LinSysContinuous(aMat, bMat, uEllObj);
% Initializing directions matrix
nDims = 4;
nDirs = 1;
dirMeshVec = 0:(2*pi/nDirs):2*pi;
dirNum = length(dirMeshVec)^nDims;
[x1, x2, x3, x4] = ndgrid(dirMeshVec,dirMeshVec,dirMeshVec,dirMeshVec);
lineDir1Mat = reshape( x1, [1, dirNum]);
lineDir2Mat = reshape( x2, [1, dirNum]);
lineDir3Mat = reshape( x3, [1, dirNum]);
lineDir4Mat = reshape( x4, [1, dirNum]);
dirMat = [lineDir1Mat; lineDir2Mat; lineDir3Mat; lineDir4Mat];
dirMat = dirMat(:,2:end);
dirMat = dirMat ./ sqrt(repmat(sum(dirMat.^2,1), nDims, 1));
% Set of final states
x1EllObj = 1E-3 * ell_unitball(4) + x1Vec; 
% Calculating solvability set
timeVec = [endTime, 0];
solvObj = elltool.reach.ReachContinuous(linSysObj, x1EllObj, dirMat, ...
    timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-3);