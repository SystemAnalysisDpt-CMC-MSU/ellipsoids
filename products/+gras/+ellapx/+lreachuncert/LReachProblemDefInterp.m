classdef LReachProblemDefInterp<gras.ellapx.lreachplain.LReachProblemDefInterp
    properties (Access=private)
        CQCTransSpline
        CqtSpline
    end
    methods
        function CqtSpline=getCqtSpline(self)
            CqtSpline=self.CqtSpline;
        end
        function CQCTransSpline=getCQCTransSpline(self)
            CQCTransSpline=self.CQCTransSpline;
        end
        function self=LReachProblemDefInterp(AtDefMat,BtDefMat,...
                PtDefMat,ptDefVec,CtDefMat,QtDefMat,qtDefVec,...
                X0DefMat,x0DefVec,tLims,calcPrecision)
            import gras.interp.MatrixSymbInterpFactory;
            import gras.gen.SquareMatVector;
            %
            self=self@gras.ellapx.lreachplain.LReachProblemDefInterp(...
                AtDefMat,BtDefMat,...
                PtDefMat,ptDefVec,X0DefMat,x0DefVec,tLims,calcPrecision);
            %
            self.CQCTransSpline=MatrixSymbInterpFactory.rMultiply(...
                CtDefMat,QtDefMat,CtDefMat.');
            %
            self.CqtSpline=MatrixSymbInterpFactory.rMultiplyByVec(...
                CtDefMat,qtDefVec);
        end
    end
end