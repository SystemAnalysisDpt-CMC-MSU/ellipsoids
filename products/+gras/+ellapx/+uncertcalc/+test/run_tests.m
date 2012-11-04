function results=run_tests(varargin)
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'gras.ellapx.uncertcalc.test.mlunit.SuiteBasic');
%
crm=gras.ellapx.uncertcalc.test.conf.ConfRepoMgr();
confNameList=crm.deployConfTemplate('*');
crmSys=gras.ellapx.uncertcalc.test.conf.sysdef.ConfRepoMgr();
crmSys.deployConfTemplate('*');
nConfs=length(confNameList);
suiteList=cell(1,nConfs);
for iConf=nConfs:-1:1
    confName=confNameList{iConf};
    suiteList{iConf}=loader.load_tests_from_test_case(...
        'gras.ellapx.uncertcalc.test.mlunit.SuiteRegression',{confName},...
        crm,crmSys,'marker',confName);
end
suiteList=[suiteList,{suite}];
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
%
resList{1}=runner.run(suite);
resList{2}=gras.ellapx.uncertcalc.conf.sysdef.test.run_tests();
resList{3}=gras.ellapx.uncertcalc.test.run_support_function_tests();
%
results=[resList{:}];