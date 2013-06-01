classdef LReachDiscrBackwardDynamics < ...
        gras.ellapx.lreachplain.probdyn.AReachDiscrBackwardDynamics & ...
        gras.ellapx.lreachuncert.probdyn.AReachProblemDynamics
    properties (Access=protected)
        xtDynamics
    end
    methods
        function self = LReachDiscrBackwardDynamics(problemDef)
            import gras.ellapx.common.*;
            import gras.mat.CompositeMatrixOperations;
            import gras.interp.MatrixInterpolantFactory;
            %
            if ~isa(problemDef,...
                    'gras.ellapx.lreachuncert.probdef.IReachContProblemDef')
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            %
            % call superclass constructor
            %
            self = self@gras.ellapx.lreachplain.probdyn.AReachDiscrBackwardDynamics(...
                problemDef);
            %
            compOpFact = CompositeMatrixOperations();
            %
            % create inv(A)(t)C(t)Q(t)C'(t)(inv(A)(t))' and 
            % inv(A)(t)C(t)q(t) dynamics
            %
            aMatFcn = MatrixSymbFormulaBased(AtDefCMat);
            aInvMatFcn = compOpFact.inv(aMatFcn);
            ctDefCMat = problemDef.getCMatDef();
            cqcTransDynamics = compOpFact.rSymbMultiply(...
                ctDefCMat, problemDef.getQCMat(), ctDefCMat.');
            self.CQCTransDynamics = compOpFact.rMultiply(...
                aInvMatFcn, cqcTransDynamics, aInvTransMatFcn);
            cqtDynamics = compOpFact.rSymbMultiplyByVec(...
                ctDefCMat, problemDef.getqCVec());
            self.CqtDynamics = compOpFact.rMultiply(...
                aInvMatFcn, cqtDynamics);
            %
            % copy necessary data to local variables
            %
            x0DefVec = problemDef.getx0Vec();
            sysDim = size(problemDef.getAMatDef(), 1);
            nTimePoints = length(self.timeVec);
            %
            % compute x(t)
            %
            xtArray = zeros(sysDim, nTimePoints);
            xtArray(:, 1) = x0DefVec;
            for iTime = 2:nTimePoints
                aMat = self.AtDynamics.evaluate(self.timeVec(iTime));
                bpVec = self.BptDynamics().evaluate(self.timeVec(iTime));
                cqVec = self.getCqtDynamics().evaluate(self.timeVec(iTime));
                xtArray(:, iTime) = ...
                    aMat * (xtArray(:, iTime - 1) - bpVec - cqVec);
            end
            %
            self.xtDynamics = MatrixInterpolantFactory.createInstance(...
                'column', xtArray, self.timeVec);
        end
    end
end