classdef ExtEllApxBuilder<gras.ellapx.lreachplain.ATightEllApxBuilder
    properties (Constant,GetAccess=private)
        APPROX_SCHEMA_NAME='ExternalQ'
        APPROX_SCHEMA_DESCR='External approximation based on matrix ODE for Q'
    end
    methods (Access=protected)
        function resMat=calcEllApxMatrixDeriv(self,ADynamics,...
                BPBTransDynamics,ltSpline,t,QMat)
            import modgen.common.throwerror;
            AMat=ADynamics.evaluate(t);
            ltVec=ltSpline.evaluate(t);            
            BPBTransMat=BPBTransDynamics.evaluate(t);
            piNumerator=realsqrt(sum((BPBTransMat*ltVec).*ltVec));
            piDenominator=realsqrt(sum((QMat*ltVec).*ltVec));
            if piNumerator<=self.absTol
                throwerror('wrongInput:degenerateControlBounds',...
                    ['matrices B,P for control ',...
                    'contraints are either degenerate or ill-conditioned']);
            elseif piDenominator<=self.absTol
                throwerror('wrongInput:estimateDegraded',...
                    'the estimate has degraded, reason unknown');
            end          
            tmpMat=AMat*QMat;
            resMat=tmpMat+tmpMat.'+(piNumerator./piDenominator).*QMat+...
                (piDenominator./piNumerator).*BPBTransMat;
            resMat=(resMat+resMat.')*0.5;
        end
        function fHandle=getEllApxMatrixDerivFunc(self,iGoodDir)
            fHandle=...
                @(t,y)calcEllApxMatrixDeriv(self,...
                self.getProblemDef().getAtDynamics,...
                self.getProblemDef.getBPBTransDynamics,...
                self.getGoodDirSet.getRGoodDirOneCurveSpline(iGoodDir),...
                t,y);
        end
        function QArray=adjustEllApxMatrixVec(~,QArray)
        end
        function initQMat=getEllApxMatrixInitValue(self,~)
            initQMat=self.getProblemDef().getX0Mat();
        end
    end
    methods (Access=protected)
        function apxType=getApxType(~)
            apxType=gras.ellapx.enums.EApproxType.External;
        end
        function [apxSchemaName,apxSchemaDescr]=getApxSchemaNameAndDescr(self)
            apxSchemaName=self.APPROX_SCHEMA_NAME;
            apxSchemaDescr=self.APPROX_SCHEMA_DESCR;
        end
    end
    methods
        function self=ExtEllApxBuilder(varargin)
            self=self@gras.ellapx.lreachplain.ATightEllApxBuilder(...
                varargin{:});
        end
    end
end
