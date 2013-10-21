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
ellObj.plot('color', [0 0 1], 'newFigure', true);
hold on
[hypVec, hypScal] = grdHypObj.double;
hyp = hyperplane([hypVec(1); hypVec(2); hypVec(3)], hypScal);
[centVec, ~] = double(ellObj);
hyp.plot('center', [centVec(1) 200 centVec(3)], 'color', [1 0 0]);

ellObj = externalEllMat(50).projection(basisMat);
ellObj.plot('color', [0 0 1], 'newFigure', true);
hold on
hyp.plot('center', [centVec(1) 200 centVec(3)], 'color', [1 0 0]);

ellObj = externalEllMat(80).projection(basisMat);
ellObj.plot('color', [0 0 1], 'newFigure', true);
hold on
hyp.plot('center', [centVec(1) 200 centVec(3)], 'color', [1 0 0]);

figure;
basisMat = [1 0 0 0; 0 1 0 0]';
ellObjVec = copyEllMat(1:101).projection(basisMat);
ellObjVec.plot('color', [0 0 1], 'fill', 1);
hold on     
plot(x0EllObj.projection(basisMat), 'color', [1 0 1]);
hold on
hyp = hyperplane([hypVec(1); hypVec(2)], hypScal);
hyp.plot('center', [170 200], 'color', [1 0 0]);       
crsexternalEllMat = crsObjVec.get_ea();
ellObjVec = crsexternalEllMat(1:83).projection(basisMat);
ellObjVec.plot('color', [0 1 0], 'fill', 1);



