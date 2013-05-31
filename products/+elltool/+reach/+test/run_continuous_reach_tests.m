function results = run_continuous_reach_tests(inpConfNameList)
import elltool.reach.ReachFactory;
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
confCMat = {
    'demo3firstTest',  [1 0 1 0 1 0 1 0];
    'demo3secondTest', [1 0 0 1 1 0 0 0];
    'demo3thirdTest',  [1 1 0 0 1 1 0 1];
    'demo3fourthTest', [1 1 1 1 1 1 0 0];
    };
%
if nargin>0
    isSpecVec=ismember(confCMat(:,1),inpConfNameList);
    confCMat=confCMat(isSpecVec,:);
end
nConfs = size(confCMat, 1);
suiteList = {};
%
for iConf = 1:nConfs
    confName = confCMat{iConf, 1};
    confTestsVec = confCMat{iConf, 2};
    if confTestsVec(1)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, false, false),...
            'marker',[confName,'_IsBackFalseIsEvolveFalse']);
    end
    if confTestsVec(2)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, true, false),...
            'marker',[confName,'_IsBackTrueIsEvolveFalse']);
    end
    if confTestsVec(3)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, false, true),...
            'marker',[confName,'_IsBackFalseIsEvolveTrue']);
    end
    if confTestsVec(4)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, true, true),...
            'marker',[confName,'_IsBackTrueIsEvolveTrue']);
    end
    if confTestsVec(5)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachProjTestCase',...
            confName, crm, crmSys,...
            'marker',confName);
    end
    if confTestsVec(7)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachRefineTestCase',...
            ReachFactory(confName, crm, crmSys, false, false),...
            'marker',confName);
    end
	if confTestsVec(8)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachRegTestCase',...
            confName, crm, crmSys);
    end
end
suiteList{end + 1} = loader.load_tests_from_test_case(...
    'elltool.reach.test.mlunit.ContinuousReachFirstTestCase',...
    'demo3firstTest', crm, crmSys);
suiteList{end + 1} = loader.load_tests_from_test_case(...
    'elltool.reach.test.mlunit.ReachPlotTestCase',...
     ReachFactory('demo3firstTest', crm, crmSys, false, false));
%
suiteList{end + 1} = loader.load_tests_from_test_case(...
    'elltool.reach.test.mlunit.MPTIntegrationTestCase');
%
testLists = cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite = mlunitext.test_suite(horzcat(testLists{:}));
%
resList{1} = runner.run(suite);
testCaseNameStr = 'elltool.reach.test.mlunit.ContinuousReachProjAdvTestCase';
resList{2} = elltool.reach.test.run_reach_proj_adv_tests(testCaseNameStr);
results = [resList{:}];
%
end