classdef EllTubeProj<gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel&...
        gras.ellapx.smartdb.rels.EllTubeProjBasic
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    properties (GetAccess=private,Constant)
        DEFAULT_SCALE_FACTOR=1;
    end
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
    end
    methods
        function self=EllTubeProj(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:}); 
        end
    end
end