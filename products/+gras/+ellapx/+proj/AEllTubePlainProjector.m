classdef AEllTubePlainProjector<gras.ellapx.proj.IEllTubeProjector
    %IELLTUBEPROJECTOR Summary of this class goes here
    %   Detailed explanation goes here
    methods (Access=protected,Abstract)
        [projOrthMatArray,projOrthMatTransArray]=...
            getProjectionMatrix(self,timeVec,projSpaceVec)
        projType=getProjType(self)
    end
    properties (Access=private)
        projSpaceList
    end
    methods
        function self=AEllTubePlainProjector(projSpaceList)
            self.projSpaceList=projSpaceList;
        end
        function ellTubeProjRel=project(self,ellTubeRel)
            % PROJECT creates projections of specified ellipsoidal tubes
            %
            % Input:
            %   regular:
            %       ellTubeRel: gras.ellapx.common.smartdb.rels.EllTubeBasic[1,1] -
            %           relation containing ellipsoidal tubes
            % Output:
            %   resRel: gras.ellapx.common.smartdb.rels.EllTubeProjBasic[1,1] - resulting
            %       relation containing the projected tubes
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            
            %fProj(sTime,timeVec,dim,indSTime,projSpaceVec)
            fProj=@(varargin)getProjectionMatrix(self,varargin{:});
            projType=self.getProjType;
            %
            ellTubeProjRel=ellTubeRel.project(projType,...
                self.projSpaceList,fProj);
        end
    end
end
