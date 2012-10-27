classdef IntEllApxBuilder<gras.ellapx.lreachplain.ATightIntEllApxBuilder
    properties (Access=private)
        S0X0SqrtMat
        l0Mat
    end
    properties (Constant,GetAccess=private)
        APPROX_SCHEMA_NAME='InternalSqrtQ'
        APPROX_SCHEMA_DESCR='Internal approximation based on matrix ODE for sqrt(Q)'
    end
    methods (Access=protected)
        function res=calcEllApxMatrixDeriv(self,At_spline,...
                BPBSqrtSpline,ltSpline,l0Vec,t,Q_star)
            A=At_spline.evaluate(t);
            ltVec=ltSpline.evaluate(t);
            R_sqrt=BPBSqrtSpline.evaluate(t);
            %
            S=self.getOrthTranslMatrix(Q_star,R_sqrt,R_sqrt*ltVec,l0Vec);
            res=A*Q_star+R_sqrt*transpose(S);
        end 
        function fHandle=getEllApxMatrixDerivFunc(self,iGoodDir)
                fHandle=...
                    @(t,y)calcEllApxMatrixDeriv(self,...
                    self.getProblemDef().getAtSpline(),...
                    self.getBPBTransSqrtSpline(),...
                    self.getltSpline(iGoodDir),...
                    self.l0Mat(:,iGoodDir),...
                    t,y);     
        end        
        function QArray=adjustEllApxMatrixVec(~,QArray)
            import gras.gen.SquareMatVector;
            QArray=SquareMatVector.rMultiply(QArray,SquareMatVector.transpose(...
                QArray));
        end
        function initQMat=getEllApxMatrixInitValue(self,~)
            initQMat=self.S0X0SqrtMat;
        end
    end
    methods (Access=protected)
        function [apxSchemaName,apxSchemaDescr]=getApxSchemaNameAndDescr(self)
            apxSchemaName=self.APPROX_SCHEMA_NAME;
            apxSchemaDescr=self.APPROX_SCHEMA_DESCR;
        end    
    end
    methods
        function self=IntEllApxBuilder(varargin)
            import gras.interp.MatrixInterpolantFactory;            
            self=self@gras.ellapx.lreachplain.ATightIntEllApxBuilder(...
                varargin{:});
            X0sqrt=sqrtm(self.getProblemDef().getX0Mat);
            self.S0X0SqrtMat=X0sqrt;            
            pDefObj=self.getProblemDef();            
            sysDim=pDefObj.getDimensionality();
            pTimeLimsVec=pDefObj.getTimeLimsVec();
            startTime=pTimeLimsVec(1);
            s0Mat=eye(sysDim);
            goodDirCurveSpline=self.getGoodDirSet().getGoodDirCurveSpline();
            self.l0Mat=s0Mat*X0sqrt*goodDirCurveSpline.evaluate(startTime);
        end
    end
end
