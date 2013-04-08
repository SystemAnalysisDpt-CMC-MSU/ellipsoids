classdef AReachProblemLTIDynamics<...
        gras.ellapx.lreachplain.probdyn.AReachProblemDynamics
    methods
        function self=AReachProblemLTIDynamics(problemDef,calcPrecision)
            %
            import modgen.cell.cellstr2func;
            import gras.interp.MatrixInterpolantFactory;
            import gras.gen.MatVector;
            import gras.ode.MatrixODESolver;
            import gras.mat.fcnlib.ConstMatrixFunction;
            import gras.mat.fcnlib.ConstColFunction;
            import gras.mat.MatrixOperationsFactory;
            %
            self.problemDef = problemDef;
            %
            % copy necessary data to local variables
            %
            AMat = MatVector.fromFormulaMat(problemDef.getAMatDef(),0);
            BMat = MatVector.fromFormulaMat(problemDef.getBMatDef(),0);
            PMat = MatVector.fromFormulaMat(problemDef.getPCMat(),0);
            pVec = MatVector.fromFormulaMat(problemDef.getpCVec(),0);
            t0 = problemDef.gett0();
            t1 = problemDef.gett1();
            %
            self.timeVec = linspace(t0,t1,self.N_TIME_POINTS);
            %
            % compute A(t), B(t)p(t) and B(t)P(t)B'(t) dynamics
            %
            self.AtDynamics = ConstMatrixFunction(AMat);
            self.BptDynamics = ConstColFunction(BMat*pVec);
            self.BPBTransDynamics = ConstMatrixFunction(BMat*PMat*(BMat.'));
            %
            % compute X(t,t0)
            %
            
            % (temporary) switching old code usage:
            %
            oldcode = 0;
            %
            if (oldcode)
                % [oldcode]
                matOpFactory = MatrixOperationsFactory.create(self.timeVec);
                self.Rtt0Dynamics = matOpFactory.expmt(self.AtDynamics, t0);
                % [end]
            else
                odeArgList = self.getOdePropList(calcPrecision);
                self.calcRtt0Dyn(size(AMat), numel(AMat), odeArgList);
            end
        end
    end
end