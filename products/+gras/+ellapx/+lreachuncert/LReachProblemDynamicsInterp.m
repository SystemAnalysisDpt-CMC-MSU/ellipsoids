classdef LReachProblemDynamicsInterp<...
        gras.ellapx.lreachuncert.IReachProblemDynamics & ...
        gras.ellapx.lreachplain.LReachProblemDynamicsInterp
    properties (Access=protected)
        CQCTransSpline
        CqtSpline
    end
    methods (Access=protected)
        function fHandleR_xt = getXtDerivFunc(self)
            fHandleR_xt = @(t,x) self.AtSpline.evaluate(t)*x+...
                self.BptSpline.evaluate(t)+self.CqtSpline.evaluate(t);
        end
    end
    methods
        function CqtDynamics=getCqtDynamics(self)
            CqtDynamics=self.CqtSpline;
        end
        function CQCTransDynamics=getCQCTransDynamics(self)
            CQCTransDynamics=self.CQCTransSpline;
        end
        function self=LReachProblemDynamicsInterp(problemDef,calcPrecision)
            import gras.interp.MatrixSymbInterpFactory;
            import gras.interp.MatrixInterpolantFactory;
            import gras.gen.SquareMatVector;
            import gras.ode.MatrixODESolver;
            %
            self=self@gras.ellapx.lreachplain.LReachProblemDynamicsInterp(...
                problemDef,calcPrecision);
            %
            if ~isa(problemDef,...
                    'gras.ellapx.lreachuncert.IReachContProblemDef')
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            %
            % compute C(t)Q(t)C'(t), C(t)q(t)
            %
            CtDefMat = problemDef.getCMatDef();
            self.CQCTransSpline=MatrixSymbInterpFactory.rMultiply(...
                CtDefMat,problemDef.getQCMat(),CtDefMat.');
            %
            self.CqtSpline=MatrixSymbInterpFactory.rMultiplyByVec(...
                CtDefMat,problemDef.getqCVec());
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
            solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
            [timeXtVec,xtArray]=solverObj.solve(self.getXtDerivFunc(),...
                tVec,problemDef.getx0Vec());
            %
            self.xtSpline=MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
        end
    end
end