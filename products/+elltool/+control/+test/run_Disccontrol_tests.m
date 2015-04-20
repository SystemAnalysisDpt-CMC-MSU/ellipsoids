function results = run_Disccontrol_tests(varargin)
import elltool.reach.ReachFactory;
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
confCMat = {
    'ellDemo3test',[1 1],[1 1];
    'discrFirstTest',[1 1],[1 1];
    'discrSecondTest',[1 1],[1 1];
    };
nConfs = size(confCMat, 1);
suiteList = {};
outPointVecList=[];
% 
for iConf = 1:nConfs
    confName = confCMat{iConf, 1};
    confTestsVec = confCMat{iConf, 2};
    inPointVecList  = confCMat{iConf, 3};
    if confTestsVec(1)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.control.test.mlunit.ReachDiscTC',...
            ReachFactory(confName, crm, crmSys, true, false,true),...
            inPointVecList , outPointVecList,...
            'marker',[confName,'_IsBackTrueIsEvolveFalse']);
    end 
    if confTestsVec(2)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.control.test.mlunit.ReachDiscTC',...
            ReachFactory(confName, crm, crmSys, true, true,true),...
            inPointVecList , outPointVecList,...
            'marker',[confName,'_IsBackTrueIsEvolveTrue']);
    end 

end
suiteList{end + 1} = loader.load_tests_from_test_case(...
    'elltool.reach.test.mlunit.MPTIntegrationTestCase');
testLists = cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
testList=horzcat(testLists{:});
suite = mlunitext.test_suite(testList);
suite=suite.getCopyFiltered(varargin{:});
results = runner.run(suite);

