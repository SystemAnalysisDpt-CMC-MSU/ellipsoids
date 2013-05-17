classdef LReachDiscrBackwardDynamics <...
        gras.ellapx.lreachplain.probdyn.AReachDiscrBackwardDynamics
    properties (Access=protected)
        xtDynamics
    end
    methods
        function self = LReachDiscrBackwardDynamics(problemDef)
            import gras.ellapx.common.*;
            import gras.interp.MatrixInterpolantFactory;
            %
            if ~isa(problemDef,...
                    'gras.ellapx.lreachplain.probdef.IReachContProblemDef')
                modgen.common.throwerror('wrongInput',...
                    'Incorrect system definition');
            end
            %
            % call superclass constructor
            %
            self = self@gras.ellapx.lreachplain.probdyn.AReachDiscrBackwardDynamics(...
                problemDef);
            %
            % copy necessary data to local variables
            %
            x0DefVec = problemDef.getx0Vec();
            sysDim = size(problemDef.getAMatDef(), 1);
            nTimePoints = length(self.timeVec);
            %
            % compute x(t)
            %
            xtArray = zeros(sysDim, nTimePoints);
            xtArray(:, 1) = x0DefVec;
            for iTime = 2:nTimePoints
                aMat = self.AtDynamics.evaluate(self.timeVec(iTime));
                bpVec = self.BptDynamics().evaluate(self.timeVec(iTime));
                xtArray(:, iTime) = ...
                    aMat * (xtArray(:, iTime - 1) - bpVec);
            end
            %
            self.xtDynamics = MatrixInterpolantFactory.createInstance(...
                'column', xtArray, self.timeVec);
        end
    end
end