crsObjVec = [];
for iInd = 1:size(indNonEmptyVec, 2)
    curTimeLimVec=[indNonEmptyVec(iInd)-1 nSteps];
     rsObj = elltool.reach.ReachDiscrete(secSys,...
         intersectEllVec(indNonEmptyVec(iInd)), ...
             dirsMat, curTimeLimVec,'isRegEnabled',true);
     crsObjVec = [crsObjVec rsObj];
end

copyEllMat = externalEllMat.getCopy();
basisMat = [1 0 0 0; 0 1 0 0; 0 0 1 0]';
ellObj = externalEllMat(10).projection(basisMat);
plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_before_the_guard%d',x));
% to have the use of plObj isn't necessary 
ellObj.plot('color', [0 0 1], 'newFigure', true, 'relDataPlotter', plObj);
% ellObj.plot('color', [0 0 1], 'newFigure', true);
hold on
 [hypVec, hypScal] = grdHypObj.double;
hyp = hyperplane([hypVec(1); hypVec(2); hypVec(3)], hypScal);
[centVec, ~] = double(ellObj);
hyp.plot('center', [centVec(1) 200 centVec(3)], 'color', [1 0 0], ...
    'relDataPlotter', plObj);
% hyp.plot('center', [centVec(1) 200 centVec(3)], 'color', [1 0 0]);

ellObj = externalEllMat(50).projection(basisMat);
plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_crossing_the_guard%d',x));
% to have the use of plObj isn't necessary
ellObj.plot('color', [0 0 1], 'newFigure', true, 'relDataPlotter', plObj);
% ellObj.plot('color', [0 0 1], 'newFigure', true);
hold on
hyp.plot('center', [centVec(1) 200 centVec(3)], 'color', [1 0 0], ...
    'relDataPlotter', plObj);
% hyp.plot('center', [centVec(1) 200 centVec(3)], 'color', [1 0 0]);

ellObj = externalEllMat(80).projection(basisMat);
plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_after_the_guard%d',x));
% to have the use of plObj isn't necessary
ellObj.plot('color', [0 0 1], 'newFigure', true, 'relDataPlotter', plObj);
% ellObj.plot('color', [0 0 1], 'newFigure', true);
hold on
hyp.plot('center', [centVec(1) 200 centVec(3)], 'color', [1 0 0], ...
    'relDataPlotter', plObj);
% hyp.plot('center', [centVec(1) 200 centVec(3)], 'color', [1 0 0]);


basisMat = [1 0 0 0; 0 1 0 0]';
ellObjVec = copyEllMat(1:101).projection(basisMat);
plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_all2D%d',x));
% to have the use of plObj isn't necessary
for iElem = 1:101
ellObjVec(iElem).plot('color', [0 0 1], 'fill', 1, 'relDataPlotter', plObj);
%ellObjVec.plot('color', [0 0 1], 'fill', 1);
end
hold on  
ellObj = x0EllObj.projection(basisMat);
ellObj.plot('color', [1 0 1], 'relDataPlotter', plObj);
% ellObj.plot('color', [1 0 1]);
hold on
hyp = hyperplane([hypVec(1); hypVec(2)], hypScal);
hyp.plot('center', [170 200], 'color', [1 0 0], 'relDataPlotter', plObj);       
crsexternalEllMat = crsObjVec.get_ea();
ellObjVec = crsexternalEllMat(1:83).projection(basisMat);
for iElem = 1:83
ellObjVec(iElem).plot('color', [0 1 0], 'fill', 1, 'relDataPlotter', plObj);
%ellObjVec.plot('color', [0 1 0], 'fill', 1);
end



