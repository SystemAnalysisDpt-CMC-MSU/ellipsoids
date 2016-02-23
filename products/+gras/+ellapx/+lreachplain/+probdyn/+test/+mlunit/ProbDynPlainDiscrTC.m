classdef ProbDynPlainDiscrTC <...
        gras.ellapx.lreachplain.probdyn.test.mlunit.ProbDynPlainTC
    
    methods
        function self = ProbDynPlainDiscrTC(varargin)
            self = self@gras.ellapx.lreachplain.probdyn.test.mlunit.ProbDynPlainTC(varargin{:});
        end
        
        function set_up_param(self, fDynConstr, fReader, relTol, absTol)
            self.readObj = fReader();
            params = self.readObj.getPlainParams();
            self.pDynObj = fDynConstr(params);
            
            self.tVec = self.pDynObj.getTimeVec();
            self.relTol = relTol;
            self.absTol = absTol;
        end
        
        function testDynDiscrGetters(self)
            import gras.mat.MatrixOperationsFactory;
            import gras.mat.CompositeMatrixOperations;
            matOpFactory = MatrixOperationsFactory.create(self.tVec);
            compOpFact = CompositeMatrixOperations();
            
            At = matOpFactory.fromSymbMatrix(self.readObj.aCMat);
            AtInv = compOpFact.inv(At);
            self.checkMatFun(AtInv, self.pDynObj.getAtInvDynamics());
        end
        
        function test_xtDynamics(self)
            fXtFunc = @(t)self.pDynObj.getxtDynamics().evaluate(t);
            
            fXtDiff = @(t)...
                self.pDynObj.getAtDynamics().evaluate(t)*fXtFunc(t)+...
                self.pDynObj.getBptDynamics().evaluate(t)-fXtFunc(t);
            
            self.checkDifFun(fXtDiff, fXtFunc);
        end
        
        function checkDifFun(self, XtDifFunc, XtFunc)
            import modgen.common.absrelcompare;
            TOL_MULT = 10e1;
            
            tVec = self.pDynObj.getTimeVec();
            for iTime=1:numel(tVec)-1
                t0 = tVec(iTime);
                t1 = tVec(iTime+1);
                
                dxVec = XtFunc(t1) - XtFunc(t0);
                dxRefVec = XtDifFunc(t0);
                
                [isEqual,absDif,~,relDif] = absrelcompare(dxRefVec,dxVec,...
                    TOL_MULT*self.absTol, TOL_MULT*self.relTol, @norm);
                
                mlunitext.assert(isEqual,...
                    sprintf(['xtDynamics check failed at '...
                    't=%f: absDif=%f, relDif=%f'], t0, absDif, relDif));
            end
        end
    end
end