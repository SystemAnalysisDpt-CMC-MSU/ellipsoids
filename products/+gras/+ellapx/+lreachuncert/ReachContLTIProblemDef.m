classdef ReachContLTIProblemDef<...
        gras.ellapx.lreachuncert.LReachContProblemDef
    methods
        function self=ReachContLTIProblemDef(aCMat,bCMat,...
                pCMat,pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)
            %
            import gras.mat.symb.iscellofstringconst;
            import modgen.common.type.simple.checkgen;
            %
            checkgen(aCMat,@iscellofstringconst);
            checkgen(bCMat,@iscellofstringconst);
            checkgen(pCMat,@iscellofstringconst);
            checkgen(pCVec,@iscellofstringconst);
            checkgen(cCMat,@iscellofstringconst);
            checkgen(qCMat,@iscellofstringconst);
            checkgen(qCVec,@iscellofstringconst);
            %
            %
            self=self@gras.ellapx.lreachuncert.LReachContProblemDef(...
                aCMat,bCMat,pCMat,pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec,...
                tLims);
        end
    end
end