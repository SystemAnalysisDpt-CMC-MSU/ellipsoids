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
            AtDefCMat = problemDef.getAMatDef();
            BtDefCMat = problemDef.getBMatDef();
            t0 = problemDef.gett0();
            t1 = problemDef.gett1();
            sizeAtVec = size(AtDefCMat);
            %
            self.timeVec = t0:t1;
            nTimePoints = length(self.timeVec);
            %
            % create dynamics for A(t), inv(A)(t), 
            % B(t)P(t)B'(t) and B(t)p(t)
            %
            compOpFact = CompositeMatrixOperations();
            %
            aMatFcn = MatrixSymbFormulaBased(AtDefCMat);
            aInvMatFcn = compOpFact.inv(aMatFcn);
            self.AtDynamics = aMatFcn;
            self.AtInvDynamics = aInvMatFcn;
            self.BPBTransDynamics = compOpFact.rSymbMultiply(...
                BtDefCMat, problemDef.getPCMat(), BtDefCMat.');
            self.BptDynamics = compOpFact.rSymbMultiplyByVec(...
                BtDefCMat, problemDef.getpCVec());
            %
            % compute X(t,t0)
            %
            data_Xtt0 = zeros([sizeAtVec nTimePoints]);
            data_Xtt0(:, :, 1) = eye(sizeAtVec);
            for iTime = 2:nTimePoints
                data_Xtt0(:, :, iTime) = ...
                    self.AtDynamics.evaluate(self.timeVec(iTime - 1)) * ...
                    data_Xtt0(:, :, iTime - 1);
            end
            %
            self.Xtt0Dynamics = MatrixInterpolantFactory.createInstance(...
                'column', data_Xtt0, self.timeVec);
        end
    end
end