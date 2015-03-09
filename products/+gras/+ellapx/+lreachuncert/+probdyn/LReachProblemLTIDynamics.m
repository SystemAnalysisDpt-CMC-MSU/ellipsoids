classdef LReachProblemLTIDynamics<...
        gras.ellapx.lreachplain.probdyn.AReachProblemLTIDynamics & ...
        gras.ellapx.lreachuncert.probdyn.AReachProblemDynamics
    properties (Access=protected)
        xtDynamics
    end
    methods
        function self=LReachProblemLTIDynamics(problemDef,calcPrecision)
            import gras.mat.interp.MatrixInterpolantFactory;
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
            fSolver = @gras.ode.ode45reg;
            fSolveFunc = @(varargin)fSolver(varargin{:},...
                    odeset(odeArgList{:}));
               
            solverObj = gras.ode.MatrixSysODERegInterpSolver(...
                {[sysDim 1]},fSolveFunc,'outArgStartIndVec',[1 2]);
            BpPlusCqVec = BpVec + CqVec;
            xtDerivFunc = @(t,x) AMat*x+BpPlusCqVec;
            
            function varargout=fAdvRegFunc(~,varargin)
                nEqs=length(varargin);
                varargout{1}=false;
                for iEq=1:nEqs
                    varargout{iEq+1} = varargin{iEq};
                end
            end
            %
            [~,~,~,interpObj] = ...
                solverObj.solve({xtDerivFunc,@fAdvRegFunc},...
                self.timeVec, problemDef.getx0Vec());
            self.xtDynamics = gras.ode.MatrixODE45InterpFunc(interpObj);
        end
    end
end