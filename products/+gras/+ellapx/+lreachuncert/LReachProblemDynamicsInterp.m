classdef LReachProblemDynamicsInterp<gras.ellapx.lreachuncert.IReachProblemDynamics & gras.ellapx.lreachplain.LReachProblemDynamicsInterp
    properties (Access=private)
        CQCTransSpline
        CqtSpline
    end
    methods
        function CqtDynamics=getCqtDynamics(self)
            CqtDynamics=self.CqtSpline;
        end
        function CQCTransDynamics=getCQCTransDynamics(self)
            CQCTransDynamics=self.CQCTransSpline;
        end
        function self=LReachProblemDynamicsInterp(problemDef,calcPrecision)
            import gras.interp.MatrixSymbInterpFactory;
            import gras.gen.SquareMatVector;
            %
            self=self@gras.ellapx.lreachplain.LReachProblemDynamicsInterp(problemDef,calcPrecision);
            %
            CtDefMat = problemDef.getCMatDef();
            self.CQCTransSpline=MatrixSymbInterpFactory.rMultiply(...
                CtDefMat,problemDef.getQCMat(),CtDefMat.');
            %
            self.CqtSpline=MatrixSymbInterpFactory.rMultiplyByVec(...
                CtDefMat,problemDef.getqCVec());
        end
    end
end