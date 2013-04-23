function self = testMinkProperties(self,fmink,firstEllMat,secEllMat)
if dimension(firstEllMat(1)) == 2
    plObj = fmink(firstEllMat,secEllMat, 'linewidth', 4, ...
        'fill', true, 'shade', 0.8);
    checkParams(plObj, 4, 1, 0.8, []);
else
    self.runAndCheckError(...
        'fmink(firstEllMat,secEllMat, ''linewidth'', 4,''fill'', true, ''shade'', 0.8)'...
        ,'wrongProperty');
end
plObj = fmink(firstEllMat,secEllMat, 'fill', true, 'shade', 0.1, ...
    'color', [0, 1, 1]);
checkParams(plObj, [], 1, 0.1, [0, 1, 1]);




    function checkParams(plObj, linewidth, fill, shade, colorVec)
        SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
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