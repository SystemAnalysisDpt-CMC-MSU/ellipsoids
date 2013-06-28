classdef LReachProblemLTIDynamics<...
        gras.ellapx.lreachplain.probdyn.AReachProblemLTIDynamics & ...
        gras.ellapx.lreachuncert.probdyn.AReachProblemDynamics
    properties (Access=protected)
        xtDynamics
    end
    methods
        function self=LReachProblemLTIDynamics(problemDef,calcPrecision)
            import gras.interp.MatrixInterpolantFactory;
            import gras.gen.MatVector;
            import gras.ode.MatrixODESolver;
            import gras.mat.ConstMatrixFunctionFactory;
            %
            if ~isa(problemDef,'gras.ellapx.lreachuncert.probdef.ReachContLTIProblemDef')
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            %
            % call superclass constructor
            %
            self=self@gras.ellapx.lreachplain.probdyn.AReachProblemLTIDynamics(...
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
            %
            self.CqtDynamics = ...
                ConstMatrixFunctionFactory.createInstance(CqVec);
            self.CQCTransDynamics = ...
                ConstMatrixFunctionFactory.createInstance(...
                CMat*QMat*(CMat.'));
            %
            % compute x(t)
            %
            odeArgList=self.getOdePropList(calcPrecision);
            solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
            %
            BpPlusCqVec = BpVec + CqVec;
            xtDerivFunc = @(t,x) AMat*x+BpPlusCqVec;
            %
            [timeXtVec,xtArray]=solverObj.solve(xtDerivFunc,...
                self.timeVec,x0Vec);
            %
            self.xtDynamics=MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
        end
    end
end