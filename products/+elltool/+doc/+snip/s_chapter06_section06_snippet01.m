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

% Initializing A and B according to theoretical model
aMat = [0 0 -1 0; 0 0 0 1;...
    -sysConst2/sysConst1 0 -kVec(1)/sysConst1 2*kVec(2)/sysConst1;...
    sysConst2/sysConst1 0 kVec(1)/sysConst1 ...
    -(kVec(2)/jVec(2) + 2*kVec(2)/sysConst1)];
bMat = [0 0; 0 0; -1/sysConst1 0; 0 (1/jVec(2))+1/sysConst1];
x0Vec = [0; cos(pi/8); 0; 0];
endTime=0.1;
% Creating ellipsoid for control function
diagMat = diag(uVec);
uEllObj = ellipsoid(diagMat);
% Defining linear system
linSysDataMat=elltool.linsys.LinSysContinuous(aMat, bMat, uEllObj);
% Initializing direction matrix
nShape = 4;
mSize = 10;
dirMeshVec = linspace(1,2*pi,mSize);
dirMat = [cos(dirMeshVec);sin(dirMeshVec);cos(dirMeshVec);sin(dirMeshVec)];
for iElem = 1 : mSize
    dirMat(:, iElem) = dirMat(:, iElem) ./ norm(dirMat(:, iElem));
end;
% Set of start coordinates
x0EllObj = 1E-3 * ell_unitball(4) + x0Vec; 
% Calculating solvability set
timeVec = [endTime, 0];
solvDataMat = elltool.reach.ReachContinuous(linSysDataMat, x0EllObj, dirMat, ...
    timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-3);
% Creating projection matrix and draw projection on axis (x_3, x_4)
velBasisMat = [0 0 1 0 ; 0 0 0 1]';
prTubeDataMat = solvDataMat.projection(velBasisMat);
prTubeDataMat.plotByIa();
hold on;
ylabel('x_3'); zlabel('x_4');
rotate3d on;
% Creating projection matrix and draw projection on axis (x_1, x_1)
condBasisMat = [1 0 0 0 ; 0 1 0 0]';
prTubeDataMat = solvDataMat.projection(condBasisMat);
prTubeDataMat.plotByIa();
hold on;
ylabel('x_1'); zlabel('x_2');
rotate3d on;