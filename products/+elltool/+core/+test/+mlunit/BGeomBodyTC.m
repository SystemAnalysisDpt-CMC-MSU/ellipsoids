classdef BGeomBodyTC < elltool.plot.test.AGeomBodyPlotTestCase
    %
    %$Author: Ilya Lyubich <lubi4ig@gmail.com> $
    %$Date: 2013-05-7 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    properties (Access = protected)
        fTest,fCheckBoundary
    end
    methods
        function self = BGeomBodyTC(varargin)
            self =...
                self@elltool.plot.test.AGeomBodyPlotTestCase(varargin{:});
        end
        function self = plotND(self,nDims,inpFirstArgCList,inpSecArgCList)
            nElem = numel(inpFirstArgCList);
            for iElem = 1:nElem
                testMat=...
                    self.fTest(inpFirstArgCList{iElem},...
                    inpSecArgCList{iElem});
                check(testMat, nDims);
            end
            testEllMat(1) =...
                self.fTest(inpFirstArgCList{1}, inpSecArgCList{1});
            testEllMat(2) =...
                self.fTest(inpFirstArgCList{2}, inpSecArgCList{2});
            check(testEllMat, nDims);
            testEl2Mat(nElem) = self.fTest();
            for iElem = 1:nElem
                testEl2Mat(iElem) = self.fTest(inpFirstArgCList{iElem},...
                    inpSecArgCList{iElem});
            end
            check(testEl2Mat, nDims);
            
            function check(testEllMat, nDims)
                plotObj = plot(testEllMat);
                SPlotStructure = plotObj.getPlotStructure;
                SHPlot =  toStruct(SPlotStructure.figToAxesToPlotHMap);
                num = SHPlot.figure_g1;
                [xDataCell, yDataCell, zDataCell] =...
                    arrayfun(@(x) getData(num.ax(x)), ...
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
                
                testVec = reshape(testEllMat, 1, numel(testEllMat));
                isBoundVec = self.fCheckBoundary(cellPoints,testVec);
                
                mlunitext.assert_equals(isBoundVec,...
                    ones(size(isBoundVec)));
                
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
            end
        end
        
    end
end