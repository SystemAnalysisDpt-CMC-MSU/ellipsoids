classdef ParameterizedPlotTC < mlunitext.test_case
    properties (Access=private)
        fCreateObjCVec;
        nGraphObjCVec;
    end
    methods
        function self = ParameterizedPlotTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end

        function set_up_param(self, fCrObjCVec, nGrObjCVec)
            close all;
            hold on;
            self.fCreateObjCVec = fCrObjCVec;
            self.nGraphObjCVec = nGrObjCVec;
        end
        
        function tear_down(self)
            close all;
        end
        
        function self = testLegendDisplay(self)
            centCVec = {[0;1], [1;0]};
            objCMat = self.createObjCMat(centCVec);
            plotSimultaneously(objCMat);
            legend('show');
            [hLegend, graphicalObjectsVec] =...
                getLegendAndGraphicalObjects(gcf());
            nGraphicalObjects = length(graphicalObjectsVec);
            mlunitext.assert_equals(nGraphicalObjects,...
                sum(vertcat(self.nGraphObjCVec{:})) * size(objCMat, 1));
            isCheckedObjVec = zeros(size(graphicalObjectsVec));
            curLegInd = 1;
            for iCol = 1:size(objCMat, 2)
                for iRow = 1:size(objCMat, 1)
                    if (self.nGraphObjCVec{iCol} == 2)
                        [isCheckedObjVec, curLegInd] = handleBound(...
                            graphicalObjectsVec, hLegend, curLegInd,...
                            isCheckedObjVec...
                        );
                        isCheckedObjVec = handleCenter(...
                            graphicalObjectsVec, isCheckedObjVec...
                        );
                    elseif (self.nGraphObjCVec{iCol} == 1)
                        [isCheckedObjVec, curLegInd] = handleBound(...
                            graphicalObjectsVec, hLegend, curLegInd,...
                            isCheckedObjVec...
                        );
                    else
                        mlunitext.fail('Too many graphical objects');
                    end
                end
            end
            mlunitext.assert_equals(all(isCheckedObjVec), 1);
            mlunitext.assert_equals(curLegInd, length(hLegend.String) + 1);
        end

        function testSequentialAndSimultaneousDisplay(self)
            centCVec = {[0;1], [1;0]};
            objCMat = self.createObjCMat(centCVec);
            plotSimultaneously(objCMat);
            legend('show');
            [hLegendSimultaneous, ~] = getLegendAndGraphicalObjects(gcf());
            legSimultStrCVec = hLegendSimultaneous.String;
            legendLength = length(legSimultStrCVec);

            figure;
            hold on;
            plotSequentially(objCMat);
            legend('show');
            [hLegendSequential, ~] = getLegendAndGraphicalObjects(gcf());
            legSequentStrCVec = hLegendSequential.String;
            mlunitext.assert_equals(legendLength, length(legSequentStrCVec));
            for iStr = 1:legendLength
                mlunitext.assert_equals(...
                    legSequentStrCVec{iStr}, legSimultStrCVec{iStr}...
                );
            end
        end
    end
    methods (Access=private)
        function objCMat = createObjCMat(self, centCVec)
            %objects' types in the same column are the same
            nCenters = numel(centCVec);
            objCMat = cell(nCenters, numel(self.fCreateObjCVec));
            for iCent = 1:nCenters
                for iFunc = 1:numel(self.fCreateObjCVec)
                    centDim = numel(centCVec{iCent});
                    shMat = eye(centDim);
                    curFunc = self.fCreateObjCVec{iFunc};
                    objCMat{iCent, iFunc} = curFunc(centCVec{iCent}, shMat);
                end
            end
        end
    end
end

function isChk = handleCenter(graphicalObjectsVec, isChecked)
    for objInd = 1:length(isChecked)
        if (strcmp(graphicalObjectsVec(objInd).Marker, '*')...
            && ~isChecked(objInd)...
        )
            curObjInd = objInd;
            break;
        end
    end
    hCenter = graphicalObjectsVec(curObjInd);
    mlunitext.assert_equals(hCenter.Type, 'patch');
    mlunitext.assert_equals(...
        hCenter.Annotation.LegendInformation.IconDisplayStyle, 'off');
    isChecked(curObjInd) = 1;
    isChk = isChecked;
end


function [isChk, legInd] =...
    handleBound(graphicalObjectsVec, hLegend, curLegInd, isChecked)

    str = hLegend.String{curLegInd};
    mlunitext.assert_equals(str, num2str(curLegInd));
    curObjInd = zeros(0);
    for objInd = 1:length(isChecked)
        if (strcmp(graphicalObjectsVec(objInd).DisplayName, str)...
            && ~isChecked(objInd)...
        )
            curObjInd = [curObjInd, objInd];
        end
    end
    mlunitext.assert_equals(numel(curObjInd), 1);
    hBound = graphicalObjectsVec(curObjInd);
    mlunitext.assert_equals(hBound.Type, 'patch');
    mlunitext.assert_equals(hBound.Marker, 'none');
    mlunitext.assert_equals(hBound.FaceColor, 'none');
    mlunitext.assert_equals(...
        hBound.Annotation.LegendInformation.IconDisplayStyle, 'on');
    isChecked(curObjInd) = 1;
    isChk = isChecked;
    legInd = curLegInd + 1;
end

function [hLegend, graphicalObjectsVec] = getLegendAndGraphicalObjects(hFigure)
    childVec = hFigure.Children;
    for iObj = 1:length(childVec)
        if (strcmp(childVec(iObj).Type, 'legend'))
            hLegend = childVec(iObj);
        elseif (strcmp(childVec(iObj).Type, 'axes'))
            hAxes = childVec(iObj);
        end
    end
    graphicalObjectsVec = hAxes.Children;
end

function plotSimultaneously(objCMat)
    for iCol = 1:size(objCMat, 2)
        plot(objCMat{:, iCol});
    end
end

function plotSequentially(objCMat)
    for iRow = 1:size(objCMat, 1)
        for iCol = 1:size(objCMat, 2)
            plot(objCMat{iRow, iCol});
        end
    end
end
