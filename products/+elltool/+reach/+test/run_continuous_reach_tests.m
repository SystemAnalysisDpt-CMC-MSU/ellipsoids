function results = run_continuous_reach_tests(inpConfNameList)
import elltool.reach.ReachFactory;
%
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
confCMat = {...
    'demo3firstTest',  0*[1 0 1 0 1 0 1 0];...
    'demo3secondTest', 0*[1 0 0 1 1 0 0 0];...
    'demo3thirdTest',  [0 0 0 0 1 0 0 0];...%[1 1 0 0 1 1 0 1]
    'demo3fourthTest', 0*[1 1 1 1 1 1 0 0];...
    };
%
if nargin>0
    isSpecVec=ismember(confCMat(:,1),inpConfNameList);
    confCMat=confCMat(isSpecVec,:);
end
nConfs = size(confCMat, 1);
suiteList = {};
%
for iConf = 1 : nConfs
    confName = confCMat{iConf, 1};
    confTestsVec = confCMat{iConf, 2};
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
    if confTestsVec(6)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachProjTestCase',...
            confName, crm, crmSys);
    end
    if confTestsVec(7)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachRefineTestCase',...
            ReachFactory(confName, crm, crmSys, false, false));
    end
	if confTestsVec(8)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachRegTestCase',...
            confName, crm, crmSys);
    end
end
% suiteList{end + 1} = loader.load_tests_from_test_case(...
%     'elltool.reach.test.mlunit.ContinuousReachFirstTestCase',...
%     'demo3firstTest', crm, crmSys);
%
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
%
resList{1}=runner.run(suite);
resList{2}=elltool.reach.test.run_reachcont_proj_adv_tests();
results=[resList{:}];
%
end