classdef AReachProblemLTIDynamics<...
        gras.ellapx.lreachplain.IReachProblemDynamics
    properties (Access=protected)
        problemDef
        AtDynamics
        BptDynamics
        BPBTransDynamics
        xtSpline
        Xtt0Spline
        timeVec
    end
    properties (Constant,GetAccess=protected)
        ODE_NORM_CONTROL='on';
        N_TIME_POINTS=1000;
    end
    methods
        function BPBTransDynamics=getBPBTransDynamics(self)
            BPBTransDynamics=self.BPBTransDynamics;
        end
        function AtDynamics=getAtDynamics(self)
            AtDynamics=self.AtDynamics;
        end
        function BptDynamics=getBptDynamics(self)
            BptDynamics=self.BptDynamics;
        end
        function xtDynamics=getxtDynamics(self)
            xtDynamics=self.xtSpline;
        end
        function Xtt0Dynamics=getXtt0Dynamics(self)
            Xtt0Dynamics=self.Xtt0Spline;
        end
        function timeVec=getTimeVec(self)
            timeVec=self.timeVec;
        end
    end
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
            self.Xtt0Spline=MatrixInterpolantFactory.createInstance(...
                'column',data_Xtt0,self.timeVec);
        end
    end
end