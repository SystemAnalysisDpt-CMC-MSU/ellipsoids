classdef IntProperEllApxBuilder<gras.ellapx.lreachplain.ATightIntEllApxBuilder
    properties (Constant,GetAccess=private)
        APPROX_SCHEMA_NAME='InternalJustQ'
        APPROX_SCHEMA_DESCR='Internal approximation based on matrix ODE for (Q)'
    end
    methods (Access=protected)
        function res=calcEllApxMatrixDeriv(self,AtDynamics,...
                BPBSqrtDynamics,ltSpline,t,QMat)
            AMat=AtDynamics.evaluate(t);
            ltVec=ltSpline.evaluate(t);
            RSqrtMat=BPBSqrtDynamics.evaluate(t);
            QSqrtMat=gras.la.sqrtmpos(QMat);
            %
            SMat=self.getOrthTranslMatrix(QSqrtMat,RSqrtMat,RSqrtMat*ltVec,...
                QSqrtMat*ltVec);
            tmpMat=(AMat*QSqrtMat+RSqrtMat*transpose(SMat))*transpose(QSqrtMat);
            res=tmpMat+tmpMat.';
        end
        function fHandle=getEllApxMatrixDerivFunc(self,iGoodDir)
            fHandle=...
                @(t,y)calcEllApxMatrixDeriv(self,...
                self.getProblemDef().getAtDynamics(),...
                self.getBPBTransSqrtDynamics(),...
                self.getltSpline(iGoodDir),...
                t,y);
        end
        function QArray=adjustEllApxMatrixVec(~,QArray)
        end
        function initQMat=getEllApxMatrixInitValue(self,~)
            initQMat=self.getProblemDef().getX0Mat();
        end
    end
    methods (Access=protected)
        function [apxSchemaName,apxSchemaDescr]=getApxSchemaNameAndDescr(self)
            apxSchemaName=self.APPROX_SCHEMA_NAME;
            apxSchemaDescr=self.APPROX_SCHEMA_DESCR;
        end
    end
    methods
        function self=IntProperEllApxBuilder(varargin)
            self=self@gras.ellapx.lreachplain.ATightIntEllApxBuilder(...
                varargin{:});
        end
    end
end