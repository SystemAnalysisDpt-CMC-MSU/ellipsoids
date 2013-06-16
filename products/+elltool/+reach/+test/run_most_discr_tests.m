function results = run_most_discr_tests(confNameRegExp,...
    testCaseRegExp,testNameRegExp,markerRegExp)
import elltool.reach.ReachFactory;
import elltool.logging.Log4jConfigurator;
DISP_VERT_SEP_STR='--------------------------';
%
logger=Log4jConfigurator.getLogger();
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm = gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys = gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
confCMat = {
    'discrFirstTest',  [1 0 1 1 0];
    'discrSecondTest',  [1 1 1 0 0];
    'demo3fourthTest', [0 0 0 0 1];
    };
%
if nargin>0
    isSpecVec=isMatch(confCMat(:,1),confNameRegExp);
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
            'elltool.reach.test.mlunit.DiscreteReachTestCase', ...
            ReachFactory(confName, crm, crmSys, false, false, true), ...
            'marker', [confName,'_IsBackFalseIsEvolveFalse']);
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.DiscreteReachTestCase', ...
            ReachFactory(confName, crm, crmSys, true, false, true), ...
            'marker', [confName,'_IsBackTrueIsEvolveFalse']);
    end
    if confTestsVec(2)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase', ...
            ReachFactory(confName, crm, crmSys, false, false, true), ...
            'marker', [confName,'_IsBackFalseIsEvolveFalse']);
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase', ...
            ReachFactory(confName, crm, crmSys, true, false, true), ...
            'marker', [confName,'_IsBackTrueIsEvolveFalse']);
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase', ...
            ReachFactory(confName, crm, crmSys, false, true, true), ...
            'marker', [confName,'_IsBackFalseIsEvolveTrue']);
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase', ...
            ReachFactory(confName, crm, crmSys, true, true, true), ...
            'marker', [confName,'_IsBackTrueIsEvolveTrue']);
    end
    if confTestsVec(3)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.DiscreteReachProjTestCase', ...
            confName, crm, crmSys, 'marker', confName);
    end
    if confTestsVec(4)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachRefineTestCase',...
            ReachFactory(confName, crm, crmSys, false, false),...
            'marker',confName);
    end
    if confTestsVec(5)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.DiscreteReachRegTestCase',...
            confName, crm, crmSys);
    end
end
suiteList{end + 1} = loader.load_tests_from_test_case(...
    'elltool.reach.test.mlunit.DiscreteReachFirstTestCase',...
    crm, crmSys);
%
testLists = cellfun(@(x)x.tests,suiteList,'UniformOutput',false);




testList=horzcat(testLists{:});
%
isTestCaseMatchVec=isMatchTest(@class,testList,testCaseRegExp);
isTestNameMatchVec=isMatchTest(@(x)x.name,testList,testNameRegExp);
isMarkerMatchVec=isMatchTest(@(x)x.marker,testList,markerRegExp);
isMatchVec=isTestCaseMatchVec&isTestNameMatchVec&isMarkerMatchVec;
%
testList=testList(isMatchVec);
testNameList=cellfun(@(x)x.str(),testList,'UniformOutput',false);
testNameStr=modgen.string.catwithsep(testNameList,sprintf('/n'));
logMsg=sprintf('\n Number of found tests %d\n%s\n%s\n%s',numel(testList),...
    DISP_VERT_SEP_STR,testNameStr,DISP_VERT_SEP_STR);
logger.info(logMsg);
%
suite = mlunitext.test_suite(testList);
%
results = runner.run(suite);
end
function isPosVec=isMatchTest(fGetProp,testList,regExpStr)
isPosVec=isMatch(cellfun(fGetProp,testList,'UniformOutput',false),...
    regExpStr);
end
function isPosVec=isMatch(tagList,regExpStr)
isPosVec=~cellfun(@isempty,regexp(tagList,regExpStr,'emptymatch'));
end
