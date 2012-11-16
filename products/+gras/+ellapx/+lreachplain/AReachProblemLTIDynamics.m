classdef AReachProblemLTIDynamics<...
        gras.ellapx.lreachplain.AReachProblemDynamics
    methods
        function self=AReachProblemLTIDynamics(problemDef,calcPrecision)
            %
            import modgen.cell.cellstr2func;
            import gras.interp.MatrixInterpolantFactory;
            import gras.gen.MatVector;
            import gras.ode.MatrixODESolver;
            import gras.mat.ConstMatrixFunction;
            import gras.mat.ConstColFunction;
            %
            self.problemDef = problemDef;
            %
            % copy necessary data to local variables
            %
            AMat = MatVector.fromFormulaMat(problemDef.getAMatDef(),0);
            BMat = MatVector.fromFormulaMat(problemDef.getBMatDef(),0);
            PMat = MatVector.fromFormulaMat(problemDef.getPCMat(),0);
            pVec = MatVector.fromFormulaMat(problemDef.getpCVec(),0);
            BpVec = BMat*pVec;
            BPBTransMat = BMat*PMat*(BMat.');
            t0 = problemDef.gett0();
            t1 = problemDef.gett1();
            sysDim=size(AMat,1);
            %
            % compute A(t), B(t)p(t) and B(t)P(t)B'(t) dynamics
            %
            self.AtDynamics = ConstMatrixFunction(AMat);
            self.BptDynamics = ConstColFunction(BpVec);
            self.BPBTransDynamics = ConstMatrixFunction(BPBTransMat);
            %
            % compute X(t,t0)
            %
            self.timeVec = linspace(t0,t1,self.N_TIME_POINTS);
            data_Xtt0 = zeros([sysDim, sysDim, self.N_TIME_POINTS]);
            for iTimePoint = 1:self.N_TIME_POINTS
                t = self.timeVec(iTimePoint)-t0;
                data_Xtt0(:,:,iTimePoint) = expm(AMat*t);
            end
            self.Xtt0Dynamics=MatrixInterpolantFactory.createInstance(...
                'column',data_Xtt0,self.timeVec);
        end
    end
end