function results=run_discr_tests_from_suitedef(suiteDefList, varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;

import import gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefConfigReader;
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();

REL_ABS_TOL = {1e-6, 1e-8};

suiteList = {};
for iSuiteElem=1:numel(suiteDefList)
    SCurSuite = suiteDefList{iSuiteElem};
    testCase = SCurSuite.TC;
    fDynConstr = @(p)createDynDiscrObj(...
        SCurSuite.dynConstr, SCurSuite.defConstr, p);
        
	for iConfElem=1:numel(SCurSuite.confs)
    	confName = SCurSuite.confs{iConfElem};
        fReader = @()ProbDefConfigReader(confName, crm, crmSys);
            
        suiteList{end+1} = loader.load_tests_from_test_case(testCase,... 
            fDynConstr, fReader, REL_ABS_TOL{:},...
            'marker', sprintf('suite=%d_conf=%s',iSuiteElem,confName));
	end
end

testsList = cellfun(@(x)x.tests, suiteList, 'UniformOutput', false);
testsList = horzcat(testsList{:});
suite = mlunitext.test_suite(testsList).getCopyFiltered(varargin{:});
results = runner.run(suite);
end

function dynObj = createDynDiscrObj(fDynConstr, fDefConstr, params)
    dynObj = fDynConstr(fDefConstr(params{:}));
end