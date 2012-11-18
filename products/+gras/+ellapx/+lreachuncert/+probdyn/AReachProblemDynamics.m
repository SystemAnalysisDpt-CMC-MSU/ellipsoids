classdef AReachProblemDynamics<...
        gras.ellapx.lreachplain.probdyn.AReachProblemDynamics & ...
        gras.ellapx.lreachuncert.probdyn.IReachProblemDynamics
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
    end
end