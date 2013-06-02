classdef AReachDiscrForwardDynamics <...
        gras.ellapx.lreachplain.probdyn.AReachProblemDynamics
    properties (Access=protected)
        AtInvDynamics
    end
    methods
        function AtInvDynamics = getAtInvDynamics(self)
            AtInvDynamics = self.AtInvDynamics;
        end
        %
        function self = AReachDiscrForwardDynamics(problemDef)
            import gras.ellapx.common.*;
            import gras.mat.symb.MatrixSymbFormulaBased;
            import gras.mat.CompositeMatrixOperations;
            import gras.interp.MatrixInterpolantFactory;
            %
            self.problemDef = problemDef;
            %
            % copy necessary data to local variables
            %
            atDefCMat = problemDef.getAMatDef();
            btDefCMat = problemDef.getBMatDef();
            t0 = problemDef.gett0();
            t1 = problemDef.gett1();
            %
            self.timeVec = t0:t1;
            %
            % create dynamics for A(t), inv(A)(t), 
            % B(t)P(t)B'(t) and B(t)p(t)
            %
            compOpFact = CompositeMatrixOperations();
            %
            aMatFcn = MatrixSymbFormulaBased(atDefCMat);
            aInvMatFcn = compOpFact.inv(aMatFcn);
            self.AtDynamics = aMatFcn;
            self.AtInvDynamics = aInvMatFcn;
            self.BPBTransDynamics = compOpFact.rSymbMultiply(...
                btDefCMat, problemDef.getPCMat(), btDefCMat.');
            self.BptDynamics = compOpFact.rSymbMultiplyByVec(...
                btDefCMat, problemDef.getpCVec());
        end
    end
end