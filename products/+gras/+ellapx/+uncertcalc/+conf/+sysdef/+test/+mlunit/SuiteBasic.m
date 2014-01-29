classdef SuiteBasic < mlunitext.test_case
    properties 
    end
    
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)

        end
        %
        function self=testSysDef(self)
            crm=gras.ellapx.uncertcalc.conf.sysdef.test.ConfRepoMgr();
            [SConf,confVersion,metaData]=crm.getConf('test');
            crm.putConf('test2',SConf,confVersion,metaData);
            [SConf2,confVersion2,metaData2]=crm.getConf('test2');
            mlunitext.assert_equals(true,isequal(SConf,SConf2));
            mlunitext.assert_equals(true,isequal(confVersion,confVersion2));
            mlunitext.assert_equals(true,isequal(metaData,metaData2));
        end
    end
end
