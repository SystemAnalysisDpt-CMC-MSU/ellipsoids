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
x1Vec = [pi/2; 0; 0; 0];
endTime=0.05;
% Creating ellipsoid for pointwise restrictions on control
diagMat = diag(uVec);
uEllObj = ellipsoid(diagMat);
% Defining linear system
linSysObj=elltool.linsys.LinSysContinuous(aMat, bMat, uEllObj);
% Initializing directions matrix
nDims = 3;
nDirs = 3;
dirMesh1Vec = 0:(2*pi/nDirs):2*pi;%phi
dirMesh2Vec = 0:(pi/nDirs):pi;%psi
dirMesh3Vec = 0:(pi/nDirs):pi;%theta
[phiMat, psiMat, zetaMat] = ndgrid(dirMesh1Vec,dirMesh2Vec,dirMesh3Vec);
lineDir1Mat = reshape( cos(phiMat), 1, []);
lineDir2Mat = reshape( sin(phiMat).*cos(psiMat), 1, []);
lineDir3Mat = reshape( sin(phiMat).*sin(psiMat).*cos(zetaMat), 1, []);
lineDir4Mat = reshape( sin(phiMat).*sin(psiMat).*sin(zetaMat), 1, []);
dirMat = [lineDir1Mat; lineDir2Mat; lineDir3Mat; lineDir4Mat];
dirMat = dirMat(:,2:end);
dirMat = dirMat ./ sqrt(repmat(sum(dirMat.^2,1), nDims+1, 1));
% Set of final states
x1EllObj = 1E-3 * ell_unitball(4) + x1Vec; 
% Calculating solvability set
timeVec = [endTime, 0];
solvObj = elltool.reach.ReachContinuous(linSysObj, x1EllObj, dirMat, ...
    timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-3);