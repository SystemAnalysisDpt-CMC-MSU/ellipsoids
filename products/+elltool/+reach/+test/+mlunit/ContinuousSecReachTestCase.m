classdef ContinuousSecReachTestCase < elltool.reach.test.mlunit.ATestDynGettersBaseTestCase
    
    methods
        function self = ContinuousSecReachTestCase(varargin)            
            self = self@elltool.reach.test.mlunit.ATestDynGettersBaseTestCase(varargin{:});            
        end        
    end
    
    methods(Access = protected)
        function bpbMat = bpbFunc(self,pDynBPBMat,probDynObj,curTime)
            bpbMat=pDynBPBMat;
        end
    end
end