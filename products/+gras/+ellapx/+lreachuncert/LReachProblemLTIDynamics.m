classdef LReachProblemLTIDynamics<...
        gras.ellapx.lreachplain.AReachProblemLTIDynamics & ...
        gras.ellapx.lreachuncert.IReachProblemDynamics
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
            import gras.mat.ConstMatrixFunction;
            import gras.mat.ConstColFunction;
            %
            if ~isa(problemDef,'gras.ellapx.lreachuncert.ReachContLTIProblemDef')
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            %
            % call superclass constructor
            %
            self=self@gras.ellapx.lreachplain.AReachProblemLTIDynamics(...
                problemDef,calcPrecision);
            %
            % copy necessary data to local variables
            %
            AMat = self.AtDynamics.evaluate(0);
            BpVec = self.BptDynamics.evaluate(0);
            x0Vec = problemDef.getx0Vec();
            sysDim = size(AMat,1);
            %
            % compute C(t)q(t) and C(t)Q(t)C'(t)
            %
            CMat = MatVector.fromFormulaMat(problemDef.getCMatDef(),0);
            QMat = MatVector.fromFormulaMat(problemDef.getQCMat(),0);
            qVec = MatVector.fromFormulaMat(problemDef.getqCVec(),0);
            CqVec = CMat*qVec;
            CQCTransMat = CMat*QMat*(CMat.');
            %
            self.CqtDynamics = ConstColFunction(CqVec);
            self.CQCTransDynamics = ConstMatrixFunction(CQCTransMat);
            %
            % compute x(t)
            %
            odeArgList={'NormControl',self.ODE_NORM_CONTROL,'RelTol',...
                calcPrecision,'AbsTol',calcPrecision};
            solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
            %
            BpPlusCqVec = BpVec + CqVec;
            xtDerivFunc = @(t,x) AMat*x+BpPlusCqVec;
            %
            [timeXtVec,xtArray]=solverObj.solve(xtDerivFunc,...
                self.timeVec,x0Vec);
            %
            self.xtSpline=MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
        end
    end
end