classdef LReachDiscrForwardDynamics <...
        gras.ellapx.lreachplain.probdyn.AReachDiscrForwardDynamics
    properties (Access=protected)
        xtDynamics
    end
    methods
        function self = LReachDiscrForwardDynamics(problemDef)
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
            self = self@gras.ellapx.lreachplain.probdyn.AReachDiscrForwardDynamics(...
                problemDef);
        end
    end
end