function results=run_regr_tests(varargin)
% Examples:
%
%   gras.ellapx.uncertcalc.test.regr.run_regr_tests({'testA0UInterval','uosc8'},'reCache',true,'nParallelProcesses',12)
%   gras.ellapx.uncertcalc.test.regr.run_regr_tests('reCache',true,'nParallelProcesses',12,'filter',{'testA0UInterval','.*','.*'})
%   gras.ellapx.uncertcalc.test.regr.run_regr_tests('reCache',true,'nParallelProcesses',12,'filter',{'testA0UInterval','gras.ellapx.uncertcalc.test.regr.mlunit.SuiteRegression','testRegression'})
%   gras.ellapx.uncertcalc.test.regr.run_regr_tests('reCache',true,'nParallelProcesses',12,'filter',{'testA0UInterval','.*','testRegression'})
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
%
[restArgList,~,prop]=modgen.common.parseparext(varargin,...
    {'reCache';false;'islogical(x)'},[],'propRetMode','list');
%
[restArgList,~,filterProp]=modgen.common.parseparext(restArgList,...
    {'filter';{}});
%
[reg,suitePropList]=modgen.common.parseparams(restArgList);
%
if ~isempty(reg)
    confNameList=reg{1};
    if ischar(confNameList)
        confNameList={confNameList};
    end
else
    confNameList=crm.deployConfTemplate('*');
end
%
NOT_TO_TEST_CONF_NAME_LIST = {'discrSecondTest',...
    'check','checkTime','testA0Cunitball'};
isNotToTestVec=ismember(confNameList,NOT_TO_TEST_CONF_NAME_LIST);
confNameList=confNameList(~isNotToTestVec);
%
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
crmSys.deployConfTemplate('*');
nConfs=length(confNameList);
suiteList=cell(1,nConfs);
for iConf=nConfs:-1:1
    confName=confNameList{iConf};
    suiteList{iConf}=loader.load_tests_from_test_case(...
        'gras.ellapx.uncertcalc.test.regr.mlunit.SuiteRegression',...
        {confName},crm,crmSys,prop{:},'marker',confName);
end
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}),suitePropList{:});
suite=suite.getCopyFiltered(filterProp{:});
%
results=runner.run(suite);