classdef EllMinkBodyPlotT < handle
%$Author: Ilya Lyubich <lubi4ig@gmail.com> $
%$Date: 2013-05-7 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
    properties (Access=protected)
        fMink
    end
    methods
        function self=EllMinkBodyPlotT(varargin)
           
        end
        function minkColor(self,firstEllMat,secEllMat,...
                numObj)
            plObj = self.fMink(firstEllMat,secEllMat,'color',[0,1,0]);
            if dimension(firstEllMat(1)) == 2
                check2dCol(plObj,numObj, [0, 1, 0]);
            else
                check3dCol(plObj,numObj, [0, 1, 0]);
            end
            plObj = self.fMink(firstEllMat,secEllMat,'r');
            if dimension(firstEllMat(1)) == 2
                check2dCol(plObj,numObj, [1, 0, 0]);
            else
                check3dCol(plObj,numObj, [1, 0, 0]);
            end
            function check2dCol(plObj,numObj, colMat)
                colMat = repmat(colMat,numObj,1);
                SHPlot =  ...
                    plObj.getPlotStructure().figToAxesToHMap.toStruct();
                import elltool.plot.common.AxesNames;
                plEllObjVec = get(SHPlot.figure_g1.(AxesNames.AXES_2D_KEY),...
                                  'Children');
                plEllColCMat = get(plEllObjVec, 'EdgeColor');
                if iscell(plEllColCMat)
                    plEllColMat = vertcat(plEllColCMat{:});
                else
                    plEllColMat = plEllColCMat;
                end
                mlunitext.assert_equals(plEllColMat, colMat);
            end
            function check3dCol(plObj, numObj, colMat)
                colMat = repmat(colMat,numObj,1);
                SHPlot = ...
                    plObj.getPlotStructure().figToAxesToHMap.toStruct();
                import elltool.plot.common.AxesNames;
                plEllObjVec = get(SHPlot.figure_g1.(AxesNames.AXES_3D_KEY), 'Children');
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
        function minkFillAndShade(self,firstEllMat,secEllMat)
            fMinkOp = self.fMink;
            fMinkOp(firstEllMat,secEllMat,'fill',false,'shade',1);
            fMinkOp(firstEllMat,secEllMat,'fill',true,'shade',0.7);
            self.runAndCheckError...
                ('fMinkOp([firstEllMat,secEllMat],''shade'',NaN)', ...
                'wrongShade');
            self.runAndCheckError...
                ('fMinkOp([firstEllMat,secEllMat],''shade'',[0 1])', ...
                'wrongParamsNumber');
        end
        function minkProperties(self,firstEllMat,secEllMat)
            fMinkOp = self.fMink;
            dim = dimension(firstEllMat(1));
            if dim == 2
                plObj = fMinkOp(firstEllMat,secEllMat, 'linewidth', 4, ...
                    'fill', true, 'shade', 0.8);
                checkParams(plObj, dim, 4, 1, 0.8, []);
            else
                strErr = strcat('fMinkOp(firstEllMat,secEllMat,',...
                    '''linewidth'', 4',...
                    ',''fill'', true, ''shade'', 0.8)');
                self.runAndCheckError(strErr,'wrongProperty');
            end
            plObj = fMinkOp(firstEllMat,secEllMat, ...
                'fill', true, 'shade', 0.1, ...
                'color', [0, 1, 1]);
            checkParams(plObj, dim, [], 1, 0.1, [0, 1, 1]);
            function checkParams(plObj, dim, linewidth, fill, shade, colorVec)
                import elltool.plot.common.AxesNames;
                import elltool.plot.GraphObjTypeEnum;
                SHPlot=plObj.getPlotStructure().figToAxesToHMap.toStruct();
                checkAxesLabels(plObj);
                if dim >= 3
                    plEllObjVec = get(SHPlot.figure_g1.(AxesNames.AXES_3D_KEY),...
                                      'Children');
                    mlunitext.assert_equals(GraphObjTypeEnum.MinkOpBoundary,...
                                    plEllObjVec(4).UserData.graphObjType);              
                else
                    plEllObjVec = get(SHPlot.figure_g1.(AxesNames.AXES_2D_KEY),...
                                      'Children');
                    mlunitext.assert_equals(GraphObjTypeEnum.MinkOpCenter,...
                                    plEllObjVec(1).UserData.graphObjType);
                    mlunitext.assert_equals(GraphObjTypeEnum.MinkOpBoundary,...
                                    plEllObjVec(2).UserData.graphObjType);              
                end
                isEqVec = arrayfun(@(x) checkEllParams(x), plEllObjVec);
                mlunitext.assert_equals(isEqVec, ones(size(isEqVec)));
                isFillVec = arrayfun(@(x) checkIsFill(x), plEllObjVec, ...
                    'UniformOutput', false);
                mlunitext.assert_equals(numel(isFillVec) > 0, fill);
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
                        if numel(linewidth) > 03
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
    end
end