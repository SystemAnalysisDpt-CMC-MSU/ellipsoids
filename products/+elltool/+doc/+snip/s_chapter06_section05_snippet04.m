% Question 1
%can there be a collision e_i \leq 0
grdHyp1Obj = hyperplane([1 0 0]', e1);
grdHyp2Obj = hyperplane([0 1 0]', e2);
grdHyp3Obj = hyperplane([0 0 1]', e3);

basis0Mat = [...
    1 0 0 0 0 0 0 0 0
    0 0 0 1 0 0 0 0 0
    0 0 0 0 0 0 1 0 0]';

[externalEllMat, timeVec] = thRsObj.get_ea();
[externalNEllMat,externalMEllMat] = size(externalEllMat);

iElem = 0;
resEllNomObj = -1;
globalMax = -inf;
platoonDist = -inf;
%check the intersection with hyperplanes

while  (iElem < externalMEllMat)
    iElem = iElem + 1;
    ellVec = externalEllMat(:,iElem);
    resEllObj = ellintersection_ia(ellVec);
    resEllObj = resEllObj.projection(basis0Mat);
    [bpMat,fMat,supVec,lGridMat] = resEllObj.getRhoBoundary();
    %find max(sum(e_i))
    if max(sum(bpMat,2)) > platoonDist
        platoonDist = max(sum(bpMat,2));
        platoonDistNumber = iElem;
    end
    %find max(e_i)
    if max(bpMat(:))> globalMax
        globalMax = max(bpMat(:));
        globalMaxNum = iElem;
    end
    if (resEllNomObj == -1)
        intersectEll1Vec = resEllObj.hpintersection(grdHyp1Obj);
        intersectEll2Vec = resEllObj.hpintersection(grdHyp2Obj);
        intersectEll3Vec = resEllObj.hpintersection(grdHyp3Obj);
    end
    if (~isEmpty(intersectEll1Vec) || ~isEmpty(intersectEll2Vec) || ...
            ~isEmpty(intersectEll3Vec)) && (resEllNomObj == -1)          
        resEllNomObj = iElem;
        resEllAnsFirstObj = resEllObj;
    end
    if (~isEmpty(intersectEll1Vec) || ~isEmpty(intersectEll2Vec) || ...
            ~isEmpty(intersectEll3Vec))
        resEllNomObj = iElem;
        resEllAnsLastObj = resEllObj;
    end    
end

%If there are no intersections with hyperplanes
if resEllNomObj == -1
    disp(['There are no intersections, '...
        'we derive the result for a finite time']);
    resEllAnsObj = resEllObj;
else
    %choose and change to build   
    resEllAnsObj =  resEllAnsFirstObj;
end


plObj=smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_before_the_guard1%d',x));
resEllAnsObj.plot('color', [0 0 1], 'newFigure', true, 'relDataPlotter',...
    plObj);

hold on;
[hypVec, hypScal] = grdHyp1Obj.double;
hypObj = hyperplane([hypVec(1); hypVec(2);hypVec(3)], hypScal);
[centVec, ~] = double(resEllAnsObj);
hypObj.plot('center', [e1 centVec(2) centVec(3)], 'color', [1 0 0]);

hold on;
[hypVec, hypScal] = grdHyp2Obj.double;
hyp2Obj = hyperplane([hypVec(1); hypVec(2);hypVec(3)], hypScal);
[centVec, ~] = double(resEllAnsObj);
hyp2Obj.plot('center', [ centVec(1) e2 centVec(3)], 'color', [1 0 0]);

hold on;
[hypVec, hypScal] = grdHyp3Obj.double;
hyp3Obj = hyperplane([hypVec(1); hypVec(2);hypVec(3)], hypScal);
[centVec, ~] = double(resEllAnsObj);
hyp3Obj.plot('center', [centVec(1) centVec(2) e3], 'color', [1 0 0]);