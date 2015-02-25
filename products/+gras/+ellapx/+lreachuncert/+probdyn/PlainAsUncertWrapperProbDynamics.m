classdef PlainAsUncertWrapperProbDynamics<...
        gras.ellapx.lreachplain.probdyn.PlainWrapperProbDynamics&...
        gras.ellapx.lreachplain.probdyn.IReachProblemDynamics
    %
    properties (Access=private)
        cqtDynamics
        cQCTransDynamics
    end
    %
    methods
        function self=PlainAsUncertWrapperProbDynamics(plainDynObj)
            import gras.mat.ConstMatrixFunctionFactory;
            self=self@gras.ellapx.lreachplain.probdyn.PlainWrapperProbDynamics(...
                plainDynObj);
            nDims=plainDynObj.getDimensionality();
            self.cqtDynamics=...
                ConstMatrixFunctionFactory.createInstance(zeros(nDims,1));
            self.cQCTransDynamics=...
                ConstMatrixFunctionFactory.createInstance(zeros(nDims,nDims));
        end
        function cqtDynamics=getCqtDynamics(self)
            cqtDynamics=self.cqtDynamics;
        end
        function cQCTransDynamics=getCQCTransDynamics(self)
            cQCTransDynamics=self.cQCTransDynamics;
        end
    end
end