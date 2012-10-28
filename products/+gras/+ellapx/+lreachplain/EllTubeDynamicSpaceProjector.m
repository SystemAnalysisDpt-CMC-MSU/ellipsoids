classdef EllTubeDynamicSpaceProjector<gras.ellapx.proj.AEllTubePlainProjector
    %IELLTUBEPROJECTOR Summary of this class goes here
    %   Detailed explanation goes here
    properties(Access=private)
        goodDirSetObj
    end
    methods 
        function self=EllTubeDynamicSpaceProjector(projSpaceList,goodDirSetObj)
            self=self@gras.ellapx.proj.AEllTubePlainProjector(projSpaceList);
            self.goodDirSetObj=goodDirSetObj;
        end
    end
    methods (Access=protected)
        function projType=getProjType(~)
            projType=gras.ellapx.enums.EProjType.DynamicAlongGoodCurve;
        end
        function [projOrthMatArray,projOrthMatTransArray]=...
                getProjectionMatrix(self,projSpaceVec,timeVec,...
                varargin)
            import gras.gen.SquareMatVector;
            projDimNumVec=find(projSpaceVec);
            nTimePoints=length(timeVec);
            sizeVec=self.goodDirSetObj.getXstTransSpline.getMatrixSize();
            xstTransArray=self.goodDirSetObj.getXstTransSpline.evaluate(timeVec);
            xstTransProjArray=xstTransArray(:,projDimNumVec,:);
            projOrthMatTransArray=zeros([sizeVec nTimePoints]);
            for iTime=1:1:nTimePoints
                projOrthMatTransArray(:,:,iTime)=gras.la.matorth(...
                    xstTransProjArray(:,:,iTime));
            end
            %
            nProjDims=length(projDimNumVec);
            projOrthMatTransArray=projOrthMatTransArray(:,1:nProjDims,:);
            projOrthMatArray=SquareMatVector.transpose(projOrthMatTransArray);
        end
    end
end
