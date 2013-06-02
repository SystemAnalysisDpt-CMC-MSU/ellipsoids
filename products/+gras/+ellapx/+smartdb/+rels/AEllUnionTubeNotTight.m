classdef AEllUnionTubeNotTight < ...
        gras.ellapx.smartdb.rels.IEllUnionTubeNotTight
    %
    properties (Constant,Hidden)
        FCODE_ELL_UNION_TIME_DIRECTION
    end
    %
    methods(Access=protected)
        function checkDataConsistency(self)
            import modgen.common.throwerror;
            %
            isOkVec = arrayfun(...
                @(x)isa(x,'gras.ellapx.enums.EEllUnionTimeDirection'),...
                self.ellUnionTimeDirection);
            %
            if any(~isOkVec)
                throwerror('wrongInput',...
                    'Incorrect type of ellUnionTimeDirection');
            end
        end
    end
    %
    methods (Static,Access=protected)
        function SData=fromEllTubesInternal(ellTubeRel)
            import gras.ellapx.enums.EEllUnionTimeDirection
            %
            nTubes=ellTubeRel.getNTuples();
            SData=ellTubeRel.getData();
            SData.ellUnionTimeDirection=repmat(...
                EEllUnionTimeDirection.Ascending,nTubes,1);
        end
    end
end