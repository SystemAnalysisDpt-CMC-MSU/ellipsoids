classdef LReachProblemDynamicsInterp<...
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
    methods (Static,Access=protected)
        function res=R_Xtt0(At,t,x)
            import gras.gen.SquareMatVector;
            res=reshape(SquareMatVector.fromFormulaMat(At,t)*...
                reshape(x,size(At)),[numel(At) 1]);
        end
    end
    methods (Access=protected)
        function fHandleR_xt = getXtDerivFunc(self)
            fHandleR_xt = @(t,x) self.AtSpline.evaluate(t)*x+...
                self.BptSpline.evaluate(t);
        end
    end
    methods
        function self=LReachProblemDynamicsInterp(problemDef,calcPrecision)
            import gras.ellapx.common.*;
            import gras.interp.MatrixInterpolantFactory;
            import gras.interp.MatrixSymbInterpFactory;
            %
            import gras.gen.SquareMatVector;
            import gras.ellapx.lreachplain.LReachProblemDynamicsInterp;
            import gras.ode.MatrixODESolver;
            %
            if ~isa(problemDef,...
                    'gras.ellapx.lreachplain.IReachContProblemDef')
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            self.problemDef = problemDef;
            %
            ODE_NORM_CONTROL='on';
            %
            nTimePoints=LReachProblemDynamicsInterp.N_TIME_POINTS;
            odeArgList={'NormControl',ODE_NORM_CONTROL,'RelTol',...
                calcPrecision,'AbsTol',calcPrecision};
            %
            AtDefMat = problemDef.getAMatDef();
            BtDefMat = problemDef.getBMatDef();
            PtDefMat = problemDef.getPCMat();
            ptDefVec = problemDef.getpCVec();
            x0DefVec = problemDef.getx0Vec();
            t0 = problemDef.gett0();
            t1 = problemDef.gett1();
            %
            sysDim = size(AtDefMat, 1);
            tVec = linspace(t0,t1,nTimePoints);
            self.timeVec = tVec;
            %
            % compute X(t,t0)
            %
            solverObj=MatrixODESolver([sysDim,sysDim],@ode45,...
                odeArgList{:});
            fHandleR_Xtt0=@(t,x)LReachProblemDynamicsInterp.R_Xtt0(...
                AtDefMat,t,x);
            [timeXtt0Vec,data_Xtt0]=solverObj.solve(fHandleR_Xtt0,tVec,...
                eye(sysDim));
            %
            self.Xtt0Spline=MatrixInterpolantFactory.createInstance(...
                'column',data_Xtt0,timeXtt0Vec);
            %
            % compute A(t), B(t)P(t)B'(t), B(t)p(t)
            %
            self.AtSpline=MatrixSymbInterpFactory.single(AtDefMat);
            %
            self.BPBTransSpline=MatrixSymbInterpFactory.rMultiply(...
                BtDefMat,PtDefMat,BtDefMat.');
            self.BptSpline=MatrixSymbInterpFactory.rMultiplyByVec(...
                BtDefMat,ptDefVec);
            %
            % compute x(t) only if the constructor was called directly
            % i.e. not from a subclass constructor
            %
            if ~isa(self,...
                    'gras.ellapx.lreachuncert.LReachProblemDynamicsInterp')
                solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
                [timeXtVec,xtArray]=solverObj.solve(self.getXtDerivFunc(),...
                    tVec,x0DefVec);
                %
                self.xtSpline=MatrixInterpolantFactory.createInstance(...
                    'column',xtArray,timeXtVec);
            end
        end
    end
end