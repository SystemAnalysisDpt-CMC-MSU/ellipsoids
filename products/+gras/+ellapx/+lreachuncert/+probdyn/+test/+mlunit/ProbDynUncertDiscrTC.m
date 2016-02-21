classdef ProbDynUncertDiscrTC <...
        gras.ellapx.lreachplain.probdyn.test.mlunit.ProbDynPlainDiscrTC&...
        gras.ellapx.lreachuncert.probdyn.test.mlunit.ProbDynUncertTC
    
    methods        
        function self = ProbDynUncertDiscrTC(varargin)
            self = self@gras.ellapx.lreachplain.probdyn.test.mlunit.ProbDynPlainDiscrTC(varargin{:});
        end

        function set_up_param(self, fDynConstr, fReader, relTol, absTol)
            self.readObj = fReader();
            params = self.readObj.getUncertParams();
            self.pDynObj = fDynConstr(params);

            self.tVec = self.pDynObj.getTimeVec();
            self.relTol = relTol;
            self.absTol = absTol;
        end
        
        function test_xtDynamics(self)
            XtDifFunc = @(t,x)...
                self.pDynObj.getAtDynamics().evaluate(t)*x+...
                self.pDynObj.getBptDynamics().evaluate(t)+...
                self.pDynObj.getCqtDynamics().evaluate(t)-x;
            
            XtFunc = @(t)self.pDynObj.getxtDynamics().evaluate(t);
            
            self.checkDifFun(XtDifFunc, XtFunc);
        end
    end
end