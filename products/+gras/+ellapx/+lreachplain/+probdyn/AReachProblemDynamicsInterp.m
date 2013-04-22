classdef AReachProblemDynamicsInterp<...
        gras.ellapx.lreachplain.probdyn.AReachProblemDynamics
    methods
        function self=AReachProblemDynamicsInterp(problemDef, calcPrecision)
            %
            import gras.ellapx.common.*;
            import gras.mat.MatrixOperationsFactory;
            %
            % call superclass constructor
            %
            self=self@gras.ellapx.lreachplain.probdyn.AReachProblemDynamics(...
                problemDef);
            %
            % copy necessary data to local variables
            %
            AtDefCMat = problemDef.getAMatDef();
            %
            % create dynamics for A(t), B(t)P(t)B'(t) and B(t)p(t)
            %
            matOpFactory = MatrixOperationsFactory.create(self.timeVec);
            %
            self.AtDynamics = matOpFactory.fromSymbMatrix(AtDefCMat);
            BtDefCMat = problemDef.getBMatDef();
            self.BPBTransDynamics = matOpFactory.rSymbMultiply(...
                BtDefCMat, problemDef.getPCMat(), BtDefCMat.');
            self.BptDynamics = matOpFactory.rSymbMultiplyByVec(...
                BtDefCMat, problemDef.getpCVec());
        end
    end
end