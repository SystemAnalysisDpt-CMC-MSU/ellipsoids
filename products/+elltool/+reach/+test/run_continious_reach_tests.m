function results = run_continious_reach_tests()
%
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
confNameList = {'demo3firstTest', 'demo3secondTest',...
   'demo3thirdTest', 'demo3fourthTest'};
% confNameList = {'demo3secondTest',...
%    'demo3thirdTest', 'demo3fourthTest'};
confNameList = {'demo3firstTest'};
%
nConfs=length(confNameList);
suiteList=cell(1,nConfs);
for iConf=nConfs:-1:1
    suiteList{iConf}=loader.load_tests_from_test_case(...
        'elltool.reach.test.mlunit.ContiniousReachTestCase',...
        confNameList{iConf},crm,crmSys);
end
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
results=runner.run(suite);
end