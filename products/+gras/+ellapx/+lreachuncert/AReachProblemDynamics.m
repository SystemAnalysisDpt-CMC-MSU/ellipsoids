classdef AReachProblemDynamics<...
        gras.ellapx.lreachplain.AReachProblemDynamics & ...
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
    end
end