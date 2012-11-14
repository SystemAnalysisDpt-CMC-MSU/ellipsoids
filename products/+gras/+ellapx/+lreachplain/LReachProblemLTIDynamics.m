classdef LReachProblemLTIDynamics<...
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
        function self=LReachProblemLTIDynamics(problemDef,calcPrecision)
            %
            import modgen.cell.cellstr2func;
            import gras.interp.MatrixInterpolantFactory;
            import gras.gen.MatVector;
            import gras.ode.MatrixODESolver;
            %
            if ~(isa(self,'gras.ellapx.lreachplain.LReachProblemLTIDynamics')&&...
                    isa(problemDef,'gras.ellapx.lreachplain.ReachContLTIProblemDef')||...
                    isa(self,'gras.ellapx.lreachuncert.LReachProblemLTIDynamics')&&...
                    isa(problemDef,'gras.ellapx.lreachuncert.ReachContLTIProblemDef'))
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            %
            self.problemDef = problemDef;
            %
            AMat = MatVector.fromFormulaMat(problemDef.getAMatDef(),0);
            BMat = MatVector.fromFormulaMat(problemDef.getBMatDef(),0);
            PMat = MatVector.fromFormulaMat(problemDef.getPCMat(),0);
            pVec = MatVector.fromFormulaMat(problemDef.getpCVec(),0);
            BpVec = BMat*pVec;
            BPBTransMat = BMat*PMat*(BMat.');
            %
            self.AtDynamics = gras.gen.ConstMatrixFunction( AMat );
            self.BptDynamics = gras.gen.ConstMatrixFunction( BpVec );
            self.BPBTransDynamics = gras.gen.ConstMatrixFunction(...
                BPBTransMat );
            %
            % setup ode solver
            %
            ODE_NORM_CONTROL='on';
            sysDim=size(AMat,1);
            nTimePoints=self.N_TIME_POINTS;
            tVec=linspace(problemDef.gett0(),problemDef.gett1(),...
                nTimePoints);
            self.timeVec = tVec;
            odeArgList={'NormControl',ODE_NORM_CONTROL,'RelTol',...
                calcPrecision,'AbsTol',calcPrecision};
            %
            % compute X(t,t0)
            %
            solverObj=MatrixODESolver([sysDim,sysDim],@ode45,...
                odeArgList{:});
            sizeVec = size(AMat);
            nElem = numel(AMat);
            fHandleR_Xtt0=@(t,x)reshape(AMat*reshape(x,sizeVec),[nElem 1]);
            [timeXtt0Vec,data_Xtt0]=solverObj.solve(fHandleR_Xtt0,tVec,...
                eye(sysDim));
            %
            self.Xtt0Spline=MatrixInterpolantFactory.createInstance(...
                'column',data_Xtt0,timeXtt0Vec);
            %
            % compute x(t) only if the constructor was called directly
            % i.e. not from a subclass constructor
            %
            if ~isa(self,...
                    'gras.ellapx.lreachuncert.LReachProblemLTIDynamics')
                solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
                fHandleR_xt = @(t,x) AMat*x+BpVec;
                [timeXtVec,xtArray]=solverObj.solve(fHandleR_xt,...
                    tVec,problemDef.getx0Vec());
                %
                self.xtSpline=MatrixInterpolantFactory.createInstance(...
                    'column',xtArray,timeXtVec);
            end
        end
    end
end