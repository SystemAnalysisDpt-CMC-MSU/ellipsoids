%%

firstSysObj = elltool.linsys.LinSysContinuous(firstAMat, firstBMat,...
    firstUBoundsEllObj);

x0EllObj = ellipsoid(inVec',eye(9));

% columns of L specify the directions
dirsMat = ...
   [1 0 0 0 0 0 0 0 0
    0 1 0 0 0 0 0 0 0
    0 0 1 0 0 0 0 0 0
    0 0 0 1 0 0 0 0 0
    0 0 0 0 1 0 0 0 0
    0 0 0 0 0 1 0 0 0
    0 0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 1 0
    0 0 0 0 0 0 0 0 1]';
firstRsObj = elltool.reach.ReachContinuous(firstSysObj, x0EllObj, dirsMat,...
    [0 switchTimeFirst], 'isRegEnabled', true, 'isJustCheck',false,...
    'regTol', 1e-5,'absTol',1e-6,'relTol',1e-7);

% solve collision with same times
secSysObj = elltool.linsys.LinSysContinuous(secAMat,...
    secBMat,secUBoundsEllObj);
if switchTimeSec == switchTimeFirst
    thRsObj = firstRsObj.evolve(maxTime, firstSysObj);
else
    secRsObj = firstRsObj.evolve(switchTimeSec, secSysObj);
    thRsObj = secRsObj.evolve(maxTime, firstSysObj);
end


basis1Mat = [1 0 0 0 0 0 0 0 0
    0 0 0 1 0 0 0 0 0]';

basis2Mat = [1 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 1 0 0]';

basis3Mat = [0 0 0 1 0 0 0 0 0
    0 0 0 0 0 0 1 0 0]';

thPs1Obj = thRsObj.projection(basis1Mat);
thPs2Obj = thRsObj.projection(basis2Mat);
thPs3Obj = thRsObj.projection(basis3Mat);

% external approximation
plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_forward_reach_set_proj%d',x));
thPs1Obj.plotByEa('r',plObj);

%%
