classdef LReachProblemDynamicsInterp<...
        gras.ellapx.lreachplain.AReachProblemDynamicsInterp
    properties (Access=protected)
        xtDynamics
    end
    methods
        function self=LReachProblemDynamicsInterp(problemDef,calcPrecision)
            import gras.ellapx.common.*;
            import gras.interp.MatrixInterpolantFactory;
            import gras.ode.MatrixODESolver;
            %
            if ~isa(problemDef,...
                    'gras.ellapx.lreachplain.IReachContProblemDef')
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            %
            % call superclass constructor
            %
            self=self@gras.ellapx.lreachplain.AReachProblemDynamicsInterp(...
                problemDef,calcPrecision);
            %
            % copy necessary data to local variables
            %
            x0DefVec = problemDef.getx0Vec();
            sysDim = size(problemDef.getAMatDef(), 1);
            %
            % compute x(t)
            %
            odeArgList={'NormControl',self.ODE_NORM_CONTROL,'RelTol',...
                calcPrecision,'AbsTol',calcPrecision};
            solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
            %
            XtDerivFunc = @(t,x) self.AtDynamics.evaluate(t)*x+...
                self.BptDynamics.evaluate(t);
            %
            [timeXtVec,xtArray]=solverObj.solve(XtDerivFunc,...
                self.timeVec,x0DefVec);
            %
            self.xtDynamics=MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
        end
    end
end