classdef mlunit_test_adaptivecrmversioned < modgen.configuration.test.mlunit_test_crmversioned
    
    properties (Access=protected)
        tcm
    end
    methods (Access=private)
        function self=initData(self)
            import modgen.configuration.test.*;   
            
            self.cm=self.factory.getInstance();
            self.cm.removeAll();
            self.tcm=self.cm.getTemplateRepo();
            self.tcm.removeAll()            
            SConfA=struct('confName','testConfA','alpha',0,'beta',0);
            SConfB=struct('confName','testConfB','alpha',11,'beta',11);
            %
            self.tcm.putConf('testConfA',SConfA,0);
            self.tcm.putConf('testConfB',SConfB,0);
        end
    end
    methods
        function self = mlunit_test_adaptivecrmversioned(varargin)
            self = self@modgen.configuration.test.mlunit_test_crmversioned(varargin{:});
        end
        function self = set_up_param(self,factory)
            self.factory=factory;
            self=self.initData();
        end
        function self=test_updateAll(self)
            self.cm.updateAll();
            self.aux_checkUpdateAll(self.cm);
            self.aux_checkUpdateAll(self.tcm);
        end
        function self=test_update(self)
            self.cm.deployConfTemplate('testConfA');
            self.cm.updateConfTemplate('testConfA');
            [SConf,confVersion,metaData]=self.tcm.getConf('testConfB');
            self.cm.putConf('testConfB',SConf,confVersion,metaData);
            %
            self.aux_checkUpdate(self.cm);
            self.aux_checkUpdate(self.tcm);
        end        
    end
end