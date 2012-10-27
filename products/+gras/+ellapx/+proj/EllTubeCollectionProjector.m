classdef EllTubeCollectionProjector<gras.ellapx.proj.IEllTubeProjector
    %IELLTUBEPROJECTOR Summary of this class goes here
    %   Detailed explanation goes here
    properties(Access=private)
        projectorList
    end
    methods
        function self=EllTubeCollectionProjector(projectorList)
            self.projectorList=projectorList;
        end
        function ellTubeProjRel=project(self,ellTubeRel)
            import modgen.common.throwerror;
            nProjectors=length(self.projectorList);            
            if nProjectors>0
                ellTubeProjRel=self.projectorList{1}.project(ellTubeRel);
                for iProjector=2:nProjectors
                    ellTubeProjRel.unionWith(...
                        self.projectorList{iProjector}.project(...
                        ellTubeRel),'checkType',true);
                end
            else
                throwerror('wrongInput',...
                    'number of projectors cannot be zero');
            end
        end
    end
end
