classdef GenEllipsoidPlotTestCase < mlunitext.test_case
    
    methods
        function self=GenEllipsoidPlotTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
            import elltool.core.GenEllipsoid;
        end
        function self = tear_down(self,varargin)
            close all;
        end

        function self = testOrdinaryPlot2d(self)
            import elltool.core.GenEllipsoid;
            qMat = [cos(pi/4), sin(pi/4); -sin(pi/4), cos(pi/4)]* ...
                [1, 0; 0, 4]*[cos(pi/4), sin(pi/4); -sin(pi/4), cos(pi/4)].';
            testEll = GenEllipsoid(qMat);
            check(testEll);

            qMat = [1, 2; 2, 5];
            testEll = GenEllipsoid(qMat);
            check(testEll);

            qMat = diag([1e-4, 1e-5]);
            testEll = GenEllipsoid(qMat);
            check(testEll);

            qMat = diag([10000, 1e-5]);
            testEll = GenEllipsoid(qMat);
            check(testEll);

            qMat = diag([3, 0.1]);
            testEll = GenEllipsoid([4, 5].', qMat);
            check(testEll);

            qMat = diag([10000, 10000]);
            testEll = GenEllipsoid(qMat);
            check(testEll);

            qMat = diag([1e-5, 4]);
            testEll = GenEllipsoid(qMat);
            check(testEll);
            
            
            qMat = diag([1e-5, 4]);
            testEllArr(1) = GenEllipsoid(qMat);
            qMat = diag([1000, 1e-3]);
            testEllArr(2) = GenEllipsoid(qMat);
            check(testEllArr);
            
            qMat = [1, 2; 2, 5];
            testEllArr(1) = GenEllipsoid(qMat);

            qMat = diag([1e-4, 1e-5]);
            testEllArr(2) = GenEllipsoid([100, 100].', qMat);

            qMat = diag([10000, 1e-5]);
            testEllArr(3) = GenEllipsoid(qMat);
            
            qMat = diag([3, 0.1]);
            testEllArr(4) = GenEllipsoid([4, 5].', qMat);
        
            qMat = diag([10000, 10000]);
            testEllArr(5) = GenEllipsoid(qMat);
          
            qMat = diag([1e-5, 4]);
            testEllArr(6) = GenEllipsoid([-10, -10].', qMat);
            check(testEllArr);
         
        end
        
        function self = testDegeneratePlot2d(self)
            import elltool.core.GenEllipsoid;
            qMat = [0, 0; 0, 4];
            testEll = GenEllipsoid(qMat);
            check(testEll);
            
            dMat = [0, 0; 0, 9];
            eMat = [cos(pi/3), -sin(pi/3); sin(pi/3), cos(pi/3)];
            testEll = GenEllipsoid([0, 0].', dMat, eMat);
            check(testEll);
            
            qMat = [0.25, 0; 0, 0];
            testEll = GenEllipsoid(qMat);
            check(testEll);
            
            dMat = [9, 0; 0, 0];
            eMat = [cos(pi/3), -sin(pi/3); sin(pi/3), cos(pi/3)];
            testEll = GenEllipsoid([0, 0].', dMat, eMat);
            check(testEll);

            qMat = [Inf, 0; 0, 4];
            testEll = GenEllipsoid([10, 7].', qMat);
            check(testEll);

            
            dMat = [Inf, 0; 0, 9];
            eMat = [cos(pi/3), -sin(pi/3); sin(pi/3), cos(pi/3)];
            testEll = GenEllipsoid([1, -5].', dMat, eMat);
            check(testEll);

            qMat = [4, 0; 0, Inf];
            testEll = GenEllipsoid([10, 7].', qMat);
            check(testEll);

            
            dMat = [9, 0; 0, Inf];
            eMat = [cos(pi/3), sin(pi/3); -sin(pi/3), cos(pi/3)];
            testEll = GenEllipsoid([1, -5].', dMat, eMat);
            check(testEll);

            
            qMat = [0, 0; 0, 4];
            testEllArr(1) = GenEllipsoid(qMat);
            
            dMat = [0, 0; 0, 9];
            eMat = [cos(pi/3), -sin(pi/3); sin(pi/3), cos(pi/3)];
            testEllArr(2) = GenEllipsoid([0, 0].', dMat, eMat);
            
            qMat = [0.25, 0; 0, 0];
            testEllArr(3) = GenEllipsoid(qMat);
            
            dMat = [9, 0; 0, 0];
            eMat = [cos(pi/3), -sin(pi/3); sin(pi/3), cos(pi/3)];
            testEllArr(4) = GenEllipsoid([0, 0].', dMat, eMat);

            qMat = [Inf, 0; 0, 4];
            testEllArr(5) = GenEllipsoid([10, 7].', qMat);

            dMat = [Inf, 0; 0, 9];
            eMat = [cos(pi/3), -sin(pi/3); sin(pi/3), cos(pi/3)];
            testEllArr(6) = GenEllipsoid([1, -5].', dMat, eMat);
          
            qMat = [4, 0; 0, Inf];
            testEllArr(7) = GenEllipsoid([10, 7].', qMat);

            dMat = [9, 0; 0, Inf];
            eMat = [cos(pi/3), sin(pi/3); -sin(pi/3), cos(pi/3)];
            testEllArr(8) = GenEllipsoid([1, -5].', dMat, eMat);
            check(testEllArr);
            
        end
    end
end

function check(testEll)

import elltool.core.GenEllipsoid;
isBound = 0;
plotObj = plot(testEll);
plotStructure = plotObj.getPlotStructure;
hPlot =  toStruct(plotStructure.figToAxesToPlotHMap);
num = hPlot.figure_g1;
[xData] = get(num.ax,'XData');
[yData] = get(num.ax,'YData');

points = [xData{:}; yData{:}];
cellPoints = num2cell(points(:, :), 1);

for iEll = 1:size(testEll, 1)
    for jEll = 1:size(testEll, 2)
        dMat = testEll(iEll, jEll).getDiagMat();
        if dMat(1, 1) == 0
            isBoundEll = check2dDimZero(testEll(iEll, jEll), cellPoints, 1);
        elseif dMat(1, 1) == Inf
            isBoundEll = check2dDimInf(testEll(iEll, jEll), cellPoints, 1);
        elseif dMat(2, 2) == 0
            isBoundEll = check2dDimZero(testEll(iEll, jEll), cellPoints, 2);
        elseif dMat(2, 2) == Inf
            isBoundEll = check2dDimInf(testEll(iEll, jEll), cellPoints, 2);
        else
            isBoundEll = check2dNorm(testEll(iEll, jEll), cellPoints);
        end
        isBound = isBound | isBoundEll;
    end
end

mlunit.assert_equals(isBound, ones(size(isBound)));
end

function isBoundEll = check2dNorm(testEll, cellPoints)  
    absTol = elltool.conf.Properties.getAbsTol();
    qCen = testEll.getCenter();
    dMat = testEll.getDiagMat();
    eigMat = testEll.getEigvMat();
    qMat = eigMat*dMat*eigMat.';
    isBoundEll = cellfun(@(x) abs(((x - qCen).'/qMat)*(x-qCen)-1)< ...
    absTol, cellPoints);
    isBoundEll = isBoundEll | cellfun(@(x) norm(x - qCen) < ...
        absTol, cellPoints);

end

function isBoundEll = check2dDimZero(testEll, cellPoints, dim)
    absTol = elltool.conf.Properties.getAbsTol();
    qCen = testEll.getCenter();
    qCen = qCen(3-dim);
    dMat = testEll.getDiagMat();
    eigMat = testEll.getEigvMat();
    secDim = @(x) x(3-dim);
    eigPoint = @(x) secDim(eigMat*(x-qCen)+qCen);
    isBoundEll = cellfun(@(x) abs(((eigPoint(x) - qCen).'/dMat(3-dim, 3-dim))*...
        (eigPoint(x) - qCen)) < 1 +  absTol, cellPoints);

end


function isBoundEll = check2dDimInf(testEll, cellPoints, dim)
    absTol = elltool.conf.Properties.getAbsTol();
    qCen = testEll.getCenter();
    dMat = testEll.getDiagMat();
    eigMat = testEll.getEigvMat();
    eigPoint = @(x) eigMat*(x-qCen) + qCen;
    secDim = @(x) x(3-dim);
    if dim == 1
        invMat = [0, 0; 0, 1/dMat(2,2)];
    else
        invMat = [1/dMat(1, 1), 0; 0, 0];
    end
    isBoundEll = cellfun(@(x) abs(((eigPoint(x) - qCen).'*invMat)*...
        (eigPoint(x) - qCen)) < 1 + absTol, cellPoints) ;
  
end

