function results=run_cont_tests_from_package(testCase, suiteDefList,...
    varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;

import import gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefConfigReader;
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();

REL_ABS_TOL = {1e-6, 1e-8};

suiteList = {};
for iSuiteElem=1:numel(suiteDefList)
    SCurSuite = suiteDefList{iSuiteElem}; 
    fDefConstr = SCurSuite.defConstr;
    
    for iDynConstrElem=1:numel(SCurSuite.dynConstr)
        fDynConstr = SCurSuite.dynConstr{iDynConstrElem};
        fConstr = @(p,t)createDynObj(fDynConstr, fDefConstr, p, t);
        
        for iConfElem=1:numel(SCurSuite.confs)
            confName = SCurSuite.confs{iConfElem};
            fReader = @()ProbDefConfigReader(confName, crm, crmSys);
            
            suiteList{end+1} = loader.load_tests_from_test_case(testCase,... 
                fConstr, fReader, REL_ABS_TOL{:},...
                'marker', num2str(numel(suiteList)+1));
        end
    end
end

testsList = cellfun(@(x)x.tests, suiteList, 'UniformOutput', false);
testsList = horzcat(testsList{:});
suite = mlunitext.test_suite(testsList).getCopyFiltered(varargin{:});
results = runner.run(suite);
end

function dynObj = createDynObj(fDynConstr, fDefConstr, paramsList, tolCVec)
    if ~isempty(fDefConstr)
        dynObj = fDynConstr(fDefConstr(paramsList{:}), tolCVec{:});
    else
        dynObj = fDynConstr(paramsList{:}, tolCVec{:});
    end
end