classdef mlunit_test_crmversioned < mlunitext.test_case
    
    properties (Access=protected)
        cm
        SDefaultEthalon=struct('firstProp','alpha','secondProp','beta');
        factory
    end
    methods (Access=private)
        function self=initData(self)
            import modgen.configuration.test.*;   
            
            self.cm=self.factory.getInstance();
            self.cm.removeAll();
            SConfA=struct('confName','testConfA','alpha',0,'beta',0);
            SConfB=struct('confName','testConfB','alpha',11,'beta',11);
            %
            self.cm.putConf('testConfA',SConfA,0);
            self.cm.putConf('testConfB',SConfB,0);
        end
    end
    methods
        function self = mlunit_test_crmversioned(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = set_up_param(self,factory)
            self.factory=factory;
            self=self.initData();
        end
        function self=test_update(self)
            self.cm.updateConf('testConfA');
            self.aux_checkUpdate(self.cm);
        end        
        function aux_checkUpdate(~,cm)
            [SConfB,confVersionB]=cm.getConf('testConfB');
            [SConfA,confVersionA]=cm.getConf('testConfA');
            mlunitext.assert_equals(2,SConfA.beta);
            mlunitext.assert_equals(103,confVersionA);
            mlunitext.assert_equals('testConfA',SConfA.confName);
            mlunitext.assert_equals(11,SConfB.beta);
            mlunitext.assert_equals(0,confVersionB);
            mlunitext.assert_equals('testConfB',SConfB.confName);
        end          
        function self=test_updateAll(self)
            self.cm.updateAll();
            self.aux_checkUpdateAll(self.cm);
        end        
        function aux_checkUpdateAll(~,cm)
            [SConfA,confVersionA]=cm.getConf('testConfA');
            [SConfB,confVersionB]=cm.getConf('testConfB');
            mlunitext.assert_equals(2,SConfA.beta);
            mlunitext.assert_equals(103,confVersionA);
            mlunitext.assert_equals('testConfA',SConfA.confName);
            mlunitext.assert_equals(2,SConfB.beta);
            mlunitext.assert_equals(103,confVersionB);
            mlunitext.assert_equals('testConfB',SConfB.confName);
        end        
    end
end
