classdef LReachProblemDefInterp<...
        gras.ellapx.lreachplain.LReachProblemDefInterp
    methods
        function CqtSpline=getCqtSpline(self)
            CqtSpline=self.pDynObj.getCqtDynamics();
        end
        function CQCTransSpline=getCQCTransSpline(self)
            CQCTransSpline=self.pDynObj.getCQCTransDynamics();
        end
        function self=LReachProblemDefInterp(AtDefMat,BtDefMat,...
                PtDefMat,ptDefVec,CtDefMat,QtDefMat,qtDefVec,...
                X0DefMat,x0DefVec,tLims,calcPrecision)
            %
            import gras.ellapx.lreachuncert.LReachProblemDynamicsFactory;
            %
            self = self@gras.ellapx.lreachplain.LReachProblemDefInterp();
            %
            self.pDynObj = LReachProblemDynamicsFactory.createByParams(...
                AtDefMat,BtDefMat,PtDefMat,ptDefVec,CtDefMat,QtDefMat,...
                qtDefVec,X0DefMat,x0DefVec,tLims,calcPrecision);
            self.pDefObj = self.pDynObj.getProblemDef();
        end
    end
end