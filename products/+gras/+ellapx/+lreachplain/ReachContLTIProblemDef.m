classdef ReachContLTIProblemDef<...
        gras.ellapx.lreachplain.LReachContProblemDef
    methods (Static,Access=protected)
        % check whether there are no 't' occurences
        function isOk=isConst(mCMat)
            isOk=all(reshape(cellfun('isempty',strfind(mCMat,'t')),[],1));
        end
    end
    methods
        function self=ReachContLTIProblemDef(aCMat,bCMat,...
                pCMat,pCVec,x0Mat,x0Vec,tLims)
            %
            import gras.ellapx.lreachplain.ReachContLTIProblemDef;
            %
            if ~(ReachContLTIProblemDef.isConst(aCMat)&&...
                    ReachContLTIProblemDef.isConst(bCMat)&&...
                    ReachContLTIProblemDef.isConst(pCMat)&&...
                    ReachContLTIProblemDef.isConst(pCVec))
                modgen.common.throwerror('wrongInput',...
                    'Input depends on ''t''');
            end
            %
            self=self@gras.ellapx.lreachplain.LReachContProblemDef(...
                aCMat,bCMat,pCMat,pCVec,x0Mat,x0Vec,tLims);
        end
    end
end