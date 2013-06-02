classdef IEllTubeNotTightProj < gras.ellapx.smartdb.rels.IEllTubeNotTight
    %
    properties (Abstract,Access=protected,Constant)
        N_SPOINTS
        REACH_TUBE_PREFIX
        REG_TUBE_PREFIX
    end
    %
    methods (Abstract)
        getReachTubeNamePrefix(~)
        getRegTubeNamePrefix(~)
    end
    %
    methods(Access=protected)
        getPlotArgumentsFieldList(~)
        scaleAxesHeight(~)
        projSpecVec2Str(~)
        axesGetKeyTubeFunc(~)
        axesGetKeyGoodCurveFunc(~)
        axesSetPropGoodCurveFunc(~)
        axesSetPropTubeFunc(~)
        axesSetPropRegTubeFunc(~)
        figureGetNamedGroupKeyFunc(~)
        figureNamedSetPropFunc(~)
        getGoodDirColor(~)
        getGoodCurveColor(~)
        getPatchColorByApxType(~)
        getRegTubeColor(~)
        plotCreateGoodDirFunc(~)
        plotCreateGenericTubeFunc(~)
        plotCreateReachTubeFunc(~)
        plotCreateRegTubeFunc(~)
    end
end