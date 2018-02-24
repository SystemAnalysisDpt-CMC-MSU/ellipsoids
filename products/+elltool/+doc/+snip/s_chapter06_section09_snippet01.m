%%
% define all initial conditions
delta = 1;
f10 = 0.015;
f20 = 0.005;
f0 = 0.02;
c1 = 1;
c2 = 2;
c0 = 1.25;
v0 = 1;

%theta is the tank filling time
theta = v0/f0;

%define the error
error = 1E-5;

%set the number of cycles of delay
k = 3;

%define the initial vector
x0Vec = 5*ones(2*k+2, 1);
x0Vec(1) = v0;
x0Vec(2) = c0;

%define the certain volume and concentration
v = 10;
c = 10;
x1Vec = zeros(2*k+2, 1);
x1Vec(1) = 0;
x1Vec(2) = 0;

%define the matrixes A' and B' for equation x' = A'x + B'u
firstAMat = [...
    exp(-delta/(2*theta)) 0;
    0                     exp(-delta/theta)];

firstBMat = [...
    2*theta*(1 - exp(-delta/(2*theta))) 2*theta*(1 - exp(-delta/(2*theta)));
    0                                   0
    ];

secondBMat = [...
    0                                                               0;
    ((theta*(c1 - c0)) / v0) * (1 - exp(-delta/(theta))) ((theta*(c2 - c0)) / v0) * (1 - exp(-delta/(theta)))
    ];

finalCAMat = zeros(2*k+2);
finalCAMat(1:2, 1:2) = firstAMat;
finalCAMat(1:2, 2*k+1:2*k+2) = secondBMat;
finalCAMat(5:2*k+2, 3:2*k) = eye(2*k-2);


finalCBMat = zeros(2*k+2, 2);
finalCBMat(1:2, :) = firstBMat;
finalCBMat(3:4, :) = eye(2);

%define the timeVec for ReachDiscrete function
maxTime = 5;
timeVec = [0, maxTime];

%define bounds for control
uVec = [1, 1]';
uEllObj = uVec + ell_unitball(2);

%define the x0EllObj
qMat = error * eye(2*k+2);
x0EllObj = ellipsoid(x0Vec, qMat);

%define the discrete system
linSysObj=elltool.linsys.LinSysDiscrete(finalCAMat, finalCBMat, uEllObj);

% definition of dirMat
dirMat = eye(2*k+2);

%construction of reachability tube
solvObj = elltool.reach.ReachDiscrete(linSysObj, x0EllObj, dirMat, ...
    timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-1);

%%
%define the basis on which we project our tube
condBasisMat = zeros(2*k+2, 2);
condBasisMat(1:2, 1:2) = eye(2);
prTubeObj = solvObj.projection(condBasisMat);

plObj = smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_forward_reach_set_proj%d',x));
prTubeObj.plotByEa('r',plObj);
hold on;
plot3(maxTime, v, c, 'b*');
ylabel('V'); zlabel('c');
title('Ellipsoidal reach tube, proj. on subspace [V, c]');
rotate3d on;
%%
%check whether the point belongs to the reachability tube
[iaEllMat, timeVec] = prTubeObj.get_ia();
x2Vec = [v, c]';
firstEllObj = x1Vec + ellipsoid(qMat);
iaEllMat.isinternal(x2Vec, 'u')