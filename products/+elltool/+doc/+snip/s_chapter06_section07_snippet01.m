% initialize all variables for this model
mVec = [1; 2];
jVec = [0; 0];
phi0Vec = [0; 0];
lVec = [5; 5];
sVec = [3; 3];
alphaVec = [3; 10];
kVec = [0; 0];
g = 9.8;

a1 = mVec(1) * sVec(1)^2 + jVec(1) + mVec(2) * lVec(1)^2;
a2 = lVec(1) * sVec(2) * cos(phi0Vec(1) - phi0Vec(2));
b1 = lVec(1) * sVec(2) * cos(phi0Vec(1) - phi0Vec(2));
b2 = mVec(2) * sVec(2)^2 + jVec(2);

d1 = (mVec(1) * a1 + mVec(2) * lVec(2)) * g;
d2 = mVec(2) * a2 * g;

x1 = -kVec(1) * a2 / (a2 * b1 - a1 * b2);
x2 = kVec(2) * a1 / (a2 * b1 - a1 * b2);
x3 = a2 / (a2 * b1 - a1 * b2);
x4 = -a1 / (a2 * b1 - a1 * b2);
x5 = -(d1 * a2 + d2 * a1) / (a2 * b1 - a1 * b2);

y1 = -kVec(1) * b2 / (a2 * b1 - a1 * b2);
y2 = kVec(2) * b1 / (a2 * b1 - a1 * b2);
y3 = b2 / (a2 * b1 - a1 * b2);
y4 = -b1 / (a2 * b1 - a1 * b2);
y5 = (d2 * b1 - d1 * b2) / (a2 * b1 - a1 * b2);

x11 = d1 * a2 * sin(phi0Vec(1)) / (a2 * b1 - a1 * b2);
x12 = d2 * a1 * sin(phi0Vec(2)) / (a2 * b1 - a1 * b2);
x13 = (-d1 * a2 * cos(phi0Vec(1)) - d1 * a2 * sin(phi0Vec(1)) * phi0Vec(1)) / ...
    (a2 * b1 - a1 * b2) + (-d2 * a1 * cos(phi0Vec(2)) - ...
    d2 * a1 * sin(phi0Vec(2)) * phi0Vec(2)) / (a2 * b1 - a1 * b2);

y11 = d1 * b2 * sin(phi0Vec(1)) / (a2 * b1 - a1 * b2);
y12 = -d2 * b1 * sin(phi0Vec(2)) / (a2 * b1 - a1 * b2);
y13 = (d2 * b1 * cos(phi0Vec(2)) + d2 * b1 * sin(phi0Vec(2)) * phi0Vec(2)) / ...
    (a2 * b1 - a1 * b2) + (-d1 * b2 * cos(phi0Vec(1)) - ...
    d1 * b2 * sin(phi0Vec(1)) * phi0Vec(1)) / (a2 * b1 - a1 * b2);

%initialize A and B relying on theoretical materials
aMat = [0 0 1 0; 0 0 0 1; y11 y12 y1 y2; x11 x12 x1 x2];
bMat = [0 0; 0 0; y3 y4; x3 x4];

x0Vec = [0; 0; 0; 0];
endTime=5;
% after initializing we create ellipsoid for control function
diagMat = diag(alphaVec);
uEllObj = ellipsoid(diagMat);
% define linear systems
linSys=elltool.linsys.LinSysContinuous(aMat, bMat, uEllObj);
% initialize direction matrix
nShape = 4;
mSize = 10;
dirMat = 2*(rand(nShape, mSize) - 0.5);
for iElem = 1 : mSize
    dirMat(:, iElem) = dirMat(:, iElem) ./ norm(dirMat(:, iElem));
end;
% set of start coordinates
x0EllObj = 1E-2 * ell_unitball(4) + x0Vec;
% calculate solvability set
timeVec = [endTime, 0];
rsTube = elltool.reach.ReachContinuous(linSys, x0EllObj, dirMat, ...
    timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-3);
% create projection matrix and draw projection on current axis (z_3, z_4)
v1v2Mat = [0 0 1 0 ; 0 0 0 1]';
prTube = rsTube.projection(v1v2Mat);
prTube.plotByIa();
hold on;
ylabel('z_3'); zlabel('z_4');
rotate3d on;
% create projection matrix and draw projection on current axis (z_3, z_4)
v1v2Mat = [1 0 0 0 ; 0 1 0 0]';
prTube = rsTube.projection(v1v2Mat);
prTube.plotByIa();
hold on;
ylabel('z_1'); zlabel('z_2');
rotate3d on;