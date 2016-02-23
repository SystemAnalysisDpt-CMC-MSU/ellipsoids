classdef ProbDynUncertTC <...
        gras.ellapx.lreachplain.probdyn.test.mlunit.ProbDynPlainTC
    
    methods
        function self = ProbDynUncertTC(varargin)
            self = self@gras.ellapx.lreachplain.probdyn.test.mlunit.ProbDynPlainTC(varargin{:});
        end
        
        function set_up_param(self, fDynConstr, fReader, relTol, absTol)
            self.readObj = fReader();
            params = self.readObj.getUncertParams();
            self.pDynObj = fDynConstr(params, {relTol absTol});
            
            self.tVec = self.pDynObj.getTimeVec();
            self.relTol = relTol;
            self.absTol = absTol;
        end
        
        function testDynUncertGetters(self)
            import gras.mat.MatrixOperationsFactory;
            matOpFactory = MatrixOperationsFactory.create(self.tVec);
            
            bigCMat = self.readObj.cCMat;
            CqtMatFun = matOpFactory.rSymbMultiplyByVec(...
                bigCMat, self.readObj.qCVec);
            self.checkMatFun(CqtMatFun, self.pDynObj.getCqtDynamics());
            
            bigCQCTransMatFun = matOpFactory.rSymbMultiply(...
                bigCMat, self.readObj.qCMat, bigCMat');
            self.checkMatFun(bigCQCTransMatFun,...
                self.pDynObj.getCQCTransDynamics());
        end
        
        function test_xtDynamics(self)
            fXtFunc = @(t)self.pDynObj.getxtDynamics().evaluate(t);
            
            fXtDeriv = @(t,x)...
                self.pDynObj.getAtDynamics().evaluate(t)*fXtFunc(t)+...
                self.pDynObj.getBptDynamics().evaluate(t)+...
                self.pDynObj.getCqtDynamics().evaluate(t);
            
            self.checkDerivFun(fXtDeriv, fXtFunc);
        end
    end
end