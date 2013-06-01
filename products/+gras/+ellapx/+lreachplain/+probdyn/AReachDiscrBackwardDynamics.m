classdef AReachDiscrBackwardDynamics <...
        gras.ellapx.lreachplain.probdyn.AReachProblemDynamics
    properties (Access=protected)
        AtInvDynamics
    end
    methods
        function AtInvDynamics = getAtInvDynamics(self)
            AtInvDynamics = self.AtInvDynamics;
        end
        %
        function self = AReachDiscrBackwardDynamics(problemDef)
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
            self.timeVec = fliplr(t1:t0);
            %
            % create dynamics for A(t), inv(A)(t),
            % inv(A)(t)B(t)P(t)B'(t)(inv(A)(t))' and inv(A)(t)B(t)p(t)
            %
            compOpFact = CompositeMatrixOperations();
            %
            aMatFcn = MatrixSymbFormulaBased(atDefCMat);
            aInvMatFcn = compOpFact.inv(aMatFcn);
            aInvTransMatFcn = compOpFact.transpose(aInvMatFcn);
            self.AtDynamics = aInvMatFcn;
            self.AtInvDynamics = aMatFcn;
            bpbTransDynamics = compOpFact.rSymbMultiply(...
                btDefCMat, problemDef.getPCMat(), btDefCMat.');
            self.BPBTransDynamics = compOpFact.rMultiply(...
                aInvMatFcn, bpbTransDynamics, aInvTransMatFcn);
            bptDynamics = compOpFact.rSymbMultiplyByVec(...
                btDefCMat, problemDef.getpCVec());
            self.BptDynamics = compOpFact.rMultiply(...
                aInvMatFcn, bptDynamics);
        end
    end
end