classdef IEllTube < gras.ellapx.smartdb.rels.IEllTubeNotTight
    %
    methods (Abstract,Static)
        calcTouchCurveData(~)
    end
    %
    methods (Abstract,Access=protected)
        getTouchCurveDependencyFieldList(~)
        getTouchCurveDependencyCheckedFieldList(~)
        getTouchCurveDependencyCheckTransFuncList(~)
        checkTouchCurveIndependence(~)
        checkTouchCurves(~)
        checkTouchCurveVsQNormArray(~)
    end
end