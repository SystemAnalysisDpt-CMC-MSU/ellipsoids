%classdef ContinuousSecReachTestCase < elltool.reach.test.mlunit.TestDynGettersBaseTestCase
classdef ContinuousSecReachTestCase < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
        linSys
        reachObj
        tVec
        x0Ell
        l0Mat
        expDim
        reachFactoryObj
        
    end
    methods
        function self = ContinuousSecReachTestCase(varargin)
            %TestDynGettersBaseTestCase(varargin{:});
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
            %bpbFunc=@(probDynObj,curTime) probDynObj.getBPBTransDynamics().evaluate(curTime);
           %elltool.reach.test.mlunit.TestDynGettersBaseTestCase.baseTestDynGetters(bpbFunc);
            %elltool.reach.test.mlunit.TestDynGettersBaseTestCase(varargin{:});
            %baseTestDynGetters(bpbFunc);

        end
        %
        function self = set_up_param(self, reachFactObj)
            self.reachFactoryObj=reachFactObj;
            self.reachObj = reachFactObj.createInstance();
            self.linSys = reachFactObj.getLinSys();
            self.expDim = reachFactObj.getDim();
            self.tVec = reachFactObj.getTVec();
            self.x0Ell = reachFactObj.getX0Ell();
            self.l0Mat = reachFactObj.getL0Mat();
        end
    end
   methods
       function self = testDynGetters(self)
           
           bpbFunc=@(pDynBPBMat,probDynObj,curTime) pDynBPBMat;
           %isOk=elltool.reach.test.mlunit.TestDynGettersBaseTestCase.baseTestDynGetters(reachObj,bpbFunc);
           %baseTestDynGetters(bpbFunc);
           baseTestObj=elltool.reach.test.mlunit.TestDynGettersBaseTestCase(self.reachObj,self.reachFactoryObj,bpbFunc);
           isOk=baseTestObj.baseTestDynGetters();
           mlunitext.assert_equals(true, isOk);
           
       end;           
   end
end