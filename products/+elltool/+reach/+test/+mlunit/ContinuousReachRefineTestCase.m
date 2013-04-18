classdef ContinuousReachRefineTestCase < mlunitext.test_case
    properties (Access=private)
        linSys
        reachObj
        tVec
        x0Ell
        l0P1Mat
        l0P2Mat
    end
     methods
        function self = ContinuousReachRefineTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self, reachFactObj)
            self.reachObj = reachFactObj.createInstance();
            self.linSys = reachFactObj.getLinSys();
            self.tVec = reachFactObj.getTVec();
            l0Mat = reachFactObj.getL0Mat();
            [~, mSize]=size(l0Mat);
            nPart1=floor(mSize/2);
            self.x0Ell = reachFactObj.getX0Ell();
            self.l0P1Mat=l0Mat(:,1:nPart1);
            self.l0P2Mat=l0Mat(:,nPart1+1:end);
        end
        %
        function self = testRefine(self)
            import gras.ellapx.smartdb.F;
            %
            reachWholeObj=elltool.reach.ReachContinuous(self.linSys,...
                self.x0Ell,self.l0P1Mat,self.tVec);
            %
            reachWholeObj.refine(self.l0P2Mat);
            isEqual = self.reachObj.isEqual(reachWholeObj);
            mlunit.assert_equals(true,isEqual);
        end 
    end
end