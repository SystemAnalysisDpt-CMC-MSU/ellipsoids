classdef EllTubeStaticSpaceProjector<gras.ellapx.proj.AEllTubePlainProjector
    %IELLTUBEPROJECTOR Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function self=EllTubeStaticSpaceProjector(varargin)
            self=self@gras.ellapx.proj.AEllTubePlainProjector(varargin{:});
        end
    end
    methods (Access=protected)
        function projType=getProjType(~)
            projType=gras.ellapx.enums.EProjType.Static;            
        end
        function [projOrthMatArray,projOrthMatTransArray]=...
                getProjectionMatrix(~,projSpaceVec,timeVec,varargin)
            nDims=length(projSpaceVec);
            nTimes=length(timeVec);
            projDimNumVec=find(projSpaceVec);
            nProjDims=length(projDimNumVec);
            indVec=sub2ind([nProjDims, nDims],1:nProjDims,projDimNumVec);
            projOrthSTimeMat=zeros(nProjDims,nDims);
            projOrthSTimeMat(indVec)=1;
            projOrthMatArray=repmat(projOrthSTimeMat,[1 1 nTimes]);
            projOrthMatTransArray=repmat(projOrthSTimeMat.',[1 1 nTimes]);            
        end
    end
end
