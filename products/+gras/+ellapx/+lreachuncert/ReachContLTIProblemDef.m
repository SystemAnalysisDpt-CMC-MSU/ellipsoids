classdef ReachContLTIProblemDef<gras.ellapx.lreachuncert.LReachContProblemDef
    methods (Static,Access=private)
        % check whether there are no 't' occurences
        function isConst = isConst(mMat)
            isConst = all( cellfun( @(x) isempty(x), strfind(mMat, 't') ) );
        end
    end    
    methods
        function self=ReachContLTIProblemDef(aCMat,bCMat,...
                pCMat,pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)
            %
            if ~isConst(aCMat) || ~isConst(bCMat) || ~isConst(pCMat) || ~isConsr(pCVec) || ...
               ~isConst(cCMat) || ~isConst(qCMat) || ~isConst(qCVec)
                modgen.common.throwerror('ReachContLTIProblemDef:WrongInput', 'Input depends on ''t''');
            end
            %
            self=self@gras.ellapx.lreachuncert.LReachContProblemDef(aCMat,bCMat,pCMat,pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims);
        end
    end
end