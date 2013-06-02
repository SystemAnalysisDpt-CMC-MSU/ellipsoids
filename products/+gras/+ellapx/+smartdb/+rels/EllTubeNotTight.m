classdef EllTubeNotTight < gras.ellapx.smartdb.rels.AEllTubeNotTight & ...
        gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %
    methods (Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
    end
    %
    methods
        function self=EllTubeNotTight(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:});
        end
    end
end

