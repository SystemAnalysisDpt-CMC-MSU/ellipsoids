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
nShape = 4;
mSize = 2;
dirMeshVec = 0:(2*pi/mSize):2*pi;
dirNum = length(dirMeshVec)^4;
%dirMat = [dirMeshVec;fliplr(dirMeshVec);fliplr(dirMeshVec);dirMeshVec];
[x1, x2, x3, x4] = ndgrid(dirMeshVec,dirMeshVec,...
    dirMeshVec,dirMeshVec);
lineDirMat1 = reshape( x1, [1, dirNum]);
lineDirMat2 = reshape( x2, [1, dirNum]);
lineDirMat3 = reshape( x3, [1, dirNum]);
lineDirMat4 = reshape( x4, [1, dirNum]);
dirMat = [lineDirMat1; lineDirMat2; lineDirMat3; lineDirMat4];
dirMat = dirMat(:,2:end);
for iElem = 1 : mSize
    dirMat(:, iElem) = dirMat(:, iElem) ./ norm(dirMat(:, iElem));
end;
% Set of final states
x1EllObj = 1E-3 * ell_unitball(4) + x1Vec; 
% Calculating solvability set
timeVec = [endTime, 0];
solvObj = elltool.reach.ReachContinuous(linSysObj, x1EllObj, dirMat, ...
    timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-3);
% Creating projection matrix and draw projection on axis (x_3, x_4)
velBasisMat = [0 0 1 0 ; 0 0 0 1]';
prTubeObj = solvObj.projection(velBasisMat);
prTubeObj.plotByIa();
hold on;
ylabel('x_3'); zlabel('x_4');
rotate3d on;
% Creating projection matrix and draw projection on axis (x_1, x_2)
condBasisMat = [1 0 0 0 ; 0 1 0 0]';
prTubeObj = solvObj.projection(condBasisMat);
prTubeObj.plotByIa();
hold on;
ylabel('x_1'); zlabel('x_2');
rotate3d on;