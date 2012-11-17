classdef LReachProblemDynamicsInterp<...
        gras.ellapx.lreachplain.AReachProblemDynamicsInterp & ...
        gras.ellapx.lreachuncert.AReachProblemDynamics
    properties (Access=protected)
        xtDynamics
    end
    methods
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
            self.CQCTransDynamics=MatrixSymbInterpFactory.rMultiply(...
                CtDefMat,QCMat,CtDefMat.');
            %
            % compute C(t)q(t)
            %
            self.CqtDynamics=MatrixSymbInterpFactory.rMultiplyByVec(...
                CtDefMat,qCVec);
            %
            % compute x(t)
            %
            odeArgList=self.getOdePropList(calcPrecision);
            solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
            %
            xtDerivFunc = @(t,x) self.AtDynamics.evaluate(t)*x+...
                self.BptDynamics.evaluate(t)+self.CqtDynamics.evaluate(t);
            %
            [timeXtVec,xtArray]=solverObj.solve(xtDerivFunc,...
                self.timeVec,x0DefVec);
            %
            self.xtDynamics=MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
        end
    end
end