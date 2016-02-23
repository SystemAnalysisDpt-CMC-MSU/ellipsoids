% define disturbance:
gMat = [0 0; 0 0; 1 0; 0 1];
vEllObj = 0.05*ell_unitball(2);
% linear system with disturbance
lsysd = elltool.linsys.LinSysContinuous(aMat, bMat, uBoundsEllObj,...
    gMat, vEllObj); 
% reach set
rsdObj = elltool.reach.ReachContinuous(lsysd, x0EllObj, dirsMat,...
    timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 0.12,...
    'absTol',1e-5,'relTol',1e-4); 
psdObj = rsdObj.projection(basisMat);  % reach set projection onto (x1, x2)
% plot projection of reach set external approximation:

plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_tube_with_disturbance%d',x));

% plot the whole reach tube:
psdObj.plotByEa(plObj); % to have the use of plObj isn't necessary 
%psObj.plotByEa();

% plot reach set approximation at time t = 4:
psdCutObj = psdObj.cut(4);

plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_set_with_disturbance%d',x));
psdCutObj.plotByEa(plObj);  % to have the use of plObj isn't necessary 
%psdCutObj.plotByEa();