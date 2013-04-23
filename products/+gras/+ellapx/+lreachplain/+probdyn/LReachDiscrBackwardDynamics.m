classdef LReachDiscrBackwardDynamics <...
        gras.ellapx.lreachplain.probdyn.AReachDiscrBackwardDynamics
    properties (Access=protected)
        xtDynamics
    end
    methods
        function self = LReachDiscrBackwardDynamics(problemDef)
            import gras.ellapx.common.*;
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
        end
    end
end