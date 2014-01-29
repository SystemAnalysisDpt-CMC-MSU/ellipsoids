classdef mlunit_test_versionedconfrepomgr < modgen.configuration.test.mlunit_test_adaptiveconfrepomgr
    
    properties (Access=private)
        cm1
        tcm1
        cm2
    end
    methods
        function self = mlunit_test_versionedconfrepomgr(varargin)
            self = self@modgen.configuration.test.mlunit_test_adaptiveconfrepomgr(varargin{:});
        end
        function self = set_up_param(self,factory)
            self=set_up_param@modgen.configuration.test.mlunit_test_adaptiveconfrepomgr(self,factory);
            SConfC=struct('alpha',0,'beta',0);
            self.cm1=self.factory.getInstance('repoSubFolderName','confRepoVersioned');
            self.cm1.removeAll();
            self.tcm1=self.cm1.getTemplateRepo();
            self.tcm1.putConf('testConfC',struct());
            self.tcm1.removeAll();
            %
            self.tcm1.putConf('testConfC',SConfC,0);
            self.tcm1.putConf('testConfCK',SConfC,0);
            self.cm1.putConf('testConfK',SConfC,0);
            self.cm1.putConf('testConfCK',SConfC,0);
            %
            self.cm2=self.factory.getInstance('repoSubFolderName','confRepoFixedExamples');
            
        end
        function self=test_updateConfFromTemplate(self)
            self.aux_test_updateConf('testConfC');
        end
        function self=test_updateConfLocally(self)
            self.cm1.updateConf('testConfK');
            self.aux_test_updateConf('testConfK');
        end
        function self=aux_test_updateConf(self,confName)
            [SConf,confVersion]=self.cm1.getConf(confName);
            mlunitext.assert_equals(103,confVersion);
            mlunitext.assert_equals(2,SConf.beta);            
        end
        function self=test_updateConfOnSelect(self)
            self.cm1.selectConf('testConfK');
            self.aux_test_updateConf('testConfK');
            self.cm1.selectConf('testConfC');
            self.aux_test_updateConf('testConfC');
        end
        function self=test_updateAll(self)
%            self.cm1.updateConf('testConfC');
            self.cm1.updateAll();
            self.aux_test_updateConf('testConfK');
            self.aux_test_updateConf('testConfC');
            self.aux_test_updateConf('testConfCK');
        end
        function self=test_updateAll_wrongKey(self)
            try
                self.cm2.updateAll();
                mlunitext.assert_equals(false,true);
            catch meObj
                 mlunitext.assert_equals(false,...
                     isempty(findstr(meObj.identifier,':badConfRepo')));
            end
        end
    end
end