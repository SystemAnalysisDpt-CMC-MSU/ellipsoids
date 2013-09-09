classdef AGeomBodyPlotTestCase < mlunitext.test_case
%$Author: Ilya Lyubich <lubi4ig@gmail.com> $
%$Date: 2013-05-7 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
    methods(Abstract,Access=protected)
        getInstance(varargin)
    end
    methods
        function self=AGeomBodyPlotTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
            
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testWrongInput(self)
            
            testFirEll = self.getInstance(eye(2));
            testSecEll = self.getInstance([1, 0].', eye(2));
            testThirdEll = self.getInstance([0, -1].', eye(2));
            self.runAndCheckError...
                ('plot(testFirEll,''r'',testSecEll,''g'',''shade'',1,''fill'',false,''lineWidth'',0)',...
                'wrongLineWidth');
            self.runAndCheckError...
                ('plot(testFirEll,''color'',[0,0,0,1])',...
                'wrongColorVecSize');
            self.runAndCheckError...
                ('plot(testFirEll,''color'',[0,0,1].'')',...
                'wrongColorVecSize');
            self.runAndCheckError...
                ('plot(testFirEll,''color'',[0,0,-1])','wrongColorVec');
            self.runAndCheckError...
                ('plot(testFirEll,testSecEll,''lineWidth'',2,''color'',[0,0,1],testThirdEll,''color'',[1 0 1])',...
                'wrongInput:duplicatePropertiesSpec');
            self.runAndCheckError...
                ('plot(testFirEll, testSecEll,''r'',testThirdEll,''g'',''g'')',...
                'wrongColorChar');
            plot([testFirEll,testSecEll,testThirdEll],'shade',[0 0 1]);
            plot([testFirEll,testSecEll,testThirdEll],'lineWidth',[1 1 2]);
            plot([testFirEll,testSecEll,testThirdEll],'fill',[false false true]);
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll;testFirEll,testSecEll,testThirdEll],''fill'',[false false true false])', ...
                'wrongParamsNumber');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll;testFirEll,testSecEll,testThirdEll],''fill'',[false false true false].'')', ...
                'wrongParamsNumber');
            plot([testFirEll,testSecEll,testThirdEll;testFirEll,testSecEll...
                ,testThirdEll],'fill',[true; true; true;true; true; true]);
            plot([testFirEll,testSecEll,testThirdEll;testFirEll,testSecEll...
                ,testThirdEll],'color',[1 0 0;0 1 0;0 0 1;1 0 0;0 1 0;0 0 1]) ;
            plot([testFirEll,testSecEll,testThirdEll;testFirEll,testSecEll...
                ,testThirdEll],'fill',[true; true; true;true; true; true].');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll],''lineWidth'',[0 1 0])', ...
                'wrongLineWidth');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll],''shade'',nan)', ...
                'wrongShade');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll],''color'',[nan, nan, nan])', ...
                'wrongColorVec');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll],''lineWidth'',[nan, inf, -inf])', ...
                'wrongLineWidth');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll],''lineWidth'')', ...
                'wrongPropertyValue');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll],''color'')', ...
                'wrongPropertyValue');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll],''shade'')', ...
                'wrongPropertyValue');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll],''newfigure'')', ...
                'wrongPropertyValue');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll],''fill'')', ...
                'wrongPropertyValue');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll], 1)', ...
                'wrongPropertyType');
            testFirEll = self.getInstance(eye(3));
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll])', 'dimMismatch');
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll], ''fill'', [false, true, true])', ...
                'dimMismatch');
            testFirEll = self.getInstance(eye(2));
            self.runAndCheckError...
                ('plot([testFirEll,testSecEll,testThirdEll], ''color'',[0 1 1;0 1 0])', ...
                'wrongColorVecSize');
            testFirEll = self.getInstance(eye(4));
            self.runAndCheckError...
                ('plot([testFirEll], ''fill'',false)', ...
                'wrongDim');
            testFirEll = self.getInstance(1);
            plot(testFirEll,'fill',true);
            plot(testFirEll,'fill',false);
        end
        function self = testHoldOn(self)
            [testEll,numObj] = self.getInstance(eye(2));
            checkHoldOff(testEll, numObj);
            checkHoldOn(testEll, numObj+1);
            [testEllArr(1),numObj1] = self.getInstance(eye(2));
            [testEllArr(2),numObj2] = self.getInstance([1, 0].', eye(2));
            checkHoldOff(testEllArr, numObj1+numObj2);
            checkHoldOn(testEllArr, numObj1+numObj2+1);
            [testEllArr(1),numObj1] = self.getInstance(eye(3));
            [testEllArr(2),numObj2] = self.getInstance([1, 0, 0].', eye(3));
            checkHoldOff(testEllArr, numObj1+numObj2);
            checkHoldOn(testEllArr, numObj1+numObj2+1);
           
            checkHoldOffNewFig(testEllArr, numObj2);
            checkHoldOnNewFig(testEllArr, numObj2);
            function checkHoldOff(testEllArr, testAns)
                plot(1:10,sin(1:10));
                hold off;
                plotObj = plot(testEllArr);
                SHPlot = plotObj.getPlotStructure().figToAxesToHMap.toStruct();
                SAxes = SHPlot.figure_g1;
                plotFig = get(SAxes.ax, 'Children');
                mlunitext.assert_equals(numel(plotFig), testAns);
            end
            function checkHoldOn(testEllArr, testAns)
                plot(1:10,sin(1:10));
                hold on;
                plotObj = plot(testEllArr);
                SHPlot = plotObj.getPlotStructure().figToAxesToHMap.toStruct();
                SAxes = SHPlot.figure_g1;
                plotFig = get(SAxes.ax, 'Children');
                mlunitext.assert_equals(numel(plotFig), testAns);
            end
            function checkHoldOffNewFig(testEllArr, testAns)
                plot(1:10,sin(1:10));
                hold off;
                plotObj = plot(testEllArr, 'newfigure', true);
                SHPlot = plotObj.getPlotStructure().figToAxesToHMap.toStruct();
                SAxes = SHPlot.figure1_g1;
                plotFig = get(SAxes.ax1, 'Children');
                mlunitext.assert_equals(numel(plotFig), testAns);
            end
            function checkHoldOnNewFig(testEllArr, testAns)
                plot(1:10,sin(1:10));
                hold on;
                plotObj = plot(testEllArr, 'newfigure', true);
                SHPlot = plotObj.getPlotStructure().figToAxesToHMap.toStruct();
                SAxes = SHPlot.figure1_g1;
                plotFig = get(SAxes.ax1, 'Children');
                mlunitext.assert_equals(numel(plotFig), testAns);               
            end           
        end
        function self = testColorChar(self)
            [testEll,numObj] = self.getInstance(eye(2));
            plObj = plot(testEll, 'b');
            check2dCol(plObj, [0, 0, 1]);
            [testSecEll,numObj] = self.getInstance([1, 0].', eye(2));
            plObj = plot(testEll, 'g', testSecEll, 'b');
            check2dCol(plObj, [0, 1, 0], [0, 0, 1]);
            [testThirdEll,numObj] = self.getInstance([0, 1].', eye(2));
            plObj = plot(testEll, 'g', testSecEll, 'b', testThirdEll, 'y');
            check2dCol(plObj, [0, 1, 0], [0, 0, 1], [1, 1, 0]);
            [testEll,numObj] = self.getInstance(eye(3));
            plObj = plot(testEll, 'y');
            check3dCol(plObj, [1, 1, 0]);
            [testSecEll,numObj] = self.getInstance([1, 1, 0].', eye(3));
            plObj = plot(testEll, 'g', testSecEll, 'b');
            check3dCol(plObj, [0, 1, 0], [0, 0, 1]);
            [testThirdEll,numObj] = self.getInstance([-1, -1, -1].', eye(3));
            plObj = plot(testEll, 'c', testSecEll, 'm', testThirdEll, 'w');
            check3dCol(plObj, [0, 1, 1], [1, 0, 1], [1, 1, 1]);
            
            function check2dCol(plObj, varargin)
                colMat = vertcat(varargin{:});
                colMat = repmat(colMat,numObj,1);
                colMat = sortrows(colMat);
                SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
                plEllObjVec = get(SHPlot.figure_g1.ax, 'Children');
                plEllColCMat = get(plEllObjVec, 'EdgeColor');
                if iscell(plEllColCMat)
                    plEllColMat = vertcat(plEllColCMat{:});
                else
                    plEllColMat = plEllColCMat;
                end
                plEllColMat = sortrows(plEllColMat);
                mlunitext.assert_equals(plEllColMat, colMat);
            end
            function check3dCol(plObj, varargin)
                colMat = vertcat(varargin{:});
                colMat = sortrows(colMat);
                SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
                plEllObjVec = get(SHPlot.figure_g1.ax, 'Children');
                plEllColCMat = arrayfun(@(x) getColVec(x), plEllObjVec, ...
                    'UniformOutput', false);
                plEllColMat = vertcat(plEllColCMat{:});
                plEllColMat = sortrows(plEllColMat);
                mlunitext.assert_equals(plEllColMat, colMat);
                function clrVec = getColVec(plEllObj)
                    if ~eq(get(plEllObj, 'Type'), 'patch')
                        clrVec = [];
                    else
                        clrMat = get(plEllObj, 'FaceVertexCData');
                        clrVec = clrMat(1, :);
                    end
                end
            end
        end
        function self = testNewFigure(self)
            testEll = self.getInstance(eye(3));
            checkNewFig(testEll, 1);
            checkNotNewFig(testEll);
            testEllArr(1) = self.getInstance(eye(3));
            testEllArr(2) = self.getInstance([1, 1, 1].', eye(3));
            testEllArr(3) = self.getInstance([-1, 0, 1].', eye(3));
            checkNewFig(testEllArr, 3);
            checkNotNewFig(testEllArr);
            function checkNewFig(testEllArr, numEll)
                plObj = plot(testEllArr, 'newfigure', true);
                SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
                mlunitext.assert_equals(numel(fields(SHPlot)), numEll);
            end
            function checkNotNewFig(testEllArr)
                plObj = plot(testEllArr, 'newfigure', false);
                SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
                mlunitext.assert_equals(numel(SHPlot), 1);
            end
        end
        function self = testProperties(self)
            testFirEll = self.getInstance(eye(2));
            testSecEll = self.getInstance([1, 0].', eye(2));
            plObj = plot([testFirEll, testSecEll], 'linewidth', 4, ...
                'fill', true, 'shade', 0.8);
            checkParams(plObj, 4, 1, 0.8, []);
            testEll = self.getInstance(eye(3));
            plObj = plot(testEll, 'fill', true, 'shade', 0.1, ...
                'color', [0, 1, 1]);
            checkParams(plObj, [], 1, 0.1, [0, 1, 1]);
            testEllArr(1) = self.getInstance([1, 1, 0].', eye(3));
            testEllArr(2) = self.getInstance([0, 0, 0].', eye(3));
            testEllArr(3) = self.getInstance([-1, -1, -1].', eye(3));
            plObj = plot(testEllArr, 'fill', true, 'color', [1, 0, 1]);
            checkParams(plObj, [], 1, [], [1, 0, 1]);
            plObj = plot(testEllArr, 'fill', true);
            checkParams(plObj, [], 1, [], []);
            testEll = self.getInstance(eye(3));
            self.runAndCheckError...
                ('plot(testEll, ''LineWidth'', 2)','wrongProperty');
            function checkParams(plObj, linewidth, fill, shade, colorVec)
                SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
                plEllObjVec = get(SHPlot.figure_g1.ax, 'Children');
                isEqVec = arrayfun(@(x) checkEllParams(x), plEllObjVec);
                mlunitext.assert_equals(isEqVec, ones(size(isEqVec)));
                isFillVec = arrayfun(@(x) checkIsFill(x), plEllObjVec, ...
                    'UniformOutput', false);
                mlunitext.assert_equals(numel(isFillVec) > 0, fill);
                function isFill = checkIsFill(plObj)
                    if strcmp(get(plObj, 'type'), 'patch')
                        if get(plObj, 'FaceAlpha') > 0
                            isFill = true;
                        else
                            isFill = [];
                        end
                    else
                        isFill = [];
                    end
                end
                function isEq = checkEllParams(plObj)
                    isEq = true;
                    if strcmp(get(plObj, 'type'), 'line') &&...
                            (~strcmp(get(plObj, 'Marker'), '*'))
                        linewidthPl = get(plObj, 'linewidth');
                        colorPlVec = get(plObj, 'Color');
                        if numel(linewidth) > 0
                            isEq = isEq & eq(linewidth, linewidthPl);
                        end
                        if numel(colorVec) > 0
                            isEq = isEq & eq(colorVec, colorPlVec);
                        end
                    elseif strcmp(get(plObj, 'type'), 'patch')
                        shadePl = get(plObj, 'FaceAlpha');
                        if numel(shade) > 0
                            isEq = isEq & eq(shade, shadePl);
                        end
                        colorPlMat = get(plObj, 'FaceVertexCData');
                        if numel(colorPlMat) > 0
                            colorPlVec = colorPlMat(1, :);
                            if numel(colorVec) > 0
                                isEq = isEq & all(colorVec == colorPlVec);
                            end
                        end                        
                    end
                end
            end
        end
        function self = testNewAxis(self)
            
            testEll = self.getInstance(eye(2));
            checkNewAxis(testEll);
            
            testEllArr = [self.getInstance(eye(2)), ...
                self.getInstance([1, 0].', eye(2))];
            checkNewAxis(testEllArr);
            
            testFirEll = self.getInstance(eye(3));
            testSecEll = self.getInstance([1, 0, 0].', eye(3));
            testEllArr = [testFirEll, testSecEll; testFirEll, testSecEll];
            checkNewAxis(testEllArr);
            checkNewAxisNewFig(testEllArr);
            for iEll = 1:2
                for jEll = 1:2
                    testEllArr(iEll, jEll, 1) = testFirEll;
                    testEllArr(iEll, jEll, 2) = testSecEll;
                end
            end
            checkNewAxis(testEllArr);
            checkNewAxisNewFig(testEllArr);
            function checkNewAxis(testEllArr)
                axesSubPlHandle = subplot(3,2,2);
                plotObj = plot(testEllArr);
                SHPlot = plotObj.getPlotStructure().figToAxesToHMap.toStruct();
                SAxes = SHPlot.figure_g1;
                axesHandle = SAxes.ax;
                mlunitext.assert_equals(axesHandle, axesSubPlHandle);
            end
            function checkNewAxisNewFig(testEllArr)
                axesSubPlHandle = subplot(3,2,2);
                plotObj = plot(testEllArr, 'newfigure', true);
                SHPlot =  plotObj.getPlotStructure().figToAxesToHMap.toStruct();
                SAxes = SHPlot.figure1_g1;
                axesHandle = SAxes.ax1;
                mlunitext.assert(~eq(axesHandle, axesSubPlHandle));
                
            end
            
        end
        
    end
end