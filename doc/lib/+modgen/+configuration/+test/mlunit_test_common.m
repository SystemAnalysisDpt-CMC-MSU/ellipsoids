classdef mlunit_test_common < mlunitext.test_case
    properties (Access=protected)
        cm
        SDefaultEthalon=struct('firstProp','alpha','secondProp','beta');
        factory
    end
    methods (Access=private)
        function self=initData(self)
            import modgen.configuration.test.*;   
            %
            self.cm=self.factory.getInstance();
            SConfA=struct('confName','testConfA','alpha',0,'beta',0);
            SConfB=struct('confName','testConfB','alpha',11,'beta',11);
            %
            self.cm.putConf('testConfA',SConfA,0);
            self.cm.putConf('testConfB',SConfB,0);
        end
    end
    methods
        function self = mlunit_test_common(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = set_up_param(self,factory)
            self.factory=factory;
            self=self.initData();
        end
        function self = test_setParamAfterSelect(self)
            import modgen.configuration.test.*;
            cm=self.cm;
            cm.selectConf('testConfA');
            valOrig=cm.getParam('alpha');
            val=valOrig+1;
            cm.setParam('alpha',val,'writeDepth','cache');
            cm.selectConf('testConfA','reloadIfSelected',false);
            mlunitext.assert_equals(val,cm.getParam('alpha'));
            cm.selectConf('testConfA','reloadIfSelected',true);
            mlunitext.assert_equals(valOrig,cm.getParam('alpha'));
            %
        end
    end
end