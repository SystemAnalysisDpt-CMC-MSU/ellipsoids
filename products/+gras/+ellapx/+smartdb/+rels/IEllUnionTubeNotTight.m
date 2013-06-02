classdef IEllUnionTubeNotTight < ...
        gras.ellapx.smartdb.rels.IEllTubeNotTight
    %
    methods (Static)
        fromEllTubes(~)
    end
    %
    methods (Abstract,Static,Access=protected)
        fromEllTubesInternal(~)
    end
end