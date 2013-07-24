classdef AEllTubePlainProjector<gras.ellapx.proj.IEllTubeProjector
    %IELLTUBEPROJECTOR Summary of this class goes here
    %   Detailed explanation goes here
    methods (Access=protected,Abstract)
        [projOrthMatArray,projOrthMatTransArray]=...
            getProjectionMatrix(self,timeVec,projSpaceVec)
        projType=getProjType(self)
    end
    properties (Access=private)
        projMatList
    end
    methods
        function self=AEllTubePlainProjector(projMatList)
            self.projMatList=projMatList;
        end
        function [ellTubeProjRel,indProj2OrigVec]=project(self,ellTubeRel)
            % PROJECT creates projections of specified ellipsoidal tubes
            %
            % Input:
            %   regular:
            %       ellTubeRel: gras.ellapx.common.smartdb.rels.EllTubeBasic[1,1] -
            %           relation containing ellipsoidal tubes
            % Output:
            %   resRel: gras.ellapx.common.smartdb.rels.EllTubeProjBasic[1,1] - resulting
            %       relation containing the projected tubes
            %    indProj2OrigVec:cell[nDim, 1] - index of the line number from
            %       which is obtained the projection
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            fProj=@(varargin)getProjectionMatrix(self,varargin{:});
            projType=self.getProjType;
            [ellTubeProjRel,indProj2OrigVec]=ellTubeRel.project(projType,...
                self.projMatList,fProj);
        end
    end
end
