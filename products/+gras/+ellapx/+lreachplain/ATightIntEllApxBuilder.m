classdef ATightIntEllApxBuilder<gras.ellapx.lreachplain.ATightEllApxBuilder
    properties (Access=private)
        ltSplineList
        BPBTransSqrtDynamics
    end
    methods (Access=protected)
        function ltSpline=getltSpline(self,iGoodDir)
            ltSpline=self.ltSplineList{iGoodDir};
        end
        %
        function resObj=getBPBTransSqrtDynamics(self)
            resObj=self.BPBTransSqrtDynamics;
        end
    end
    methods (Access=protected)
        function apxType=getApxType(~)
            apxType=gras.ellapx.enums.EApproxType.Internal;
        end
    end
    methods (Access=private)
        function self=prepareODEData(self)
            import gras.mat.MatrixOperationsFactory;
            pDefObj = self.getProblemDef();
            matOpFactory = MatrixOperationsFactory.create(...
                pDefObj.getTimeVec());
            self.BPBTransSqrtDynamics = matOpFactory.sqrtmpos(...
                pDefObj.getBPBTransDynamics());
            self.ltSplineList = ...
                self.getGoodDirSet().getRGoodDirOneCurveSplineList();
        end
    end
    methods
        function self=ATightIntEllApxBuilder(pDefObj,goodDirSetObj,...
                timeLimsVec,relTol,absTol,varargin)
            [unparsedArgList,~,sMethodName] = ...
                modgen.common.parseparext(varargin,...
                {'selectionMethodForSMatrix'},[0 2],...
                'isObligatoryPropVec',true);
            self=self@gras.ellapx.lreachplain.ATightEllApxBuilder(pDefObj,...
                goodDirSetObj,timeLimsVec,relTol,absTol,unparsedArgList{:});
            %
            self.sMethodName=sMethodName;
            self.prepareODEData();
        end
    end
end