classdef SuiteBasic < mlunitext.test_case
    properties (Access=private)
        confName
        crm
        crmSys
    end
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,crm,crmSys,confName)
            self.crm=crm;
            self.crmSys=crmSys;
            self.confName=confName;
        end
        %
        function testSimpleRun(self)
            gras.ellapx.uncertmixcalc.run(self.confName,...
                'confRepoMgr',self.crm,'sysConfRepoMgr',self.crmSys);
        end
    end
end