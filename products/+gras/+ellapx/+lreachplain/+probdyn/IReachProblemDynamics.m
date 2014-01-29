classdef IReachProblemDynamics<handle
    methods (Abstract)
        BPBTransDynamics=getBPBTransDynamics(self)
        AtDynamics=getAtDynamics(self)
        BptDynamics=getBptDynamics(self)
        xtDynamics=getxtDynamics(self)
        problemDef=getProblemDef(self)
        timeVec=getTimeVec(self)
        X0Mat=getX0Mat(self)
        x0Vec=getx0Vec(self)
        timeLimsVec=getTimeLimsVec(self)
        t0=gett0(self)
        t1=gett1(self)
        sysDim=getDimensionality(self)
    end
end