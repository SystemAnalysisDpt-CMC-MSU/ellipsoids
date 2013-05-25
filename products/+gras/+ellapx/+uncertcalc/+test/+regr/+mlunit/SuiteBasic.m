classdef SuiteBasic < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
    end
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',filesep,shortClassName];
        end
        %
        function self = set_up_param(self,varargin)
            
        end
        function testTouchRun(~)
            N_EXP_ELL_TUBES=6;
            N_EXP_ELL_PROJS=24;
            crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            SRunProp=gras.ellapx.uncertcalc.run('basic','basic',...
                'confRepoMgr',crm,'sysConfRepoMgr',crmSys);
            if crm.getParam('plottingProps.isEnabled')
                SRunProp.plotterObj.closeAllFigures();
            end
            mlunitext.assert_equals(N_EXP_ELL_PROJS,...
                SRunProp.ellTubeProjRel.getNTuples);
            mlunitext.assert_equals(N_EXP_ELL_TUBES,...
                SRunProp.ellTubeRel.getNTuples());
        end
    end
end