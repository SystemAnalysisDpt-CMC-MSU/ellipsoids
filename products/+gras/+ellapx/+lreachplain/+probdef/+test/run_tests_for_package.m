function results=run_tests_for_package(package, testCase, varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;

import import gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefConfigReader;
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();

confList = {
    'demo3firstTest';
    'demo3secondTest';
    'demo3thirdTest';
    'demo3fourthTest';
    'test2dbad';
};

classList = {
    struct('class', 'AReachContProblemDef',   'confs', [1 2 3 4 5]);
    struct('class', 'LReachContProblemDef',   'confs', [1 2 3 4 5]); 
    struct('class', 'ReachContLTIProblemDef', 'confs', [1 4 5]);
};

suiteList = {};
for iClassElem=1:numel(classList)
    fPDefConstr = getConstr(classList{iClassElem}.class);
    
    for iConfElem=classList{iClassElem}.confs
        confName=confList{iConfElem};
        fConfReader=@()ProbDefConfigReader(confName, crm, crmSys);
        
        suiteList{end+1} = loader.load_tests_from_test_case(testCase,... 
            fPDefConstr, fConfReader,...
            'marker', ['conf=' confName '_class=' num2str(iClassElem)]);
    end
end

testsList = cellfun(@(x)x.tests, suiteList, 'UniformOutput', false);
testsList = horzcat(testsList{:});
suite = mlunitext.test_suite(testsList).getCopyFiltered(varargin{:});
results = runner.run(suite);

function fConstr = getConstr(className)
    fConstr = eval(['@' package '.'  className]);
end
end