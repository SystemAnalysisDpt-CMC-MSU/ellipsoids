classdef LReachDiscrForwardDynamics < ...
        gras.ellapx.lreachplain.probdyn.AReachDiscrForwardDynamics & ...
        gras.ellapx.lreachuncert.probdyn.AReachProblemDynamics
    properties (Access=protected)
        xtDynamics
    end
    methods
        function self = LReachDiscrForwardDynamics(problemDef)
            import gras.ellapx.common.*;
            import gras.mat.CompositeMatrixOperations;
            %
            if ~isa(problemDef,...
                    'gras.ellapx.lreachuncert.probdef.IReachContProblemDef')
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            %
            % call superclass constructor
            %
            self = self@gras.ellapx.lreachplain.probdyn.AReachDiscrForwardDynamics(...
                problemDef);
            %
            compOpFact = CompositeMatrixOperations();
            %
            % create C(t)Q(t)C'(t) and C(t)q(t) dynamics
            %
            CtDefCMat = problemDef.getCMatDef();
            self.CQCTransDynamics = compOpFact.rSymbMultiply(...
                CtDefCMat, problemDef.getQCMat(), CtDefCMat.');
            self.CqtDynamics = compOpFact.rSymbMultiplyByVec(...
                CtDefCMat, problemDef.getqCVec());
        end
    end
end