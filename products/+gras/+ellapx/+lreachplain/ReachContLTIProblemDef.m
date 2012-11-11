classdef ReachContLTIProblemDef<gras.ellapx.lreachplain.LReachContProblemDef
    methods (Static,Access=private)
        % check whether there are no 't' occurences
        function isConst = isConst(mMat)
            isConst = all( cellfun( @(x) isempty(x), strfind(mMat, 't') ) );
        end
    end    
    methods
        function self=ReachContLTIProblemDef(aCMat,bCMat,...
                pCMat,pCVec,x0Mat,x0Vec,tLims)
            %
            if ~isConst(aCMat) || ~isConst(bCMat) || ~isConst(pCMat) || ~isConsr(pCVec)
                modgen.common.throwerror('ReachContLTIProblemDef:WrongInput', 'Input depends on ''t''');
            end
            %
            self=self@gras.ellapx.lreachplain.LReachContProblemDef(aCMat,bCMat,pCMat,pCVec,x0Mat,x0Vec,tLims);
        end
    end
end