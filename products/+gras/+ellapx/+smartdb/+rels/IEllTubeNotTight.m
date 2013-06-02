classdef IEllTubeNotTight < handle
    %
    properties (Abstract,Access=protected,Constant)
        DEFAULT_SCALE_FACTOR
        N_GOOD_DIR_DISP_DIGITS
        GOOD_DIR_DISP_TOL
    end
    %
    methods (Abstract)
        plot(~)
        thinOutTuples(~)
        cat(~)
        cut(~)
        scale(~)
        project(~)
        projectToOrths(~)
        getEllArray(~)
    end
    %
    methods (Abstract,Static)
        scaleTubeData(~)
        getCutObj(~)
        getLogicalInd(~)
    end
    %
    methods (Abstract,Access=protected)
        getProtectedFromCutFieldList(~)
        getSTimeFieldList(~)
        getProblemDependencyFieldList(~)
        getProjectionDependencyFieldList(~)
        goodDirProp2Str(~)
        figureGetGroupKeyFunc(~)
        figureSetPropFunc(~)
        axesGetKeyDiamFunc(~)
        axesGetKeyTraceFunc(~)
        axesSetPropBasicFunc(~)
        axesSetPropDiamFunc(~)
        axesSetPropTraceFunc(~)
        plotTubeTraceFunc(~)
        plotTubeDiamFunc(~)
        projectInternal(~)
        buildOneProjection(~)
        checkDataConsistency(~)
        checkIntWithinExt(~)
        checkSVsTConsistency(~)
    end
end