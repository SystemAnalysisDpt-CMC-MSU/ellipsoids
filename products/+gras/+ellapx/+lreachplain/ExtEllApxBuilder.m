classdef ExtEllApxBuilder<gras.ellapx.lreachplain.TATightEllApxBuilder
    properties (Constant,GetAccess=private)
        APPROX_SCHEMA_NAME='ExternalQ'
        APPROX_SCHEMA_DESCR='External approximation based on matrix ODE for Q'
    end
    methods (Access=protected)
        function resMat=calcEllApxMatrixDeriv(self,ADynamics,...
                bigBPBTransDynamics,ltSpline,t,bigQMat)
            import modgen.common.throwerror;
            bigAMat=ADynamics.evaluate(t);
            ltVec=ltSpline.evaluate(t);
            ltVec=ltVec./norm(ltVec);
            %
            bigBPBTransMat=bigBPBTransDynamics.evaluate(t);
            piNumerator=realsqrt(sum((bigBPBTransMat*ltVec).*ltVec));
            piDenominator=realsqrt(sum((bigQMat*ltVec).*ltVec));
            if piNumerator<=self.absTol
                throwerror('wrongInput:degenerateControlBounds',...
                    ['matrices B,P for control ',...
                    'contraints are found either degenerate ',...
                    'or ill-conditioned with absolute precision=%g'],...
                    self.absTol);
            elseif piDenominator<=self.absTol
                throwerror('wrongInput:estimateDegraded',...
                    'the estimate has degraded, reason unknown');
            end          
            tmpMat=bigAMat*bigQMat;
            resMat=tmpMat+tmpMat.'+(piNumerator./piDenominator).*bigQMat+...
                (piDenominator./piNumerator).*bigBPBTransMat;
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
            self=self@gras.ellapx.lreachplain.TATightEllApxBuilder(...
                varargin{:});
        end
    end
end