classdef IReachContProblemDef<gras.ellapx.lreachplain.probdef.IReachContProblemDef
    methods (Abstract)
        cCMat=getCMatDef(self)
        qCVec=getqCVec(self)
        qCMat=getQCMat(self)
    end
end