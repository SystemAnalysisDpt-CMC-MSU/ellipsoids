classdef LReachDiscrBackwardDynamics < ...
        gras.ellapx.lreachplain.probdyn.AReachDiscrBackwardDynamics & ...
        gras.ellapx.lreachuncert.probdyn.AReachProblemDynamics
    properties (Access=protected)
        xtDynamics
    end
    methods
        function self = LReachDiscrBackwardDynamics(problemDef)
            import gras.ellapx.common.*;
            import gras.mat.symb.MatrixSymbFormulaBased;
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
            CtDefCMat = problemDef.getCMatDef();
            CQCTransDynamics = compOpFact.rSymbMultiply(...
                CtDefCMat, problemDef.getQCMat(), CtDefCMat.');
            self.CQCTransDynamics = compOpFact.rMultiply(...
                aInvMatFcn, CQCTransDynamics, aInvTransMatFcn);
            CqtDynamics = compOpFact.rSymbMultiplyByVec(...
                CtDefCMat, problemDef.getqCVec());
            self.CqtDynamics = compOpFact.rMultiply(...
                aInvMatFcn, CqtDynamics);
        end
    end
end