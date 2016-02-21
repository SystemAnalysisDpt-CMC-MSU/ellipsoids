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
            XtDifFunc = @(t,x)self.pDynObj.getAtDynamics().evaluate(t)*x...
            +self.pDynObj.getBptDynamics().evaluate(t)-x;
            
            XtFunc = @(t)self.pDynObj.getxtDynamics().evaluate(t);
            
            self.checkDifFun(XtDifFunc, XtFunc);
        end
        
        function checkDifFun(self, XtDifFunc, XtFunc)
            import modgen.common.absrelcompare;
            TOL_MULT = 10e1;
            
            tVec = self.pDynObj.getTimeVec();
            for iElem=1:numel(tVec)-1
                t0 = tVec(iElem);
                t1 = tVec(iElem+1);
                
                xVec = XtFunc(t0);
                dxVec = XtFunc(t1) - XtFunc(t0);
                dxRefVec = XtDifFunc(t0, xVec);
                
                [isEqual,absDif,~,relDif] = absrelcompare(dxRefVec,dxVec,...
                    TOL_MULT*self.absTol, TOL_MULT*self.relTol, @norm);
                
                mlunitext.assert(isEqual,...
                    sprintf(['xtDynamics check failed at '...
                    't=%f: absDif=%f, relDif=%f'], t0, absDif, relDif));
            end
        end
    end
end