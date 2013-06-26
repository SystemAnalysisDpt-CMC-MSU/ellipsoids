classdef AReachProblemLTIDynamics<...
        gras.ellapx.lreachplain.probdyn.AReachProblemDynamics
    methods
        function self=AReachProblemLTIDynamics(problemDef,calcPrecision)
            %
            import modgen.cell.cellstr2func;
            import gras.gen.MatVector;
            import gras.mat.ConstMatrixFunctionFactory;
            import gras.mat.MatrixOperationsFactory;
            %
            % call superclass constructor
            %
            self = ...
                self@gras.ellapx.lreachplain.probdyn.AReachProblemDynamics(...
                problemDef);
            %
            % copy necessary data to local variables
            %
            AMat = MatVector.fromFormulaMat(problemDef.getAMatDef(),0);
            BMat = MatVector.fromFormulaMat(problemDef.getBMatDef(),0);
            PMat = MatVector.fromFormulaMat(problemDef.getPCMat(),0);
            pVec = MatVector.fromFormulaMat(problemDef.getpCVec(),0);
            %
            % compute A(t), B(t)p(t) and B(t)P(t)B'(t) dynamics
            %
            self.AtDynamics = ...
                ConstMatrixFunctionFactory.createInstance(AMat);
            self.BptDynamics = ...
                ConstMatrixFunctionFactory.createInstance(BMat*pVec);
            self.BPBTransDynamics = ...
                ConstMatrixFunctionFactory.createInstance(...
                BMat*PMat*(BMat.'));
        end
    end
end