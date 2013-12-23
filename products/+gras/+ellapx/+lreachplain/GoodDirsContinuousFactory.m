classdef GoodDirsContinuousFactory<handle
    methods (Static)
        function goodDirObj = create(pDynObj, sTime, lsGoodDirMat, ...
                relTol, absTol)
            import gras.ellapx.lreachplain.GoodDirsContinuousGen;
            import gras.ellapx.lreachplain.GoodDirsContinuousLTI;
            if isa(pDynObj, ...
                'gras.ellapx.lreachplain.probdyn.AReachProblemLTIDynamics')
                goodDirObj = GoodDirsContinuousLTI(pDynObj, sTime, ...
                    lsGoodDirMat, relTol, absTol);
            else
                goodDirObj = GoodDirsContinuousGen(pDynObj, sTime, ...
                    lsGoodDirMat, relTol, absTol);
            end
        end
    end
end