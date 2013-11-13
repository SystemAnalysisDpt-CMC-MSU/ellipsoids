mEllObj  = ellipsoid(0.01*eye(3));  % terminating set
termTime = 3;  % terminating time

% compute backward reach set:
% compute the reach set:
secBrsObj = elltool.reach.ReachContinuous(secondSys, mEllObj, dirsMat,...
 [termTime switchTime], 'isRegEnabled', true, 'isJustCheck', false,...
 'regTol', 1e-5);  % second system comes first
firstBrsObj = secBrsObj.evolve(0, firstSys);  % then the first system

% obtain projections onto (x1, x2) subspace:
firstBpsObj = firstBrsObj.projection(basisMat);
secBpsObj = secBrsObj.projection(basisMat);

% plot the results:

plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_backward_reach_set_proj1%d',x));
% to have the use of plObj isn't necessary 
firstBpsObj.plotByEa('r', plObj); % external apprx. of backward reach set 1 (red)
% firstBpsObj.plotByEa('r');
hold on;

plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_backward_reach_set_proj2%d',x));
% to have the use of plObj isn't necessary 
firstBpsObj.plotByIa('g', plObj); % internal apprx. of backward reach set 1 (green)
% firstBpsObj.plotByIa('g');

plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_backward_reach_set_proj3%d',x));
% to have the use of plObj isn't necessary 
secBpsObj.plotByEa('y', plObj); % external apprx. of backward reach set 2 (yellow)
% secBpsObj.plotByEa('y');

plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_backward_reach_set_proj4%d',x));
% to have the use of plObj isn't necessary 
secBpsObj.plotByIa('b', plObj); % internal apprx. of backward reach set 2 (blue)
% secBpsObj.plotByIa('b');

% plot the 3-dimensional backward reach set at time t = 0:

plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_backward_reach_set_3D_1%d',x));
% to have the use of plObj isn't necessary 
firstBrsObj = firstBrsObj.cut(0);
firstBrsObj.plotByEa('r', plObj);
% firstBrsObj.plotByEa('r');
hold on;
plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc',@(x)sprintf('_backward_reach_set_3D_2%d',x));
% to have the use of plObj isn't necessary 
firstBrsObj.plotByIa('g', plObj);
% firstBrsObj.plotByIa('g');
