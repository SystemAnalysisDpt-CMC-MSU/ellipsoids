classdef GoodDirsContinuousFactory<handle
    methods (Static)
        function goodDirObj = create(pDynObj, sTime, lsGoodDirMat, ...
                calcPrecision)
            import gras.ellapx.lreachplain.GoodDirsContinuousGen;
            import gras.ellapx.lreachplain.GoodDirsContinuousLTI;
            if isa(pDynObj, ...
                'gras.ellapx.lreachplain.probdyn.AReachProblemLTIDynamics')
                goodDirObj = GoodDirsContinuousLTI(pDynObj, sTime, ...
                    lsGoodDirMat, calcPrecision);
            else
                goodDirObj = GoodDirsContinuousGen(pDynObj, sTime, ...
                    lsGoodDirMat, calcPrecision);
            end
        end
    end
end