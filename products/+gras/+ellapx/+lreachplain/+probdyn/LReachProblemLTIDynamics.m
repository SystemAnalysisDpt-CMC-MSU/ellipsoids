classdef LReachProblemLTIDynamics<...
        gras.ellapx.lreachplain.probdyn.AReachProblemLTIDynamics
    properties (Access=protected)
        xtDynamics
    end
    methods
        function self=LReachProblemLTIDynamics(problemDef,relTol,absTol)
            %
            import gras.mat.interp.MatrixInterpolantFactory;
            import gras.ode.MatrixODESolver;
            %
            if ~isa(problemDef, ...
                    'gras.ellapx.lreachplain.probdef.ReachContLTIProblemDef')
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            %
            % call superclass constructor
            %
            self=self@gras.ellapx.lreachplain.probdyn.AReachProblemLTIDynamics(...
                problemDef,relTol,absTol);
            %
            % copy necessary data to local variables
            %
            AMat = self.AtDynamics.evaluate(0);
            BpVec = self.BptDynamics.evaluate(0);
            x0Vec = problemDef.getx0Vec();
            sysDim = size(AMat,1);
            %
            % compute x(t)
            %
            odeArgList=self.getOdePropList(relTol,absTol);
            solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
            %
            xtDerivFunc = @(t,x) AMat*x+BpVec;
            %
            [timeXtVec,xtArray]=solverObj.solve(xtDerivFunc,...
                self.timeVec,x0Vec);
            %
            self.xtDynamics=MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
        end
    end
end