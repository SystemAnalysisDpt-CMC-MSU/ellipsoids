classdef EllMinkBodyPlotT < handle
%$Author: Ilya Lyubich <lubi4ig@gmail.com> $
%$Date: 2013-05-7 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
    methods
        function self=EllMinkBodyPlotT(varargin)
           
        end
        function self = minkColor(self,fMink,firstEllMat,secEllMat,...
                numObj)
            plObj = fMink(firstEllMat,secEllMat,'color',[0,1,0]);
            if dimension(firstEllMat(1)) == 2
                check2dCol(plObj,numObj, [0, 1, 0]);
            else
                check3dCol(plObj,numObj, [0, 1, 0]);
            end
            plObj = fMink(firstEllMat,secEllMat,'r');
            if dimension(firstEllMat(1)) == 2
                check2dCol(plObj,numObj, [1, 0, 0]);
            else
                check3dCol(plObj,numObj, [1, 0, 0]);
            end
            function check2dCol(plObj,numObj, colMat)
                colMat = repmat(colMat,numObj,1);
                SHPlot =  ...
                    plObj.getPlotStructure().figToAxesToHMap.toStruct();
                plEllObjVec = get(SHPlot.figure_g1.ax, 'Children');
                plEllColCMat = get(plEllObjVec, 'EdgeColor');
                if iscell(plEllColCMat)
                    plEllColMat = vertcat(plEllColCMat{:});
                else
                    plEllColMat = plEllColCMat;
                end
                mlunit.assert_equals(plEllColMat, colMat);
            end
            function check3dCol(plObj, numObj, colMat)
                colMat = repmat(colMat,numObj,1);
                SHPlot = ...
                    plObj.getPlotStructure().figToAxesToHMap.toStruct();
                plEllObjVec = get(SHPlot.figure_g1.ax, 'Children');
                plEllColCMat = arrayfun(@(x) getColVec(x), plEllObjVec, ...
                    'UniformOutput', false);
                plEllColMat = vertcat(plEllColCMat{:});
                plEllColMat = sortrows(plEllColMat);
                mlunit.assert_equals(plEllColMat, colMat);
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
        function self = minkFillAndShade(self,fMink,firstEllMat,secEllMat)
            fMink(firstEllMat,secEllMat,'fill',false,'shade',1);
            fMink(firstEllMat,secEllMat,'fill',true,'shade',0.7);
            self.runAndCheckError...
                ('fMink([firstEllMat,secEllMat],''shade'',NaN)', ...
                'wrongShade');
            self.runAndCheckError...
                ('fMink([firstEllMat,secEllMat],''shade'',[0 1])', ...
                'wrongParamsNumber');
        end
        function self =minkProperties(self,fMink,firstEllMat,secEllMat)
            if dimension(firstEllMat(1)) == 2
                plObj = fMink(firstEllMat,secEllMat, 'linewidth', 4, ...
                    'fill', true, 'shade', 0.8);
                checkParams(plObj, 4, 1, 0.8, []);
            else
                self.runAndCheckError(...
                    'fMink(firstEllMat,secEllMat, ''linewidth'', 4,''fill'', true, ''shade'', 0.8)'...
                    ,'wrongProperty');
            end
            plObj = fMink(firstEllMat,secEllMat, ...
                'fill', true, 'shade', 0.1, ...
                'color', [0, 1, 1]);
            checkParams(plObj, [], 1, 0.1, [0, 1, 1]);
            
            
            
            
            function checkParams(plObj, linewidth, fill, shade, colorVec)
                SHPlot=plObj.getPlotStructure().figToAxesToHMap.toStruct();
                plEllObjVec = get(SHPlot.figure_g1.ax, 'Children');
                isEqVec = arrayfun(@(x) checkEllParams(x), plEllObjVec);
                mlunit.assert_equals(isEqVec, ones(size(isEqVec)));
                isFillVec = arrayfun(@(x) checkIsFill(x), plEllObjVec, ...
                    'UniformOutput', false);
                mlunit.assert_equals(numel(isFillVec) > 0, fill);
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