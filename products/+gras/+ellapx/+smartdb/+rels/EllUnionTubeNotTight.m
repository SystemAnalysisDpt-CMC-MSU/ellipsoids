classdef EllUnionTubeNotTight < ...
        gras.ellapx.smartdb.rels.AEllTubeNotTight & ...
        gras.ellapx.smartdb.rels.AEllUnionTubeNotTight & ...
        gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
        %
        function checkDataConsistency(self)
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllTubeNotTight(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllUnionTubeNotTight(self);
        end
    end
    %
    methods
        function self=EllUnionTubeNotTight(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:});
        end
        %
        function [ellTubeProjRel,indProj2OrigVec]=project(self,projType,...
                varargin)
            import gras.ellapx.smartdb.rels.EllUnionTubeNotTightStaticProj;
            import gras.ellapx.enums.EProjType;
            import modgen.common.throwerror;
            %
            if self.getNTuples()>0
                if projType~=EProjType.Static
                    throwerror('wrongInput',...
                        'only projections on Static subspace are supported');
                end
                
                [SProjData,indProj2OrigVec]=self.projectInternal(...
                    projType,varargin{:});
                projRel=smartdb.relations.DynamicRelation(SProjData);
                projRel.catWith(self.getTuples(indProj2OrigVec),...
                    'duplicateFields','useOriginal');
                ellTubeProjRel=EllUnionTubeNotTightStaticProj(projRel);
            else
                ellTubeProjRel=EllUnionTubeNotTightStaticProj();
            end
        end
    end
    %
    methods (Static)
        function ellUnionTubeRel=fromEllTubes(ellTubeRel)
            import gras.ellapx.smartdb.rels.EllUnionTubeNotTight
            import gras.ellapx.smartdb.rels.AEllUnionTubeNotTight
            %
            SData = AEllUnionTubeNotTight.fromEllTubesInternal(ellTubeRel);
            ellUnionTubeRel = EllUnionTubeNotTight(SData);
        end
    end
end