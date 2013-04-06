function results = run_continuous_reach_tests()
import elltool.reach.test.mlunit.ReachFactory;
%
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
confList = {...
    'demo3firstTest',  [1 0 1 0 1];...
    'demo3secondTest', [1 1 1 1 1];...
    'demo3thirdTest', [1 1 1 1 1];...
    'demo3fourthTest', [1 1 1 1 1];
    };
%
nConfs = size(confList, 1);
suiteList = {};
%
for iConf = 1
    confName = confList{iConf, 1};
    confTestsVec = confList{iConf, 2};
    if confTestsVec(1)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, false, false));
    end
    if confTestsVec(2)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, true, false));
    end
    if confTestsVec(3)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, false, true));
    end
    if confTestsVec(4)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, true, true));
    end
    if confTestsVec(5)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachRegrTestCase',...
            confName, crm, crmSys);
    end
end
suiteList{end + 1} = loader.load_tests_from_test_case(...
    'elltool.reach.test.mlunit.ContinuousReachFirstTestCase',...
    'demo3firstTest', crm, crmSys);
%
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
results=runner.run(suite);
end