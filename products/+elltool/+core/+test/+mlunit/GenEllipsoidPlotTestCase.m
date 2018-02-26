classdef GenEllipsoidPlotTestCase < elltool.plot.test.AGeomBodyPlotTestCase
    properties (Access=private)
        ellFactoryObj;
    end
    %
    methods
        function set_up_param(self)
            self.ellFactoryObj = elltool.core.test.mlunit.TEllipsoidFactory();
        end
    end
    methods
        function ellObj = genEllipsoid(self, varargin)
            ellObj = self.ellFactoryObj.createInstance('GenEllipsoid', ...
                varargin{:});
        end
    end
    %
    methods(Access=protected)
        function [plObj,numObj] = getInstance(self, varargin)
            import elltool.core.GenEllipsoid;
            if numel(varargin)==1
                plObj = self.genEllipsoid(varargin{1});
                if size(varargin{1},1) == 2
                    numObj = 2;
                else
                    numObj = 4;
                end
            else
                plObj = self.genEllipsoid(varargin{1},varargin{2});
                if size(varargin{2},1) == 2
                    numObj = 2;
                else
                    numObj = 4;
                end
            end
        end
    end
    methods
        function self=GenEllipsoidPlotTestCase(varargin)

            self=self@elltool.plot.test.AGeomBodyPlotTestCase(varargin{:});
            import elltool.core.GenEllipsoid;
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testPlot1d(self)
            import elltool.core.GenEllipsoid;
            nDims = 1;
            inpArgCList = {1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 0};
            inpCenCList = {1, 2, 3, 4, 5, -5, -4, -3, -2, -1, 0};
            nElem = numel(inpArgCList);
            for iElem = 1:nElem
                testEll=self.genEllipsoid(inpCenCList{iElem}, inpArgCList{iElem});
                check(testEll, nDims);
            end
            testEllArr(1) = self.genEllipsoid(inpCenCList{1}, inpArgCList{1});
            testEllArr(2) = self.genEllipsoid(inpCenCList{2}, inpArgCList{2});
            testEllArr(3) = self.genEllipsoid(inpCenCList{3}, inpArgCList{3});
            check(testEllArr, nDims);

        end
        function self = testOrdinaryPlot2d(self)
            import elltool.core.GenEllipsoid;
            nDims = 2;
            inpArgCList = {[cos(pi/4), sin(pi/4); -sin(pi/4), cos(pi/4)]* ...
                [1, 0; 0, 4]*[cos(pi/4), sin(pi/4); -sin(pi/4), cos(pi/4)].', ...
                [1, 2; 2, 5], diag([10000, 1e-5]), diag([3, 0.1]), ...
                diag([10000, 10000]), diag([1e-5, 4])};
            inpCenCList = {[0, 0].', [100, 100].', [0, 0].', [4, 5].', ...
                [0, 0].', [-10, -10].'};
            nElem = numel(inpArgCList);
            for iElem = 1:nElem
                testEll=self.genEllipsoid(inpCenCList{iElem}, inpArgCList{iElem});
                check(testEll, nDims);
            end

            testEllArr(1) = self.genEllipsoid(inpCenCList{1}, inpArgCList{1});
            testEllArr(2) = self.genEllipsoid(inpCenCList{2}, inpArgCList{2});
            check(testEllArr, nDims);

            for iElem = 1:nElem
                testEllArr(iElem) = self.genEllipsoid(inpCenCList{iElem},...
                    inpArgCList{iElem});
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
                testEll=self.genEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem});
                check(testEll, nDims);
            end

            for iElem = 1:nElem
                testEllArr(iElem)=self.genEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem}); %#ok<AGROW>
            end
            check(testEllArr, nDims);

        end

        function self = testOrdinaryPlot3d(self)
            import elltool.core.GenEllipsoid;
            nDims = 3;
            inpArgCList = {eye(3), diag([2, 1, 0.1]), diag([3, 1, 1]), ...
                diag([0.1, 0.1, 0.01]), diag([1, 100, 0.1]),[0 0 0;0 1 0; 0 0 1]};
            inpCenCList = {[0, 0, 0].', [1, 10, -1].', [0, 0, 0].', ...
                [1, 1, 0].', [10, -10, 10].',[0 0 0]'};
            inpRotCList = {eye(3), [1, 0, 0; 0, cos(pi/3), -sin(pi/3); 0, sin(pi/3), cos(pi/3)], ...
               [cos(pi/3), 0, -sin(pi/3); 0, 1, 0; sin(pi/3), 0, cos(pi/3)], ...
               [cos(pi/3), -sin(pi/3), 0; sin(pi/3), cos(pi/3), 0; 0, 0, 1], ...
                eye(3),[0 0 1;0 1 0; 1 0 0]};
            nElem = numel(inpArgCList);
            for iElem = 1:nElem
                testEll=self.genEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem});
                check(testEll, nDims);
            end

            for iElem = 1:nElem
                testEllArr(iElem)=self.genEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem}); %#ok<AGROW>
            end
            check(testEllArr, nDims);
        end

        function self = testDegeneratePlot3d(self)
            import elltool.core.GenEllipsoid;
            nDims = 3;
            inpArgCList = {diag([Inf, 1, 1]), diag([0.25, Inf, 3]),...
                diag([0, 5, Inf]), ...
                diag([Inf, 4, 0.5]), diag([Inf, Inf, 1]), diag([Inf, 4, Inf]),...
                diag([3, Inf, Inf]), ...
                diag([0, 1, 1]), diag([1.1, 0, 4]), diag([3, 1, 0]), ...
                diag([1, Inf, 0]), ...
                diag([Inf, 1, 0]), diag([0, Inf, 3]), diag([0, 3, Inf]),...
                diag([0.01, Inf, 1])};
            inpCenCList = {[1, 0, 0].', [0, 0, 1].', ...
                [0, 0, 0].', [1, 1, 1].', [1, 1, 0].', ...
                [-1, 1, 0].', [-1, -1, 0].', [0, 0, -1].', [0, -1, 1].', ...
                [1, 1, 0].', [-1, 1, 0].', ...
                [0, 0, 0].', [0, 0, 0].', [1, 0, 0].', [-1, 1, -1].'};
            inpRotCList = {eye(3), [1, 0, 0; 0, cos(pi/3), -sin(pi/3); 0, ...
                sin(pi/3), cos(pi/3)], ...
                eye(3), [cos(pi/3), 0, -sin(pi/3); 0, 1, 0; ...
                sin(pi/3), 0, cos(pi/3)], ...
                eye(3), [cos(pi/3), -sin(pi/3), 0; sin(pi/3), ...
                cos(pi/3), 0; 0, 0, 1], ...
                eye(3), eye(3), [cos(pi/6), -sin(pi/6), 0;...
                sin(pi/6), cos(pi/6), 0; 0, 0, 1], ...
                [1, 0, 0; 0, cos(pi/4), -sin(pi/4);...
                0, sin(pi/4), cos(pi/4)], ...
                [cos(pi/4), 0, sin(pi/4); 0, 1, 0; ...
                -sin(pi/4), 0, cos(pi/4)], eye(3), ...
                eye(3),  [cos(pi/3), 0, -sin(pi/3); ...
                0, 1, 0; sin(pi/3), 0, cos(pi/3)], ...
                [cos(pi/3), -sin(pi/3), 0;...
                sin(pi/3), cos(pi/3), 0; 0, 0, 1]};
            nElem = numel(inpArgCList);
            for iElem = 1:nElem
                testEll=self.genEllipsoid(inpCenCList{iElem}, inpArgCList{iElem}, ...
                    inpRotCList{iElem});
                check(testEll, nDims);
            end

            for iElem = 1:5
                testEllArr(iElem)=self.genEllipsoid(inpCenCList{iElem}, ...
                    inpArgCList{iElem}, inpRotCList{iElem}); %#ok<AGROW>
            end
            check(testEllArr, nDims);

            for iElem = 1:nElem
                testEllArr(iElem)=self.genEllipsoid(inpCenCList{iElem}, ...
                    inpArgCList{iElem}, inpRotCList{iElem});
            end
            check(testEllArr, nDims);
        end
        function testPlot2d3d(~)
            import elltool.core.GenEllipsoid;
            ellV = [GenEllipsoid(eye(2)), GenEllipsoid(eye(3)),... 
                    GenEllipsoid(eye(2).*2), GenEllipsoid(eye(3).*2)];
            check(ellV, 0);
        end
        function testGraphObjType(~)
            import elltool.plot.GraphObjTypeEnum;
            import elltool.plot.common.AxesNames;
            import elltool.core.GenEllipsoid;
            ellV = [GenEllipsoid(eye(2)), GenEllipsoid(eye(3))];
            rdp = plot(ellV);
            axesStruct = rdp.getPlotStructure().figToAxesToHMap.toStruct();
            ell2DPatchV = axesStruct.figure_g1.(AxesNames.AXES_2D_KEY).Children;
            ell3DPatchV = axesStruct.figure_g1.(AxesNames.AXES_3D_KEY).Children;
            mlunitext.assert_equals(GraphObjTypeEnum.EllCenter2D,...
                                    ell2DPatchV(1).UserData.graphObjType);
            mlunitext.assert_equals(GraphObjTypeEnum.EllBoundary2D,...
                                    ell2DPatchV(2).UserData.graphObjType);
            mlunitext.assert_equals(GraphObjTypeEnum.EllBoundary3D,...
                                    ell3DPatchV(4).UserData.graphObjType);
        end
    end
end

function check(testEllArr, nDims)
import elltool.core.GenEllipsoid;
plotObj = plot(testEllArr);
SPlotStructure = plotObj.getPlotStructure;
SHPlot =  toStruct(SPlotStructure.figToAxesToPlotHMap);
num = SHPlot.figure_g1;
checkAxesLabels(plotObj);
if nDims == 0
    dimVec = dimension(testEllArr);
    check_inner(testEllArr(dimVec >= 3),num,3);
    check_inner(testEllArr(dimVec <= 2),num,2);
else
    check_inner(testEllArr, num, nDims);
end
    function checkAxesLabels(plObj)
        SFigure = plObj.getPlotStructure.figHMap.toStruct();
        children = SFigure.figure_g1.Children;
        for i=1:size(children,1);
            mlunitext.assert_equals('x_1',...
                                    children(i).XLabel.String);
            mlunitext.assert_equals('x_2',...
                                    children(i).YLabel.String);
            mlunitext.assert_equals('x_3',...
                                    children(i).ZLabel.String);
        end
    end
end

function check_inner(testEllArr, num, nDims)
import elltool.core.GenEllipsoid;
import elltool.plot.common.AxesNames;
isBoundVec = 0;
if nDims >= 3
    [xDataCell, yDataCell, zDataCell] = arrayfun(...
        @(x) getData(num.(AxesNames.AXES_3D_KEY)(x)), ...
        1:numel(num.(AxesNames.AXES_3D_KEY)), 'UniformOutput', false);
else
    [xDataCell, yDataCell, zDataCell] = arrayfun(...
        @(x) getData(num.(AxesNames.AXES_2D_KEY)(x)), ...
        1:numel(num.(AxesNames.AXES_2D_KEY)), 'UniformOutput', false);    
end
if iscell(xDataCell)
    xDataArr = horzcat(xDataCell{:});
else
    xDataArr = xDataCell;
end
if iscell(yDataCell)
    yDataArr =  horzcat(yDataCell{:});
else
    yDataArr = yDataCell;
end

if nDims == 3
    if iscell(zDataCell)
        zDataArr = horzcat(zDataCell{:});
    else
        zDataArr = zDataCell;
    end
    nPoints = numel(xDataArr);
    xDataVec = reshape(xDataArr, 1, nPoints);
    yDataVec = reshape(yDataArr, 1, nPoints);
    zDataVec = reshape(zDataArr, 1, nPoints);
    pointsMat = [xDataVec; yDataVec; zDataVec];
elseif nDims == 2
    pointsMat = [xDataArr; yDataArr];
else
    pointsMat = xDataArr;
end
cellPoints = num2cell(pointsMat(:, :), 1);

testEllVec = reshape(testEllArr, 1, numel(testEllArr));
nEll = numel(testEllVec);
for iEll = 1:nEll
    dMat = testEllVec(iEll).getDiagMat();
    if nDims == 1
        isBoundEllVec = check1d(testEllVec(iEll), cellPoints);
    elseif nDims == 2
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

mlunitext.assert_equals(isBoundVec, ones(size(isBoundVec)));

    function [outXData, outYData, outZData] = getData(hObj)
        objType = get(hObj, 'type');
        if strcmp(objType, 'patch') || strcmp(objType, 'line')
            outXData = get(hObj, 'XData');
            outYData = get(hObj, 'YData');
            outZData = get(hObj, 'ZData');
            outXData = outXData(:)';
            outYData = outYData(:)';
            outZData = outZData(:)';
        else
            outXData = [];
            outYData = [];
            outZData = [];
        end
    end
    function isBoundEllVec = checkNorm(testEll, cellPoints)
        absTol = elltool.conf.Properties.getAbsTol();
        qCenVec = testEll.getCenterVec();
        dMat = testEll.getDiagMat();
        eigMat = testEll.getEigvMat();
        qMat = eigMat.'*dMat*eigMat;
        isBoundEllVec = cellfun(@(x) abs(((x - qCenVec).'/qMat)*(x-qCenVec)-1)< ...
            absTol, cellPoints);
        isBoundEllVec = isBoundEllVec | cellfun(@(x) norm(x - qCenVec) < ...
            absTol, cellPoints);

    end

    function isBoundEllVec = check1d(testEll, cellPoints)
        absTol = elltool.conf.Properties.getAbsTol();
        qCenVec = testEll.getCenterVec();
        dMat = testEll.getDiagMat();
        eigMat = testEll.getEigvMat();
        qMat = eigMat.'*dMat*eigMat;
        isBoundEllVec = cellfun(@(x) abs((x-qCenVec)*(x-qCenVec).') <= qMat*(1 + absTol), ...
            cellPoints);
    end

    function isBoundEllVec = check2dDimZero(testEll, cellPoints, dim)
        absTol = elltool.conf.Properties.getAbsTol();
        qCenVec = testEll.getCenterVec();
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
        qCenVec = testEll.getCenterVec();
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
        qCenVec = testEll.getCenterVec();
        dMat = testEll.getDiagMat();
        eigMat = testEll.getEigvMat();
        eigPoint = @(x) eigMat*(x-qCenVec) + qCenVec;
        invMat = diag(1./diag(dMat));
        isBoundEllVec = cellfun(@(x) abs(((eigPoint(x) - qCenVec).'*invMat)*...
            (eigPoint(x) - qCenVec)) < 1 + absTol, cellPoints) ;

    end
end
