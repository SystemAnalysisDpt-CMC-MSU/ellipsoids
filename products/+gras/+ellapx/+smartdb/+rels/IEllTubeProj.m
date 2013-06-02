classdef IEllTubeProj < ...
        gras.ellapx.smartdb.rels.IEllTube & ...
        gras.ellapx.smartdb.rels.IEllTubeNotTightProj
    %
    methods (Abstract,Access=protected)
        plotCreateTubeTouchCurveFunc(~)
    end
end