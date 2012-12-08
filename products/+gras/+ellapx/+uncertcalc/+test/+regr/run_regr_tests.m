function results=run_regr_tests(confNameList)
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
if ischar(confNameList)
    confNameList={confNameList};
end
%
if nargin==0
    confNameList=crm.deployConfTemplate('*');
end
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
crmSys.deployConfTemplate('*');
nConfs=length(confNameList);
suiteList=cell(1,nConfs);
for iConf=nConfs:-1:1
    confName=confNameList{iConf};
    suiteList{iConf}=loader.load_tests_from_test_case(...
        'gras.ellapx.uncertcalc.test.regr.mlunit.SuiteRegression',{confName},...
        crm,crmSys,'marker',confName);
end
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
%
results=runner.run(suite);
