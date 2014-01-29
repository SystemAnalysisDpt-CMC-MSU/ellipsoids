classdef mlunit_test_adaptiveconfrepomgr < modgen.configuration.test.mlunit_test_crm
    %mlunitext.test_case
    
    properties (Access=protected)
        tcm
        initialConfNameList
    end
    methods (Access=protected)
        function self=initData(self)
            import modgen.configuration.test.*;   
            
            self.cm=self.factory.getInstance();
            self.cm.removeAll();
            self.tcm=self.cm.getTemplateRepo();
            self.tcm.putConf('testConfC',struct());
            self.tcm.removeAll();
            SConfA=genteststruct(1);
            SConfB=genteststruct(2);
            %
            self.tcm.putConf('testConfA',SConfA);
            self.tcm.putConf('testConfB',SConfB);
            self.cm.putConf('testConfA',SConfB);
            self.initialConfNameList=self.tcm.getConfNameList();
        end
    end
    methods
        function self = mlunit_test_adaptiveconfrepomgr(varargin)
            self = self@modgen.configuration.test.mlunit_test_crm(varargin{:});
        end
        function self = set_up_param(self,factory)
            self.factory=factory;
            self=self.initData();
        end
        function self = test_setGetConf(self)
            import modgen.configuration.test.*;
            SConf=genteststruct(3);
            self.tcm.putConf('testConfB',SConf);
            SRes=self.cm.getConf('testConfB');
            mlunitext.assert_equals(isequalwithequalnans(SConf,SRes),true);
        end
        function self = test_setGetConfWithVer(self)
            import modgen.configuration.test.*;
            SConf=genteststruct(3);
            [~,lastRev]=self.tcm.getConf('testConfA');
            testVer=min(333,lastRev);
            self.tcm.putConf('testConfB',SConf,testVer);
            [SRes,resVer]=self.cm.getConf('testConfB');
            mlunitext.assert_equals(isequalwithequalnans(SConf,SRes),true);
            mlunitext.assert_equals(testVer,resVer);
        end        
        function self=test_deployConfTemplate(self)
            confNameList=[self.tcm.getConfNameList,{'testConfD'}];            
            self.tcm.copyConf('testConfA','testConfD');
            self.cm.deployConfTemplate('*');
            isEqual=isequal(confNameList,...
                sort(self.cm.getConfNameList()));
            mlunitext.assert_equals(isEqual,true);
        end
    end
end
