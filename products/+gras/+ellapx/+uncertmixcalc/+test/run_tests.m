function results=run_tests(varargin)
% Examples:
%
%   gras.ellapx.uncertmixcalc.test.run_tests({'testA0UInterval','uosc8'},'nParallelProcesses',12)
%   gras.ellapx.uncertmixcalc.test.run_tests('nParallelProcesses',12,'filter',{'testA0UInterval','.*','.*'})
%   gras.ellapx.uncertmixcalc.test.run_tests('nParallelProcesses',12,'filter',{'testA0UInterval','gras.ellapx.uncertcalc.test.regr.mlunit.SuiteRegression','testRegression'})
%   gras.ellapx.uncertmixcalc.test.run_tests('nParallelProcesses',12,'filter',{'testA0UInterval','.*','testRegression'})
%
%
% $Authors: Peter Gagarinov <pgagarinov@gmail.com>
% $Date: 23-Feb-2016 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012-2016$
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
[restArgList,~,filterProp]=modgen.common.parseparext(varargin,...
    {'filter';{}});
%
crm=gras.ellapx.uncertmixcalc.test.conf.ConfRepoMgr();
crmSys=gras.ellapx.uncertmixcalc.test.conf.sysdef.ConfRepoMgr();
%
[reg,suitePropList]=modgen.common.parseparams(restArgList);
if ~isempty(reg)
    confNameList=reg{1};
    if ischar(confNameList)
        confNameList={confNameList};
    end
else
    confNameList=crm.deployConfTemplate('*');
    confNameList=setdiff(confNameList,{'default'});
end
%
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
suite=mlunitext.test_suite(horzcat(testLists{:}),suitePropList{:});
suite=suite.getCopyFiltered(filterProp{:});
%
resList{1}=runner.run(suite);
%
results=[resList{:}];