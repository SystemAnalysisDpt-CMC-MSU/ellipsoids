classdef LReachContProblemDef<gras.ellapx.lreachuncert.probdef.AReachContProblemDef
    methods
        function self=LReachContProblemDef(aCMat,bCMat,pCMat,pCVec,...
                cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)
            %
            self=self@gras.ellapx.lreachuncert.probdef.AReachContProblemDef(...
                aCMat,bCMat,pCMat,pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec,...
                tLims);
        end
    end
end