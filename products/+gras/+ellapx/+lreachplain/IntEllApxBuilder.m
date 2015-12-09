classdef IntEllApxBuilder<gras.ellapx.lreachplain.ATightIntEllApxBuilder
    properties (Access=private)
        bigS0X0SqrtMat
        l0Mat
    end
    properties (Constant,GetAccess=private)
        APPROX_SCHEMA_NAME='InternalSqrtQ'
        APPROX_SCHEMA_DESCR='Internal approximation based on matrix ODE for sqrt(Q)'
    end
    methods (Access=protected)
        function dMat=calcEllApxMatrixDeriv(self,AtDynamics,...
                bigBPBSqrtDynamics,ltSpline,l0Vec,t,bigQMat)
            bigAMat=AtDynamics.evaluate(t);
            ltVec=ltSpline.evaluate(t);
            bigRSqrtMat=bigBPBSqrtDynamics.evaluate(t);
            bigSMat=self.getOrthTranslMatrix(bigQMat,bigRSqrtMat,...
                bigRSqrtMat*ltVec,l0Vec);
            dMat=bigAMat*bigQMat+bigRSqrtMat*transpose(bigSMat);
        end
        function fHandle=getEllApxMatrixDerivFunc(self,iGoodDir)
            fHandle=...
                @(t,y)calcEllApxMatrixDeriv(self,...
                self.getProblemDef().getAtDynamics(),...
                self.getBPBTransSqrtDynamics(),...
                self.getltSpline(iGoodDir),...
                self.l0Mat(:,iGoodDir),...
                t,y);
        end
        function bigQArray=adjustEllApxMatrixVec(~,bigQArray)
            import gras.gen.SquareMatVector;
            bigQArray=SquareMatVector.rMultiply(bigQArray,...
                SquareMatVector.transpose(...
                bigQArray));
        end
        function initQMat=getEllApxMatrixInitValue(self,~)
            initQMat=self.bigS0X0SqrtMat;
        end
    end
    methods (Access=protected)
        function [apxSchemaName,apxSchemaDescr]=getApxSchemaNameAndDescr(...
                self)
            apxSchemaName=self.APPROX_SCHEMA_NAME;
            apxSchemaDescr=self.APPROX_SCHEMA_DESCR;
        end
    end
    methods
        function self=IntEllApxBuilder(varargin)
            self=self@gras.ellapx.lreachplain.ATightIntEllApxBuilder(...
                varargin{:});
            bigX0SqrtMat=gras.la.sqrtmpos(self.getProblemDef().getX0Mat);
            self.bigS0X0SqrtMat=bigX0SqrtMat;
            pDefObj=self.getProblemDef();
            sysDim=pDefObj.getDimensionality();
            pTimeLimsVec=pDefObj.getTimeLimsVec();
            startTime=pTimeLimsVec(1);
            s0Mat=eye(sysDim);
            goodDirCurveSpline=self.getGoodDirSet().getGoodDirCurveSpline();
            self.l0Mat=s0Mat*bigX0SqrtMat*goodDirCurveSpline.evaluate(...
                startTime);
        end
    end
end
