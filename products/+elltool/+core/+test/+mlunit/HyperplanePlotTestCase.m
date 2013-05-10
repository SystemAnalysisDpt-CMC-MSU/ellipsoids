classdef HyperplanePlotTestCase < elltool.plot.test.AGeomBodyPlotTestCase
    %
    %$Author: Ilya Lyubich <lubi4ig@gmail.com> $
    %$Date: 2013-05-7 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    properties (Access=private)
        testDataRootDir
        
    end
    %
    methods(Access=protected)
        function [plObj,numObj] = getInstance(varargin)
            if numel(varargin)==2
                temp = varargin{2};
                plObj = hyperplane(temp(:,1));
                if size(varargin{2},1) == 2
                    numObj = 1;
                else
                    numObj = 4;
                end
            else
                temp = varargin{3};
                plObj = hyperplane(temp(:,1),sum(varargin{2}));
                if size(varargin{3},1) == 2
                    numObj = 1;
                else
                    numObj = 4;
                end
            end
        end
    end
    methods
        function self = HyperplanePlotTestCase(varargin)
            self = self@elltool.plot.test.AGeomBodyPlotTestCase(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',...
                filesep,shortClassName];
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testPlot2d(self)
            nDims = 2;
            inpNormCList = {[1;1],[2;1],[0;0]};
            inpScalCList = {1,3,0};
            nElem = numel(inpNormCList);
            for iElem = 1:nElem
                testHyp=hyperplane(inpNormCList{iElem}, inpScalCList{iElem});
                check(testHyp, nDims);
            end
            testHypArr(1) = hyperplane(inpNormCList{1}, inpScalCList{1});
            testHypArr(2) = hyperplane(inpNormCList{2}, inpScalCList{2});
            check(testHypArr, nDims);
            testHyp2Arr(nElem) = hyperplane();
            for iElem = 1:nElem
                testHyp2Arr(iElem) = hyperplane(inpNormCList{iElem},...
                    inpScalCList{iElem});
            end
            check(testHypArr, nDims);
        end
        function self = testPlot3d(self)
            nDims = 3;
            inpNormCList = {[1;1;1],[2;1;3],[0;0;0],[1;0;0]};
            inpScalCList = {1,3,0,0};
            nElem = numel(inpNormCList);
            for iElem = 1:nElem
                testHyp=hyperplane(inpNormCList{iElem}, inpScalCList{iElem});
                check(testHyp, nDims);
            end
            
            testHypArr(1) = hyperplane(inpNormCList{1}, inpScalCList{1});
            testHypArr(2) = hyperplane(inpNormCList{2}, inpScalCList{2});
            check(testHypArr, nDims);
            testHyp2Arr(nElem) = hyperplane();
            for iElem = 1:nElem
                testHyp2Arr(iElem) = hyperplane(inpNormCList{iElem},...
                    inpScalCList{iElem});
            end
            check(testHypArr, nDims);
        end
        function testWrongCenterSize(self)
            testFirstHyp = hyperplane([2;1],-1);
            testSecondHyp = hyperplane([3;1],1);
            self.runAndCheckError...
                ('plot(testFirstHyp,''size'',-5)', ...
                'wrongSizeVec');
            self.runAndCheckError...
                ('plot(testFirstHyp,''size'',''a'')', ...
                'wrongInput');
            plot(testFirstHyp,testSecondHyp,'center',[1 -1;1 -2]);
            plot(testFirstHyp,'center',[1 3]);
            plot(testFirstHyp,testSecondHyp,'size',100);
            plot(testFirstHyp,testSecondHyp,'size',[100;2]);
        end
    end
end
function check(testHypArr, nDims)
isBoundVec = 0;
plotObj = plot(testHypArr);
SPlotStructure = plotObj.getPlotStructure;
SHPlot =  toStruct(SPlotStructure.figToAxesToPlotHMap);
num = SHPlot.figure_g1;
[xDataCell, yDataCell, zDataCell] = arrayfun(@(x) getData(num.ax(x)), ...
    1:numel(num.ax), 'UniformOutput', false);
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

testHypVec = reshape(testHypArr, 1, numel(testHypArr));
nHyp = numel(testHypVec);
for iHyp = 1:nHyp
    isBoundHypVec = checkNorm(testHypVec(iHyp), cellPoints);
    isBoundVec = isBoundVec | isBoundHypVec;
end

mlunit.assert_equals(isBoundVec, ones(size(isBoundVec)));

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
    function isBoundHypVec = checkNorm(testHyp, cellPoints)
        absTol = elltool.conf.Properties.getAbsTol();
        [normVec, hypScal] = testHyp.double();
        isBoundHypVec = cellfun(@(x) abs(x.'*normVec-hypScal)< ...
            absTol, cellPoints);
        
    end
end