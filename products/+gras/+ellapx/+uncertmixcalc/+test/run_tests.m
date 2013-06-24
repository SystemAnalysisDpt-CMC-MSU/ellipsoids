function results=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm=gras.ellapx.uncertmixcalc.test.conf.ConfRepoMgr();
confNameList=crm.deployConfTemplate('*');
confNameList=setdiff(confNameList,{'default'});
crmSys=gras.ellapx.uncertmixcalc.test.conf.sysdef.ConfRepoMgr();
crmSys.deployConfTemplate('*');
nConfs=length(confNameList);
%
suiteList=cell(1,nConfs);
for iConf=1:nConfs
    confName = confNameList{iConf};
    %
    if ~isempty(strfind(confName, 'springs_'))
        suiteList{iConf}=loader.load_tests_from_test_case(...
            'gras.ellapx.uncertmixcalc.test.mlunit.SuiteMixTubeFort',...
            crm,crmSys,confName,'marker',confName);
    else
        suiteList{iConf}=loader.load_tests_from_test_case(...
            'gras.ellapx.uncertmixcalc.test.mlunit.SuiteBasic',...
            crm,crmSys,confName);
    end
end
%
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
%
resList{1}=runner.run(suite);
%
results=[resList{:}];