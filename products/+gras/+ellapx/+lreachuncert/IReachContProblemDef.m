classdef IReachContProblemDef<gras.ellapx.lreachplain.IReachContProblemDef
    methods (Abstract)
        cCMat=getCMatDef(self)
		qCVec=getqCVec(self)
		qCMat=getQCMat(self)
    end
end