classdef LReachProblemDynamicsFactory<handle
    methods(Static)
        function pDynamicsObject=create(pDefObj,calcPrecision)
            import gras.ellapx.lreachplain.LReachProblemDynamicsInterp;
            import gras.ellapx.lreachplain.LReachProblemLTIDynamics;
            %
            if isa(pDefObj,...
                    'gras.ellapx.lreachplain.ReachContLTIProblemDef')
                pDynamicsObject = LReachProblemLTIDynamics(pDefObj,...
                    calcPrecision);
            elseif isa(pDefObj,...
                    'gras.ellapx.lreachplain.LReachContProblemDef')
                pDynamicsObject = LReachProblemDynamicsInterp(pDefObj,...
                    calcPrecision);
            else
                modgen.common.throwerror(...
                    'wrongInput', 'Incorrect system definition');
            end
        end
        function pDynamicsObject=createByParams(aCMat,bCMat,pCMat,pCVec,...
                x0Mat,x0Vec,tLims,calcPrecision)
            import gras.ellapx.lreachplain.LReachContProblemDef;
            import gras.ellapx.lreachplain.LReachProblemDynamicsInterp;
            import gras.ellapx.lreachplain.ReachContLTIProblemDef;
            import gras.ellapx.lreachplain.LReachProblemLTIDynamics;
            %
            if ReachContLTIProblemDef.isCompatible(aCMat,bCMat,pCMat,...
                    pCVec,x0Mat,x0Vec,tLims)
                pDefObj = ReachContLTIProblemDef(aCMat,bCMat,pCMat,...
                    pCVec,x0Mat,x0Vec,tLims);
                pDynamicsObject = LReachProblemLTIDynamics(pDefObj,...
                    calcPrecision);
            elseif LReachContProblemDef.isCompatible(aCMat,bCMat,pCMat,...
                    pCVec,x0Mat,x0Vec,tLims)
                pDefObj = LReachContProblemDef(aCMat,bCMat,pCMat,...
                    pCVec,x0Mat,x0Vec,tLims);
                pDynamicsObject = LReachProblemDynamicsInterp(pDefObj,...
                    calcPrecision);                
            else
                modgen.common.throwerror(...
                    'wrongInput', 'Incorrect system definition');
            end
        end        
    end
end