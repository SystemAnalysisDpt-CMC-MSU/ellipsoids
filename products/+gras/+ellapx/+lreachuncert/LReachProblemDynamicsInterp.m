classdef LReachProblemDynamicsInterp<...
        gras.ellapx.lreachplain.AReachProblemDynamicsInterp & ...
        gras.ellapx.lreachuncert.IReachProblemDynamics
    properties (Access=protected)
        CQCTransSpline
        CqtSpline
    end
    methods
        function CqtDynamics=getCqtDynamics(self)
            CqtDynamics=self.CqtSpline;
        end
        function CQCTransDynamics=getCQCTransDynamics(self)
            CQCTransDynamics=self.CQCTransSpline;
        end
        function self=LReachProblemDynamicsInterp(problemDef,calcPrecision)
            import gras.ellapx.common.*;
            import gras.interp.MatrixInterpolantFactory;
            import gras.interp.MatrixSymbInterpFactory;
            import gras.ode.MatrixODESolver;
            %
            if ~isa(problemDef,...
                    'gras.ellapx.lreachuncert.IReachContProblemDef')
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
            CtDefMat = problemDef.getCMatDef();
            QCMat = problemDef.getQCMat();
            qCVec = problemDef.getqCVec();
            x0DefVec = problemDef.getx0Vec();
            sysDim = size(problemDef.getAMatDef(), 1);
            %
            % compute C(t)Q(t)C'(t)
            %
            self.CQCTransSpline=MatrixSymbInterpFactory.rMultiply(...
                CtDefMat,QCMat,CtDefMat.');
            %
            % compute C(t)q(t)
            %
            self.CqtSpline=MatrixSymbInterpFactory.rMultiplyByVec(...
                CtDefMat,qCVec);
            %
            % compute x(t)
            %
            odeArgList={'NormControl',self.ODE_NORM_CONTROL,'RelTol',...
                calcPrecision,'AbsTol',calcPrecision};
            solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
            %
            xtDerivFunc = @(t,x) self.AtSpline.evaluate(t)*x+...
                self.BptSpline.evaluate(t)+self.CqtSpline.evaluate(t);
            %
            [timeXtVec,xtArray]=solverObj.solve(xtDerivFunc,...
                self.timeVec,x0DefVec);
            %
            self.xtSpline=MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
        end
    end
end