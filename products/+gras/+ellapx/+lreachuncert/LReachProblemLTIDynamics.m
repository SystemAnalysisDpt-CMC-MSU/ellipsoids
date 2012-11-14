classdef LReachProblemLTIDynamics<...
        gras.ellapx.lreachuncert.IReachProblemDynamics & ...
        gras.ellapx.lreachplain.LReachProblemLTIDynamics
    properties (Access=protected)
        CQCTransDynamics
        CqtDynamics
    end
    methods
        function CqtDynamics=getCqtDynamics(self)
            CqtDynamics=self.CqtDynamics;
        end
        function CQCTransDynamics=getCQCTransDynamics(self)
            CQCTransDynamics=self.CQCTransDynamics;
        end
        function self=LReachProblemLTIDynamics(problemDef,calcPrecision)
            import gras.interp.MatrixInterpolantFactory;
            import gras.gen.MatVector;
            import gras.ode.MatrixODESolver;
            %
            self=self@gras.ellapx.lreachplain.LReachProblemLTIDynamics(...
                problemDef,calcPrecision);
            %
            if ~isa(problemDef,...
                    'gras.ellapx.lreachuncert.ReachContLTIProblemDef')
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            %
            CMat = MatVector.fromFormulaMat(problemDef.getCMatDef(),0);
            QMat = MatVector.fromFormulaMat(problemDef.getQCMat(),0);
            qVec = MatVector.fromFormulaMat(problemDef.getqCVec(),0);
            CqVec = CMat*qVec;
            %
            self.CqtDynamics = gras.gen.ConstMatrixFunction( CqVec );
            self.CQCTransDynamics = gras.gen.ConstMatrixFunction( ...
                CMat*QMat*(CMat.') );
            %
            % setup ode solver
            %
            ODE_NORM_CONTROL='on';
            sysDim=size(problemDef.getAMatDef(),1);
            nTimePoints=self.N_TIME_POINTS;
            tVec=linspace(problemDef.gett0(),problemDef.gett1(),...
                nTimePoints);
            odeArgList={'NormControl',ODE_NORM_CONTROL,'RelTol',...
                calcPrecision,'AbsTol',calcPrecision};
            %
            % compute x(t)
            %
            AMat = self.getAtDynamics().evaluate(0);
            BpVec = self.getBptDynamics().evaluate(0);
            BpPlusCqVec = BpVec+CqVec;
            solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
            fHandleR_xt = @(t,x) AMat*x+BpPlusCqVec;
            [timeXtVec,xtArray]=solverObj.solve(fHandleR_xt,...
                tVec,problemDef.getx0Vec());
            %
            self.xtSpline=MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
        end
    end
end