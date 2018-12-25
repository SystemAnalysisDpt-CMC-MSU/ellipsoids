alpha = 10;
k1 = 50;
k2 = 500;
m1 = 150;
m2 = 100;
l = 5;
g = 9.8;
jc = 100;

x1 = 1;
v1 = 0;
theta1 = pi/2;
omega1 = 0;
t1 = 1;

d = jc + m2*l^2/4;
% define matrices aMat, bMat, and control bounds uBoundsEllObj:
aMat = [0, 1, 0, 0; 0, -k1/m1, 0, 0; 0, 0, 0, 1; 0, 0, m2*l*g/2/d, -k2*l/d];
bMat = [0; 1/m1; 0; 0];
uBoundsEllObj = alpha * ell_unitball(1);
%define disturbance:
gMat = [0; 0; 0; -m2*l*g*pi/4/d];
vEllObj = ellipsoid(1, 0); %known disturbance

%linear system
lsysObj = elltool.linsys.LinSysContinuous(aMat, bMat, uBoundsEllObj,...
    gMat, vEllObj);
timeVec = [t1, 0];
% initial directions:
nDirs = 3;
param1Vec = linspace(0, pi, nDirs);
param2Vec = linspace(0, 2*pi, nDirs);
[param1Arr, param2Arr, param3Arr] = meshgrid(param1Vec, param1Vec, param2Vec);
dirsMat = [...
    cos(param1Arr(:)),...
    sin(param1Arr(:)) .* cos(param2Arr(:)),...
    sin(param1Arr(:)) .* sin(param2Arr(:)) .* cos(param3Arr(:)),...
    sin(param1Arr(:)) .* sin(param2Arr(:)) .* sin(param3Arr(:))...
].'; %3-sphere parametrization
x1EllObj = ellipsoid([x1; v1; theta1; omega1], zeros(4)); %known final point

%backward reach set
brsObj = elltool.reach.ReachContinuous(lsysObj, x1EllObj, dirsMat, timeVec,...
    'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-4,...
    'absTol', 1e-5, 'relTol', 1e-4);

basisMat = [1 0 0 0; 0 0 1 0].'; % orthogonal basis of (x1, x3) subspace
psObj = brsObj.projection(basisMat); % reach set projection
