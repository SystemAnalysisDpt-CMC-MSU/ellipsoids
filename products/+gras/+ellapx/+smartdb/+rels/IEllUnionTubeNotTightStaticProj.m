classdef IEllUnionTubeNotTightStaticProj < ...
        gras.ellapx.smartdb.rels.IEllTubeNotTightProj & ...
        gras.ellapx.smartdb.rels.IEllUnionTubeNotTight
    %
    properties (Abstract,Constant,Access=protected)
        N_ISO_SURF_ONEDIM_POINTS
        N_ISO_SURF_MIN_TIME_POINTS
        N_ISO_SURF_MAX_TIME_POINTS
    end
    %
    methods (Abstract,Access=protected)
        getNoTouchGoodDirColor(~)
        getPatchColorByApxType(~)
    end
end