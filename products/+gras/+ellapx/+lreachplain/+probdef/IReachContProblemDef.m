classdef IReachContProblemDef<handle
    methods (Abstract)
        sysDim=getDimensionality(self)
        bCMat=getBMatDef(self)
        aCMat=getAMatDef(self)
        x0Mat=getX0Mat(self)
        x0Vec=getx0Vec(self)
        tLims=getTimeLimsVec(self)
        t0=gett0(self)
        t1=gett1(self)
        pCVec=getpCVec(self)
        pCMat=getPCMat(self)
    end
    methods(Abstract,Static)
        isOk=isCompatible(self)
    end
end