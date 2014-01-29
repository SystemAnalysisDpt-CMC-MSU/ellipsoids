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
                getProjectionMatrix(self,projMat,timeVec,...
                varargin)
            import gras.gen.SquareMatVector;
            nTimePoints=length(timeVec);
            nProjDims=sum(sum(projMat));
            sizeVec=self.goodDirSetObj.getRstTransDynamics.getMatrixSize();
            rstTransArray=self.goodDirSetObj.getRstTransDynamics.evaluate(timeVec);
            rstTransProjArray=SquareMatVector.rMultiply(rstTransArray,projMat');
            projOrthMatTransArray=zeros([sizeVec(1) nProjDims nTimePoints]);
            %
            for iTime=1:1:nTimePoints
                projOrthMatTransArray(:,:,iTime)=gras.la.matorthcol(...
                    rstTransProjArray(:,:,iTime));
            end
            %
            projOrthMatArray=SquareMatVector.transpose(projOrthMatTransArray);
        end
    end
end
