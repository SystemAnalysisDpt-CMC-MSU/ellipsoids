classdef IReachProblemDynamics<handle
    methods (Abstract)
        BPBTransDynamics=getBPBTransDynamics(self)
        AtDynamics=getAtDynamics(self)
        BptDynamics=getBptDynamics(self)
        xtDynamics=getxtDynamics(self)
        Xtt0Dynamics=getXtt0Dynamics(self)
        timeVec=getTimeVec(self)
    end
end