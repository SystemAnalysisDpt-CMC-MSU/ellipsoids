classdef IntProperEllApxBuilder<gras.ellapx.lreachplain.ATightIntEllApxBuilder
    properties (Constant,GetAccess=private)
        APPROX_SCHEMA_NAME='InternalJustQ'
        APPROX_SCHEMA_DESCR='Internal approximation based on matrix ODE for (Q)'
    end
    methods (Access=protected)
        function res=calcEllApxMatrixDeriv(self,AtDynamics,...
                BPBSqrtDynamics,ltSpline,t,QMat)
            A=AtDynamics.evaluate(t);
            ltVec=ltSpline.evaluate(t);
            %
            R_sqrt=BPBSqrtDynamics.evaluate(t);
            [VMat,DMat]=eig(QMat);
            Q_star=VMat*sqrt(DMat)*transpose(VMat);
            S=self.getOrthTranslMatrix(Q_star,R_sqrt,R_sqrt*ltVec,Q_star*ltVec);
            tmp=(A*Q_star+R_sqrt*transpose(S))*transpose(Q_star);
            res=tmp+transpose(tmp);
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