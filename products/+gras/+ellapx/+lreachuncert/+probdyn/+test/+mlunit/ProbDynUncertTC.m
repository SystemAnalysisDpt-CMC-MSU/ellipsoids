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
        
        function testDynGetters(self)
            self.testDynGetters@gras.ellapx.lreachplain.probdyn.test.mlunit.ProbDynPlainTC();
            
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
            import gras.ellapx.common.*;
            import gras.mat.interp.MatrixInterpolantFactory;
            import gras.ode.MatrixODESolver;
            
            sysDim = size(self.readObj.aCMat, 1);
            odeArgList=self.getOdePropList();
            solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
            
            XtDerivFunc = @(t,x)self.pDynObj.getAtDynamics().evaluate(t)*x...
            +self.pDynObj.getBptDynamics().evaluate(t)...
            +self.pDynObj.getCqtDynamics().evaluate(t);
        
            [timeXtVec,xtArray]=solverObj.solve(XtDerivFunc,...
                self.tVec,self.readObj.x0Vec);
            
            xt = MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
            
            self.checkMatFun(xt, self.pDynObj.getxtDynamics());
        end
    end
end