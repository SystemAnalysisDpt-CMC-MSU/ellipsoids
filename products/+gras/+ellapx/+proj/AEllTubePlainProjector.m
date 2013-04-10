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
            nProj=length(self.projSpaceList);
            projMatList=cell(1,nProj);
            nDims=length(self.projSpaceList{1});
            for iProj=1:nProj
                projSpaceVec=self.projSpaceList{iProj};
                projDimNumVec=find(projSpaceVec);
                nProjDims=length(projDimNumVec);
                indVec=sub2ind([nProjDims, nDims],1:nProjDims,projDimNumVec);
                projMatList{iProj}=zeros(nProjDims,nDims);
                projMatList{iProj}(indVec)=1;
            end
            ellTubeProjRel=ellTubeRel.project(projType,...
                projMatList,fProj);
        end
    end
end
