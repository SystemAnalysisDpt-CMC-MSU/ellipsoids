classdef LReachContProblemDef<gras.ellapx.lreachuncert.AReachContProblemDef
    methods
        function self=LReachContProblemDef(aCMat,bCMat,pCMat,pCVec,...
                cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)
            %
            import gras.ellapx.lreachuncert.AReachContProblemDef;
            %
            if ~AReachContProblemDef.isCompatible(aCMat,bCMat,pCMat,...
                    pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)
                modgen.common.throwerror(...
                    'wrongInput','Incorrect system definition');
            end
            %
            self=self@gras.ellapx.lreachuncert.AReachContProblemDef(...
                aCMat,bCMat,pCMat,pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec,...
                tLims);
        end
    end
end