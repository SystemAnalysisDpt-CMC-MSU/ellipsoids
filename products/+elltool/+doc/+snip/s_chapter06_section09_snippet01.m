%%
% define system
% initial conditions
k = 3;
delta = 1;
eps = 1E-5;
F_10 = 0.015;
F_20 = 0.005;
F_0 = 0.02;
c_1 = 1;
c_2 = 2;
c_0 = 1.25;
V_0 = 1;
tetha = V_0/F_0;
uVec = [1, 1]';
x0Vec = 5*ones(2*k+2, 1);
x0Vec(1) = V_0;
x0Vec(2) = c_0;

%define the certain volume and concentration
V = 10;
c = 4;


firstAMat = [...
    exp(-delta/(2*tetha)) 0;
    0                     exp(-delta/tetha)];

firstBMat = [...
    2*tetha*(1 - exp(-delta/(2*tetha))) 2*tetha*(1 - exp(-delta/(2*tetha)));
    0                                   0
];

secondBMat = [...
    0 0;
    ((tetha*(c_1 - c_0)) / V_0) * (1 - exp(-delta/(tetha))) ((tetha*(c_2 - c_0)) / V_0) * (1 - exp(-delta/(tetha)))
];
% 
% myCAMat = [...
% firstAMat secondBMat;
% 0 0 0 0;
% 0 0 0 0
% ];
% 
% 
% myCBMat = [...
%     firstBMat;
%     eye(2)];


myCAMat = zeros(2*k+2);
myCAMat(1:2, 1:2) = firstAMat;
myCAMat(1:2, 2*k+1:2*k+2) = secondBMat;
myCAMat(5:2*k+2, 3:2*k) = eye(2*k-2);


myCBMat = zeros(2*k+2, 2);
myCBMat(1:2, :) = firstBMat;
myCBMat(3:4, :) = eye(2);

%define the timeVec for ReachDiscrete function
maxTime = 5;
timeVec = [0, maxTime];

%define bounds for control
uEllObj = uVec + ell_unitball(2); 

%define the x0EllObj
QMat = eps * eye(2*k+2);
x0EllObj = ellipsoid(x0Vec, QMat);

%define the system
linSysObj=elltool.linsys.LinSysDiscrete(myCAMat, myCBMat, uEllObj);

% % %definition of dirMat
% nDims = 4; 
% nDirs = 1; 
% dirMeshVec = 0:(2*pi/nDirs):2*pi; 
% dirNum = length(dirMeshVec)^nDims; 
% [x1, x2, x3, x4] = ndgrid(dirMeshVec,dirMeshVec,dirMeshVec,dirMeshVec); 
% lineDir1Mat = reshape( x1, [1, dirNum]); 
% lineDir2Mat = reshape( x2, [1, dirNum]); 
% lineDir3Mat = reshape( x3, [1, dirNum]); 
% lineDir4Mat = reshape( x4, [1, dirNum]); 
% dirMat = [lineDir1Mat; lineDir2Mat; lineDir3Mat; lineDir4Mat]; 
% dirMat = dirMat(:,2:end); 
% dirMat = dirMat ./ sqrt(repmat(sum(dirMat.^2,1), nDims, 1)); 
dirMat = eye(2*k+2);


% solvObj = elltool.reach.ReachDiscrete(linSysObj, x1EllObj, dirMat, ... 
% timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-1);
solvObj = elltool.reach.ReachDiscrete(linSysObj, x0EllObj, dirMat, ... 
timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-1);

%%
condBasisMat = zeros(2*k+2, 2);
condBasisMat(1:2, 1:2) = eye(2);

prTubeObj = solvObj.projection(condBasisMat);
plObj = smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_forward_reach_set_proj%d',x));
prTubeObj.plotByEa('r',plObj);
hold on;
t = 0:maxTime;
plot3(t, V, c, 'b*');
ylabel('V'); zlabel('c');
title('Ellipsoidal reach tube, proj. on subspace [1 0 0 0, 0 1 0 0]');
rotate3d on;
