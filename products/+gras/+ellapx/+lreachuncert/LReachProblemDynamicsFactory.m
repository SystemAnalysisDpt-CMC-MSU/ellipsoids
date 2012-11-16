classdef LReachProblemDynamicsFactory<handle
    methods(Static)
        function pDynamicsObject=create(pDefObj,calcPrecision)
            import gras.ellapx.lreachuncert.LReachProblemDynamicsInterp;
            import gras.ellapx.lreachuncert.LReachProblemLTIDynamics;
            %
            if isa(pDefObj,...
                    'gras.ellapx.lreachuncert.ReachContLTIProblemDef')
                pDynamicsObject = LReachProblemLTIDynamics(pDefObj,...
                    calcPrecision);
            elseif isa(pDefObj,...
                    'gras.ellapx.lreachuncert.LReachContProblemDef')
                pDynamicsObject = LReachProblemDynamicsInterp(pDefObj,...
                    calcPrecision);
            else
                modgen.common.throwerror(...
                    'wrongInput', 'Incorrect system definition');
            end
        end
        function pDynamicsObject=createByParams(aCMat,bCMat,pCMat,pCVec,...
                cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims,calcPrecision)
            import gras.ellapx.lreachuncert.LReachContProblemDef;
            import gras.ellapx.lreachuncert.LReachProblemDynamicsInterp;
            import gras.ellapx.lreachuncert.ReachContLTIProblemDef;
            import gras.ellapx.lreachuncert.LReachProblemLTIDynamics;
            %
            if ReachContLTIProblemDef.isCompatible(aCMat,bCMat,pCMat,pCVec,...
                    cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)
                pDefObj = ReachContLTIProblemDef(aCMat,bCMat,pCMat,pCVec,...
                    cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims);
                pDynamicsObject = LReachProblemLTIDynamics(pDefObj,...
                    calcPrecision);
            elseif LReachContProblemDef.isCompatible(aCMat,bCMat,pCMat,pCVec,...
                    cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)
                pDefObj = LReachContProblemDef(aCMat,bCMat,pCMat,pCVec,...
                    cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims);
                pDynamicsObject = LReachProblemDynamicsInterp(pDefObj,...
                    calcPrecision);
            else
                modgen.common.throwerror(...
                    'wrongInput', 'Incorrect system definition');
            end
        end
    end
end