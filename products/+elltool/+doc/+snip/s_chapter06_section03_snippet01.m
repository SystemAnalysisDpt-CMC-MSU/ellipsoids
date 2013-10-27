% define system 1
firstAMat = [-1/6 0 -1/3; 0 0 1/7; 1/2 -1/2 -1/2];
firstBMat = [1/6 1/3; 0 0; 0 0];
firstUBoundsEllObj = ellipsoid(eye(2));
firstSys = elltool.linsys.LinSysContinuous(firstAMat, firstBMat,...
       firstUBoundsEllObj);
% define system 2:
secAMat = [-1/6 0 -1/3; 0 0 1/3; 1/6 -1/6 -1/3];
secBMat = [1/6; 0; 0];
secUBoundsEllObj = ellipsoid(1);
secondSys = elltool.linsys.LinSysContinuous(secAMat, secBMat,....
         secUBoundsEllObj);
x0EllObj = ellipsoid(0.01*eye(3));  % set of initial states
dirsMat = eye(3);  % 3 initial directions
switchTime = 2;  % time of switch
termTime = 3;  % terminating time

% compute the reach set:
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat,...
 [0 switchTime], 'isRegEnabled', true, 'isJustCheck', false,...
 'regTol', 1e-5);  % reach set of the first system
% computation of the second reach set starts
% where the first left off
secRsObj = firstRsObj.evolve(termTime, secondSys);

% obtain projections onto (x1, x2) subspace:
basisMat = [1 0 0; 0 1 0]';  % (x1, x2) subspace basis
firstPsObj = firstRsObj.projection(basisMat);
secPsObj = secRsObj.projection(basisMat);

% plot the results:

plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_forward_reach_set_proj1%d',x));
% to have the use of plObj isn't necessary 
firstPsObj.plotByEa('r', plObj);  % external apprx. of reach set 1 (red)
%firstPsObj.plotByEa('r');
hold on;
plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_forward_reach_set_proj2%d',x));
% to have the use of plObj isn't necessary 
firstPsObj.plotByIa('g', plObj);  % internal apprx. of reach set 1 (green)
%firstPsObj.plotByIa('g');
plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_forward_reach_set_proj3%d',x));
% to have the use of plObj isn't necessary 
secPsObj.plotByEa('y', plObj);  % external apprx. of reach set 2 (yellow)
%secPsObj.plotByEa('y');
plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_forward_reach_set_proj4%d',x));
% to have the use of plObj isn't necessary 
secPsObj.plotByIa('b', plObj);  % internal apprx. of reach set 2 (blue)
%secPsObj.plotByIa('b');

% plot the 3-dimensional reach set at time t = 3:

plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_forward_reach_set_3D_1%d',x));
% to have the use of plObj isn't necessary 
secRsObj = secRsObj.cut(3);
secRsObj.plotByEa('y', plObj);
%secRsObj.plotByEa('y');
hold on;
plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_forward_reach_set_3D_2%d',x));
% to have the use of plObj isn't necessary 
secRsObj.plotByIa('b', plObj);
%secRsObj.plotByIa('b');
