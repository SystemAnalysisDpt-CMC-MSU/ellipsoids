classdef IReachProblemDynamics<...
        gras.ellapx.lreachplain.probdyn.IReachProblemDynamics
    methods (Abstract)
        CqtDynamics=getCqtDynamics(self)
        CQCTransDynamics=getCQCTransDynamics(self)
    end
end