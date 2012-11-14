classdef AReachProblemDynamicsInterp<...
        gras.ellapx.lreachplain.IReachProblemDynamics
    properties (Access=protected)
        problemDef
        AtSpline
        BptSpline
        xtSpline
        BPBTransSpline
        Xtt0Spline
        timeVec
    end
    properties (Constant,GetAccess=protected)
        N_TIME_POINTS=1000;
        ODE_NORM_CONTROL='on';
    end
    methods
        function BPBTransDynamics=getBPBTransDynamics(self)
            BPBTransDynamics=self.BPBTransSpline;
        end
        function AtDynamics=getAtDynamics(self)
            AtDynamics=self.AtSpline;
        end
        function BptDynamics=getBptDynamics(self)
            BptDynamics=self.BptSpline;
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
        function self=AReachProblemDynamicsInterp(problemDef,calcPrecision)
            import gras.ellapx.common.*;
            import gras.interp.MatrixInterpolantFactory;
            import gras.interp.MatrixSymbInterpFactory;
            import gras.gen.SquareMatVector;
            import gras.ellapx.lreachplain.LReachProblemDynamicsInterp;
            import gras.ode.MatrixODESolver;
            %
            self.problemDef = problemDef;
            %
            % copy necessary data to local variables
            %
            AtDefMat = problemDef.getAMatDef();
            BtDefMat = problemDef.getBMatDef();
            PtDefMat = problemDef.getPCMat();
            ptDefVec = problemDef.getpCVec();
            t0 = problemDef.gett0();
            t1 = problemDef.gett1();
            sizeAtVec = size(AtDefMat);
            numelAt = numel(AtDefMat);
            %
            % compute X(t,t0)
            %
            self.timeVec = linspace(t0,t1,self.N_TIME_POINTS);
            %
            odeArgList={'NormControl',self.ODE_NORM_CONTROL,'RelTol',...
                calcPrecision,'AbsTol',calcPrecision};
            solverObj=MatrixODESolver(sizeAtVec,@ode45,odeArgList{:});
            %
            Xtt0DerivFunc = @(t,x) reshape(...
                SquareMatVector.fromFormulaMat(AtDefMat,t)*...
                reshape(x,sizeAtVec),[numelAt 1]);
            Xtt0InitialMat = eye(sizeAtVec);
            %
            [timeXtt0Vec,data_Xtt0]=solverObj.solve(Xtt0DerivFunc,...
                self.timeVec,Xtt0InitialMat);
            %
            self.Xtt0Spline=MatrixInterpolantFactory.createInstance(...
                'column',data_Xtt0,timeXtt0Vec);
            %
            % compute A(t)
            %
            self.AtSpline=MatrixSymbInterpFactory.single(AtDefMat);
            %
            % compute B(t)P(t)B'(t)
            %
            self.BPBTransSpline=MatrixSymbInterpFactory.rMultiply(...
                BtDefMat,PtDefMat,BtDefMat.');
            %
            % compute B(t)p(t)
            %
            self.BptSpline=MatrixSymbInterpFactory.rMultiplyByVec(...
                BtDefMat,ptDefVec);
        end
    end
end