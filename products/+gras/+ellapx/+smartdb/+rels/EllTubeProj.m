classdef EllTubeProj<gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel&...
        gras.ellapx.smartdb.rels.EllTubeProjBasic
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    methods (Static,Access=protected)
        function resObj=loadobj(inpObj)
            resObj=gras.ellapx.smartdb.rels.EllTubeProj(inpObj);    
            renameFieldsInternal(resObj,{'projSpecDimVec'},{'projSTimeMat'},{'Projection matrix at time s'});
        end
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