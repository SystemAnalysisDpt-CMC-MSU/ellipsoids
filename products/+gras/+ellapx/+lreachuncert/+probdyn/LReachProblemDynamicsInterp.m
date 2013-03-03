classdef LReachProblemDynamicsInterp<...
        gras.ellapx.lreachplain.probdyn.AReachProblemDynamicsInterp & ...
        gras.ellapx.lreachuncert.probdyn.AReachProblemDynamics
    properties (Access=protected)
        xtDynamics
    end
    methods
        function self=LReachProblemDynamicsInterp(problemDef,calcPrecision)
            import gras.ellapx.common.*;
            import gras.interp.MatrixInterpolantFactory;
            import gras.ode.MatrixODESolver;
            import gras.mat.MatrixOperationsFactory;
            %
            if ~isa(problemDef,...
                    'gras.ellapx.lreachuncert.probdef.IReachContProblemDef')
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            %
            % call superclass constructor
            %
            self=self@gras.ellapx.lreachplain.probdyn.AReachProblemDynamicsInterp(...
                problemDef,calcPrecision);
            %
            matOpFactory = MatrixOperationsFactory.create(self.timeVec);
            %
            sysDim = self.AtDynamics.getNRows();
            %
            % create C(t)Q(t)C'(t) and C(t)q(t) dynamics
            %
            CtDefCMat = problemDef.getCMatDef();
            self.CQCTransDynamics = matOpFactory.rSymbMultiply(...
                CtDefCMat, problemDef.getQCMat(), CtDefCMat.');
            self.CqtDynamics = matOpFactory.rSymbMultiplyByVec(...
                CtDefCMat, problemDef.getqCVec());
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
                self.timeVec, problemDef.getx0Vec());
            %
            self.xtDynamics=MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
        end
    end
end