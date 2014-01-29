function results=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm=gras.ellapx.uncertcalc.test.comp.conf.ConfRepoMgr();
confNameList=crm.deployConfTemplate('*');
crmSys=gras.ellapx.uncertcalc.test.comp.conf.sysdef.ConfRepoMgr();
crmSys.deployConfTemplate('*');
nConfs=length(confNameList);
PAIR_CONF_NAME_SUFFIX='_pair';
%
suiteList={};
for iConf=nConfs:-1:1
    confName = confNameList{iConf};
    if isempty(strfind(confName,PAIR_CONF_NAME_SUFFIX));
        % if system is not lti, find corresponding lti system
        confNameLti = strcat(confName,PAIR_CONF_NAME_SUFFIX);
        % add lti and not-lti pair test
        suiteList{end+1}=loader.load_tests_from_test_case(...
            'gras.ellapx.uncertcalc.test.comp.mlunit.SuiteCompare',...
            {confName,confNameLti},crm,crmSys,'marker',confName);
    else
        % if system is lti, skip
        continue;
    end
end
%
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
%
resList{1}=runner.run(suite);
%
results=[resList{:}];