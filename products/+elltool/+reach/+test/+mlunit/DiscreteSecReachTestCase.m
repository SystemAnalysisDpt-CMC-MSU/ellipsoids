classdef DiscreteSecReachTestCase < elltool.reach.test.mlunit.ATestDynGettersBaseTestCase
    methods
        function self = DiscreteSecReachTestCase(varargin)
            self = self@elltool.reach.test.mlunit.ATestDynGettersBaseTestCase(varargin{:});
        end
    end
    methods(Access = protected)
        function bpbMat = bpbFunc(self,pDynBPBMat,probDynObj,curTime)
            aInvMat=probDynObj.getAtInvDynamics().evaluate(curTime);
            bpbMat=aInvMat*pDynBPBMat*(aInvMat)';
        end
    end
end