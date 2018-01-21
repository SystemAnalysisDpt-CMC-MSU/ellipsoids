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
            self.fCreateObjCVec = fCrObjCVec;
            self.nGraphObjCVec = nGrObjCVec;
        end
        
        function tear_down(self)
            close all;
        end
        
        function self = testLegendDisplay(self)
            centCVec = {[0;1], [1;0]};
            objCMat = self.createObjCMat(centCVec);
            plObj = plotSimultaneously(objCMat);
            [hLegend, graphicalObjectsVec] =...
                getLegendAndGraphicalObjects(plObj);
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
            plObj = plotSimultaneously(objCMat);
            [hLegendSimultaneous, ~] = getLegendAndGraphicalObjects(plObj);
            legSimultStrCVec = hLegendSimultaneous.String;
            nLegends = length(legSimultStrCVec);

            plObj = plotSequentially(objCMat);
            [hLegendSequential, ~] = getLegendAndGraphicalObjects(plObj);
            legSequentStrCVec = hLegendSequential.String;
            mlunitext.assert_equals(nLegends, length(legSequentStrCVec));
            for iStr = 1:nLegends
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

function isChkVec = handleCenter(graphicalObjectsVec, isCheckedVec)
    for objInd = 1:length(isCheckedVec)
        if (strcmp(graphicalObjectsVec(objInd).Marker, '*')...
            && ~isCheckedVec(objInd)...
        )
            curObjInd = objInd;
            break;
        end
    end
    hCenter = graphicalObjectsVec(curObjInd);
    mlunitext.assert_equals(hCenter.Type, 'patch');
    mlunitext.assert_equals(...
        hCenter.Annotation.LegendInformation.IconDisplayStyle, 'off');
    isCheckedVec(curObjInd) = 1;
    isChkVec = isCheckedVec;
end


function [isChkVec, legInd] =...
    handleBound(graphicalObjectsVec, hLegend, curLegInd, isCheckedVec)

    str = hLegend.String{curLegInd};
    mlunitext.assert_equals(str, num2str(curLegInd));
    curObjInd = zeros(0);
    for objInd = 1:length(isCheckedVec)
        if (strcmp(graphicalObjectsVec(objInd).DisplayName, str)...
            && ~isCheckedVec(objInd)...
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
    isCheckedVec(curObjInd) = 1;
    isChkVec = isCheckedVec;
    legInd = curLegInd + 1;
end

function [hLegend, graphicalObjectsVec] = getLegendAndGraphicalObjects(plObj)
    SProps = plObj.getPlotStructure();
    %getting figure handle
    SFigure = SProps.figHMap.toStruct();
    figureKeyCVec = fieldnames(SFigure);
    mlunitext.assert_equals(1, numel(figureKeyCVec));
    figureKey = figureKeyCVec{:};
    hFigure = SFigure.(figureKey);
    %getting axes handle
    SAxes = SProps.figToAxesToHMap(figureKey).toStruct();
    axesKeyCVec = fieldnames(SAxes);
    mlunitext.assert_equals(1, numel(axesKeyCVec));
    axesKey = axesKeyCVec{:};
    hAxes = SAxes.(axesKey);
    %getting legend
    hLegend = legend(hAxes, 'show');
    %getting graphical objects
    SHPlot = SProps.figToAxesToPlotHMap(figureKey).toStruct();
    graphicalObjectsVec = SHPlot.(axesKey);
end

function plObj = plotSimultaneously(objCMat)
    plObj = smartdb.disp.RelationDataPlotter();
    for iCol = 1:size(objCMat, 2)
        plot(objCMat{:, iCol}, 'relDataPlotter', plObj);
    end
end

function plObj = plotSequentially(objCMat)
    plObj = smartdb.disp.RelationDataPlotter();
    for iRow = 1:size(objCMat, 1)
        for iCol = 1:size(objCMat, 2)
            plot(objCMat{iRow, iCol}, 'relDataPlotter', plObj);
        end
    end
end
