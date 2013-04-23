function self = testMinkColor(self,fmink,firstEllMat,secEllMat,numObj)
    plObj = fmink(firstEllMat,secEllMat,'color',[0,1,0]);
    if dimension(firstEllMat(1)) == 2
        check2dCol(plObj,numObj, [0, 1, 0]);
    else
        check3dCol(plObj,numObj, [0, 1, 0]);
    end
    plObj = fmink(firstEllMat,secEllMat,'r');
    if dimension(firstEllMat(1)) == 2
        check2dCol(plObj,numObj, [1, 0, 0]);
    else
        check3dCol(plObj,numObj, [1, 0, 0]);
    end
            function check2dCol(plObj,numObj, colMat)
                colMat = repmat(colMat,numObj,1);
                SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
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
                SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
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