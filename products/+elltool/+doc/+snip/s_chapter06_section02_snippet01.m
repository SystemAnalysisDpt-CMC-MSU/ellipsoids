k1 = 24;  k2 = 32;
m1 = 1.5; m2 = 1;
% define matrices aMat, bMat, and control bounds uBoundsEll:
aMat = [0 0 1 0; 0 0 0 1; -(k1+k2)/m1 k2/m1 0 0; k2/m2 -(k1+k2)/m2 0 0];
bMat = [0 0; 0 0; 1/m1 0; 0 1/m2];
uBoundsEllObj = ell_unitball(2);
% linear system
lsys = elltool.linsys.LinSysContinuous(aMat, bMat, uBoundsEllObj);  
timeVec = [0 4];  % time interval% initial conditions:
x0EllObj = [0 2 0 0].' + ellipsoid([0.01 0 0 0; 0 0.01 0 0; 0 0 0 0;...
           0 0 0 0]);
% initial directions (some random vectors in R^4):
dirsMat = [1 0 1 0; 1 -1 0 0; 0 -1 0 1; 1 1 -1 1; -1 1 1 0; -2 0 1 1].';
% reach set
rsObj = elltool.reach.ReachContinuous(lsys, x0EllObj, dirsMat, timeVec,...
    'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-3,...
    'absTol',1e-5,'relTol',1e-4);  
basisMat = [1 0 0 0; 0 1 0 0]';  % orthogonal basis of (x1, x2) subspace
psObj = rsObj.projection(basisMat);  % reach set projection
% plot projection of reach set external approximation:

plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_tube_without_disturbance%d',x));
% plot the whole reach tube:
psObj.plotByEa('g', plObj); % to have the use of plObj isn't necessary 
%psObj.plotByEa('g');

%
% ReachContinuous's cut() doesn't work with projections:
psObj = psObj.cut(4);

plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_set_without_disturbance%d',x));
% plot reach set approximation at time t = 4:
psObj.plotByEa('g', plObj); % to have the use of plObj isn't necessary
%psObj.plotByEa('g');
