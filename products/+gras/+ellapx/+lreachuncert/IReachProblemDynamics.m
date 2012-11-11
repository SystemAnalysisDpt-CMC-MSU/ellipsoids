classdef IReachProblemDynamics<gras.ellapx.lreachplain.IReachProblemDynamics
    methods (Abstract)
        CqtDynamics=getCqtDynamics(self)
        CQCTransDynamics=getCQCTransDynamics(self) 
    end
end