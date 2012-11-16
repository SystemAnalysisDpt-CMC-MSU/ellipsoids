classdef LReachContProblemDef<gras.ellapx.lreachplain.AReachContProblemDef
    methods
        function self=LReachContProblemDef(aCMat,bCMat,pCMat,pCVec,...
                x0Mat,x0Vec,tLims)
            %
            import gras.ellapx.lreachplain.AReachContProblemDef;
            %
            if ~AReachContProblemDef.isCompatible(aCMat,bCMat,pCMat,...
                    pCVec,x0Mat,x0Vec,tLims)
                modgen.common.throwerror(...
                    'wrongInput','Incorrect system definition');
            end
            %
            self=self@gras.ellapx.lreachplain.AReachContProblemDef(...
                aCMat,bCMat,pCMat,pCVec,x0Mat,x0Vec,tLims);
        end
    end
end



