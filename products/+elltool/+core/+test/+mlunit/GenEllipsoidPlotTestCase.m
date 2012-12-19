classdef GenEllipsoidPlotTestCase < mlunitext.test_case
    
    methods
        function self=GenEllipsoidPlotTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
            import elltool.core.GenEllipsoid;
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testNewAxis(self)
            import elltool.core.GenEllipsoid;
            
            testEll = GenEllipsoid(eye(2));
            checkNewAxis(testEll);
            
            testEllArr = [GenEllipsoid(eye(2)), GenEllipsoid([1, 0].', eye(2))];
            checkNewAxis(testEllArr);
            
            testFirEll = GenEllipsoid(eye(3));
            testSecEll = GenEllipsoid([1, 0, 0].', eye(3));
            testEllArr = [testFirEll, testSecEll; testFirEll, testSecEll];
            checkNewAxis(testEllArr);
            
            for iEll = 1:2
                for jEll = 1:2
                    testEllArr(iEll, jEll, 1) = testFirEll;
                    testEllArr(iEll, jEll, 2) = testSecEll;
                end
            end
            checkNewAxis(testEllArr);
            
            function checkNewAxis(testEllArr)
                axesSubPlHandle = subplot(3,2,2);
                plotObj = plot(testEllArr);
                SHPlot =  plotObj.getPlotStructure().figToAxesToHMap.toStruct();
                SAxes = SHPlot.figure_g1;
                axesHandle = SAxes.ax;
                mlunit.assert_equals(axesHandle, axesSubPlHandle);
                
            end
        end
        
        function self = testHoldOn(self)
            import elltool.core.GenEllipsoid;
            plot(1:10,sin(1:10));
            hold on;
            testEll = GenEllipsoid(eye(2));
            plotObj = plot(testEll);
            SHPlot =  plotObj.getPlotStructure().figToAxesToHMap.toStruct();
            SAxes = SHPlot.figure_g1;
            plotFig = get(SAxes.ax, 'Children');
            mlunit.assert_equals(numel(plotFig), 3);
            
            hold off;
            plot(1:10,sin(1:10));
            plotObj = plot(testEll);
            SHPlot =  plotObj.getPlotStructure().figToAxesToHMap.toStruct();
            SAxes = SHPlot.figure_g1;
            plotFig = get(SAxes.ax, 'Children');
            mlunit.assert_equals(numel(plotFig), 2);

        end
        
        function self = testOrdinaryPlot2d(self)
            import elltool.core.GenEllipsoid;
            nDims = 2;
            inpArgCList = {[cos(pi/4), sin(pi/4); -sin(pi/4), cos(pi/4)]* ...
                [1, 0; 0, 4]*[cos(pi/4), sin(pi/4); -sin(pi/4), cos(pi/4)].', ...
                [1, 2; 2, 5], diag([10000, 1e-5]), diag([3, 0.1]), diag([10000, 10000]), ...
                diag([1e-5, 4])};
            inpCenCList = {[0, 0].', [100, 100].', [0, 0].', [4, 5].', [0, 0].', [-10, -10].'};
            nElem = numel(inpArgCList);
            for iElem = 1:nElem
                testEll=GenEllipsoid(inpCenCList{iElem}, inpArgCList{iElem});
                check(testEll, nDims);
            end
            
            testEllArr(1) = GenEllipsoid(inpCenCList{1}, inpArgCList{1});
            testEllArr(2) = GenEllipsoid(inpCenCList{2}, inpArgCList{2});
            check(testEllArr, nDims);
            
            for iElem = 1:nElem
                testEllArr(iElem) = GenEllipsoid(inpCenCList{iElem}, inpArgCList{iElem});
            end
            check(testEllArr, nDims);
            
        end
        
        function self = testDegeneratePlot2d(self)
            import elltool.core.GenEllipsoid;
            nDims = 2;
            inpArgCList = {[0, 0; 0, 4], [0, 0; 0, 9], [0.25, 0; 0, 0], ...
                [9, 0; 0, 0], [Inf, 0; 0, 4], [4, 0; 0, Inf], [9, 0; 0, Inf]};
            inpRotCList = {eye(2), [cos(pi/3), -sin(pi/3); sin(pi/3), cos(pi/3)], ...
                eye(2), [cos(pi/3), -sin(pi/3); sin(pi/3), cos(pi/3)], ...
                eye(2), [cos(pi/3), -sin(pi/3); sin(pi/3), cos(pi/3)], ...
                eye(2), [cos(pi/3), sin(pi/3); -sin(pi/3), cos(pi/3)]};
            inpCenCList = {[0, 0].', [0, 0].', [0, 0].', [10, 7].', ...
                [1, -5].', [10, 7].', [1, -5].'};
            nElem = numel(inpCenCList);
            for iElem = 1:nElem
                testEll=GenEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem});
                check(testEll, nDims);
            end
            
            for iElem = 1:nElem
                testEllArr(iElem)=GenEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem});
            end
            check(testEllArr, nDims);
            
        end
        
        function self = testOrdinaryPlot3d(self)
            import elltool.core.GenEllipsoid;
            nDims = 3;
            inpArgCList = {eye(3), diag([2, 1, 0.1]), diag([3, 1, 1]), ...
                diag([0.1, 0.1, 0.01]), diag([1, 100, 0.1])};
            inpCenCList = {[0, 0, 0].', [1, 10, -1].', [0, 0, 0].', ...
                [1, 1, 0].', [10, -10, 10].'};
            inpRotCList = {eye(3), [1, 0, 0; 0, cos(pi/3), -sin(pi/3); 0, sin(pi/3), cos(pi/3)], ...
                eye(3), [cos(pi/3), 0, -sin(pi/3); 0, 1, 0; sin(pi/3), 0, cos(pi/3)], ...
                eye(3), [cos(pi/3), -sin(pi/3), 0; sin(pi/3), cos(pi/3), 0; 0, 0, 1], ...
                eye(3)};
            nElem = numel(inpArgCList);
            for iElem = 1:nElem
                testEll=GenEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem});
                check(testEll, nDims);
            end
            
            for iElem = 1:nElem
                testEllArr(iElem)=GenEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem});
            end
            check(testEllArr, nDims);
        end
        
        function self = testDegeneratePlot3d(self)
            import elltool.core.GenEllipsoid;
            nDims = 3;
            inpArgCList = {diag([Inf, 1, 1]), diag([0.25, Inf, 3]), diag([0, 5, Inf]), ...
                diag([Inf, 4, 0.5]), diag([Inf, Inf, 1]), diag([Inf, 4, Inf]), diag([3, Inf, Inf]), ...
                diag([0, 1, 1]), diag([1.1, 0, 4]), diag([3, 1, 0]), diag([1, Inf, 0]), ...
                diag([Inf, 1, 0]), diag([0, Inf, 3]), diag([0, 3, Inf]), diag([0.01, Inf, 1])};
            inpCenCList = {[1, 0, 0].', [0, 0, 1].', [0, 0, 0].', [1, 1, 1].', [1, 1, 0].', ...
                [-1, 1, 0].', [-1, -1, 0].', [0, 0, -1].', [0, -1, 1].', [1, 1, 0].', [-1, 1, 0].', ...
                [0, 0, 0].', [0, 0, 0].', [1, 0, 0].', [-1, 1, -1].'};
            inpRotCList = {eye(3), [1, 0, 0; 0, cos(pi/3), -sin(pi/3); 0, sin(pi/3), cos(pi/3)], ...
                eye(3), [cos(pi/3), 0, -sin(pi/3); 0, 1, 0; sin(pi/3), 0, cos(pi/3)], ...
                eye(3), [cos(pi/3), -sin(pi/3), 0; sin(pi/3), cos(pi/3), 0; 0, 0, 1], ...
                eye(3), eye(3), [cos(pi/6), -sin(pi/6), 0; sin(pi/6), cos(pi/6), 0; 0, 0, 1], ...
                [1, 0, 0; 0, cos(pi/4), -sin(pi/4); 0, sin(pi/4), cos(pi/4)], ... 
                [cos(pi/4), 0, sin(pi/4); 0, 1, 0; -sin(pi/4), 0, cos(pi/4)], eye(3), ...
                eye(3),  [cos(pi/3), 0, -sin(pi/3); 0, 1, 0; sin(pi/3), 0, cos(pi/3)], ...
                [cos(pi/3), -sin(pi/3), 0; sin(pi/3), cos(pi/3), 0; 0, 0, 1]};
            nElem = numel(inpArgCList);
            for iElem = 1:nElem
                testEll=GenEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem});
                check(testEll, nDims);
            end
            
            for iElem = 1:5
                testEllArr(iElem)=GenEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem});
            end
            check(testEllArr, nDims);
      
            for iElem = 1:nElem
                testEllArr(iElem)=GenEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem});
            end
            check(testEllArr, nDims);
        end
    end
end

function check(testEllArr, nDims)

import elltool.core.GenEllipsoid;
isBoundVec = 0;
plotObj = plot(testEllArr);
SPlotStructure = plotObj.getPlotStructure;
SHPlot =  toStruct(SPlotStructure.figToAxesToPlotHMap);
num = SHPlot.figure_g1;

[xDataCell, yDataCell, zDataCell] = arrayfun(@(x) getData(num.ax(x)), 1:numel(num.ax), 'UniformOutput', false);
if iscell(xDataCell)
    xDataArr = xDataCell{:};
else
    xDataArr = xDataCell;
end
if iscell(yDataCell)
    yDataArr = yDataCell{:};
else
    yDataArr = yDataCell;
end

if nDims == 3
    if iscell(zDataCell)
        zDataArr = zDataCell{:};
    else
        zDataArr = zDataCell;
    end
    nPoints = numel(xDataArr);
    xDataVec = reshape(xDataArr, 1, nPoints);
    yDataVec = reshape(yDataArr, 1, nPoints);
    zDataVec = reshape(zDataArr, 1, nPoints);
    pointsMat = [xDataVec; yDataVec; zDataVec];
else
    pointsMat = [xDataArr; yDataArr];
end

cellPoints = num2cell(pointsMat(:, :), 1);

testEllVec = reshape(testEllArr, 1, numel(testEllArr));
nEll = numel(testEllVec);
for iEll = 1:nEll
        dMat = testEllVec(iEll).getDiagMat();
        if nDims == 2
            if dMat(1, 1) == 0
                isBoundEllVec = check2dDimZero(testEllVec(iEll), cellPoints, 1);
            elseif dMat(2, 2) == 0
                isBoundEllVec = check2dDimZero(testEllVec(iEll), cellPoints, 2);
                
            elseif max(dMat(:)) == Inf
                isBoundEllVec = checkDimInf(testEllVec(iEll), cellPoints);
            else
                isBoundEllVec = checkNorm(testEllVec(iEll), cellPoints);
            end
        elseif nDims == 3
            if dMat(1, 1) == 0
                 isBoundEllVec = check3dDimZero(testEllVec(iEll), cellPoints, 1);
            elseif dMat(2, 2) == 0
                 isBoundEllVec = check3dDimZero(testEllVec(iEll), cellPoints, 2);
            elseif dMat(3, 3) == 0
                 isBoundEllVec = check3dDimZero(testEllVec(iEll), cellPoints, 3);
            elseif max(dMat(:)) == Inf
                isBoundEllVec = checkDimInf(testEllVec(iEll), cellPoints);
            else
                isBoundEllVec = checkNorm(testEllVec(iEll), cellPoints);
            end
        end
        isBoundVec = isBoundVec | isBoundEllVec;
end

mlunit.assert_equals(isBoundVec, ones(size(isBoundVec)));

    function [outXData, outYData, outZData] = getData(hObj)
        objType = get(hObj, 'type');
        if strcmp(objType, 'patch')
            outXData = get(hObj, 'XData');
            outYData = get(hObj, 'YData');
            outZData = get(hObj, 'ZData');
        else
            outXData = [];
            outYData = [];
            outZData = [];
        end
    end
end



function isBoundEllVec = checkNorm(testEll, cellPoints)
absTol = elltool.conf.Properties.getAbsTol();
qCenVec = testEll.getCenter();
dMat = testEll.getDiagMat();
eigMat = testEll.getEigvMat();
qMat = eigMat.'*dMat*eigMat;
isBoundEllVec = cellfun(@(x) abs(((x - qCenVec).'/qMat)*(x-qCenVec)-1)< ...
    absTol, cellPoints);
isBoundEllVec = isBoundEllVec | cellfun(@(x) norm(x - qCenVec) < ...
    absTol, cellPoints);

end



function isBoundEllVec = check2dDimZero(testEll, cellPoints, dim)
absTol = elltool.conf.Properties.getAbsTol();
qCenVec = testEll.getCenter();
dMat = testEll.getDiagMat();
eigMat = testEll.getEigvMat();
secDim = @(x) x(3-dim);
eigPoint = @(x) secDim(eigMat*(x-qCenVec)+qCenVec);
qCenVec = qCenVec(3-dim);
isBoundEllVec = cellfun(@(x) abs(((eigPoint(x) - qCenVec).'/dMat(3-dim, 3-dim))*...
    (eigPoint(x) - qCenVec)) < 1 +  absTol, cellPoints);

end

function isBoundEllVec = check3dDimZero(testEll, cellPoints, dim)
absTol = elltool.conf.Properties.getAbsTol();
qCenVec = testEll.getCenter();
dMat = testEll.getDiagMat();
eigMat = testEll.getEigvMat();
if dim == 1
    secDim = @(x) [x(2), x(3)].';
    invMat = diag([1/dMat(2,2), 1/dMat(3,3)]);
elseif dim == 2
    secDim = @(x) [x(1), x(3)].';
    invMat = diag([1/dMat(1,1), 1/dMat(3,3)]);
else
    secDim = @(x) [x(1), x(2)].';
    invMat = diag([1/dMat(1,1), 1/dMat(2,2)]);
end
eigPoint = @(x) secDim(eigMat*(x-qCenVec)+qCenVec);
qCenVec = secDim(qCenVec);
isBoundEllVec = cellfun(@(x) abs(((eigPoint(x) - qCenVec).'*invMat)*...
    (eigPoint(x) - qCenVec)) < 1 +  absTol, cellPoints);

end


function isBoundEllVec = checkDimInf(testEll, cellPoints)
absTol = elltool.conf.Properties.getAbsTol();
qCenVec = testEll.getCenter();
dMat = testEll.getDiagMat();
eigMat = testEll.getEigvMat();
eigPoint = @(x) eigMat*(x-qCenVec) + qCenVec;
invMat = diag(1./diag(dMat));
isBoundEllVec = cellfun(@(x) abs(((eigPoint(x) - qCenVec).'*invMat)*...
    (eigPoint(x) - qCenVec)) < 1 + absTol, cellPoints) ;

end