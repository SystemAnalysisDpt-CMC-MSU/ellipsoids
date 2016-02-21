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
            
            cCMat = self.readObj.cCMat;
            Cqt = matOpFactory.rSymbMultiplyByVec(...
                cCMat, self.readObj.qCVec);
            self.checkMatFun(Cqt, self.pDynObj.getCqtDynamics());
            
            CQCTrans = matOpFactory.rSymbMultiply(...
                cCMat, self.readObj.qCMat, cCMat');
            self.checkMatFun(CQCTrans, self.pDynObj.getCQCTransDynamics());
        end
        
        function test_xtDynamics(self)
            XtDerivFunc = @(t,x)...
                self.pDynObj.getAtDynamics().evaluate(t)*x+...
                self.pDynObj.getBptDynamics().evaluate(t)+...
                self.pDynObj.getCqtDynamics().evaluate(t);
            
            XtFunc = @(t)self.pDynObj.getxtDynamics().evaluate(t);
            
            self.checkDerivFun(XtDerivFunc, XtFunc);
        end
    end
end