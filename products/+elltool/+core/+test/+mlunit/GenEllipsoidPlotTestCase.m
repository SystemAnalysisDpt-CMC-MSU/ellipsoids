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
            subplot(3,2,2);
            testEll = GenEllipsoid(eye(2));
            plot(testEll);
        end
        
        function self = testHoldOn(self)
            import elltool.core.GenEllipsoid;
            plot(1:10,sin(1:10));
            hold on;
            testEll = GenEllipsoid(eye(2));
            plot(testEll);
            
            hold off;
            plot(1:10,sin(1:10));
            plot(testEll);
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

function check(testEll, nDims)

import elltool.core.GenEllipsoid;
isBound = 0;
plotObj = plot(testEll);
plotStructure = plotObj.getPlotStructure;
hPlot =  toStruct(plotStructure.figToAxesToPlotHMap);
num = hPlot.figure_g1;
[xData] = get(num.ax,'XData');
[yData] = get(num.ax,'YData');
if iscell(xData)
    xData = xData{:};
end
if iscell(yData)
    yData = yData{:};
end

if nDims == 3
    [zData] = get(num.ax,'ZData');
    if iscell(zData)
        zData = zData{:};
    end
    xData = reshape(xData, 1, numel(xData));
    yData = reshape(yData, 1, numel(yData));
    zData = reshape(zData, 1, numel(zData));
    points = [xData; yData; zData];
else
    points = [xData; yData];
end

cellPoints = num2cell(points(:, :), 1);
for iEll = 1:size(testEll, 1)
    for jEll = 1:size(testEll, 2)
        dMat = testEll(iEll, jEll).getDiagMat();
        if nDims == 2
            if dMat(1, 1) == 0
                isBoundEll = check2dDimZero(testEll(iEll, jEll), cellPoints, 1);
            elseif dMat(2, 2) == 0
                isBoundEll = check2dDimZero(testEll(iEll, jEll), cellPoints, 2);
                
            elseif max(dMat(:)) == Inf
                isBoundEll = checkDimInf(testEll(iEll, jEll), cellPoints);
            else
                isBoundEll = checkNorm(testEll(iEll, jEll), cellPoints);
            end
        elseif nDims == 3
            if dMat(1, 1) == 0
                 isBoundEll = check3dDimZero(testEll(iEll, jEll), cellPoints, 1);
            elseif dMat(2, 2) == 0
                 isBoundEll = check3dDimZero(testEll(iEll, jEll), cellPoints, 2);
            elseif dMat(3, 3) == 0
                 isBoundEll = check3dDimZero(testEll(iEll, jEll), cellPoints, 3);
            elseif max(dMat(:)) == Inf
                isBoundEll = checkDimInf(testEll(iEll, jEll), cellPoints);
            else
                isBoundEll = checkNorm(testEll(iEll, jEll), cellPoints);
            end
        end
        isBound = isBound | isBoundEll;
    end
end

mlunit.assert_equals(isBound, ones(size(isBound)));
end



function isBoundEll = checkNorm(testEll, cellPoints)
absTol = elltool.conf.Properties.getAbsTol();
qCen = testEll.getCenter();
dMat = testEll.getDiagMat();
eigMat = testEll.getEigvMat();
qMat = eigMat.'*dMat*eigMat;
isBoundEll = cellfun(@(x) abs(((x - qCen).'/qMat)*(x-qCen)-1)< ...
    absTol, cellPoints);
isBoundEll = isBoundEll | cellfun(@(x) norm(x - qCen) < ...
    absTol, cellPoints);

end



function isBoundEll = check2dDimZero(testEll, cellPoints, dim)
absTol = elltool.conf.Properties.getAbsTol();
qCen = testEll.getCenter();
dMat = testEll.getDiagMat();
eigMat = testEll.getEigvMat();
secDim = @(x) x(3-dim);
eigPoint = @(x) secDim(eigMat*(x-qCen)+qCen);
qCen = qCen(3-dim);
isBoundEll = cellfun(@(x) abs(((eigPoint(x) - qCen).'/dMat(3-dim, 3-dim))*...
    (eigPoint(x) - qCen)) < 1 +  absTol, cellPoints);

end

function isBoundEll = check3dDimZero(testEll, cellPoints, dim)
absTol = elltool.conf.Properties.getAbsTol();
qCen = testEll.getCenter();
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
eigPoint = @(x) secDim(eigMat*(x-qCen)+qCen);
qCen = secDim(qCen);
isBoundEll = cellfun(@(x) abs(((eigPoint(x) - qCen).'*invMat)*...
    (eigPoint(x) - qCen)) < 1 +  absTol, cellPoints);

end


function isBoundEll = checkDimInf(testEll, cellPoints)
absTol = elltool.conf.Properties.getAbsTol();
qCen = testEll.getCenter();
dMat = testEll.getDiagMat();
eigMat = testEll.getEigvMat();
eigPoint = @(x) eigMat*(x-qCen) + qCen;
invMat = inv(dMat);
isBoundEll = cellfun(@(x) abs(((eigPoint(x) - qCen).'*invMat)*...
    (eigPoint(x) - qCen)) < 1 + absTol, cellPoints) ;

end