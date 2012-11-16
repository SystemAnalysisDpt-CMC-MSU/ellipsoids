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
            import gras.ellapx.lreachuncert.LReachContProblemDef;
            import gras.ellapx.lreachuncert.ReachContLTIProblemDef;
            %
            self = self@gras.ellapx.lreachplain.LReachProblemDefInterp();
            %
            try
                self.pDefObj = ReachContLTIProblemDef(AtDefMat,BtDefMat,...
                    PtDefMat,ptDefVec,CtDefMat,QtDefMat,qtDefVec,...
                    X0DefMat,x0DefVec,tLims);
            catch error
                self.pDefObj = LReachContProblemDef(AtDefMat,BtDefMat,...
                    PtDefMat,ptDefVec,CtDefMat,QtDefMat,qtDefVec,...
                    X0DefMat,x0DefVec,tLims);
            end
            %
            self.pDynObj = LReachProblemDynamicsFactory.create(...
                self.pDefObj,calcPrecision);
        end
    end
end