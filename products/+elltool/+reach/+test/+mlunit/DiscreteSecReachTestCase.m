classdef DiscreteSecReachTestCase < mlunitext.test_case
%classdef DiscreteSecReachTestCase < elltool.reach.test.mlunit.TestDynGettersBaseTestCase
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
        function self = DiscreteSecReachTestCase(varargin)            
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName]; 
%               bpbFunc=@(pDynBPBMat,probDynObj,curTime) probDynObj.getAtInvDynamics().evaluate(curTime)*...
%                 pDynBPBMat*(probDynObj.getAtInvDynamics().evaluate(curTime))';
%               self = self@elltool.reach.test.mlunit.TestDynGettersBaseTestCase(bpbFunc,varargin{:});
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
           bpbFunc=@(pDynBPBMat,probDynObj,curTime) probDynObj.getAtInvDynamics().evaluate(curTime)*...
               pDynBPBMat*(probDynObj.getAtInvDynamics().evaluate(curTime))';         
           baseTestObj=elltool.reach.test.mlunit.TestDynGettersBaseTestCase(self.reachObj,self.reachFactoryObj,bpbFunc);
           isOk=baseTestObj.baseTestDynGetters();
           mlunitext.assert_equals(true, isOk); 
             %%self.baseTestDynGetters();
       end;           
   end
end