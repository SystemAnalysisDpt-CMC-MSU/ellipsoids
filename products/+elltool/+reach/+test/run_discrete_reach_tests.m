function results = run_discrete_reach_tests(varargin)
import elltool.reach.ReachFactory;
%
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm = gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys = gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
confList = {...
    'demo3firstTest',  [1 0 1 1];
    };
%
nConfs = size(confList, 1);
suiteList = {};
%
for iConf = 1:nConfs
    confName = confList{iConf, 1};
    confTests = confList{iConf, 2};
    suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.DiscreteReachTestCase',...
            ReachFactory(confName, crm, crmSys, false, false, true));
    suiteList{end + 1} = loader.load_tests_from_test_case(...
        'elltool.reach.test.mlunit.ReachDiscrLogicalTestCase',varargin{:});
end
%
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
results=runner.run(suite);

end