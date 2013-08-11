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
                getProjectionMatrix(self,projMat,timeVec,varargin)
            import modgen.common.throwwarn
%             ABS_TOL = 1e-12;
            kSize = size(projMat,1);
%             if ~all(abs(projMat*projMat'-eye(kSize))< ABS_TOL)
%                 throwwarn('WrongInput','projMat is not orthogonal');
%             end
            projMat = gras.la.matorth(projMat');
            projMat = projMat(1:kSize,:);
            nTimes=length(timeVec);
            projOrthMatArray=repmat(projMat,[1 1 nTimes]);
            projOrthMatTransArray=repmat(projMat.',[1 1 nTimes]);            
        end
    end
end
