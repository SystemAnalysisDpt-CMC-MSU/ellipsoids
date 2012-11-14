classdef ReachContLTIProblemDef<...
        gras.ellapx.lreachplain.LReachContProblemDef
    methods
        function self=ReachContLTIProblemDef(aCMat,bCMat,...
                pCMat,pCVec,x0Mat,x0Vec,tLims)
            %
            import gras.mat.symb.iscellofstringconst;
            import modgen.common.type.simple.checkgen;
            %
            checkgen(aCMat,@iscellofstringconst);
            checkgen(bCMat,@iscellofstringconst);
            checkgen(pCMat,@iscellofstringconst);
            checkgen(pCVec,@iscellofstringconst);
            %
            self=self@gras.ellapx.lreachplain.LReachContProblemDef(...
                aCMat,bCMat,pCMat,pCVec,x0Mat,x0Vec,tLims);
        end
    end
end